import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/features/auth/domain/validators/phone_validator.dart';
import 'package:jdonut/features/auth/presentation/providers/auth_dependencies.dart';
import 'package:jdonut/features/auth/presentation/providers/registration_draft.dart';
import 'package:jdonut/features/auth/presentation/providers/submit_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'phone_submit_notifier.g.dart';

@riverpod
class PhoneSubmit extends _$PhoneSubmit {
  @override
  SubmitState build() => const SubmitState();

  /// Requests an OTP. Returns true when the user can move to the OTP step.
  /// Ignores taps while a request is running (double tap = one request).
  Future<bool> submit() async {
    if (state.isSubmitting) return false;
    final draft = ref.read(registrationDraftProvider);
    if (validatePhone(draft.phoneInput) != null) return false;

    state = const SubmitState(isSubmitting: true);
    final phone = normalizePhone(draft.phoneInput);
    final result = await ref
        .read(authRepositoryProvider)
        .requestOtp(phone: phone, mode: draft.mode);
    if (!ref.mounted) return false;

    switch (result) {
      case Ok(:final value):
        ref
            .read(registrationDraftProvider.notifier)
            .otpSent(phone: phone, expiresAt: value);
        // Stay "submitting" until the user comes back to this step, so a
        // tap during the page transition can't send a second request.
        return true;
      case Err(:final failure):
        state = SubmitState(failure: failure);
        return false;
    }
  }

  /// Called when the user returns to this step (Back from OTP).
  void reset() => state = const SubmitState();

  /// Hides the inline message once the user edits the number or switches mode.
  void clearFailure() {
    if (state.failure != null) state = const SubmitState();
  }
}
