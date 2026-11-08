import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/constants/app_assets.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/app_image.dart';

void main() {
  Future<void> pumpImage(WidgetTester tester, AppImage image) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: SizedBox.square(dimension: 200, child: image),
        ),
      );

  bool showsLogoFallback() => find
      .byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == AppAssets.logoTransparent,
      )
      .evaluate()
      .isNotEmpty;

  testWidgets('no cached, network or bundled image → grayscale app logo', (
    tester,
  ) async {
    await pumpImage(tester, const AppImage(assetPath: null));

    expect(showsLogoFallback(), isTrue);
    expect(find.byType(ColorFiltered), findsOneWidget);
  });

  testWidgets('a bundled asset is shown when there is no URL', (tester) async {
    await pumpImage(
      tester,
      const AppImage(assetPath: 'assets/images/products/p_coconut.jpg'),
    );

    expect(showsLogoFallback(), isFalse);
  });
}
