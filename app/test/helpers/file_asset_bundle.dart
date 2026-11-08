import 'dart:io';

import 'package:flutter/services.dart';

/// Reads assets straight from the project folder (for non-widget tests).
class FileAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(await File(key).readAsBytes()));
}
