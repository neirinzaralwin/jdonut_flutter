import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/main_flow.dart';
import 'helpers/real_fonts.dart';

/// The brief: portrait phones 4.7"–6.9", text scale up to 1.3, no overflow.
/// Walks every screen of the main flow on the smallest and largest phone at
/// 1.3 with the real fonts. Any overflow is a Flutter error, which fails the
/// test with the screen it happened on.
void main() {
  setUpAll(loadRealFonts);
  setUp(_stubPlatformPlugins);

  const maxTextScale = 1.3;
  final phones = {
    'iPhone SE 4.7"': const Size(375, 667),
    'iPhone 16 Pro Max 6.9"': const Size(440, 956),
  };

  for (final MapEntry(key: name, value: size) in phones.entries) {
    testWidgets('every screen fits on $name at text scale 1.3', (tester) async {
      tester.view
        ..physicalSize = size * 3
        ..devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = maxTextScale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await launchFreshApp(tester);
      await registerNewUser(tester);
      await openCoconutDonut(tester);
      await visitRewardsAndSettings(tester);

      // Unmount so the carousel's timer doesn't outlive the test.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(_timerDrain);
    });
  }
}

const Duration _timerDrain = Duration(seconds: 6);

/// Plugins that only exist on a device: report "offline" and give the image
/// cache a temp folder. Everything else in the app is real.
void _stubPlatformPlugins() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final (channel, reply) in [
    ('dev.fluttercommunity.plus/connectivity', <String>['none']),
    ('dev.fluttercommunity.plus/connectivity_status', null),
    ('plugins.flutter.io/path_provider', '/tmp/jdonut_test_cache'),
  ]) {
    messenger.setMockMethodCallHandler(
      MethodChannel(channel),
      (_) async => reply,
    );
  }
}
