import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/error/failure.dart';
import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/features/auth/domain/entities/auth_mode.dart';
import 'package:jdonut/features/auth/presentation/pages/otp_page.dart';
import 'package:jdonut/features/auth/presentation/pages/phone_page.dart';
import 'package:jdonut/features/auth/presentation/providers/registration_draft.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_auth_page.dart';

void main() {
  const phone = '+959254135592';
  late MockAuthRepository repository;

  setUp(() => repository = MockAuthRepository());

  group('Phone step', () {
    testWidgets(
      'invalid number: Continue disabled, message after leaving the field',
      (tester) async {
        await pumpAuthPage(tester, const PhonePage(), repository: repository);

        await tester.enterText(find.byType(TextField), '0812345');
        await tester.pump();
        expect(isContinueEnabled(tester), isFalse);
        expect(
          find.textContaining('valid Myanmar mobile number'),
          findsNothing,
        );

        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump();
        expect(
          find.textContaining('valid Myanmar mobile number'),
          findsOneWidget,
        );
      },
    );

    testWidgets('enables Continue for a valid number', (tester) async {
      await pumpAuthPage(tester, const PhonePage(), repository: repository);

      await tester.enterText(find.byType(TextField), '09 254 135 592');
      await tester.pump();

      expect(isContinueEnabled(tester), isTrue);
    });

    testWidgets('log in with an unregistered number offers a Register link', (
      tester,
    ) async {
      when(
        () => repository.requestOtp(phone: phone, mode: AuthMode.logIn),
      ).thenAnswer(
        (_) async => const Err(AuthFailure(AuthFailureKind.notRegistered)),
      );
      final container = await pumpAuthPage(
        tester,
        const PhonePage(),
        repository: repository,
        arrange: (container) => container
            .read(registrationDraftProvider.notifier)
            .start(AuthMode.logIn),
      );

      await tester.enterText(find.byType(TextField), '09254135592');
      await tester.pump();
      await tester.tap(find.text('CONTINUE'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text("This number isn't registered yet."), findsOneWidget);
      await tester.tap(find.text('Register'));
      await tester.pump();
      expect(container.read(registrationDraftProvider).mode, AuthMode.register);
      expect(
        container.read(registrationDraftProvider).phoneInput,
        '09254135592',
      );
    });

    testWidgets('a double tap on Continue sends one request', (tester) async {
      when(
        () => repository.requestOtp(phone: phone, mode: AuthMode.register),
      ).thenAnswer((_) async => Ok(widgetTestToday));
      await pumpAuthPage(tester, const PhonePage(), repository: repository);

      await tester.enterText(find.byType(TextField), '09254135592');
      await tester.pump();
      // Two taps before any rebuild: the second must be ignored.
      await tester.tap(find.text('CONTINUE'));
      await tester.tap(find.text('CONTINUE'));
      await tester.pump(const Duration(seconds: 1));

      verify(
        () => repository.requestOtp(phone: phone, mode: AuthMode.register),
      ).called(1);
    });
  });

  group('OTP step', () {
    Future<void> pumpOtp(WidgetTester tester) => pumpAuthPage(
      tester,
      const OtpPage(),
      repository: repository,
      arrange: (container) {
        container.read(registrationDraftProvider.notifier)
          ..start(AuthMode.logIn)
          ..otpSent(
            phone: phone,
            expiresAt: widgetTestToday.add(const Duration(minutes: 5)),
          );
      },
    );

    Future<void> enterCode(WidgetTester tester, String code) async {
      await tester.enterText(find.byType(TextField), code);
      await tester.pump(const Duration(seconds: 1));
    }

    setUp(() {
      when(
        () => repository.verifyOtp(
          phone: phone,
          code: any(named: 'code'),
        ),
      ).thenAnswer(
        (_) async => const Err(AuthFailure(AuthFailureKind.invalidOtp)),
      );
    });

    testWidgets(
      'a wrong code clears the boxes and says how many attempts are left',
      (tester) async {
        await pumpOtp(tester);

        await enterCode(tester, '000000');

        expect(find.text('Wrong code. 2 attempts left.'), findsOneWidget);
        expect(find.text('0'), findsNothing, reason: 'boxes are cleared');
      },
    );

    testWidgets('three wrong codes lock entry until Resend', (tester) async {
      await pumpOtp(tester);

      for (var attempt = 0; attempt < 3; attempt++) {
        await enterCode(tester, '000000');
      }

      expect(
        find.text('Too many wrong codes. Resend a new code to try again.'),
        findsOneWidget,
      );
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      verify(
        () => repository.verifyOtp(phone: phone, code: '000000'),
      ).called(3);
    });
  });
}
