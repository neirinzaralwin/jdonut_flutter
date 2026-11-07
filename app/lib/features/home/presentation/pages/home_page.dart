import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/features/auth/auth.dart';
import 'package:jdonut/features/shell/shell.dart';

/// Home — Task 2 replaces this with the real screen. Shows the signed-in
/// user's name (from the local DB) to prove the session works.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final name = session is Authenticated ? session.user.firstName : '';
    return PlaceholderTabPage(title: context.l10n.greeting(name));
  }
}
