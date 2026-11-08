import 'dart:io';

/// Mock server address. Defaults work out of the box:
/// Android emulator → `10.0.2.2` (the host machine), iOS simulator →
/// `localhost`. Real device or other host:
/// `--dart-define=API_BASE_URL=http://192.168.1.10:3000`
abstract final class Env {
  static const String _definedBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _androidEmulatorHost = 'http://10.0.2.2:3000';
  static const String _localHost = 'http://localhost:3000';

  static String get apiBaseUrl {
    if (_definedBaseUrl.isNotEmpty) return _definedBaseUrl;
    return Platform.isAndroid ? _androidEmulatorHost : _localHost;
  }

  static const String apiVersionPath = '/v1';

  /// Debug only: start without the bundled catalog (products, banners,
  /// sections, shops), to see the empty states or data that comes only from
  /// the mock server. The member and challenges are still loaded.
  /// `flutter run --dart-define=SKIP_SEED=true`
  static const bool skipCatalogSeed = bool.fromEnvironment('SKIP_SEED');
}
