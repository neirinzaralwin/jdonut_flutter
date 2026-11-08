import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/router/app_routes.dart';
import 'package:jdonut/features/shell/presentation/widgets/app_bottom_nav.dart';

/// Signed-in shell: five tabs, each keeping its own navigation stack.
class AppShell extends StatelessWidget {
  const AppShell({
    required this.navigationShell,
    required this.location,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  /// Current path; full-screen pages (Product detail) hide the bar.
  final String location;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      // Content scrolls behind the floating bar.
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _HideableBar(
        hidden: AppRoutes.hidesBottomNav(location),
        child: AppBottomNav(
          currentIndex: navigationShell.currentIndex,
          onSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          items: [
            (icon: Icons.home_outlined, label: l10n.navHome),
            (icon: Icons.workspace_premium_outlined, label: l10n.navReward),
            (icon: Icons.donut_large_rounded, label: l10n.navOrder),
            (
              icon: Icons.account_balance_wallet_outlined,
              label: l10n.navWallet,
            ),
            (icon: Icons.settings_outlined, label: l10n.navSettings),
          ],
        ),
      ),
    );
  }
}

/// Slides the bar down out of view (and back) instead of popping it.
class _HideableBar extends StatelessWidget {
  const _HideableBar({required this.hidden, required this.child});

  final bool hidden;
  final Widget child;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: hidden,
    child: AnimatedSlide(
      offset: hidden ? const Offset(0, 1) : Offset.zero,
      duration: context.motion(AppDurations.medium),
      curve: AppCurves.standard,
      child: child,
    ),
  );
}
