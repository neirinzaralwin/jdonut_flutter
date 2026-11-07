import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:jdonut/core/database/tables/users_table.dart';

part 'app_database.g.dart';

/// Single local database — the app's source of truth.
/// Bump [schemaVersion] and add a step in [migration] for every schema change.
@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: _databaseName));

  static const String _databaseName = 'jdonut';

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    // Version steps go here, e.g. `if (from < 2) await m.addColumn(...)`.
    onUpgrade: (migrator, from, to) async {},
  );
}
