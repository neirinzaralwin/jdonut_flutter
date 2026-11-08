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

  static const int seedVersion = 4;
  static const String _versionKey = 'seed_version';
  static const String _seedDirectory = 'assets/seed';

  /// [withCatalog] false (debug `SKIP_SEED`) loads only the member and
  /// challenges, and doesn't record the seed version — so a normal run later
  /// still seeds the catalog.
  Future<void> seedIfNeeded({bool withCatalog = true}) async {
    if (await _storedVersion() == seedVersion) return;
    final data = await _loadAll();
    await _database.transaction(() async {
      if (withCatalog) {
        await CatalogWriter(_database).replaceCatalog(
          products: data.products,
          banners: data.banners,
          sections: data.sections,
          shops: data.shops,
        );
      }
      await _writeMember(data.member, data.challenges, markSeeded: withCatalog);
    });
  }

  Future<_SeedData> _loadAll() async {
    final files = await Future.wait([
      for (final name in ['products', 'banners', 'sections', 'shops', 'member'])
        _load(name),
    ]);
    List<Json> list(Object file) => (file as List<dynamic>).cast<Json>();
    final member = files[4] as Json;
    return (
      products: list(files[0]),
      banners: list(files[1]),
      sections: list(files[2]),
      shops: list(files[3]),
      member: member['member'] as Json,
      challenges: list(member['challenges'] as Object),
    );
  }

  /// The member, their challenges, and the seed version, in one batch.
  Future<void> _writeMember(
    Json member,
    List<Json> challenges, {
    required bool markSeeded,
  }) {
    final db = _database;
    return db.batch((batch) {
      batch
        ..deleteAll(db.challenges)
        ..insertAll(db.challenges, challenges.map(challengeFromJson))
        ..insert(
          db.members,
          memberFromJson(member),
          mode: InsertMode.insertOrReplace,
        );
      if (markSeeded) {
        batch.insert(
          db.appMeta,
          AppMetaCompanion.insert(key: _versionKey, value: '$seedVersion'),
          mode: InsertMode.insertOrReplace,
        );
      }
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

typedef _SeedData = ({
  List<Json> products,
  List<Json> banners,
  List<Json> sections,
  List<Json> shops,
  Json member,
  List<Json> challenges,
});
