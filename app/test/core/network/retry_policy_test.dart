import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/network/network_constants.dart';
import 'package:jdonut/core/network/retry_policy.dart';

DioException _error({
  String method = 'GET',
  DioExceptionType type = DioExceptionType.connectionError,
  int? status,
}) {
  final options = RequestOptions(method: method);
  return DioException(
    requestOptions: options,
    type: type,
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
