import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A pie slice from 12 o'clock, clockwise, covering [fraction] of the circle.
/// Used to colour the donut in quarter by quarter.
class DonutProgressClipper extends CustomClipper<Path> {
  const DonutProgressClipper(this.fraction);

  final double fraction;

  @override
  Path getClip(Size size) {
    final center = size.center(Offset.zero);
    // Larger than the image so the slice covers its corners.
    final radius = size.longestSide;
    if (fraction >= 1) return Path()..addRect(Offset.zero & size);
    return Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * fraction,
        false,
      )
      ..close();
  }

  @override
  bool shouldReclip(DonutProgressClipper oldClipper) =>
      oldClipper.fraction != fraction;
}
