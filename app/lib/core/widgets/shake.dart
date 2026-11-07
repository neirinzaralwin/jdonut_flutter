import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';

/// Shakes [child] horizontally every time [trigger] changes.
class Shake extends StatefulWidget {
  const Shake({required this.trigger, required this.child, super.key});

  final int trigger;
  final Widget child;

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.otpShake,
  );

  @override
  void didUpdateWidget(Shake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger && !context.reduceMotion) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(_offset(_controller.value), 0),
        child: child,
      ),
    );
  }

  /// A sine wave that fades out over the animation.
  double _offset(double progress) =>
      math.sin(progress * math.pi * 2 * AppMotionValues.shakeCycles) *
      AppMotionValues.shakeOffset *
      (1 - progress);
}
