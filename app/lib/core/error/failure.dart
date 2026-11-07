/// Typed failures. Add cases here; never throw raw exceptions across layers.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No connection']);
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.code});
  final String? code;
}

final class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
