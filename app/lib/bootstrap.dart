import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonut/app.dart';
import 'package:jdonut/features/auth/auth.dart';

/// Restores the session before the first frame, so a logged-in user lands
/// on Home without a flash of Onboarding.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await container.read(sessionProvider.notifier).restore();
  runApp(
    UncontrolledProviderScope(container: container, child: const JDonutApp()),
  );
}
