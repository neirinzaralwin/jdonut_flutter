import 'package:flutter/material.dart';
import 'package:jdonut/core/constants/app_assets.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/donut_art.dart';
import 'package:jdonut/core/widgets/staggered_entrance.dart';

/// Donut circles that drift in from the edges (brief: Onboarding motion).
class OnboardingHero extends StatelessWidget {
  const OnboardingHero({required this.animation, super.key});

  final Animation<double> animation;

  /// Where each circle sits and how big it is (fraction of the shortest
  /// side). Alignments past ±1 let the circles bleed off the edges, like the
  /// design; the last one is the big centre circle with the logo.
  static const List<(Alignment, double)> _layout = [
    (Alignment(-1.3, -0.9), 0.38),
    (Alignment(1.35, -0.7), 0.34),
    (Alignment(-1.2, 1.05), 0.3),
    (Alignment(1.2, 1.1), 0.32),
    (Alignment.center, 0.62),
  ];

  static const double _diameterScale = 1.4;

  @override
  Widget build(BuildContext context) {
    final circles = _circles(context);
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

  /// Pairs [_layout] with theme colours (background, icing).
  List<_CircleSpec> _circles(BuildContext context) {
    final colors = context.colors;
    final appColors = context.appColors;
    final paints = [
      (colors.primary, appColors.tierGold.light),
      (appColors.banner, colors.secondary),
      (appColors.badge, colors.surface),
      (colors.primaryContainer, colors.secondary),
      (colors.surface, colors.secondary),
    ];
    return [
      for (final (index, (alignment, size)) in _layout.indexed)
        _CircleSpec(
          alignment: alignment,
          sizeFactor: size,
          background: paints[index].$1,
          icing: paints[index].$2,
          imageAsset: index == _layout.length - 1 ? AppAssets.appLogo : null,
        ),
    ];
  }
}

class _CircleSpec {
  const _CircleSpec({
    required this.alignment,
    required this.sizeFactor,
    required this.background,
    required this.icing,
    this.imageAsset,
  });

  final Alignment alignment;
  final double sizeFactor;
  final Color background;
  final Color icing;

  /// Shown instead of a drawn donut (the app logo in the middle circle).
  final String? imageAsset;
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
    child: spec.imageAsset == null
        ? DonutArt(icing: spec.icing, size: diameter * _donutRatio)
        : ClipOval(
            child: Image.asset(
              spec.imageAsset!,
              width: diameter,
              height: diameter,
              fit: BoxFit.cover,
              semanticLabel: context.l10n.appTitle,
            ),
          ),
  );
}
