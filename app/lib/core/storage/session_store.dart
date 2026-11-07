import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the signed-in user id. The only place that touches secure storage.
abstract interface class SessionStore {
  Future<String?> readUserId();
  Future<void> writeUserId(String userId);
  Future<void> clear();
}

class SecureSessionStore implements SessionStore {
  const SecureSessionStore(this._storage);

  final FlutterSecureStorage _storage;
  static const String _userIdKey = 'session_user_id';

  @override
  Future<String?> readUserId() => _storage.read(key: _userIdKey);

  @override
  Future<void> writeUserId(String userId) =>
      _storage.write(key: _userIdKey, value: userId);

  @override
  Future<void> clear() => _storage.delete(key: _userIdKey);
}
