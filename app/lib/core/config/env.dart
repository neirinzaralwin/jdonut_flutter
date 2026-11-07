/// Mock server base URL. Override: --dart-define=API_BASE_URL=http://10.0.2.2:3000
abstract final class Env {
  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');
  static const String apiVersionPath = '/v1';
}
