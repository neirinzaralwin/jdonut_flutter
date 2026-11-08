import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:jdonut/core/database/app_database.dart';
import 'package:jdonut/core/database/catalog_writer.dart';
import 'package:jdonut/core/database/seed/seed_mappers.dart';

/// First-launch seeding (brief Task 2): bundled JSON → Drift, in one
/// transaction, so the app works fully offline from the very first open.
/// Re-seeds only when [seedVersion] changes.
class SeedService {
  const SeedService(this._database, this._bundle);

  final AppDatabase _database;
  final AssetBundle _bundle;

  static const int seedVersion = 3;
  static const String _versionKey = 'seed_version';
  static const String _seedDirectory = 'assets/seed';

  Future<void> seedIfNeeded() async {
    if (await _storedVersion() == seedVersion) return;
    final files = await Future.wait([
      for (final name in ['products', 'banners', 'sections', 'shops', 'member'])
        _load(name),
    ]);
    final data = (
      products: (files[0] as List<dynamic>).cast<Json>(),
      banners: (files[1] as List<dynamic>).cast<Json>(),
      sections: (files[2] as List<dynamic>).cast<Json>(),
      shops: (files[3] as List<dynamic>).cast<Json>(),
      member: (files[4] as Json)['member'] as Json,
    );
    final db = _database;
    await db.transaction(() async {
      await CatalogWriter(db).replaceCatalog(
        products: data.products,
        banners: data.banners,
        sections: data.sections,
        shops: data.shops,
      );
      await db.batch((batch) {
        batch
          ..insert(
            db.members,
            memberFromJson(data.member),
            mode: InsertMode.insertOrReplace,
          )
          ..insert(
            db.appMeta,
            AppMetaCompanion.insert(key: _versionKey, value: '$seedVersion'),
            mode: InsertMode.insertOrReplace,
          );
      });
    });
  }

  Future<int?> _storedVersion() async {
    final query = _database.select(_database.appMeta)
      ..where((meta) => meta.key.equals(_versionKey));
    final row = await query.getSingleOrNull();
    return row == null ? null : int.tryParse(row.value);
  }

  /// Each seed file is `{version, updatedAt, data}`.
  Future<Object> _load(String name) async {
    final raw = await _bundle.loadString('$_seedDirectory/$name.json');
    return switch ((jsonDecode(raw) as Json)['data']) {
      final Object data => data,
      null => throw FormatException('Seed file $name has no data'),
    };
  }
}
