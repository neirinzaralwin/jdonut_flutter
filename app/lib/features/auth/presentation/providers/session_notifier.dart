import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/features/auth/domain/entities/session_state.dart';
import 'package:jdonut/features/auth/domain/entities/user.dart';
import 'package:jdonut/features/auth/presentation/providers/auth_dependencies.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_notifier.g.dart';

/// App-wide session; the router guard listens to it.
@Riverpod(keepAlive: true)
class Session extends _$Session {
  @override
  SessionState build() => const SessionUnknown();

  /// Called once at startup, before the first frame.
  Future<void> restore() async {
    final result = await ref.read(authRepositoryProvider).currentUser();
    state = switch (result) {
      Ok(value: final User user) => Authenticated(user),
      Ok() || Err() => const Unauthenticated(),
    };
  }

  void signedIn(User user, {bool isNewUser = false}) =>
      state = Authenticated(user, isNewUser: isNewUser);

  /// After Welcome, a new user is treated like any returning user.
  void welcomeSeen() {
    if (state case Authenticated(:final user)) state = Authenticated(user);
  }

  Future<void> logOut() async {
    await ref.read(authRepositoryProvider).logOut();
    state = const Unauthenticated();
  }
}
