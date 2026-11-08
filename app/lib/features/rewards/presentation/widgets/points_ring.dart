import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/utils/formatters.dart';
import 'package:jdonut/features/rewards/presentation/painters/points_ring_painter.dart';

/// Ring sweeps 0 → [progress] while the total counts up 0 → [points].
/// When [bonus] grows (points earned), the ring "gulps" and the total counts
/// up from the old value to the new one.
class PointsRing extends StatefulWidget {
  const PointsRing({
    required this.points,
    required this.progress,
    required this.entrance,
    this.bonus = 0,
    super.key,
  });

  final int points;
  final int bonus;
  final double progress;
  final Animation<double> entrance;

  @override
  State<PointsRing> createState() => _PointsRingState();
}

class _PointsRingState extends State<PointsRing>
    with SingleTickerProviderStateMixin {
  static const double _sprinkleAlpha = 0.7;

  late final AnimationController _gain = AnimationController(
    vsync: this,
    duration: AppDurations.pointsGain,
    value: 1,
  );
  late int _fromBonus = widget.bonus;

  @override
  void didUpdateWidget(PointsRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bonus == oldWidget.bonus) return;
    // Start from what is on screen now, so quick double earns stay smooth.
    _fromBonus = _shownBonus.round();
    if (context.reduceMotion) {
      _gain.value = 1;
    } else {
      _gain.forward(from: 0);
    }
  }

  double get _shownBonus => lerpDouble(
    _fromBonus.toDouble(),
    widget.bonus.toDouble(),
    AppCurves.standard.transform(_gain.value),
  )!;

  @override
  void dispose() {
    _gain.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sweep = CurvedAnimation(
      parent: widget.entrance,
      curve: AppStagger.pointsRing.interval(0),
    );
    final pink = context.colors.secondary;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([sweep, _gain]),
        builder: (context, _) {
          // One smooth bump that peaks early and settles: sin over 0..π.
          final gulp = math.sin(math.pi * _gain.value);
          return Transform.scale(
            scale: 1 + (AppMotionValues.ringGainScale - 1) * gulp,
            child: CustomPaint(
              painter: PointsRingPainter(
                progress: widget.progress * sweep.value,
                trackColor: context.colors.outlineVariant,
                frostLight: context.appColors.frostLight,
                frostDark: pink,
                sprinkleColor: context.colors.surface.withValues(
                  alpha: _sprinkleAlpha,
                ),
                highlightColor: context.colors.surface,
              ),
              child: _total(
                context,
                (widget.points + _shownBonus) * sweep.value,
              ),
            ),
          );
        },
      ),
    );
  }

  /// "Total points" over the counting number, centred in the ring.
  Widget _total(BuildContext context, double total) {
    final pink = context.colors.secondary;
    final locale = Localizations.localeOf(context).toString();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.totalPoints,
            style: context.text.titleSmall?.copyWith(color: pink),
          ),
          FittedBox(
            child: Text(
              formatNumber(total.round(), locale),
              style: context.text.headlineMedium?.copyWith(color: pink),
            ),
          ),
        ],
      ),
    );
  }
}
