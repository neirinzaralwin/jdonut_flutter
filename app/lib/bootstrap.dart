import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonut/app.dart';
import 'package:jdonut/core/database/database_provider.dart';
import 'package:jdonut/features/auth/auth.dart';
import 'package:jdonut/features/home/home.dart';

/// Seeds local data and restores the session before the first frame, so a
/// logged-in user lands on Home without a flash of Onboarding.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  // Offline-first: bundled data is in the DB before the first frame.
  await container.read(seedServiceProvider).seedIfNeeded();
  await container.read(sessionProvider.notifier).restore();
  // Refresh from the server now (if online) and whenever we reconnect.
  container.read(backgroundCatalogSyncProvider);
  runApp(
    UncontrolledProviderScope(container: container, child: const JDonutApp()),
  );
}
