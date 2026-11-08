import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:jdonut/core/network/network_constants.dart';

/// Our retry rules, plugged into `dio_smart_retry`'s RetryInterceptor:
/// safe requests only (GET), never on 4xx, at most
/// [NetworkConstants.maxRetries] times, growing delays with jitter.
///
/// Not retried: requests marked with [noRetryKey] (the server health probe
/// answers "is it up?" — one try is the answer), and "connection refused"
/// (the server is plainly down; retrying only delays the offline state).
abstract final class RetryPolicy {
  /// Set `extra[noRetryKey] = true` on a request to send it once.
  static const String noRetryKey = 'no_retry';

  /// `attempt` is 1-based (dio_smart_retry's convention).
  static bool shouldRetry(DioException error, int attempt) {
    if (attempt > NetworkConstants.maxRetries) return false;
    if (error.requestOptions.extra[noRetryKey] == true) return false;
    if (isConnectionRefused(error)) return false;
    if (error.requestOptions.method.toUpperCase() != 'GET') return false;
    final status = error.response?.statusCode;
    if (status != null && status >= 400 && status < 500) return false;
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.connectionError => true,
      DioExceptionType.badResponse => status != null && status >= 500,
      _ => false,
    };
  }

  /// Nothing is listening on that host and port (e.g. the mock server isn't
  /// running). Different from a timeout, which a retry can fix.
  static bool isConnectionRefused(DioException error) => switch (error.error) {
    SocketException(:final osError?) => _refusedCodes.contains(
      osError.errorCode,
    ),
    _ => false,
  };

  /// ECONNREFUSED: 61 on iOS/macOS, 111 on Android/Linux, 10061 on Windows.
  static const Set<int> _refusedCodes = {61, 111, 10061};

  /// 400 ms, 800 ms, 1.6 s — each plus up to 50% jitter, picked once per
  /// app run so many devices don't retry in lockstep.
  static List<Duration> delays([math.Random? random]) {
    final rng = random ?? math.Random();
    return [
      for (var attempt = 0; attempt < NetworkConstants.maxRetries; attempt++)
        _withJitter(
          NetworkConstants.retryBaseDelay * math.pow(2, attempt),
          rng,
        ),
    ];
  }

  static Duration _withJitter(Duration base, math.Random random) =>
      base + base * (random.nextDouble() / 2);
}
