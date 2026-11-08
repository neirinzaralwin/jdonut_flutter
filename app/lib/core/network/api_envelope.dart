import 'package:jdonut/core/error/failure.dart';
import 'package:jdonut/core/error/result.dart';

/// Unwraps the server's `{data, error, meta}` envelope.
/// A non-null `error`, a missing `data`, or a shape that [parse] rejects all
/// become a typed [Failure] — malformed data never reaches the cache.
Result<T> parseEnvelope<T>(Object? body, T Function(Object data) parse) {
  if (body is! Map<String, dynamic>) {
    return const Err(ServerFailure('Response is not an envelope'));
  }
  if (body['error'] case {
    'code': final String code,
    'message': final String message,
  }) {
    return Err(ServerFailure(message, code: code));
  }
  final data = body['data'];
  if (data == null) return const Err(ServerFailure('Envelope has no data'));
  try {
    return Ok(parse(data as Object));
  } on FormatException catch (error) {
    return Err(ServerFailure('Malformed data: ${error.message}'));
  }
}
