import 'package:flutter/animation.dart';

/// Every duration, curve and motion amount in the app lives here
/// (brief: "named constants in one motion file").
abstract final class AppDurations {
  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration entrance = Duration(milliseconds: 900);
  static const Duration pointsCountUp = Duration(milliseconds: 1400);
  static const Duration staggerStep = Duration(milliseconds: 70);
  static const Duration bannerAutoPlay = Duration(seconds: 3);
  static const Duration otpShake = Duration(milliseconds: 400);
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration countdownTick = Duration(seconds: 1);
  static const Duration cartBarEnter = Duration(milliseconds: 550);
  static const Duration addedFeedback = Duration(milliseconds: 1400);
  static const Duration donutSpin = Duration(milliseconds: 900);
  static const Duration bannerSlide = Duration(milliseconds: 450);
  static const Duration connectionToastVisible = Duration(seconds: 3);
}

abstract final class AppCurves {
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutBack;
  static const Curve pop = Curves.elasticOut;
  static const Curve exit = Curves.easeInCubic;

  /// Soft overshoot for elements that "land" (Add to cart bar).
  static const Curve spring = Cubic(0.18, 1.25, 0.4, 1);
}

/// Distances and scales used by animations.
abstract final class AppMotionValues {
  static const double pressedScale = 0.96;
  static const double shakeOffset = 10;
  static const int shakeCycles = 3;
  static const double pageSlideFraction = 0.08;
  static const double entranceSlideFraction = 0.3;
  static const double driftDistance = 60;
  static const double tileSlideFraction = 0.4;
  static const double heroVerticalDrift = 0.2;
  static const double cartBarHiddenOffset = 1.6;
  static const double cartBarHiddenScale = 0.9;
  static const double numberSlideFraction = 0.6;
  static const double bannerHiddenOffset = 2;
  static const double toastHiddenScale = 0.85;
}

/// A staggered slice of one entrance animation: item `index` runs from
/// `start + index * step` for [length] (fractions of the whole, 0–1).
class StaggerSlot {
  const StaggerSlot({required this.start, required this.length, this.step = 0});

  final double start;
  final double step;
  final double length;

  Interval interval(int index, {Curve curve = AppCurves.standard}) {
    final begin = (start + index * step).clamp(0.0, 1.0);
    return Interval(begin, (begin + length).clamp(begin, 1.0), curve: curve);
  }
}

/// Named entrance choreography per screen.
abstract final class AppStagger {
  static const StaggerSlot onboardingCircles = StaggerSlot(
    start: 0,
    step: 0.07,
    length: 0.5,
  );
  static const StaggerSlot onboardingContent = StaggerSlot(
    start: 0.35,
    step: 0.1,
    length: 0.4,
  );
  static const StaggerSlot welcomeTiles = StaggerSlot(
    start: 0,
    step: 0.1,
    length: 0.45,
  );
  static const StaggerSlot welcomeTitle = StaggerSlot(start: 0.6, length: 0.3);
  static const StaggerSlot homeSections = StaggerSlot(
    start: 0,
    step: 0.12,
    length: 0.5,
  );
  static const StaggerSlot welcomeAction = StaggerSlot(
    start: 0.75,
    length: 0.25,
  );
}
