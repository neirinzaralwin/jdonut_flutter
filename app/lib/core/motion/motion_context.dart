import 'package:flutter/widgets.dart';

/// Reduce Motion support (brief): animations become instant when the OS
/// asks for fewer animations.
extension MotionContext on BuildContext {
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);

  Duration motion(Duration duration) => reduceMotion ? Duration.zero : duration;
}
