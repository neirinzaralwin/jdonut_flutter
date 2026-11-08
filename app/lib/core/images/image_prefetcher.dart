import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Downloads images right after a sync, so new products show their images
/// offline even if nobody opened them while online.
class ImagePrefetcher {
  const ImagePrefetcher(this._cache);

  final BaseCacheManager _cache;

  static const int _parallelDownloads = 4;

  /// Best effort: a failed download just falls back to the bundled asset.
  Future<void> prefetch(Iterable<String> urls) async {
    final queue = urls.toSet().toList();
    for (var start = 0; start < queue.length; start += _parallelDownloads) {
      final batch = queue.skip(start).take(_parallelDownloads);
      await Future.wait(batch.map(_download));
    }
  }

  Future<void> _download(String url) async {
    try {
      await _cache.downloadFile(url);
    } on Exception {
      // Offline or 404: the UI keeps using the bundled asset.
    }
  }
}
