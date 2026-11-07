import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonut/core/constants/app_constants.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/router/app_routes.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/shake.dart';
import 'package:jdonut/features/auth/domain/entities/otp_outcome.dart';
import 'package:jdonut/features/auth/presentation/auth_progress.dart';
import 'package:jdonut/features/auth/presentation/providers/auth_dependencies.dart';
import 'package:jdonut/features/auth/presentation/providers/otp_notifier.dart';
import 'package:jdonut/features/auth/presentation/providers/registration_draft.dart';
import 'package:jdonut/features/auth/presentation/widgets/auth_step_scaffold.dart';
import 'package:jdonut/features/auth/presentation/widgets/otp_input.dart';
import 'package:jdonut/features/auth/presentation/widgets/resend_countdown.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({super.key});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verify(String code) async {
    final outcome = await ref.read(otpProvider.notifier).verify(code);
    // Returning users are signed in; the router guard moves them to Home.
    if (outcome is ContinueRegistration && mounted) {
      await context.push(AppRoutes.name);
    }
  }

  void _listenForEffects() {
    ref
      ..listen(otpProvider.select((state) => state.rejectionCount), (_, _) {
        _controller.clear();
        _focusNode.requestFocus();
      })
      ..listen(otpProvider.select((state) => state.resendCount), (_, _) {
        _controller.clear();
        _focusNode.requestFocus();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.otpCodeSent)));
      });
  }

  @override
  Widget build(BuildContext context) {
    _listenForEffects();
    final draft = ref.watch(registrationDraftProvider);
    final otp = ref.watch(otpProvider);
    return AuthStepScaffold(
      title: context.l10n.otpTitle,
      progress: AuthProgress.of(AuthProgress.otpStep, draft.mode),
      previousProgress: AuthProgress.before(AuthProgress.otpStep, draft.mode),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.otpSubtitle(draft.phone),
            style: context.text.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.s6),
          Shake(
            trigger: otp.rejectionCount,
            child: OtpInput(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !otp.isLocked && !otp.isVerifying,
              hasError: otp.failure != null,
              onCompleted: _verify,
            ),
          ),
          _OtpStatusLine(state: otp),
          const SizedBox(height: AppSpacing.s6),
          if (draft.otpExpiresAt != null)
            ResendCountdown(
              expiresAt: draft.otpExpiresAt!,
              clock: ref.watch(clockProvider),
              isResending: otp.isResending,
              onResend: ref.read(otpProvider.notifier).resend,
            ),
        ],
      ),
    );
  }
}

/// Message under the boxes: verifying spinner, wrong-code/locked error,
/// or the demo-code hint.
class _OtpStatusLine extends StatelessWidget {
  const _OtpStatusLine({required this.state});

  final OtpState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = state.isLocked
        ? l10n.otpLocked
        : (state.isWrongCode ? l10n.otpWrongCode(state.attemptsLeft) : null);
    final message = error ?? (state.failure != null ? l10n.errorGeneric : null);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s3),
      child: AnimatedSwitcher(
        duration: context.motion(AppDurations.fast),
        child: state.isVerifying
            ? const Align(
                alignment: Alignment.centerLeft,
                child: SizedBox.square(
                  dimension: AppSizes.spinnerSmall,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSizes.spinnerStroke,
                  ),
                ),
              )
            : Text(
                message ?? l10n.otpDemoHint(AppConstants.fakeOtpCode),
                key: ValueKey(message),
                style: context.text.bodySmall?.copyWith(
                  color: message != null
                      ? context.colors.error
                      : context.appColors.textSecondary,
                ),
              ),
      ),
    );
  }
}
