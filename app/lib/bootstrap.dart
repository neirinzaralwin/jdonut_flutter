import 'package:flutter/widgets.dart';
import 'package:jdonut/app.dart';

/// Initialise bindings, DB, seed data and ProviderScope here.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO(bootstrap): wrap in ProviderScope once flutter_riverpod is added.
  runApp(const JDonutApp());
}
