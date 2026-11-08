import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only, one line per request and response:
///
///     → GET /products
///     → GET /products (try 2)
///     ✓ 200 GET /products · 84 ms
///
/// Failures are logged once, by `ApiClient`, after the last retry — so a
/// retried request doesn't print its error once per attempt.
class ApiLogInterceptor extends Interceptor {
  static const String _startKey = 'log_start';

  /// Set by dio_smart_retry on retried requests (0 / missing = first try).
  static const String _attemptKey = 'ro_attempt';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now();
    final attempt = options.extra[_attemptKey];
    final retry = attempt is int && attempt > 0 ? ' (try ${attempt + 1})' : '';
    debugPrint('→ ${options.method} ${options.path}$retry');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final options = response.requestOptions;
    debugPrint(
      '✓ ${response.statusCode} ${options.method} ${options.path} · '
      '${elapsedMs(options)} ms',
    );
    handler.next(response);
  }

  /// Time since the (last) attempt was sent, for the failure line too.
  static int elapsedMs(RequestOptions options) =>
      switch (options.extra[_startKey]) {
        final DateTime start => DateTime.now().difference(start).inMilliseconds,
        _ => 0,
      };
}
