import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/features/auth/domain/entities/auth_mode.dart';
import 'package:jdonut/features/auth/domain/entities/otp_outcome.dart';
import 'package:jdonut/features/auth/domain/repositories/auth_repository.dart';

/// Verifies the code, then signs in a returning user or lets a new user
/// continue registration.
class VerifyOtp {
  const VerifyOtp(this._repository);

  final AuthRepository _repository;

  Future<Result<OtpOutcome>> call({
    required String phone,
    required String code,
    required AuthMode mode,
  }) async {
    final verification = await _repository.verifyOtp(phone: phone, code: code);
    if (verification case Err(:final failure)) return Err(failure);
    if (mode == AuthMode.register) return const Ok(ContinueRegistration());

    return switch (await _repository.logIn(phone)) {
      Ok(:final value) => Ok(SignedIn(value)),
      Err(:final failure) => Err(failure),
    };
  }
}
