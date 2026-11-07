import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jdonut/core/error/failure.dart';
import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/features/auth/domain/entities/otp_outcome.dart';
import 'package:jdonut/features/auth/domain/validators/otp_validator.dart';
import 'package:jdonut/features/auth/presentation/providers/auth_dependencies.dart';
import 'package:jdonut/features/auth/presentation/providers/registration_draft.dart';
import 'package:jdonut/features/auth/presentation/providers/session_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'otp_notifier.freezed.dart';
part 'otp_notifier.g.dart';

@freezed
abstract class OtpState with _$OtpState {
  const factory OtpState({
    @Default(0) int wrongAttempts,
    @Default(false) bool isVerifying,
    @Default(false) bool isResending,

    /// Increments on each wrong code; the boxes shake and clear.
    @Default(0) int rejectionCount,

    /// Increments after a successful resend (for a confirmation message).
    @Default(0) int resendCount,
    Failure? failure,
  }) = _OtpState;

  const OtpState._();

  bool get isLocked => isOtpLocked(wrongAttempts);
  int get attemptsLeft => otpAttemptsLeft(wrongAttempts);
  bool get isWrongCode => switch (failure) {
    AuthFailure(kind: AuthFailureKind.invalidOtp) => true,
    _ => false,
  };
}

@riverpod
class Otp extends _$Otp {
  @override
  OtpState build() => const OtpState();

  /// Verifies a complete code. Returns the outcome so the page can navigate
  /// (new users → Name); returning users are signed in here and the router
  /// guard moves them to Home.
  Future<OtpOutcome?> verify(String code) async {
    if (state.isVerifying || state.isLocked || !isCompleteOtp(code)) {
      return null;
    }
    state = state.copyWith(isVerifying: true, failure: null);

    final draft = ref.read(registrationDraftProvider);
    final result = await ref
        .read(verifyOtpProvider)
        .call(phone: draft.phone, code: code, mode: draft.mode);
    if (!ref.mounted) return null;

    switch (result) {
      case Ok(:final value):
        state = state.copyWith(isVerifying: false);
        if (value case SignedIn(:final user)) {
          ref.read(sessionProvider.notifier).signedIn(user);
        }
        return value;
      case Err(:final failure):
        _rejected(failure);
        return null;
    }
  }

  /// Sends a new code: restarts the countdown and unlocks entry.
  Future<void> resend() async {
    if (state.isResending || state.isVerifying) return;
    state = state.copyWith(isResending: true);
    final draft = ref.read(registrationDraftProvider);
    final result = await ref
        .read(authRepositoryProvider)
        .requestOtp(phone: draft.phone, mode: draft.mode);
    if (!ref.mounted) return;

    switch (result) {
      case Ok(:final value):
        ref
            .read(registrationDraftProvider.notifier)
            .otpSent(phone: draft.phone, expiresAt: value);
        state = OtpState(resendCount: state.resendCount + 1);
      case Err(:final failure):
        state = state.copyWith(isResending: false, failure: failure);
    }
  }

  void _rejected(Failure failure) {
    final rejected = state.copyWith(isVerifying: false, failure: failure);
    state = rejected.copyWith(
      wrongAttempts: state.wrongAttempts + (rejected.isWrongCode ? 1 : 0),
      rejectionCount: state.rejectionCount + 1,
    );
  }
}
