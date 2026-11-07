import 'package:flutter/material.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/donut_art.dart';
import 'package:jdonut/core/widgets/staggered_entrance.dart';

/// Donut circles that drift in from the edges (brief: Onboarding motion).
class OnboardingHero extends StatelessWidget {
  const OnboardingHero({required this.animation, super.key});

  final Animation<double> animation;

  /// Circle layout (alignment can sit past the edge so circles bleed off).
  static const double _diameterScale = 1.4;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final appColors = context.appColors;
    final circles = [
      _CircleSpec(
        alignment: const Alignment(-1.3, -0.9),
        sizeFactor: 0.38,
        background: colors.primary,
        icing: appColors.tierGold,
      ),
      _CircleSpec(
        alignment: const Alignment(1.35, -0.7),
        sizeFactor: 0.34,
        background: appColors.banner,
        icing: colors.secondary,
      ),
      _CircleSpec(
        alignment: const Alignment(-1.2, 1.05),
        sizeFactor: 0.3,
        background: appColors.badge,
        icing: colors.surface,
      ),
      _CircleSpec(
        alignment: const Alignment(1.2, 1.1),
        sizeFactor: 0.32,
        background: colors.primaryContainer,
        icing: colors.secondary,
      ),
      _CircleSpec(
        alignment: Alignment.center,
        sizeFactor: 0.62,
        background: appColors.authGradientTop,
        icing: colors.secondary,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        clipBehavior: Clip.none,
        children: [
          for (final (index, spec) in circles.indexed)
            Align(
              alignment: spec.alignment,
              child: StaggeredEntrance(
                animation: animation,
                slot: AppStagger.onboardingCircles,
                index: index,
                from: Offset(
                  spec.alignment.x * AppMotionValues.entranceSlideFraction,
                  spec.alignment.y * AppMotionValues.heroVerticalDrift,
                ),
                child: _DonutCircle(
                  spec: spec,
                  diameter:
                      constraints.biggest.shortestSide *
                      spec.sizeFactor *
                      _diameterScale,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleSpec {
  const _CircleSpec({
    required this.alignment,
    required this.sizeFactor,
    required this.background,
    required this.icing,
  });

  final Alignment alignment;
  final double sizeFactor;
  final Color background;
  final Color icing;
}

class _DonutCircle extends StatelessWidget {
  const _DonutCircle({required this.spec, required this.diameter});

  final _CircleSpec spec;
  final double diameter;

  static const double _donutRatio = 0.62;

  @override
  Widget build(BuildContext context) => Container(
    width: diameter,
    height: diameter,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: spec.background, shape: BoxShape.circle),
    child: DonutArt(icing: spec.icing, size: diameter * _donutRatio),
  );
}
