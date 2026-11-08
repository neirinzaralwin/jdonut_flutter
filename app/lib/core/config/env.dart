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
}
