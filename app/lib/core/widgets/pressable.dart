import 'package:flutter/material.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';

/// Shrinks a little while pressed (the brief's "scale on press"). With a null
/// [onTap] it does nothing and doesn't react.
class Pressable extends StatefulWidget {
  const Pressable({
    required this.child,
    this.onTap,
    this.alignment = Alignment.center,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Alignment alignment;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (widget.onTap != null && value != _isPressed) {
      setState(() => _isPressed = value);
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _setPressed(true),
    onTapUp: (_) => _setPressed(false),
    onTapCancel: () => _setPressed(false),
    onTap: widget.onTap,
    child: AnimatedScale(
      scale: _isPressed ? AppMotionValues.pressedScale : 1,
      alignment: widget.alignment,
      duration: context.motion(AppDurations.fast),
      child: widget.child,
    ),
  );
}
