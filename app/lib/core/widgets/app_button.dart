import 'package:flutter/material.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/theme/theme.dart';

/// Primary pill button: scales on press, morphs into a loading circle,
/// and ignores taps while loading (double tap = one request).
class AppButton extends StatefulWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  void _setPressed(bool value) {
    if (_isEnabled && value != _isPressed) setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: _isEnabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _isPressed ? AppMotionValues.pressedScale : 1,
          duration: context.motion(AppDurations.fast),
          child: LayoutBuilder(builder: _body),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, BoxConstraints constraints) {
    final colors = context.colors;
    final color = widget.onPressed == null
        ? colors.primary.withValues(alpha: AppOpacity.disabled)
        : colors.primary;
    return Center(
      child: AnimatedContainer(
        duration: context.motion(AppDurations.medium),
        curve: AppCurves.standard,
        height: AppSizes.buttonHeight,
        width: widget.isLoading ? AppSizes.buttonHeight : constraints.maxWidth,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: context.motion(AppDurations.fast),
          child: widget.isLoading ? _spinner(colors) : _label(context),
        ),
      ),
    );
  }

  Widget _spinner(ColorScheme colors) => SizedBox.square(
    key: const ValueKey('loading'),
    dimension: AppSizes.iconM,
    child: CircularProgressIndicator(
      strokeWidth: AppSizes.spinnerStroke,
      color: colors.onPrimary,
    ),
  );

  Widget _label(BuildContext context) => Text(
    widget.label.toUpperCase(),
    key: const ValueKey('label'),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: context.text.labelLarge?.copyWith(color: context.colors.onPrimary),
  );
}
