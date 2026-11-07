import 'package:flutter/material.dart';
import 'package:jdonut/core/theme/theme.dart';

/// Pink → white wash behind every auth screen.
class AuthBackground extends StatelessWidget {
  const AuthBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [context.appColors.authGradientTop, context.colors.surface],
      ),
    ),
    child: child,
  );
}
