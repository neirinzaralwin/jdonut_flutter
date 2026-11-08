import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/router/app_routes.dart';
import 'package:jdonut/core/router/page_transitions.dart';
import 'package:jdonut/features/auth/auth.dart';
import 'package:jdonut/features/home/home.dart';
import 'package:jdonut/features/product/product.dart';
import 'package:jdonut/features/settings/settings.dart';
import 'package:jdonut/features/shell/shell.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Router with the auth guard. Composition root: the only core file that
/// imports feature barrels.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final sessionChanges = ValueNotifier<SessionState>(ref.read(sessionProvider));
  ref
    ..listen(sessionProvider, (_, next) => sessionChanges.value = next)
    ..onDispose(sessionChanges.dispose);

  final router = GoRouter(
    initialLocation: AppRoutes.onboarding,
    refreshListenable: sessionChanges,
    redirect: (_, state) =>
        authRedirect(sessionChanges.value, state.matchedLocation),
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (_, state) => fadePage(state, const OnboardingPage()),
      ),
      GoRoute(
        path: AppRoutes.phone,
        pageBuilder: (_, state) => sharedAxisPage(state, const PhonePage()),
      ),
      GoRoute(
        path: AppRoutes.otp,
        pageBuilder: (_, state) => sharedAxisPage(state, const OtpPage()),
      ),
      GoRoute(
        path: AppRoutes.name,
        pageBuilder: (_, state) => sharedAxisPage(state, const NamePage()),
      ),
      GoRoute(
        path: AppRoutes.dateOfBirth,
        pageBuilder: (_, state) =>
            sharedAxisPage(state, const DateOfBirthPage()),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        pageBuilder: (_, state) => fadePage(state, const WelcomePage()),
      ),
      _shellRoute(),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}

StatefulShellRoute _shellRoute() => StatefulShellRoute.indexedStack(
  pageBuilder: (_, state, shell) => fadePage(
    state,
    AppShell(navigationShell: shell, location: state.uri.path),
  ),
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const HomePage(),
          routes: [
            GoRoute(
              path: AppRoutes.product,
              pageBuilder: (_, state) => fadePage(
                state,
                ProductDetailPage(
                  productId: state.pathParameters['id']!,
                  heroScope:
                      state.uri.queryParameters[AppRoutes.heroScopeParam],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
    _branch(
      AppRoutes.reward,
      (context) => PlaceholderTabPage(title: context.l10n.navReward),
    ),
    _branch(
      AppRoutes.order,
      (context) => PlaceholderTabPage(title: context.l10n.navOrder),
    ),
    _branch(
      AppRoutes.wallet,
      (context) => PlaceholderTabPage(title: context.l10n.navWallet),
    ),
    _branch(AppRoutes.settings, (_) => const SettingsPage()),
  ],
);

StatefulShellBranch _branch(
  String path,
  Widget Function(BuildContext context) builder,
) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (context, _) => builder(context))],
);

/// Pure guard, unit-testable:
/// - signed out → only Onboarding and /auth/* steps
/// - signed in on an auth route → Welcome (new user) or Home
@visibleForTesting
String? authRedirect(SessionState session, String location) {
  final isPublic = AppRoutes.isPublic(location);
  return switch (session) {
    SessionUnknown() => null,
    Unauthenticated() => isPublic ? null : AppRoutes.onboarding,
    Authenticated(:final isNewUser) when isPublic =>
      isNewUser ? AppRoutes.welcome : AppRoutes.home,
    Authenticated() => null,
  };
}
