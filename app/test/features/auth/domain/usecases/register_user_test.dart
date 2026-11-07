import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/error/failure.dart';
import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/features/auth/domain/entities/new_user.dart';
import 'package:jdonut/features/auth/domain/entities/user.dart';
import 'package:jdonut/features/auth/domain/repositories/auth_repository.dart';
import 'package:jdonut/features/auth/domain/usecases/register_user.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  final today = DateTime(2026, 11, 8);
  final valid = NewUser(
    phone: '+959254135592',
    firstName: ' Ye Min ',
    lastName: '  ',
    dateOfBirth: DateTime(1980, 5),
  );
  late _MockAuthRepository repository;
  late RegisterUser registerUser;

  setUpAll(() => registerFallbackValue(valid));
  setUp(() {
    repository = _MockAuthRepository();
    registerUser = RegisterUser(repository, () => today);
    when(() => repository.register(any())).thenAnswer((invocation) async {
      final user = invocation.positionalArguments.first as NewUser;
      return Ok(
        User(
          id: 'u1',
          phone: user.phone,
          firstName: user.firstName,
          lastName: user.lastName,
          dateOfBirth: user.dateOfBirth,
        ),
      );
    });
  });

  test('stores a trimmed first name and drops a blank last name', () async {
    await registerUser(valid);

    final stored =
        verify(() => repository.register(captureAny())).captured.single
            as NewUser;
    expect(stored.firstName, 'Ye Min');
    expect(stored.lastName, isNull);
  });

  test(
    'refuses data that breaks a rule, without calling the repository',
    () async {
      final tooYoung = valid.copyWith(dateOfBirth: DateTime(2020));

      final result = await registerUser(tooYoung);

      expect(result, isA<Err<User>>());
      expect((result as Err<User>).failure, isA<ValidationFailure>());
      verifyNever(() => repository.register(any()));
    },
  );
}
