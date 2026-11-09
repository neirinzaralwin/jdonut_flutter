import 'package:flutter/material.dart';
import 'package:jdonut/core/constants/app_assets.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/theme/theme.dart';
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

  /// Pairs [_layout] with a backdrop colour and a donut photo; the centre
  /// circle shows the app logo.
  List<_CircleSpec> _circles(BuildContext context) {
    final backdrops = context.appColors.backdrops;
    final art = [
      (backdrops.sky, AppAssets.donutChocolateDrizzle),
      (backdrops.periwinkle, AppAssets.donutWhiteSprinkle),
      (backdrops.mist, AppAssets.donutPinkSprinkle),
      (backdrops.butter, AppAssets.donutAlmondCrunch),
      (Colors.transparent, AppAssets.appLogo),
    ];
    return [
      for (final (index, (alignment, size)) in _layout.indexed)
        _CircleSpec(
          alignment: alignment,
          sizeFactor: size,
          background: art[index].$1,
          imageAsset: art[index].$2,
          isLogo: index == _layout.length - 1,
        ),
    ];
  }
}

class _CircleSpec {
  const _CircleSpec({
    required this.alignment,
    required this.sizeFactor,
    required this.background,
    required this.imageAsset,
    this.isLogo = false,
  });

  final Alignment alignment;
  final double sizeFactor;
  final Color background;
  final String imageAsset;
  final bool isLogo;
}

class _DonutCircle extends StatelessWidget {
  const _DonutCircle({required this.spec, required this.diameter});

  final _CircleSpec spec;
  final double diameter;

  /// Share of the circle the photo fills. The logo is drawn alone (no
  /// backdrop), 20% smaller than its slot.
  static const double _donutRatio = 0.72;
  static const double _logoRatio = 0.8;

  @override
  Widget build(BuildContext context) {
    final size = diameter * (spec.isLogo ? _logoRatio : _donutRatio);
    final pixels = (size * MediaQuery.devicePixelRatioOf(context)).round();
    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      // The logo is already round: no backdrop behind it.
      decoration: spec.isLogo
          ? null
          : BoxDecoration(color: spec.background, shape: BoxShape.circle),
      child: ClipOval(
        clipBehavior: spec.isLogo ? Clip.antiAlias : Clip.none,
        child: Image.asset(
          spec.imageAsset,
          width: size,
          height: size,
          fit: BoxFit.contain,
          cacheWidth: pixels,
          semanticLabel: spec.isLogo ? context.l10n.appTitle : null,
          excludeFromSemantics: !spec.isLogo,
        ),
      ),
    );
  }
}
