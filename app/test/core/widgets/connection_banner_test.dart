import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/error/failure.dart';
import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/network/api_client.dart';
import 'package:jdonut/core/network/network_providers.dart';
import 'package:jdonut/core/network/network_status.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/connection_banner.dart';
import 'package:jdonut/l10n/gen/app_localizations.dart';

const _offline = "You're offline · showing saved data";
const _backOnline = "You're back online";
const _connected = 'Connected to server';

/// Health check that answers [next].
class _FakeApi implements ApiClient {
  Result<Object> next = const Ok('ok');

  @override
  Future<Result<T>> get<T>(
    String path,
    T Function(Object data) parse, {
    Duration? timeout,
    bool retry = true,
  }) async {
    lastRetry = retry;
    return next as Result<T>;
  }

  /// The health probe must not retry (one try = the answer).
  bool? lastRetry;
}

void main() {
  late StreamController<NetworkStatus> status;
  late _FakeApi api;

  setUp(() {
    status = StreamController<NetworkStatus>();
    api = _FakeApi();
  });
  tearDown(() => status.close());

  Future<void> pumpBanner(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          networkStatusProvider.overrideWith((ref) => status.stream),
          apiClientProvider.overrideWithValue(api),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Stack(children: [ConnectionBanner()]),
        ),
      ),
    );
  }

  double opacity(WidgetTester tester) => tester
      .widget<AnimatedOpacity>(
        find.descendant(
          of: find.byType(ConnectionBanner),
          matching: find.byType(AnimatedOpacity),
        ),
      )
      .opacity;

  testWidgets(
    'launch online + server answers: "Connected to server", then hides',
    (tester) async {
      await pumpBanner(tester);
      status.add(NetworkStatus.online);
      await tester.pumpAndSettle();

      expect(find.text(_connected), findsOneWidget);
      expect(opacity(tester), 1);
      await tester.pump(AppDurations.connectionToastVisible);
      await tester.pumpAndSettle();
      expect(opacity(tester), 0);
    },
  );

  testWidgets('launch online but server down: no toast', (tester) async {
    api.next = const Err(NetworkFailure());
    await pumpBanner(tester);
    status.add(NetworkStatus.online);
    await tester.pumpAndSettle();

    expect(opacity(tester), 0);
    expect(api.lastRetry, isFalse, reason: 'the health probe tries once');
  });

  testWidgets('shows the offline message and keeps it while offline', (
    tester,
  ) async {
    await pumpBanner(tester);
    status.add(NetworkStatus.offline);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();

    expect(find.text(_offline), findsOneWidget);
    expect(opacity(tester), 1);
  });

  testWidgets('back online: turns green, then slides away', (tester) async {
    await pumpBanner(tester);
    status.add(NetworkStatus.offline);
    await tester.pumpAndSettle();

    status.add(NetworkStatus.online);
    await tester.pumpAndSettle();
    expect(find.text(_backOnline), findsOneWidget);
    expect(opacity(tester), 1);

    await tester.pump(AppDurations.connectionToastVisible);
    await tester.pumpAndSettle();
    expect(opacity(tester), 0);
  });
}
