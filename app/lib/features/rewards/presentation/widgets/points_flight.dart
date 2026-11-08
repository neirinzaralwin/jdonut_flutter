import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/utils/formatters.dart';

/// Gives cards the points ring's key, so earned points know where to fly.
class PointsTarget extends InheritedWidget {
  const PointsTarget({required this.ringKey, required super.child, super.key});

  final GlobalKey ringKey;

  static GlobalKey? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PointsTarget>()?.ringKey;

  @override
  bool updateShouldNotify(PointsTarget oldWidget) =>
      ringKey != oldWidget.ringKey;
}

/// Flies a "+100 pts" chip from [from] to the points ring along an arc, then
/// calls [onArrive]. Under Reduce Motion (or with no ring) it lands at once.
void flyPoints(
  BuildContext context, {
  required RenderBox from,
  required int points,
  required VoidCallback onArrive,
}) {
  final overlay = Overlay.maybeOf(context);
  final ring = PointsTarget.maybeOf(context)?.currentContext;
  final ringBox = ring?.findRenderObject() as RenderBox?;
  if (overlay == null || ringBox == null || context.reduceMotion) {
    onArrive();
    return;
  }
  final overlayBox = overlay.context.findRenderObject()! as RenderBox;
  final rawEnd = _centreOf(ringBox, overlayBox);
  // Ring scrolled away: aim at the top edge so the chip still heads "up".
  final end = Offset(rawEnd.dx, rawEnd.dy.clamp(0, overlayBox.size.height));

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _Flight(
      start: _centreOf(from, overlayBox),
      end: end,
      label: context.l10n.pointsGained(
        formatNumber(points, Localizations.localeOf(context).toString()),
      ),
      onDone: () {
        entry.remove();
        onArrive();
      },
    ),
  );
  overlay.insert(entry);
}

Offset _centreOf(RenderBox box, RenderBox ancestor) =>
    box.localToGlobal(box.size.center(Offset.zero), ancestor: ancestor);

class _Flight extends StatefulWidget {
  const _Flight({
    required this.start,
    required this.end,
    required this.label,
    required this.onDone,
  });

  final Offset start;
  final Offset end;
  final String label;
  final VoidCallback onDone;

  @override
  State<_Flight> createState() => _FlightState();
}

class _FlightState extends State<_Flight> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppDurations.pointsFlight,
  )..forward().whenComplete(widget.onDone);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Share of the flight spent popping up; the rest shrinks into the ring.
  static const double _popShare = 0.2;
  static const double _landingScale = 0.4;

  /// Centre the chip on its path point.
  static const Offset _centred = Offset(-0.5, -0.5);

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final point = _pointAt(AppCurves.standard.transform(_c.value));
        return Stack(
          children: [
            Positioned(
              left: point.dx,
              top: point.dy,
              child: FractionalTranslation(
                translation: _centred,
                child: Transform.scale(scale: _scaleAt(_c.value), child: child),
              ),
            ),
          ],
        );
      },
      child: _PointsChip(label: widget.label),
    ),
  );

  /// Along a parabola above the straight line, highest half-way:
  /// lift = arc × distance × 4t(1−t), which is 0 at both ends and 1× at t=½.
  Offset _pointAt(double t) {
    final travel = (widget.end - widget.start).distance;
    final lift = travel * AppMotionValues.flightArc * 4 * t * (1 - t);
    return Offset.lerp(widget.start, widget.end, t)! - Offset(0, lift);
  }

  double _scaleAt(double t) => t < _popShare
      ? Curves.easeOutBack.transform(t / _popShare)
      : lerpDouble(
          1,
          _landingScale,
          Curves.easeIn.transform((t - _popShare) / (1 - _popShare)),
        )!;
}

class _PointsChip extends StatelessWidget {
  const _PointsChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final pink = context.colors.secondary;
    return Material(
      type: MaterialType.transparency,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: pink,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: [
            BoxShadow(
              color: pink.withValues(alpha: AppOpacity.shadow),
              blurRadius: AppSpacing.s4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s2,
          ),
          child: Text(
            label,
            style: context.text.labelLarge?.copyWith(
              color: context.colors.onSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
