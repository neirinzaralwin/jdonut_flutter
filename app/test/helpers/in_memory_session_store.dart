import 'package:jdonut/core/storage/session_store.dart';

class InMemorySessionStore implements SessionStore {
  String? userId;

  /// Makes the next write throw, to test rollback.
  bool failNextWrite = false;

  @override
  Future<String?> readUserId() async => userId;

  @override
  Future<void> writeUserId(String userId) async {
    if (failNextWrite) {
      failNextWrite = false;
      throw Exception('secure storage unavailable');
    }
    this.userId = userId;
  }

  @override
  Future<void> clear() async => userId = null;
}
