import 'package:jdonut/core/constants/app_constants.dart';
import 'package:jdonut/core/database/app_database.dart';
import 'package:jdonut/core/error/failure.dart';
import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/core/storage/session_store.dart';
import 'package:jdonut/core/utils/clock.dart';
import 'package:jdonut/features/auth/domain/entities/auth_mode.dart';
import 'package:jdonut/features/auth/domain/entities/new_user.dart';
import 'package:jdonut/features/auth/domain/entities/user.dart';
import 'package:jdonut/features/auth/domain/repositories/auth_repository.dart';

/// Fake auth (brief Task 1): waits ~1 s per call, stores users in Drift and
/// the session in secure storage. No network.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    required AppDatabase database,
    required SessionStore sessionStore,
    Clock clock = systemClock,
    Duration delay = AppConstants.fakeAuthDelay,
  }) : _database = database,
       _sessionStore = sessionStore,
       _clock = clock,
       _delay = delay;

  final AppDatabase _database;
  final SessionStore _sessionStore;
  final Clock _clock;
  final Duration _delay;

  @override
  Future<Result<DateTime>> requestOtp({
    required String phone,
    required AuthMode mode,
  }) => _guard(() async {
    final isRegistered = await _findByPhone(phone) != null;
    if (mode == AuthMode.logIn && !isRegistered) {
      return const Err(AuthFailure(AuthFailureKind.notRegistered));
    }
    if (mode == AuthMode.register && isRegistered) {
      return const Err(AuthFailure(AuthFailureKind.alreadyRegistered));
    }
    return Ok(_clock().add(AppConstants.otpResendCountdown));
  });

  @override
  Future<Result<void>> verifyOtp({
    required String phone,
    required String code,
  }) => _guard(
    () async => code == AppConstants.fakeOtpCode
        ? const Ok(null)
        : const Err(AuthFailure(AuthFailureKind.invalidOtp)),
  );

  @override
  Future<Result<User>> logIn(String phone) => _guard(() async {
    final row = await _findByPhone(phone);
    if (row == null) {
      return const Err(AuthFailure(AuthFailureKind.notRegistered));
    }
    await _sessionStore.writeUserId(row.id);
    return Ok(_toUser(row));
  });

  @override
  Future<Result<User>> register(NewUser newUser) => _guard(() async {
    if (await _findByPhone(newUser.phone) != null) {
      return const Err(AuthFailure(AuthFailureKind.alreadyRegistered));
    }
    final row = _toRow(newUser);
    // Insert + session in one transaction: if writing the session fails,
    // the insert rolls back and no half-registered user is left behind.
    await _database.transaction(() async {
      await _database.into(_database.users).insert(row);
      await _sessionStore.writeUserId(row.id);
    });
    return Ok(_toUser(row));
  });

  @override
  Future<Result<User?>> currentUser() async {
    try {
      final userId = await _sessionStore.readUserId();
      if (userId == null) return const Ok(null);
      final query = _database.select(_database.users)
        ..where((user) => user.id.equals(userId));
      final row = await query.getSingleOrNull();
      if (row == null) await _sessionStore.clear();
      return Ok(row == null ? null : _toUser(row));
    } on Exception catch (error) {
      // Unreadable secure storage (e.g. restored backup) → treat as logged out.
      await _clearSafely();
      return Err(UnexpectedFailure('Could not restore session', error));
    }
  }

  @override
  Future<Result<void>> logOut() async {
    try {
      await _sessionStore.clear();
      return const Ok(null);
    } on Exception catch (error) {
      return Err(UnexpectedFailure('Could not log out', error));
    }
  }

  /// Simulated latency + exception mapping for every fake "network" call.
  Future<Result<T>> _guard<T>(Future<Result<T>> Function() action) async {
    await Future<void>.delayed(_delay);
    try {
      return await action();
    } on Exception catch (error) {
      return Err(UnexpectedFailure('Auth request failed', error));
    }
  }

  Future<UserRow?> _findByPhone(String phone) {
    final query = _database.select(_database.users)
      ..where((user) => user.phone.equals(phone));
    return query.getSingleOrNull();
  }

  Future<void> _clearSafely() async {
    try {
      await _sessionStore.clear();
    } on Exception {
      // Nothing more to do: the session is already unusable.
    }
  }

  UserRow _toRow(NewUser newUser) {
    final now = _clock();
    return UserRow(
      id: 'u_${now.microsecondsSinceEpoch}',
      phone: newUser.phone,
      firstName: newUser.firstName,
      lastName: newUser.lastName,
      dateOfBirth: newUser.dateOfBirth,
      createdAt: now,
    );
  }

  User _toUser(UserRow row) => User(
    id: row.id,
    phone: row.phone,
    firstName: row.firstName,
    lastName: row.lastName,
    dateOfBirth: row.dateOfBirth,
  );
}
