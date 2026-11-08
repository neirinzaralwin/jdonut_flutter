import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:jdonut/core/theme/app_colors.dart';

/// A drawn donut (dough, icing, sprinkles), used on Onboarding and Welcome
/// so first launch needs no image assets.
class DonutArt extends StatelessWidget {
  const DonutArt({required this.icing, this.size = 120, super.key});

  final Color icing;
  final double size;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(size: Size.square(size), painter: _DonutPainter(icing)),
  );
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter(this.icing);

  final Color icing;

  /// Shares of the radius: the shadow drops a little below the dough, and
  /// sprinkles alternate between two rings on the icing.
  static const double _shadowDrop = 0.04;
  static const double _doughRatio = 0.96;
  static const double _sprinkleWidth = 0.06;
  static const double _sprinkleLength = 0.1;
  static const double _innerSprinkleRing = 0.5;
  static const double _outerSprinkleRing = 0.68;

  /// Each sprinkle leans 60° off the radius.
  static const double _sprinkleTilt = math.pi / 3;

  static const double _holeRatio = 0.18;
  static const double _icingRatio = 0.42;
  static const int _sprinkleCount = 14;
  static const List<Color> _sprinkleColors = [
    AppPalette.sky,
    AppPalette.surface,
    AppPalette.sprinkleYellow,
    AppPalette.purple,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    canvas
      ..drawCircle(
        center + Offset(0, radius * _shadowDrop),
        radius,
        Paint()..color = AppPalette.doughShadow,
      )
      ..drawCircle(
        center,
        radius * _doughRatio,
        Paint()..color = AppPalette.dough,
      )
      ..drawCircle(center, radius * _icingRatio * 2, Paint()..color = icing);
    _drawSprinkles(canvas, center, radius);
    canvas.drawCircle(
      center,
      radius * _holeRatio,
      Paint()..color = AppPalette.doughShadow,
    );
  }

  void _drawSprinkles(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..strokeWidth = radius * _sprinkleWidth
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < _sprinkleCount; i++) {
      final angle = i * math.pi * 2 / _sprinkleCount;
      final distance =
          radius * (i.isEven ? _innerSprinkleRing : _outerSprinkleRing);
      final start = center + Offset.fromDirection(angle, distance);
      final end =
          start +
          Offset.fromDirection(angle + _sprinkleTilt, radius * _sprinkleLength);
      canvas.drawLine(
        start,
        end,
        paint..color = _sprinkleColors[i % _sprinkleColors.length],
      );
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.icing != icing;
}
