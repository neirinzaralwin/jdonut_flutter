import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/rolling_number.dart';

/// − quantity + pill. The number rolls in the direction of the change.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    super.key,
  });

  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  static const double _border = 4;
  static const double _numberWidth = 48;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.s2),
    decoration: BoxDecoration(
      color: context.colors.outlineVariant,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      border: Border.all(color: context.colors.surface, width: _border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundButton(
          icon: Icons.remove_rounded,
          label: context.l10n.quantityDecrease,
          onTap: onDecrease,
        ),
        SizedBox(
          width: _numberWidth,
          child: Center(
            child: RollingNumber(
              value: quantity,
              format: (value) => '$value',
              style: AppTypography.numeric.copyWith(
                fontSize: context.text.headlineMedium?.fontSize,
              ),
            ),
          ),
        ),
        _RoundButton(
          icon: Icons.add_rounded,
          label: context.l10n.quantityIncrease,
          onTap: onIncrease,
        ),
      ],
    ),
  );
}

class _RoundButton extends StatefulWidget {
  const _RoundButton({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  State<_RoundButton> createState() => _RoundButtonState();
}

class _RoundButtonState extends State<_RoundButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (widget.onTap != null) setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final colors = context.colors;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? AppMotionValues.pressedScale : 1,
          duration: context.motion(AppDurations.fast),
          child: AnimatedContainer(
            duration: context.motion(AppDurations.fast),
            width: AppSizes.iconButton,
            height: AppSizes.iconButton,
            decoration: BoxDecoration(
              color: enabled
                  ? colors.primary
                  : colors.primary.withValues(alpha: AppOpacity.disabled),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, color: colors.onPrimary),
          ),
        ),
      ),
    );
  }
}
