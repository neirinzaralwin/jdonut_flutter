import 'package:flutter/widgets.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';

/// One entrance controller per screen; jumps to the end under Reduce Motion.
mixin EntranceControllerMixin<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  late final AnimationController entrance = AnimationController(
    vsync: this,
    duration: AppDurations.entrance,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (entrance.isAnimating || entrance.isCompleted) return;
    if (context.reduceMotion) {
      entrance.value = 1;
    } else {
      entrance.forward();
    }
  }

  @override
  void dispose() {
    entrance.dispose();
    super.dispose();
  }
}
