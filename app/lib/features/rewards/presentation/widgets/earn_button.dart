import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/pressable.dart';

/// "EARN": sky with a breathing glow when the challenge is complete (the
/// attention cue), grey otherwise. Once earned it turns into a quiet
/// "Earned ✓" and can't be tapped again.
class EarnButton extends StatefulWidget {
  const EarnButton({
    required this.isActive,
    this.isEarned = false,
    this.onEarn,
    super.key,
  });

  final bool isActive;
  final bool isEarned;

  /// Gets the button's box so the points can fly from it.
  final void Function(RenderBox from)? onEarn;

  @override
  State<EarnButton> createState() => _EarnButtonState();
}

class _EarnButtonState extends State<EarnButton>
    with SingleTickerProviderStateMixin {
  static const double _width = 88;
  static const double _height = 52;
  static const double _glowAlpha = 0.45;
  static const double _earnedTint = 0.15;

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppDurations.earnPulse,
  );

  bool get _canEarn => widget.isActive && !widget.isEarned;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPulse();
  }

  @override
  void didUpdateWidget(EarnButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    final shouldPulse = _canEarn && !context.reduceMotion;
    if (shouldPulse && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!shouldPulse) {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: _canEarn,
      label: widget.isEarned ? context.l10n.earned : context.l10n.earn,
      excludeSemantics: true,
      child: Pressable(
        onTap: _canEarn
            ? () =>
                  widget.onEarn?.call(context.findRenderObject()! as RenderBox)
            : null,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) =>
              _face(Curves.easeInOut.transform(_pulse.value), child),
          child: _EarnLabel(isEarned: widget.isEarned),
        ),
      ),
    );
  }

  /// The pill: breathes and glows with [wave] (0..1) while it can be earned.
  Widget _face(double wave, Widget? child) {
    final colors = context.colors;
    final fill = _canEarn
        ? colors.primary
        : widget.isEarned
        ? colors.primary.withValues(alpha: _earnedTint)
        : colors.outlineVariant;
    return Transform.scale(
      scale: 1 + (AppMotionValues.earnPulseScale - 1) * wave,
      child: Container(
        width: _width,
        height: _height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: _canEarn
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: _glowAlpha * wave),
                    blurRadius: AppSpacing.s4 * (1 + wave),
                    spreadRadius: AppSpacing.s1 * wave,
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}

/// "EARN" or "✓ Earned", swapped with a pop.
class _EarnLabel extends StatelessWidget {
  const _EarnLabel({required this.isEarned});

  final bool isEarned;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.text.labelLarge;
    return AnimatedSwitcher(
      duration: context.motion(AppDurations.medium),
      switchInCurve: AppCurves.emphasized,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: isEarned
          ? Row(
              key: const ValueKey('earned'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_rounded,
                  size: AppSpacing.s4,
                  color: colors.primary,
                ),
                const SizedBox(width: AppSpacing.s1),
                Text(
                  context.l10n.earned,
                  style: style?.copyWith(color: colors.primary),
                ),
              ],
            )
          : Text(
              key: const ValueKey('earn'),
              context.l10n.earn.toUpperCase(),
              style: style?.copyWith(color: colors.onPrimary),
            ),
    );
  }
}
