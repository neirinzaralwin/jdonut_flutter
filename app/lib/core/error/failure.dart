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

enum AuthFailureKind {
  notRegistered,
  alreadyRegistered,
  invalidOtp,
  sessionUnavailable,
}

final class AuthFailure extends Failure {
  const AuthFailure(this.kind, [super.message = 'Authentication failed']);
  final AuthFailureKind kind;
}

/// Wraps an unexpected exception so it is surfaced, never swallowed.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, [this.cause]);
  final Object? cause;
}
