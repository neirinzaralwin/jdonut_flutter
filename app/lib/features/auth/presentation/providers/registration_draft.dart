import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jdonut/features/auth/domain/entities/auth_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'registration_draft.freezed.dart';
part 'registration_draft.g.dart';

/// Everything typed during the auth flow, kept across steps so Back
/// returns to a filled form. Cleared when the flow starts again.
@freezed
abstract class RegistrationDraftState with _$RegistrationDraftState {
  const factory RegistrationDraftState({
    @Default(AuthMode.register) AuthMode mode,
    @Default('') String phoneInput,
    @Default('') String phone,
    DateTime? otpExpiresAt,
    @Default('') String firstName,
    @Default('') String lastName,
    int? birthMonth,
    @Default('') String birthDay,
    @Default('') String birthYear,
  }) = _RegistrationDraftState;
}

@Riverpod(keepAlive: true)
class RegistrationDraft extends _$RegistrationDraft {
  @override
  RegistrationDraftState build() => const RegistrationDraftState();

  void start(AuthMode mode) => state = RegistrationDraftState(mode: mode);

  void switchMode(AuthMode mode) => state = state.copyWith(mode: mode);

  void updatePhoneInput(String input) =>
      state = state.copyWith(phoneInput: input);

  void otpSent({required String phone, required DateTime expiresAt}) =>
      state = state.copyWith(phone: phone, otpExpiresAt: expiresAt);

  void updateName({required String firstName, required String lastName}) =>
      state = state.copyWith(firstName: firstName, lastName: lastName);

  void updateBirthDate({int? month, String? day, String? year}) =>
      state = state.copyWith(
        birthMonth: month ?? state.birthMonth,
        birthDay: day ?? state.birthDay,
        birthYear: year ?? state.birthYear,
      );

  void clear() => state = const RegistrationDraftState();
}
