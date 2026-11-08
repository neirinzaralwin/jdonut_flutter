import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Disk cache for server images (brief: cache images on disk). Files
/// survive restarts, so images keep showing in airplane mode.
/// A changed image must get a new URL (file name) — the URL is the key.
class AppImageCache {
  AppImageCache._();

  static const String _key = 'jdonut_images';
  static const Duration _keepFor = Duration(days: 30);
  static const int _maxFiles = 300;

  static final CacheManager instance = CacheManager(
    Config(_key, stalePeriod: _keepFor, maxNrOfCacheObjects: _maxFiles),
  );
}
