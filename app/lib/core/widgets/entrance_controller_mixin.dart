import 'package:flutter/widgets.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';

/// One entrance controller per screen; jumps to the end under Reduce Motion.
mixin EntranceControllerMixin<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  late final AnimationController entrance = AnimationController(
    vsync: this,
    duration: entranceDuration,
  );

  /// Override for a longer or shorter entrance.
  Duration get entranceDuration => AppDurations.entrance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (entrance.isAnimating || entrance.isCompleted) return;
    replayEntrance();
  }

  /// Plays the entrance from the start (e.g. when a tab becomes visible).
  void replayEntrance() {
    if (context.reduceMotion) {
      entrance.value = 1;
    } else {
      entrance.forward(from: 0);
    }
  }

  @override
  void dispose() {
    entrance.dispose();
    super.dispose();
  }
}
