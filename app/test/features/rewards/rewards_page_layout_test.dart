import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/features/member/member.dart';
import 'package:jdonut/features/rewards/domain/entities/challenge.dart';
import 'package:jdonut/features/rewards/presentation/providers/rewards_providers.dart';
import 'package:jdonut/features/rewards/rewards.dart';
import 'package:jdonut/l10n/gen/app_localizations.dart';

import '../../helpers/real_fonts.dart';

const _member = Member(
  id: 'm',
  tier: MemberTier.silver,
  nextTier: MemberTier.gold,
  points: 680000,
  tierProgress: 0.62,
  pointsToNextTier: 500,
  notificationCount: 3,
  rewardsCount: 3,
);

Challenge _challenge(
  ChallengeTab tab,
  ChallengeArtwork art, {
  bool complete = false,
}) => Challenge(
  id: '${tab.name}_${art.name}',
  tab: tab,
  title: 'Drink 12 cups americano with friends',
  artwork: art,
  progress: complete ? 12 : 9,
  goal: 12,
  rewardPoints: 100,
);

Widget _app({
  required double scale,
  required String locale,
  bool complete = false,
}) => ProviderScope(
  overrides: [
    memberProvider.overrideWithValue(const AsyncData(_member)),
    for (final tab in ChallengeTab.values)
      challengesProvider(tab).overrideWithValue(
        AsyncData([
          for (final art in ChallengeArtwork.values)
            _challenge(tab, art, complete: complete),
        ]),
      ),
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    locale: Locale(locale),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: const RewardsPage(),
  ),
);

void main() {
  setUpAll(loadRealFonts);

  testWidgets('Earn flies points to the ring and adds them once', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(scale: 1, locale: 'en', complete: true));
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('680,000'), findsOneWidget);

    await tester.tap(find.text('EARN').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('+100 pts'), findsOneWidget); // flying chip
    expect(find.text('Earned'), findsOneWidget); // button flipped at once
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('+100 pts'), findsNothing);
    expect(find.text('680,100'), findsOneWidget);
    if (Platform.environment['SHOTS'] != null) {
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('/tmp/earn.png'),
      );
    }

    // Already earned: no second payout.
    await tester.tap(find.text('Earned'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('680,100'), findsOneWidget);
  });

  final cases = [
    (name: 'small phone', size: const Size(320, 568), scale: 1.0, locale: 'en'),
    (name: 'large text', size: const Size(390, 844), scale: 1.6, locale: 'en'),
    (name: 'burmese', size: const Size(360, 740), scale: 1.3, locale: 'my'),
    (name: 'pro', size: const Size(402, 874), scale: 1.0, locale: 'en'),
  ];

  for (final c in cases) {
    testWidgets('Rewards never overflows: ${c.name}', (tester) async {
      tester.view.physicalSize = c.size * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(scale: c.scale, locale: c.locale));
      await tester.pump(const Duration(seconds: 3));
      expect(tester.takeException(), isNull);

      await tester.tap(find.byType(GestureDetector).first, warnIfMissed: false);
      await tester.pump(const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
    });
  }
}
