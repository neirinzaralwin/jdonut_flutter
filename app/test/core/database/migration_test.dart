import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/database/app_database.dart';

void main() {
  test('v2 → latest keeps shops, adds photo columns, renames member points '
      'and creates challenges', () async {
    // The tables as schema v2 left them.
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
          ..execute(
            'CREATE TABLE members (id TEXT NOT NULL PRIMARY KEY, '
            'tier TEXT NOT NULL, next_tier TEXT, points INTEGER NOT NULL, '
            'tier_progress REAL NOT NULL, '
            'amount_to_next_tier_mmk INTEGER NOT NULL, '
            'notification_count INTEGER NOT NULL, '
            'rewards_count INTEGER NOT NULL, photo_asset_path TEXT)',
          )
          ..execute(
            "INSERT INTO members VALUES ('m1', 'silver', 'gold', 680000, "
            '0.62, 500, 3, 3, NULL)',
          )
          ..execute('PRAGMA user_version = 2'),
      ),
    );

    final shop = (await database.select(database.shops).get()).single;
    final member = (await database.select(database.members).get()).single;
    final challenges = await database.select(database.challenges).get();

    expect(shop.id, 's1');
    expect(shop.assetPath, isNull);
    expect(member.pointsToNextTier, 500);
    expect(challenges, isEmpty);
    await database.close();
  });
}
