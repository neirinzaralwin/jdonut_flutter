import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/utils/formatters.dart';
import 'package:jdonut/core/widgets/rolling_number.dart';

/// "ADD TO CART | 3,200 MMK". Springs up from the bottom when [visible]
/// turns true, the total rolls on every change, and a tap briefly morphs
/// the label into "✓ Added" (visual feedback only — brief Task 2).
class AddToCartBar extends StatefulWidget {
  const AddToCartBar({
    required this.visible,
    required this.totalMmk,
    this.onAdd,
    super.key,
  });

  final bool visible;
  final int totalMmk;

  /// Real cart hook later; today the bar only gives feedback.
  final VoidCallback? onAdd;

  @override
  State<AddToCartBar> createState() => _AddToCartBarState();
}

class _AddToCartBarState extends State<AddToCartBar> {
  static const double _dividerHeight = 20;
  static const double _dividerWidth = 1;

  bool _isPressed = false;
  bool _showAdded = false;
  Timer? _addedTimer;

  @override
  void dispose() {
    _addedTimer?.cancel();
    super.dispose();
  }

  void _add() {
    unawaited(HapticFeedback.lightImpact());
    widget.onAdd?.call();
    setState(() => _showAdded = true);
    _addedTimer?.cancel();
    _addedTimer = Timer(AppDurations.addedFeedback, () {
      if (mounted) setState(() => _showAdded = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final duration = context.motion(AppDurations.cartBarEnter);
    return IgnorePointer(
      ignoring: !widget.visible,
      child: AnimatedSlide(
        offset: widget.visible
            ? Offset.zero
            : const Offset(0, AppMotionValues.cartBarHiddenOffset),
        duration: duration,
        curve: widget.visible ? AppCurves.spring : AppCurves.exit,
        child: AnimatedScale(
          scale: widget.visible ? 1 : AppMotionValues.cartBarHiddenScale,
          duration: duration,
          curve: widget.visible ? AppCurves.spring : AppCurves.exit,
          child: AnimatedOpacity(
            opacity: widget.visible ? 1 : 0,
            duration: context.motion(AppDurations.medium),
            child: _button(context),
          ),
        ),
      ),
    );
  }

  Widget _button(BuildContext context) => Semantics(
    button: true,
    label: context.l10n.addToCart,
    child: GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: _add,
      child: AnimatedScale(
        scale: _isPressed ? AppMotionValues.pressedScale : 1,
        duration: context.motion(AppDurations.fast),
        child: Container(
          height: AppSizes.buttonHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.colors.primary,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withValues(alpha: 0.35),
                blurRadius: AppSpacing.s5,
                offset: const Offset(0, AppSpacing.s2),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: context.motion(AppDurations.medium),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: _showAdded ? _addedContent(context) : _content(context),
          ),
        ),
      ),
    ),
  );

  Widget _content(BuildContext context) {
    final style = context.text.labelLarge?.copyWith(
      color: context.colors.onPrimary,
    );
    final locale = Localizations.localeOf(context).toString();
    return Row(
      key: const ValueKey('add'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.addToCart.toUpperCase(), style: style),
        Container(
          width: _dividerWidth,
          height: _dividerHeight,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
          color: context.colors.onPrimary,
        ),
        RollingNumber(
          value: widget.totalMmk,
          format: (value) => context.l10n.priceMmk(formatNumber(value, locale)),
          style: style,
        ),
      ],
    );
  }

  Widget _addedContent(BuildContext context) => Row(
    key: const ValueKey('added'),
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.check_circle_rounded, color: context.colors.onPrimary),
      const SizedBox(width: AppSpacing.s2),
      Text(
        context.l10n.added.toUpperCase(),
        style: context.text.labelLarge?.copyWith(
          color: context.colors.onPrimary,
        ),
      ),
    ],
  );
}
