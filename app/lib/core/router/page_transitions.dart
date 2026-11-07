import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonut/core/motion/app_motion.dart';

/// Shared-axis (horizontal) transition for registration steps:
/// the new step slides in a little while fading.
CustomTransitionPage<void> sharedAxisPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppDurations.pageTransition,
    reverseTransitionDuration: AppDurations.pageTransition,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      final incoming = CurvedAnimation(
        parent: animation,
        curve: AppCurves.standard,
      );
      final outgoing = CurvedAnimation(
        parent: secondaryAnimation,
        curve: AppCurves.standard,
      );
      return SlideTransition(
        position: Tween(
          begin: const Offset(AppMotionValues.pageSlideFraction, 0),
          end: Offset.zero,
        ).animate(incoming),
        child: FadeTransition(
          opacity: incoming,
          child: SlideTransition(
            position: Tween(
              begin: Offset.zero,
              end: const Offset(-AppMotionValues.pageSlideFraction, 0),
            ).animate(outgoing),
            child: FadeTransition(
              opacity: ReverseAnimation(outgoing),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

/// Fade for top-level switches (Onboarding ↔ Home, Welcome).
CustomTransitionPage<void> fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppDurations.pageTransition,
    transitionsBuilder: (context, animation, _, child) =>
        MediaQuery.disableAnimationsOf(context)
        ? child
        : FadeTransition(opacity: animation, child: child),
  );
}
