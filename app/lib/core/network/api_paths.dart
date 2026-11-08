import 'package:jdonut/core/config/env.dart';

/// Every `/v1` endpoint in one place.
abstract final class ApiPaths {
  static const String health = '/health';
  static const String products = '/products';
  static const String banners = '/banners';
  static const String sections = '/sections';
  static const String shops = '/shops';

  /// Server image paths are relative (`/static/...`); make them absolute.
  static String? resolve(String? path) {
    if (path == null || path.isEmpty) return null;
    return path.startsWith('http') ? path : '${Env.apiBaseUrl}$path';
  }
}
