import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/features/auth/domain/validators/name_validator.dart';

void main() {
  group('validateFirstName', () {
    test('requires a name', () {
      expect(validateFirstName(''), NameError.required);
      expect(validateFirstName('   '), NameError.required);
    });

    test('accepts Latin letters and spaces', () {
      expect(validateFirstName('Ye Min'), isNull);
    });

    test('accepts Myanmar script, including vowel signs', () {
      expect(validateFirstName('ရဲမင်း'), isNull);
      expect(validateFirstName('ဖြိုး ဝင်း'), isNull);
    });

    test('accepts 50 characters after trimming, rejects 51', () {
      expect(validateFirstName('  ${'a' * 50}  '), isNull);
      expect(validateFirstName('a' * 51), NameError.tooLong);
    });

    test('rejects Latin and Myanmar digits', () {
      expect(validateFirstName('Ye Min 2'), NameError.invalidCharacters);
      expect(validateFirstName('ရဲမင်း၂'), NameError.invalidCharacters);
    });

    test('rejects symbols', () {
      expect(validateFirstName('Ye_Min!'), NameError.invalidCharacters);
    });
  });

  group('validateLastName', () {
    test('is optional', () {
      expect(validateLastName(''), isNull);
      expect(validateLastName('  '), isNull);
    });

    test('uses the same character rules when filled', () {
      expect(validateLastName('Phyoe Win'), isNull);
      expect(validateLastName('Win3'), NameError.invalidCharacters);
      expect(validateLastName('a' * 51), NameError.tooLong);
    });
  });
}
