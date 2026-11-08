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
  static const String wallet = '/wallet';
  static const String settings = '/settings';

  /// Child of the Home tab, so the Hero image animates (same navigator).
  static const String product = 'product/:id';
  static const String _productPrefix = '$home/product/';
  static const String heroScopeParam = 'from';

  /// `/home/product/p_coconut?from=seasonal` — `from` keeps Hero tags unique.
  static String productPath(String id, {String? heroScope}) => Uri(
    path: '$_productPrefix$id',
    queryParameters: heroScope == null ? null : {heroScopeParam: heroScope},
  ).toString();

  /// Full-screen routes inside the shell that hide the bottom nav.
  static bool hidesBottomNav(String location) =>
      location.startsWith(_productPrefix);

  /// Routes a signed-out user may visit.
  static bool isPublic(String location) =>
      location == onboarding || location.startsWith('/auth/');
}
