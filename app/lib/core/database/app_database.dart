import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:jdonut/core/database/tables/catalog_tables.dart';
import 'package:jdonut/core/database/tables/member_tables.dart';
import 'package:jdonut/core/database/tables/users_table.dart';

part 'app_database.g.dart';

/// Single local database — the app's source of truth.
/// Bump [schemaVersion] and add a step in [migration] for every schema change.
@DriftDatabase(
  tables: [
    Users,
    Products,
    Banners,
    Sections,
    SectionProducts,
    Shops,
    Members,
    AppMeta,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: _databaseName));

  static const String _databaseName = 'jdonut';

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      // v2: catalog, shops, member and meta tables (Home, Task 2).
      if (from < 2) {
        final newTables = <TableInfo<Table, dynamic>>[
          products,
          banners,
          sections,
          sectionProducts,
          shops,
          members,
          appMeta,
        ];
        for (final table in newTables) {
          await migrator.createTable(table);
        }
      }
      // v3: shop photos. Tables created just above already have them.
      if (from == 2) {
        await migrator.addColumn(shops, shops.imageUrl);
        await migrator.addColumn(shops, shops.assetPath);
      }
    },
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
