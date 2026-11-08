import 'package:flutter/material.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';

/// Text that rolls up when [value] grows and down when it shrinks.
class RollingNumber extends StatefulWidget {
  const RollingNumber({
    required this.value,
    required this.format,
    this.style,
    super.key,
  });

  final int value;
  final String Function(int value) format;
  final TextStyle? style;

  @override
  State<RollingNumber> createState() => _RollingNumberState();
}

class _RollingNumberState extends State<RollingNumber> {
  bool _isIncreasing = true;

  @override
  void didUpdateWidget(RollingNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _isIncreasing = widget.value > oldWidget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final direction = _isIncreasing ? 1.0 : -1.0;
    return ClipRect(
      child: AnimatedSwitcher(
        duration: context.motion(AppDurations.medium),
        switchInCurve: AppCurves.standard,
        switchOutCurve: AppCurves.exit,
        transitionBuilder: (child, animation) {
          final isIncoming = child.key == ValueKey(widget.value);
          final from =
              AppMotionValues.numberSlideFraction *
              direction *
              (isIncoming ? 1 : -1);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: Offset(0, from),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Text(
          widget.format(widget.value),
          key: ValueKey(widget.value),
          style: widget.style,
        ),
      ),
    );
  }
}
