import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/network/network_constants.dart';
import 'package:jdonut/core/network/retry_policy.dart';

DioException _error({
  String method = 'GET',
  DioExceptionType type = DioExceptionType.connectionError,
  int? status,
  Object? cause,
  Map<String, dynamic>? extra,
}) {
  final options = RequestOptions(method: method, extra: extra);
  return DioException(
    requestOptions: options,
    type: type,
    error: cause,
    response: status == null
        ? null
        : Response<Object?>(requestOptions: options, statusCode: status),
  );
}

void main() {
  group('shouldRetry', () {
    test('retries a GET that lost the connection or timed out', () {
      expect(RetryPolicy.shouldRetry(_error(), 1), isTrue);
      expect(
        RetryPolicy.shouldRetry(
          _error(type: DioExceptionType.receiveTimeout),
          1,
        ),
        isTrue,
      );
    });

    test('retries a GET that got a 5xx', () {
      expect(
        RetryPolicy.shouldRetry(
          _error(type: DioExceptionType.badResponse, status: 503),
          1,
        ),
        isTrue,
      );
    });

    test('never retries 4xx', () {
      expect(
        RetryPolicy.shouldRetry(
          _error(type: DioExceptionType.badResponse, status: 404),
          1,
        ),
        isFalse,
      );
    });

    test('never retries non-GET requests', () {
      expect(RetryPolicy.shouldRetry(_error(method: 'POST'), 1), isFalse);
    });

    test('never retries a refused connection (server is down)', () {
      for (final code in [61, 111]) {
        final refused = _error(
          cause: SocketException(
            'Connection refused',
            osError: OSError('Connection refused', code),
          ),
        );
        expect(RetryPolicy.isConnectionRefused(refused), isTrue);
        expect(RetryPolicy.shouldRetry(refused, 1), isFalse);
      }
      // Other socket errors (e.g. DNS, network down) still retry.
      final lookup = _error(
        cause: const SocketException(
          'Failed host lookup',
          osError: OSError('nodename nor servname provided', 8),
        ),
      );
      expect(RetryPolicy.shouldRetry(lookup, 1), isTrue);
    });

    test('never retries a request marked no-retry (health probe)', () {
      final probe = _error(
        type: DioExceptionType.receiveTimeout,
        extra: {RetryPolicy.noRetryKey: true},
      );
      expect(RetryPolicy.shouldRetry(probe, 1), isFalse);
    });

    test('stops after the maximum number of attempts', () {
      expect(
        RetryPolicy.shouldRetry(_error(), NetworkConstants.maxRetries + 1),
        isFalse,
      );
    });
  });

  test('delays grow each attempt and add at most 50% jitter', () {
    final delays = RetryPolicy.delays(Random(1));
    expect(delays, hasLength(NetworkConstants.maxRetries));
    for (final (attempt, delay) in delays.indexed) {
      final floor = NetworkConstants.retryBaseDelay * pow(2, attempt);
      expect(delay, greaterThanOrEqualTo(floor));
      expect(delay, lessThanOrEqualTo(floor * 1.5));
    }
  });
}
