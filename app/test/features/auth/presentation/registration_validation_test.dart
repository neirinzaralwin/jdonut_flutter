import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/features/auth/presentation/pages/date_of_birth_page.dart';
import 'package:jdonut/features/auth/presentation/pages/name_page.dart';
import 'package:jdonut/features/auth/presentation/providers/registration_draft.dart';

import '../../../helpers/pump_auth_page.dart';

void main() {
  late MockAuthRepository repository;
  setUp(() => repository = MockAuthRepository());

  group('Name step', () {
    testWidgets('keeps Continue disabled until a first name is entered', (
      tester,
    ) async {
      await pumpAuthPage(tester, const NamePage(), repository: repository);

      expect(isContinueEnabled(tester), isFalse);
    });

    testWidgets('rejects digits in the first name once the field is left', (
      tester,
    ) async {
      await pumpAuthPage(tester, const NamePage(), repository: repository);

      await tester.enterText(find.byType(TextField).first, 'Ye Min 2');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();

      expect(find.text('Use letters and spaces only.'), findsOneWidget);
      expect(isContinueEnabled(tester), isFalse);
    });

    testWidgets('accepts a Myanmar name with no last name', (tester) async {
      await pumpAuthPage(tester, const NamePage(), repository: repository);

      await tester.enterText(find.byType(TextField).first, 'ရဲမင်း');
      await tester.pump();

      expect(isContinueEnabled(tester), isTrue);
    });

    testWidgets('keeps the entered names when the step is shown again (Back)', (
      tester,
    ) async {
      await pumpAuthPage(
        tester,
        const NamePage(),
        repository: repository,
        arrange: (container) => container
            .read(registrationDraftProvider.notifier)
            .updateName(firstName: 'Ye Min', lastName: 'Phyoe Win'),
      );

      expect(find.text('Ye Min'), findsOneWidget);
      expect(find.text('Phyoe Win'), findsOneWidget);
    });
  });

  group('Date of birth step', () {
    Future<void> pumpWithDate(
      WidgetTester tester, {
      required int month,
      required String day,
      required String year,
    }) => pumpAuthPage(
      tester,
      const DateOfBirthPage(),
      repository: repository,
      arrange: (container) => container
          .read(registrationDraftProvider.notifier)
          .updateBirthDate(month: month, day: day, year: year),
    );

    testWidgets('31 April is not a real date', (tester) async {
      await pumpWithDate(tester, month: 4, day: '31', year: '1990');

      expect(find.text('Enter a real date.'), findsOneWidget);
      expect(isContinueEnabled(tester), isFalse);
    });

    testWidgets('someone younger than 13 cannot continue', (tester) async {
      await pumpWithDate(tester, month: 1, day: '1', year: '2020');

      expect(find.text('You must be at least 13 years old.'), findsOneWidget);
      expect(isContinueEnabled(tester), isFalse);
    });

    testWidgets('a valid adult date enables Continue', (tester) async {
      await pumpWithDate(tester, month: 5, day: '1', year: '1980');

      expect(isContinueEnabled(tester), isTrue);
    });
  });
}
