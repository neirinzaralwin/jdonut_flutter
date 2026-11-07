abstract final class AppConstants {
  static const String countryCode = '+95';
  static const String fakeOtpCode = '123456';
  static const int otpLength = 6;
  static const int maxOtpAttempts = 3;
  static const Duration otpResendCountdown = Duration(minutes: 5);
  static const int minimumAgeYears = 13;
  static const int nameMaxLength = 50;
  static const Duration fakeAuthDelay = Duration(seconds: 1);
}
