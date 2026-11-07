import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/constants/app_constants.dart';
import 'package:jdonut/features/auth/domain/validators/date_of_birth_validator.dart';

void main() {
  final today = DateTime(2026, 11, 8);

  DateOfBirthError? validate(int? year, int? month, int? day) =>
      validateDateOfBirth(year: year, month: month, day: day, today: today);

  test('accepts a real date for an adult', () {
    expect(validate(1980, 5, 1), isNull);
  });

  group('real calendar date', () {
    test('rejects 31 April', () {
      expect(validate(1990, 4, 31), DateOfBirthError.invalidDate);
    });

    test('accepts 29 February in a leap year', () {
      expect(validate(2000, 2, 29), isNull);
    });

    test('rejects 29 February in a common year', () {
      expect(validate(1999, 2, 29), DateOfBirthError.invalidDate);
    });

    test('rejects month 13 and day 0', () {
      expect(validate(1990, 13, 1), DateOfBirthError.invalidDate);
      expect(validate(1990, 1, 0), DateOfBirthError.invalidDate);
    });

    test('rejects missing parts', () {
      expect(validate(null, 1, 1), DateOfBirthError.invalidDate);
      expect(validate(1990, null, 1), DateOfBirthError.invalidDate);
      expect(validate(1990, 1, null), DateOfBirthError.invalidDate);
    });
  });

  test('rejects a date in the future', () {
    expect(validate(2026, 11, 9), DateOfBirthError.inFuture);
  });

  group('minimum age', () {
    test('is a named constant of 13', () {
      expect(AppConstants.minimumAgeYears, 13);
    });

    test('accepts someone turning 13 today', () {
      expect(validate(2013, 11, 8), isNull);
    });

    test('rejects someone turning 13 tomorrow', () {
      expect(validate(2013, 11, 9), DateOfBirthError.tooYoung);
    });
  });
}
