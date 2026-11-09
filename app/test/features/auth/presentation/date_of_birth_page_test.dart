import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/widgets/app_button.dart';
import 'package:jdonut/features/auth/presentation/pages/date_of_birth_page.dart';

import '../../../helpers/pump_auth_page.dart';

void main() {
  bool continueEnabled(WidgetTester tester) =>
      tester.widget<AppButton>(find.byType(AppButton)).onPressed != null;

  testWidgets('Month / Day / Year boxes fill from the native picker', (
    tester,
  ) async {
    await pumpAuthPage(
      tester,
      const DateOfBirthPage(),
      repository: MockAuthRepository(),
    );

    // Empty boxes show their hints; Continue waits for a date.
    expect(find.text('Month'), findsOneWidget);
    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Year'), findsOneWidget);
    expect(continueEnabled(tester), isFalse);

    // Any box opens the picker; it starts 13 years back (youngest allowed).
    await tester.tap(find.text('Day'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('November'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('2013'), findsOneWidget);
    expect(continueEnabled(tester), isTrue);
  });
}
