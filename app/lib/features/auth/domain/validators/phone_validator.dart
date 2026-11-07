/// Phone rules (brief Task 1): after +95, strip spaces, dashes and one
/// leading 0; the result must be 9 followed by 7 to 9 digits.
enum PhoneError { empty, invalidFormat }

const String myanmarCountryCode = '+95';

final RegExp _separators = RegExp(r'[\s-]');
final RegExp _nationalNumber = RegExp(r'^9\d{7,9}$');

/// The national number without separators or one leading 0.
String nationalNumber(String input) {
  final digits = input.replaceAll(_separators, '');
  return digits.startsWith('0') ? digits.substring(1) : digits;
}

PhoneError? validatePhone(String input) {
  final number = nationalNumber(input);
  if (number.isEmpty) return PhoneError.empty;
  return _nationalNumber.hasMatch(number) ? null : PhoneError.invalidFormat;
}

/// `09254135592` → `+959254135592`. Call only after [validatePhone] passes.
String normalizePhone(String input) =>
    '$myanmarCountryCode${nationalNumber(input)}';
