import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonut/core/router/app_routes.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/app_button.dart';
import 'package:jdonut/features/auth/domain/repositories/auth_repository.dart';
import 'package:jdonut/features/auth/presentation/providers/auth_dependencies.dart';
import 'package:jdonut/l10n/gen/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

final DateTime widgetTestToday = DateTime(2026, 11, 8);

/// Pumps [page] with real theme + l10n, a mocked repository and a fixed
/// clock. Other auth routes render a marker text so navigation is visible.
Future<ProviderContainer> pumpAuthPage(
  WidgetTester tester,
  Widget page, {
  required AuthRepository repository,
  void Function(ProviderContainer container)? arrange,
}) async {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      clockProvider.overrideWithValue(() => widgetTestToday),
    ],
  );
  addTearDown(container.dispose);
  arrange?.call(container);

  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => page),
      for (final path in [AppRoutes.otp, AppRoutes.name, AppRoutes.dateOfBirth])
        GoRoute(path: path, builder: (_, _) => Text('route:$path')),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pump();
  return container;
}

/// The Continue button is disabled when its `onPressed` is null.
bool isContinueEnabled(WidgetTester tester) {
  return tester.widget<AppButton>(find.byType(AppButton)).onPressed != null;
}
