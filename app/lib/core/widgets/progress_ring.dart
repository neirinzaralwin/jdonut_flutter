import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/theme/theme.dart';

/// Registration progress ring (top right). Sweeps from [from] to [progress];
/// at 1.0 it morphs into a filled check.
class ProgressRing extends StatelessWidget {
  const ProgressRing({required this.progress, this.from = 0, super.key});

  final double progress;
  final double from;

  static const double _strokeWidth = 3.5;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox.square(
      dimension: AppSizes.progressRing,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: from, end: progress),
        duration: context.motion(AppDurations.slow),
        curve: AppCurves.standard,
        builder: (context, value, _) => AnimatedSwitcher(
          duration: context.motion(AppDurations.medium),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: value >= 1
              ? _Check(color: colors.secondary, iconColor: colors.onSecondary)
              : CustomPaint(
                  key: const ValueKey('ring'),
                  size: const Size.square(AppSizes.progressRing),
                  painter: _RingPainter(
                    value,
                    colors.secondary,
                    context.appColors.ringTrack,
                  ),
                ),
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.color, required this.iconColor});

  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    key: const ValueKey('check'),
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    child: Icon(
      Icons.check_rounded,
      color: iconColor,
      size: AppSizes.progressRing * 0.7,
    ),
  );
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.progress, this.color, this.trackColor);

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(ProgressRing._strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ProgressRing._strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawArc(arcRect, 0, math.pi * 2, false, paint..color = trackColor)
      ..drawArc(
        arcRect,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        paint..color = color,
      );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor;
}
