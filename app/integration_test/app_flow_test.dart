import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/main_flow.dart';

/// Runs the real app (router, providers, Drift, seed data, fake auth with its
/// real delay) through the brief's main flow on a simulator or emulator:
/// Register → Home → Product detail, then Rewards and Settings.
///
/// `flutter test integration_test -d <device>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a new user registers, lands on Home and opens a product', (
    tester,
  ) async {
    await launchFreshApp(tester);
    await registerNewUser(tester);
    await openCoconutDonut(tester);
    await visitRewardsAndSettings(tester);
  });
}
