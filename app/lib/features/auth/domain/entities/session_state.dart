import 'package:jdonut/features/auth/domain/entities/user.dart';

/// Sealed: the router guard must handle every case, and only
/// [Authenticated] carries data.
sealed class SessionState {
  const SessionState();
}

/// Session not read from storage yet.
final class SessionUnknown extends SessionState {
  const SessionUnknown();
}

final class Unauthenticated extends SessionState {
  const Unauthenticated();
}

final class Authenticated extends SessionState {
  const Authenticated(this.user, {this.isNewUser = false});

  final User user;

  /// True right after registration, so the router shows Welcome before Home.
  final bool isNewUser;
}
