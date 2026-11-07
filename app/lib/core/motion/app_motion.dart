import 'package:flutter/animation.dart';

/// Every duration and curve in the app lives here (brief: "one motion file").
abstract final class AppDurations {
  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration pointsCountUp = Duration(milliseconds: 1400);
  static const Duration staggerStep = Duration(milliseconds: 70);
  static const Duration bannerAutoPlay = Duration(seconds: 4);
  static const Duration otpShake = Duration(milliseconds: 400);
}

abstract final class AppCurves {
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutBack;
  static const Curve pop = Curves.elasticOut;
}
