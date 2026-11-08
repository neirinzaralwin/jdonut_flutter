import 'package:flutter/material.dart';
import 'package:jdonut/core/constants/app_assets.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/features/rewards/domain/entities/challenge.dart';
import 'package:jdonut/features/rewards/presentation/painters/donut_progress_clipper.dart';
import 'package:jdonut/features/rewards/presentation/painters/drink_arc_painter.dart';

/// Progress shown in the artwork itself: the donut colours in quarter by
/// quarter; the drink gets an arc that fills. [reveal] (0–1) animates it.
class ChallengeArt extends StatelessWidget {
  const ChallengeArt({
    required this.challenge,
    required this.reveal,
    required this.size,
    super.key,
  });

  final Challenge challenge;
  final Animation<double> reveal;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: AnimatedBuilder(
      animation: reveal,
      builder: (context, _) {
        final fraction = challenge.fraction * reveal.value;
        return switch (challenge.artwork) {
          ChallengeArtwork.donut => _DonutArt(fraction: fraction),
          ChallengeArtwork.drink => _DrinkArt(fraction: fraction),
        };
      },
    ),
  );
}

/// Frosted-white donut with the pink one revealed as a growing pie slice.
class _DonutArt extends StatelessWidget {
  const _DonutArt({required this.fraction});

  final double fraction;

  /// Grayscale (R, G, B weights summing to 1), then lifted towards white by
  /// [_frostLift] (0–255): un-earned icing looks frosted.
  static const double _red = 0.25;
  static const double _green = 0.6;
  static const double _blue = 0.15;
  static const double _frostLift = 70;
  static const ColorFilter _frosted = ColorFilter.matrix(<double>[
    _red, _green, _blue, 0, _frostLift, //
    _red, _green, _blue, 0, _frostLift, //
    _red, _green, _blue, 0, _frostLift, //
    0, 0, 0, 1, 0, //
  ]);

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      AppAssets.donutProgress,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        ColorFiltered(colorFilter: _frosted, child: image),
        ClipPath(clipper: DonutProgressClipper(fraction), child: image),
      ],
    );
  }
}

/// The drink under a half-circle gauge.
class _DrinkArt extends StatelessWidget {
  const _DrinkArt({required this.fraction});

  final double fraction;

  static const double _strokeWidth = 10;
  static const double _drinkHeightFraction = 0.78;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.bottomCenter,
    children: [
      Positioned.fill(
        child: CustomPaint(
          painter: DrinkArcPainter(
            fraction: fraction,
            trackColor: context.colors.outlineVariant,
            fillColor: context.colors.tertiary,
            strokeWidth: _strokeWidth,
          ),
        ),
      ),
      FractionallySizedBox(
        heightFactor: _drinkHeightFraction,
        child: Image.asset(
          AppAssets.drinkProgress,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
      ),
    ],
  );
}
