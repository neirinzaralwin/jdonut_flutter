import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/features/auth/domain/entities/auth_mode.dart';
import 'package:jdonut/features/auth/domain/entities/new_user.dart';
import 'package:jdonut/features/auth/domain/entities/user.dart';

/// Auth contract. The fake implementation can be swapped for a real API
/// in one provider without touching the UI.
abstract interface class AuthRepository {
  /// Sends an OTP to [phone] (E.164). Returns when the code expires.
  /// Fails with `notRegistered` (log in) or `alreadyRegistered` (register).
  Future<Result<DateTime>> requestOtp({
    required String phone,
    required AuthMode mode,
  });

  /// Fails with `invalidOtp` when [code] is wrong.
  Future<Result<void>> verifyOtp({required String phone, required String code});

  /// Starts a session for an existing user.
  Future<Result<User>> logIn(String phone);

  /// Stores the user and starts a session, atomically.
  Future<Result<User>> register(NewUser newUser);

  /// The signed-in user, or `null` when logged out.
  Future<Result<User?>> currentUser();

  Future<Result<void>> logOut();
}
