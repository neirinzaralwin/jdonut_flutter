/// Every route path in one place — no raw route strings elsewhere.
abstract final class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String phone = '/auth/phone';
  static const String otp = '/auth/otp';
  static const String name = '/auth/name';
  static const String dateOfBirth = '/auth/date-of-birth';
  static const String welcome = '/welcome';

  static const String home = '/home';
  static const String order = '/order';
  static const String reward = '/reward';
  static const String shops = '/shops';
  static const String settings = '/settings';

  /// Routes a signed-out user may visit.
  static bool isPublic(String location) =>
      location == onboarding || location.startsWith('/auth/');
}
