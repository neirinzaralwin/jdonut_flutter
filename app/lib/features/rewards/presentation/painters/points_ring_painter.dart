import 'dart:math' as math;

import 'package:flutter/rendering.dart';

/// The big frosted-donut ring: grey track, pink sweep from 12 o'clock with
/// rounded ends, a soft inner highlight, and sprinkles that appear as the
/// sweep passes them.
class PointsRingPainter extends CustomPainter {
  const PointsRingPainter({
    required this.progress,
    required this.trackColor,
    required this.frostLight,
    required this.frostDark,
    required this.sprinkleColor,
    required this.highlightColor,
  });

  /// 0–1 of the full circle (already animated).
  final double progress;
  final Color trackColor;
  final Color frostLight;
  final Color frostDark;
  final Color sprinkleColor;
  final Color highlightColor;

  static const double _thicknessRatio = 0.34;
  static const int _sprinkleCount = 34;
  static const double _sprinkleLengthRatio = 0.09;
  static const double _sprinkleWidthRatio = 0.035;
  static const double _highlightAlpha = 0.35;

  /// Gloss band: inset from the ring's centre line, and its width (both as a
  /// share of the ring thickness).
  static const double _highlightInset = 0.28;
  static const double _highlightWidth = 0.12;

  /// Sprinkles: random jitter along the ring (share of one slot), and the
  /// radial band they sit in (share of thickness, measured from the outer
  /// edge), so none touch the edges.
  static const double _sprinkleJitter = 0.6;
  static const double _sprinkleBandStart = 0.25;
  static const double _sprinkleBandWidth = 0.5;

  /// Same sprinkles on every frame and every launch.
  static const int _sprinkleSeed = 7;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final thickness = radius * _thicknessRatio;
    final center = size.center(Offset.zero);
    final ringRect = Rect.fromCircle(
      center: center,
      radius: radius - thickness / 2,
    );
    canvas.drawArc(
      ringRect,
      0,
      math.pi * 2,
      false,
      _stroke(thickness)..color = trackColor,
    );
    if (progress <= 0) return;

    final sweep = math.pi * 2 * progress;
    final frost = _stroke(thickness)
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [frostLight, frostDark, frostLight],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(ringRect);
    canvas.drawArc(ringRect, -math.pi / 2, sweep, false, frost);
    _drawHighlight(canvas, ringRect, thickness, sweep);
    _drawSprinkles(canvas, center, radius, thickness, sweep);
  }

  Paint _stroke(double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round;

  /// Thin light band near the inner edge: reads as glossy icing.
  void _drawHighlight(
    Canvas canvas,
    Rect ringRect,
    double thickness,
    double sweep,
  ) {
    final inner = ringRect.deflate(thickness * _highlightInset);
    canvas.drawArc(
      inner,
      -math.pi / 2,
      sweep,
      false,
      _stroke(thickness * _highlightWidth)
        ..color = highlightColor.withValues(alpha: _highlightAlpha),
    );
  }

  /// Fixed pseudo-random sprinkles; each is drawn once the sweep reaches it.
  void _drawSprinkles(
    Canvas canvas,
    Offset center,
    double radius,
    double thickness,
    double sweep,
  ) {
    final random = math.Random(_sprinkleSeed);
    final paint = _stroke(radius * _sprinkleWidthRatio)..color = sprinkleColor;
    for (var index = 0; index < _sprinkleCount; index++) {
      final along =
          (index + random.nextDouble() * _sprinkleJitter) / _sprinkleCount;
      final angle = math.pi * 2 * along;
      if (angle > sweep) continue;
      final band =
          radius -
          thickness *
              (_sprinkleBandStart + random.nextDouble() * _sprinkleBandWidth);
      final position = center + Offset.fromDirection(angle - math.pi / 2, band);
      final tilt = random.nextDouble() * math.pi;
      final half = Offset.fromDirection(
        tilt,
        radius * _sprinkleLengthRatio / 2,
      );
      canvas.drawLine(position - half, position + half, paint);
    }
  }

  @override
  bool shouldRepaint(PointsRingPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.frostLight != frostLight ||
      old.frostDark != frostDark ||
      old.sprinkleColor != sprinkleColor ||
      old.highlightColor != highlightColor;
}
