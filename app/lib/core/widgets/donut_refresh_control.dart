import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:jdonut/core/constants/app_assets.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';

/// Pull-to-refresh with the J'Donuts donut instead of a spinner.
/// Pulling grows and turns the donut with the finger; while refreshing it
/// spins; when done it shrinks away. Put it first in a CustomScrollView
/// that uses bouncing physics.
class DonutRefreshControl extends StatelessWidget {
  const DonutRefreshControl({
    required this.onRefresh,
    this.backgroundColor,
    super.key,
  });

  final Future<void> Function() onRefresh;

  /// Fills the pulled-open area (e.g. to continue a header colour).
  final Color? backgroundColor;

  static const double _triggerDistance = 110;
  static const double _indicatorExtent = 72;

  @override
  Widget build(BuildContext context) {
    // The scroll view starts behind the status bar, so add its height:
    // the donut then opens up below the notch, not under it.
    final topInset = MediaQuery.paddingOf(context).top;
    return CupertinoSliverRefreshControl(
      refreshTriggerPullDistance: _triggerDistance + topInset,
      refreshIndicatorExtent: _indicatorExtent + topInset,
      onRefresh: onRefresh,
      builder: (context, mode, pulledExtent, triggerDistance, indicatorExtent) {
        final progress =
            ((pulledExtent - topInset) / (triggerDistance - topInset)).clamp(
              0.0,
              1.0,
            );
        return ColoredBox(
          color: backgroundColor ?? const Color(0x00000000),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: _DonutIndicator(
              progress: progress,
              spinning:
                  mode == RefreshIndicatorMode.armed ||
                  mode == RefreshIndicatorMode.refresh,
              done: mode == RefreshIndicatorMode.done,
            ),
          ),
        );
      },
    );
  }
}

class _DonutIndicator extends StatefulWidget {
  const _DonutIndicator({
    required this.progress,
    required this.spinning,
    required this.done,
  });

  /// 0 → 1 as the user pulls to the trigger distance.
  final double progress;
  final bool spinning;
  final bool done;

  @override
  State<_DonutIndicator> createState() => _DonutIndicatorState();
}

class _DonutIndicatorState extends State<_DonutIndicator>
    with SingleTickerProviderStateMixin {
  static const double _size = 44;
  static const double _minScale = 0.4;

  /// How far the donut turns while being pulled (half a turn).
  static const double _pullTurns = 0.5;

  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: AppDurations.donutSpin,
  );

  @override
  void didUpdateWidget(_DonutIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldSpin = widget.spinning && !context.reduceMotion;
    if (shouldSpin && !_spin.isAnimating) {
      _spin.repeat();
    } else if (!shouldSpin && _spin.isAnimating) {
      _spin.stop();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.done
        ? _minScale
        : _minScale + (1 - _minScale) * widget.progress;
    return Padding(
      padding: const EdgeInsets.only(bottom: _size / 3),
      child: AnimatedOpacity(
        opacity: widget.done ? 0 : widget.progress,
        duration: context.motion(AppDurations.fast),
        child: AnimatedScale(
          scale: scale,
          duration: context.motion(AppDurations.fast),
          child: AnimatedBuilder(
            animation: _spin,
            builder: (context, child) => Transform.rotate(
              angle: (widget.progress * _pullTurns + _spin.value) * 2 * math.pi,
              child: child,
            ),
            child: Image.asset(
              AppAssets.donutLoading,
              width: _size,
              height: _size,
              filterQuality: FilterQuality.none,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    );
  }
}
