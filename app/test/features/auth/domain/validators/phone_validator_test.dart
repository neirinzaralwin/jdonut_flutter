import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/features/auth/domain/validators/phone_validator.dart';

void main() {
  group('validatePhone', () {
    const validNumbers = [
      '09254135592', // leading 0 is stripped
      '9254135592',
      '09 254 135 592', // spaces stripped
      '09-254-135-592', // dashes stripped
      '0912345678', // 9 + 8 digits
      '091234567', // 9 + 7 digits (shortest)
    ];
    for (final input in validNumbers) {
      test('accepts "$input"', () => expect(validatePhone(input), isNull));
    }

    test('reports an empty field as empty', () {
      expect(validatePhone(''), PhoneError.empty);
      expect(validatePhone(' - '), PhoneError.empty);
    });

    const invalidNumbers = {
      '0812345678': 'does not start with 9',
      '09123456': '9 + 6 digits is too short',
      '0912345678901': '9 + 11 digits is too long',
      '009254135592': 'only one leading 0 is stripped',
      '09254a35592': 'contains a letter',
    };
    invalidNumbers.forEach((input, reason) {
      test('rejects "$input" ($reason)', () {
        expect(validatePhone(input), PhoneError.invalidFormat);
      });
    });
  });

  test('normalizePhone turns 09254135592 into +959254135592', () {
    expect(normalizePhone('09254135592'), '+959254135592');
    expect(normalizePhone('09 254-135 592'), '+959254135592');
  });
}
