import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/app.dart';

void main() {
  testWidgets('renders the app shell', (tester) async {
    await tester.pumpWidget(const JDonutApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
