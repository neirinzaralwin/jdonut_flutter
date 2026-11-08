import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:jdonut/core/config/env.dart';
import 'package:jdonut/core/error/failure.dart';
import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/core/network/api_envelope.dart';
import 'package:jdonut/core/network/api_log_interceptor.dart';
import 'package:jdonut/core/network/network_constants.dart';
import 'package:jdonut/core/network/retry_policy.dart';

/// The only place that talks HTTP. Returns typed results, never throws.
class ApiClient {
  ApiClient(this._dio, {void Function(bool reachable)? onBackendReachability})
    : _onBackendReachability = onBackendReachability;

  factory ApiClient.create({
    void Function(bool reachable)? onBackendReachability,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: '${Env.apiBaseUrl}${Env.apiVersionPath}',
        connectTimeout: NetworkConstants.connectTimeout,
        receiveTimeout: NetworkConstants.receiveTimeout,
        sendTimeout: NetworkConstants.sendTimeout,
      ),
    );
    // Log first: retries re-enter the chain, so each attempt gets one line.
    if (kDebugMode) dio.interceptors.add(ApiLogInterceptor());
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        // retries defaults to 3 = NetworkConstants.maxRetries; the
        // evaluator enforces our limit either way.
        retryDelays: RetryPolicy.delays(),
        retryEvaluator: (error, attempt) {
          if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout) {
            onBackendReachability?.call(false);
          }
          return RetryPolicy.shouldRetry(error, attempt);
        },
      ),
    );
    return ApiClient(dio, onBackendReachability: onBackendReachability);
  }

  final void Function(bool reachable)? _onBackendReachability;

  final Dio _dio;

  /// [retry] false sends the request once (see [RetryPolicy.noRetryKey]).
  Future<Result<T>> get<T>(
    String path,
    T Function(Object data) parse, {
    Duration? timeout,
    bool retry = true,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        path,
        options: Options(
          receiveTimeout: timeout,
          sendTimeout: timeout,
          extra: {if (!retry) RetryPolicy.noRetryKey: true},
        ),
      );
      _onBackendReachability?.call(true);
      return parseEnvelope(response.data, parse);
    } on DioException catch (error) {
      _logFailure(error);
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        _onBackendReachability?.call(false);
      } else if (error.response != null) {
        _onBackendReachability?.call(true);
      }
      return Err(_toFailure(error));
    }
  }

  /// Once per request, after the last retry.
  void _logFailure(DioException error) {
    if (!kDebugMode) return;
    final options = error.requestOptions;
    final reason = RetryPolicy.isConnectionRefused(error)
        ? 'connection refused (server not running?)'
        : error.response?.statusCode?.toString() ?? error.type.name;
    debugPrint(
      '✗ ${options.method} ${options.path} · $reason · '
      '${ApiLogInterceptor.elapsedMs(options)} ms',
    );
  }

  Failure _toFailure(DioException error) {
    final body = error.response?.data;
    if (body is Map<String, dynamic>) {
      final envelope = parseEnvelope<Object>(body, (data) => data);
      if (envelope case Err(:final failure)) return failure;
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.connectionError => const NetworkFailure(),
      _ => ServerFailure(
        error.message ?? 'Request failed',
        code: '${error.response?.statusCode}',
      ),
    };
  }
}
