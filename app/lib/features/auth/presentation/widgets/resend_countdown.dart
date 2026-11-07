import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/utils/clock.dart';

/// "Didn't receive the code? Resend in 4:59 min". Remaining time is derived
/// from [expiresAt], so it stays correct after the app is backgrounded.
class ResendCountdown extends StatelessWidget {
  const ResendCountdown({
    required this.expiresAt,
    required this.clock,
    required this.onResend,
    this.isResending = false,
    super.key,
  });

  final DateTime expiresAt;
  final Clock clock;
  final VoidCallback onResend;
  final bool isResending;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      // One tick per second; the remaining time is recomputed from the clock.
      stream: Stream<void>.periodic(AppDurations.countdownTick),
      builder: (context, _) {
        final remaining = expiresAt.difference(clock());
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.otpDidntReceive, style: context.text.bodyMedium),
            if (remaining > Duration.zero)
              _countdown(context, remaining)
            else
              _resendButton(context),
          ],
        );
      },
    );
  }

  Widget _countdown(BuildContext context, Duration remaining) {
    final minutes = remaining.inMinutes;
    final seconds = (remaining.inSeconds % Duration.secondsPerMinute)
        .toString()
        .padLeft(2, '0');
    return Text(
      context.l10n.otpResendIn('$minutes:$seconds'),
      style: context.text.bodyMedium?.copyWith(
        color: context.appColors.textSecondary,
      ),
    );
  }

  Widget _resendButton(BuildContext context) => TextButton(
    onPressed: isResending ? null : onResend,
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
      alignment: Alignment.centerLeft,
    ),
    child: Text(
      context.l10n.otpResend,
      style: context.text.bodyMedium
          ?.withWeight(FontWeight.w700)
          .copyWith(color: context.appColors.link),
    ),
  );
}
