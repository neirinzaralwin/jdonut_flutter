import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jdonut/features/auth/domain/repositories/auth_repository.dart'
    show AuthRepository;

part 'new_user.freezed.dart';

/// Validated registration data handed to [AuthRepository.register].
@freezed
abstract class NewUser with _$NewUser {
  const factory NewUser({
    required String phone,
    required String firstName,
    required DateTime dateOfBirth,
    String? lastName,
  }) = _NewUser;
}
