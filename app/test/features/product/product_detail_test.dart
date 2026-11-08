import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/features/product/domain/cart_quantity.dart';
import 'package:jdonut/features/product/presentation/providers/product_providers.dart';
import 'package:jdonut/features/product/presentation/widgets/add_to_cart_bar.dart';
import 'package:jdonut/features/product/product.dart';
import 'package:jdonut/l10n/gen/app_localizations.dart';

const _coconut = Product(
  id: 'p_coconut',
  code: 'JD022123',
  name: 'Coconut Donut',
  priceMmk: 3200,
  description: 'Toasted coconut.',
  isNew: true,
);

Future<void> _pumpDetail(WidgetTester tester) async {
  // Phone-sized screen (iPhone 15 points).
  tester.view.physicalSize = const Size(1179, 2556);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        productDetailProvider(
          _coconut.id,
        ).overrideWithValue(const AsyncData(_coconut)),
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
        home: ProductDetailPage(productId: _coconut.id),
      ),
    ),
  );
  await tester.pump();
}

bool _barVisible(WidgetTester tester) =>
    tester.widget<AddToCartBar>(find.byType(AddToCartBar)).visible;

void main() {
  group('CartQuantity', () {
    test('never goes below 0 or above the max', () {
      expect(CartQuantity.decrement(0), 0);
      expect(CartQuantity.increment(CartQuantity.max), CartQuantity.max);
    });

    test('line total is quantity × unit price', () {
      expect(CartQuantity.lineTotal(3, 3200), 9600);
    });
  });

  testWidgets('shows code, name and price with thousands separators', (
    tester,
  ) async {
    await _pumpDetail(tester);

    expect(find.text('JD022123'), findsOneWidget);
    expect(find.text('Coconut Donut'), findsOneWidget);
    expect(find.text('3,200 MMK'), findsOneWidget);
    expect(find.text('New'), findsOneWidget);
  });

  testWidgets('the first + reveals Add to cart with the live total', (
    tester,
  ) async {
    await _pumpDetail(tester);
    expect(_barVisible(tester), isFalse);

    await tester.tap(find.bySemanticsLabel('Increase quantity'));
    await tester.tap(find.bySemanticsLabel('Increase quantity'));
    await tester.pumpAndSettle();

    expect(_barVisible(tester), isTrue);
    expect(find.text('6,400 MMK'), findsOneWidget);
  });

  testWidgets('going back to 0 hides Add to cart again', (tester) async {
    await _pumpDetail(tester);

    await tester.tap(find.bySemanticsLabel('Increase quantity'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Decrease quantity'));
    await tester.pumpAndSettle();

    expect(_barVisible(tester), isFalse);
  });
}
