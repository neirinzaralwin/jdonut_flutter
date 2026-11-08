import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Progressive blur along the bottom edge of a scrolling screen: content
/// softens and fades into the background as it slides under the bottom bar.
/// (Same technique as vint_flutter's home feed.)
///
/// Flutter has no masked (gradient) backdrop blur, so the blur is built from
/// a few stacked bands, each blurring a little more than the one above, with
/// a background-coloured gradient on top that hides the band seams.
///
/// Purely decorative: ignores pointers and adds nothing to semantics. Place
/// it in a [Stack] over the scrolling content.
class AppBottomFade extends StatelessWidget {
  const AppBottomFade({
    required this.color,
    this.height = defaultHeight,
    this.maxSigma = defaultMaxSigma,
    this.bands = defaultBands,
    super.key,
  });

  static const double defaultHeight = 120;
  static const double defaultMaxSigma = 4;
  static const int defaultBands = 8;

  /// What the content fades into. Should match the screen background.
  final Color color;

  /// Height above the bottom safe-area inset. The inset is added on top.
  final double height;

  /// Blur strength at the very bottom.
  final double maxSigma;

  /// Number of blur steps. More is smoother and costs more per frame.
  final int bands;

  /// Ease-in ramp: the top steps differ by a fraction of a pixel, so no band
  /// edge reads as a line.
  double _sigma(int band) {
    final progress = (band + 1) / bands;
    return maxSigma * progress * progress;
  }

  /// The colour wash on top of the blur: clear at the top, mostly opaque at
  /// the bottom edge.
  static const List<double> _tintStops = [0, 0.35, 0.7, 1];
  static const List<double> _tintAlphas = [0, 0.18, 0.5, 0.78];

  @override
  Widget build(BuildContext context) {
    final total = height + MediaQuery.paddingOf(context).bottom;
    final bandHeight = total / bands;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: SizedBox(
          height: total,
          child: Stack(
            fit: StackFit.expand,
            children: [
              for (var band = 0; band < bands; band++)
                Positioned(
                  left: 0,
                  right: 0,
                  top: bandHeight * band,
                  bottom: 0,
                  child: _blur(band),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: _tintStops,
                    colors: [
                      for (final alpha in _tintAlphas)
                        color.withValues(alpha: alpha),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mirror tiling keeps the clipped edge from sampling a hard border.
  Widget _blur(int band) => ClipRect(
    child: BackdropFilter(
      filter: ui.ImageFilter.blur(
        sigmaX: _sigma(band),
        sigmaY: _sigma(band),
        tileMode: TileMode.mirror,
      ),
      child: const SizedBox.expand(),
    ),
  );
}
