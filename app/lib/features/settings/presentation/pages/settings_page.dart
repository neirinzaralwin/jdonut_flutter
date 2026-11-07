import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/features/auth/auth.dart';

/// Settings tab — holds the Log out row (brief Task 1). The router guard
/// sends the user to Onboarding once the session ends.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsTitle, style: context.text.titleLarge),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.logout_rounded, color: context.colors.error),
            title: Text(
              context.l10n.logOut,
              style: context.text.bodyLarge?.copyWith(
                color: context.colors.error,
              ),
            ),
            onTap: ref.read(sessionProvider.notifier).logOut,
          ),
        ],
      ),
    );
  }
}
