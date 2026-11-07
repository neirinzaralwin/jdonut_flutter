import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/router/app_router.dart';
import 'package:jdonut/core/router/app_routes.dart';
import 'package:jdonut/features/auth/auth.dart';

void main() {
  final user = User(
    id: 'u1',
    phone: '+959254135592',
    firstName: 'Ye Min',
    dateOfBirth: DateTime(1980),
  );

  test('a signed-out user is sent from Home to Onboarding', () {
    expect(
      authRedirect(const Unauthenticated(), AppRoutes.home),
      AppRoutes.onboarding,
    );
  });

  test('a signed-out user may use the auth steps', () {
    expect(authRedirect(const Unauthenticated(), AppRoutes.otp), isNull);
  });

  test('a returning user on an auth route goes to Home', () {
    expect(authRedirect(Authenticated(user), AppRoutes.otp), AppRoutes.home);
    expect(
      authRedirect(Authenticated(user), AppRoutes.onboarding),
      AppRoutes.home,
    );
  });

  test('a newly registered user goes to Welcome first', () {
    expect(
      authRedirect(Authenticated(user, isNewUser: true), AppRoutes.dateOfBirth),
      AppRoutes.welcome,
    );
  });

  test('a signed-in user stays on in-app routes', () {
    expect(authRedirect(Authenticated(user), AppRoutes.settings), isNull);
  });
}
