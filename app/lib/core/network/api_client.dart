import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:jdonut/core/config/env.dart';
import 'package:jdonut/core/error/failure.dart';
import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/core/network/api_envelope.dart';
import 'package:jdonut/core/network/network_constants.dart';
import 'package:jdonut/core/network/retry_policy.dart';

/// The only place that talks HTTP. Returns typed results, never throws.
class ApiClient {
  ApiClient(this._dio, {void Function(bool reachable)? onBackendReachability})
    : _onBackendReachability = onBackendReachability;

  final void Function(bool reachable)? _onBackendReachability;

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
        logPrint: kDebugMode ? debugPrint : null,
      ),
    );
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor());
    }
    return ApiClient(dio, onBackendReachability: onBackendReachability);
  }

  final Dio _dio;

  Future<Result<T>> get<T>(
    String path,
    T Function(Object data) parse, {
    Duration? timeout,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        path,
        options: Options(receiveTimeout: timeout, sendTimeout: timeout),
      );
      _onBackendReachability?.call(true);
      return parseEnvelope(response.data, parse);
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        _onBackendReachability?.call(false);
      } else if (error.response != null) {
        _onBackendReachability?.call(true);
      }
      return Err(_toFailure(error));
    }
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
