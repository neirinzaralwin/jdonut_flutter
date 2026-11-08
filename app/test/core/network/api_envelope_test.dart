import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/error/failure.dart';
import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/core/network/api_envelope.dart';

void main() {
  String parseName(Object data) =>
      (data as Map<String, dynamic>)['name'] as String;

  test('returns data from a successful envelope', () {
    final result = parseEnvelope({
      'data': {'name': 'Coconut Donut'},
      'error': null,
      'meta': {'version': 1},
    }, parseName);

    expect((result as Ok<String>).value, 'Coconut Donut');
  });

  test('turns an error envelope into a ServerFailure with its code', () {
    final result = parseEnvelope({
      'data': null,
      'error': {'code': 'NOT_FOUND', 'message': 'missing'},
    }, parseName);

    final failure = (result as Err<String>).failure as ServerFailure;
    expect(failure.code, 'NOT_FOUND');
  });

  test('rejects a body that is not an envelope or has no data', () {
    expect(parseEnvelope('oops', parseName), isA<Err<String>>());
    expect(parseEnvelope({'error': null}, parseName), isA<Err<String>>());
  });

  test('maps a FormatException from the parser to a ServerFailure', () {
    final result = parseEnvelope<String>({
      'data': <Object>[],
    }, (_) => throw const FormatException('bad'));

    expect((result as Err<String>).failure, isA<ServerFailure>());
  });
}
