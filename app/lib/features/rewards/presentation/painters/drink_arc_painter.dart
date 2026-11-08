import 'dart:math' as math;

import 'package:flutter/rendering.dart';

/// Half-circle gauge over the drink: grey track from 9 to 3 o'clock, with
/// an orange arc filling it left to right.
class DrinkArcPainter extends CustomPainter {
  const DrinkArcPainter({
    required this.fraction,
    required this.trackColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  final double fraction;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.width / 2),
      radius: radius,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, paint..color = trackColor);
    if (fraction <= 0) return;
    canvas.drawArc(
      rect,
      math.pi,
      math.pi * fraction,
      false,
      paint..color = fillColor,
    );
  }

  @override
  bool shouldRepaint(DrinkArcPainter old) =>
      old.fraction != fraction ||
      old.trackColor != trackColor ||
      old.fillColor != fillColor ||
      old.strokeWidth != strokeWidth;
}
