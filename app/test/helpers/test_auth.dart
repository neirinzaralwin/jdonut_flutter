import 'package:drift/native.dart';
import 'package:jdonut/core/database/app_database.dart';
import 'package:jdonut/features/auth/data/repositories/fake_auth_repository.dart';

import 'in_memory_session_store.dart';

final DateTime testToday = DateTime(2026, 11, 8);

/// The real fake repository on an in-memory DB, with no delay.
class TestAuth {
  TestAuth()
    : database = AppDatabase(NativeDatabase.memory()),
      session = InMemorySessionStore() {
    repository = FakeAuthRepository(
      database: database,
      sessionStore: session,
      clock: () => testToday,
      delay: Duration.zero,
    );
  }

  final AppDatabase database;
  final InMemorySessionStore session;
  late final FakeAuthRepository repository;

  Future<void> dispose() => database.close();
}
