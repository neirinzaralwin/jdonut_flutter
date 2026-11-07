import 'package:jdonut/core/error/failure.dart';
import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/core/utils/clock.dart';
import 'package:jdonut/features/auth/domain/entities/new_user.dart';
import 'package:jdonut/features/auth/domain/entities/user.dart';
import 'package:jdonut/features/auth/domain/repositories/auth_repository.dart';
import 'package:jdonut/features/auth/domain/validators/date_of_birth_validator.dart';
import 'package:jdonut/features/auth/domain/validators/name_validator.dart';
import 'package:jdonut/features/auth/domain/validators/phone_validator.dart';

/// Re-checks every rule before storing — the UI is not the only caller
/// a real backend would trust.
class RegisterUser {
  const RegisterUser(this._repository, this._clock);

  final AuthRepository _repository;
  final Clock _clock;

  Future<Result<User>> call(NewUser newUser) async {
    if (!_isValid(newUser)) {
      return const Err(ValidationFailure('Registration data is invalid'));
    }
    return await _repository.register(
      newUser.copyWith(
        firstName: newUser.firstName.trim(),
        lastName: _blankToNull(newUser.lastName),
      ),
    );
  }

  bool _isValid(NewUser user) {
    final birth = user.dateOfBirth;
    return validatePhone(user.phone.replaceFirst(myanmarCountryCode, '0')) ==
            null &&
        validateFirstName(user.firstName) == null &&
        validateLastName(user.lastName ?? '') == null &&
        validateDateOfBirth(
              year: birth.year,
              month: birth.month,
              day: birth.day,
              today: _clock(),
            ) ==
            null;
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
