import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/constants/app_constants.dart';
import 'package:jdonut/core/error/failure.dart';
import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/features/auth/domain/entities/auth_mode.dart';
import 'package:jdonut/features/auth/domain/entities/new_user.dart';

import '../../../helpers/test_auth.dart';

void main() {
  const phone = '+959254135592';
  final newUser = NewUser(
    phone: phone,
    firstName: 'Ye Min',
    dateOfBirth: DateTime(1980, 5),
  );

  late TestAuth auth;
  setUp(() => auth = TestAuth());
  tearDown(() => auth.dispose());

  AuthFailureKind? failureKind(Result<Object?> result) => switch (result) {
    Err(failure: AuthFailure(:final kind)) => kind,
    _ => null,
  };

  test('log in with an unregistered number fails with notRegistered', () async {
    final result = await auth.repository.requestOtp(
      phone: phone,
      mode: AuthMode.logIn,
    );
    expect(failureKind(result), AuthFailureKind.notRegistered);
  });

  test('requesting an OTP returns an expiry 5 minutes from now', () async {
    final result = await auth.repository.requestOtp(
      phone: phone,
      mode: AuthMode.register,
    );
    expect(result, isA<Ok<DateTime>>());
    expect(
      (result as Ok<DateTime>).value,
      testToday.add(AppConstants.otpResendCountdown),
    );
  });

  test('only the fake code 123456 verifies', () async {
    expect(
      await auth.repository.verifyOtp(phone: phone, code: '123456'),
      isA<Ok<void>>(),
    );
    final wrong = await auth.repository.verifyOtp(phone: phone, code: '654321');
    expect(failureKind(wrong), AuthFailureKind.invalidOtp);
  });

  test('register stores the user and starts a session', () async {
    final result = await auth.repository.register(newUser);
    final user = (result as Ok).value;
    expect(auth.session.userId, isNotNull);
    expect((await auth.repository.currentUser() as Ok).value, user);
  });

  test(
    'registering the same number twice fails with alreadyRegistered',
    () async {
      await auth.repository.register(newUser);
      final again = await auth.repository.requestOtp(
        phone: phone,
        mode: AuthMode.register,
      );
      expect(failureKind(again), AuthFailureKind.alreadyRegistered);
    },
  );

  test('a failed session write rolls back the new user', () async {
    auth.session.failNextWrite = true;
    expect(await auth.repository.register(newUser), isA<Err<Object?>>());
    final retry = await auth.repository.requestOtp(
      phone: phone,
      mode: AuthMode.register,
    );
    expect(retry, isA<Ok<DateTime>>(), reason: 'no half-registered user left');
  });

  test('log out ends the session', () async {
    await auth.repository.register(newUser);
    await auth.repository.logOut();
    expect((await auth.repository.currentUser() as Ok).value, isNull);
  });
}
