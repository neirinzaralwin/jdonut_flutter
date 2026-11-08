import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/database/app_database.dart';

void main() {
  test('v2 → v3 adds shop photo columns and keeps existing shops', () async {
    // A database as v2 left it: shops without image columns.
    final database = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) => raw
          ..execute(
            'CREATE TABLE shops (id TEXT NOT NULL PRIMARY KEY, '
            'name TEXT NOT NULL, address TEXT NOT NULL, '
            'distance_km REAL NOT NULL, open_hours TEXT NOT NULL)',
          )
          ..execute(
            "INSERT INTO shops VALUES ('s1', 'Shop', 'Road', 1.0, '9-5')",
          )
          ..execute('PRAGMA user_version = 2'),
      ),
    );

    final shops = await database.select(database.shops).get();

    expect(shops.single.id, 's1');
    expect(shops.single.assetPath, isNull);
    await database.close();
  });
}
