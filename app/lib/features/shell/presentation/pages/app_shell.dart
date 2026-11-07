import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/features/shell/presentation/widgets/app_bottom_nav.dart';

/// Signed-in shell: five tabs, each keeping its own navigation stack.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: [
          (icon: Icons.home_rounded, label: l10n.navHome),
          (icon: Icons.receipt_long_rounded, label: l10n.navOrder),
          (icon: Icons.card_giftcard_rounded, label: l10n.navReward),
          (icon: Icons.storefront_rounded, label: l10n.navShops),
          (icon: Icons.settings_rounded, label: l10n.navSettings),
        ],
      ),
    );
  }
}
