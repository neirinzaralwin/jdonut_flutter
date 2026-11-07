import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/features/auth/domain/validators/otp_validator.dart';

void main() {
  test('a complete OTP is exactly 6 digits', () {
    expect(isCompleteOtp('123456'), isTrue);
    expect(isCompleteOtp('12345'), isFalse);
    expect(isCompleteOtp('1234567'), isFalse);
    expect(isCompleteOtp('12345a'), isFalse);
  });

  test('entry locks after 3 wrong codes', () {
    expect(isOtpLocked(2), isFalse);
    expect(isOtpLocked(3), isTrue);
    expect(otpAttemptsLeft(1), 2);
    expect(otpAttemptsLeft(3), 0);
  });
}
