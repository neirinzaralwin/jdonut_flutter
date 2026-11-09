import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/bootstrap.dart';
import 'package:jdonut/core/database/app_database.dart';
import 'package:jdonut/core/database/database_provider.dart';
import 'package:jdonut/core/storage/storage_providers.dart';
import 'package:jdonut/features/home/presentation/widgets/product_tile.dart';

import 'in_memory_session_store.dart';

/// The brief's main flow on the real app, shared by the integration test
/// (on a device) and the layout test (every screen at text scale 1.3).
///
/// Only storage is swapped: a fresh in-memory database and session, so each
/// run starts as a brand-new user on first launch.
List<Override> freshStorageOverrides() => [
  appDatabaseProvider.overrideWith((ref) {
    final database = AppDatabase(NativeDatabase.memory());
    ref.onDispose(database.close);
    return database;
  }),
  sessionStoreProvider.overrideWithValue(InMemorySessionStore()),
];

Future<void> launchFreshApp(WidgetTester tester) async {
  // Seeding and session restore hit the database, which needs real async.
  final app = await tester.runAsync(
    () => buildApp(overrides: freshStorageOverrides()),
  );
  await tester.pumpWidget(app!);
  await settle(tester);
}

/// Onboarding → Phone → OTP → Name → Date of birth → Welcome → Home.
Future<void> registerNewUser(WidgetTester tester) async {
  await tapText(tester, "Let's get started");
  await tester.enterText(find.byType(TextField), '09254135592');
  await tapText(tester, 'Continue');

  await tester.enterText(find.byType(TextField), '123456');
  await settle(tester);
  expect(find.text('First name'), findsOneWidget);

  await tester.enterText(find.byType(TextField).first, 'Ye Min');
  await tapText(tester, 'Continue');

  // The boxes open the native picker, which starts 13 years back (a valid
  // birthday): accept it. iOS shows a wheel with "Select", Android a
  // calendar with "OK".
  await tester.tap(find.text('Month'), warnIfMissed: false);
  await settle(tester);
  final confirm = find.text('Select').evaluate().isNotEmpty ? 'Select' : 'OK';
  await tapText(tester, confirm);
  await tapText(tester, 'Continue');

  await tapText(tester, "Let's explore");
  expect(find.text('Seasonal specials 💕'), findsOneWidget);
}

/// Home → Product detail for Coconut Donut (the reference design), then
/// checks code, MMK price and the live total.
Future<void> openCoconutDonut(WidgetTester tester) async {
  final coconut = find.text('Coconut Donut');
  await tester.scrollUntilVisible(
    coconut,
    _scrollStep,
    scrollable: find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .first,
  );
  // Centre it, so the floating bottom nav can't cover the tap.
  await Scrollable.ensureVisible(
    tester.element(coconut.first),
    alignment: _centre,
  );
  await tester.pump();
  // The name sits under the card; the card itself is the tap target.
  await tester.tap(
    find
        .descendant(
          of: find.ancestor(
            of: coconut.first,
            matching: find.byType(ProductTile),
          ),
          matching: find.byType(InkWell),
        )
        .first,
  );
  await settle(tester);
  expect(find.text('JD022123'), findsOneWidget);
  expect(find.textContaining('3,200 MMK'), findsWidgets);

  // Quantity starts at 0 (design); + reveals Add to cart with the total.
  final plus = find.byIcon(Icons.add_rounded).first;
  await tester.tap(plus);
  await settle(tester);
  await tester.tap(plus);
  await settle(tester);
  expect(find.textContaining('6,400 MMK'), findsWidgets);
}

/// Back to Home, then the Reward and Settings tabs.
Future<void> visitRewardsAndSettings(WidgetTester tester) async {
  await tester.pageBack();
  await settle(tester);
  await tester.tap(find.bySemanticsLabel('Reward'));
  await settle(tester);
  expect(find.text("J' Donuts Rewards"), findsOneWidget);
  await tester.tap(find.text('Gift'));
  await settle(tester);
  await tester.tap(find.bySemanticsLabel('Settings'));
  await settle(tester);
  expect(find.text('Log out'), findsOneWidget);
}

const double _scrollStep = 300;
const double _centre = 0.5;

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.pump(); // let typed text enable the button first
  // Buttons render their label in capitals, so match ignoring case.
  final target = find
      .byWidgetPredicate(
        (w) => w is Text && w.data?.toLowerCase() == text.toLowerCase(),
      )
      .first;
  await tester.ensureVisible(target);
  await tester.tap(target);
  await settle(tester);
}

/// Like pumpAndSettle, with a cap: the Home carousel and Earn pulse animate
/// forever, so "settled" never comes. Lets real time pass too (the database
/// and the 1 s fake auth delay run on real async), then pumps frames.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}
