import 'package:flutter/widgets.dart';
import 'package:jdonut/core/motion/app_motion.dart';

/// Fades and slides [child] in during its [slot] of a shared [animation],
/// so one controller drives a whole staggered sequence.
class StaggeredEntrance extends StatelessWidget {
  const StaggeredEntrance({
    required this.animation,
    required this.slot,
    required this.child,
    this.index = 0,
    this.from = const Offset(0, AppMotionValues.entranceSlideFraction),
    super.key,
  });

  final Animation<double> animation;
  final StaggerSlot slot;
  final int index;

  /// Starting offset as a fraction of the child's size.
  final Offset from;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final progress = CurvedAnimation(
      parent: animation,
      curve: slot.interval(index),
    );
    return FadeTransition(
      opacity: progress,
      child: SlideTransition(
        position: Tween(begin: from, end: Offset.zero).animate(progress),
        child: child,
      ),
    );
  }
}
