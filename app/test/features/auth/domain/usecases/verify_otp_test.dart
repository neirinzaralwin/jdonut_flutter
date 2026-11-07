import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/error/failure.dart';
import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/features/auth/domain/entities/auth_mode.dart';
import 'package:jdonut/features/auth/domain/entities/otp_outcome.dart';
import 'package:jdonut/features/auth/domain/entities/user.dart';
import 'package:jdonut/features/auth/domain/repositories/auth_repository.dart';
import 'package:jdonut/features/auth/domain/usecases/verify_otp.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const phone = '+959254135592';
  final user = User(
    id: 'u1',
    phone: phone,
    firstName: 'Ye Min',
    dateOfBirth: DateTime(1980),
  );
  late _MockAuthRepository repository;
  late VerifyOtp verifyOtp;

  setUp(() {
    repository = _MockAuthRepository();
    verifyOtp = VerifyOtp(repository);
  });

  void codeIsCorrect() => when(
    () => repository.verifyOtp(
      phone: phone,
      code: any(named: 'code'),
    ),
  ).thenAnswer((_) async => const Ok(null));

  test('a returning user with the right code is signed in', () async {
    codeIsCorrect();
    when(() => repository.logIn(phone)).thenAnswer((_) async => Ok(user));

    final result = await verifyOtp(
      phone: phone,
      code: '123456',
      mode: AuthMode.logIn,
    );

    expect(result, isA<Ok<OtpOutcome>>());
    expect((result as Ok<OtpOutcome>).value, isA<SignedIn>());
  });

  test(
    'a new user with the right code continues registration without signing in',
    () async {
      codeIsCorrect();

      final result = await verifyOtp(
        phone: phone,
        code: '123456',
        mode: AuthMode.register,
      );

      expect((result as Ok<OtpOutcome>).value, isA<ContinueRegistration>());
      verifyNever(() => repository.logIn(any()));
    },
  );

  test('a wrong code returns the failure and does not sign in', () async {
    when(() => repository.verifyOtp(phone: phone, code: '000000')).thenAnswer(
      (_) async => const Err(AuthFailure(AuthFailureKind.invalidOtp)),
    );

    final result = await verifyOtp(
      phone: phone,
      code: '000000',
      mode: AuthMode.logIn,
    );

    expect(result, isA<Err<OtpOutcome>>());
    verifyNever(() => repository.logIn(any()));
  });
}
