import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the bundled fonts. The default test font has different metrics and
/// would hide (or invent) overflows.
Future<void> loadRealFonts() async {
  for (final (family, asset) in [
    ('Nunito', 'assets/fonts/Nunito-Variable.ttf'),
    ('NunitoSans', 'assets/fonts/NunitoSans-Variable.ttf'),
  ]) {
    final bytes = File(asset).readAsBytesSync();
    await (FontLoader(
      family,
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }
}
