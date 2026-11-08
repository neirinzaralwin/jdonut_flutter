import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:jdonut/app.dart';
import 'package:jdonut/core/config/env.dart';
import 'package:jdonut/core/database/database_provider.dart';
import 'package:jdonut/features/auth/auth.dart';
import 'package:jdonut/features/home/home.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(await buildApp());
}

/// `--dart-define=SKIP_SEED=true`, honoured in debug builds only so a
/// release can never ship without its offline catalog.
bool _skipCatalogSeed() => kDebugMode && Env.skipCatalogSeed;

/// Seeds local data and restores the session before the first frame, so a
/// logged-in user lands on Home without a flash of Onboarding.
///
/// `overrides` lets the integration test start the real app on a fresh
/// in-memory database and session store.
Future<Widget> buildApp({List<Override> overrides = const []}) async {
  final container = ProviderContainer(overrides: overrides);
  // Offline-first: bundled data is in the DB before the first frame.
  await container
      .read(seedServiceProvider)
      .seedIfNeeded(withCatalog: !_skipCatalogSeed());
  await container.read(sessionProvider.notifier).restore();
  // Refresh from the server now (if online) and whenever we reconnect.
  container.read(backgroundCatalogSyncProvider);
  return UncontrolledProviderScope(
    container: container,
    child: const JDonutApp(),
  );
}
