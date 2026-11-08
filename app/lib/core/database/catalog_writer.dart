import 'package:jdonut/core/database/app_database.dart';
import 'package:jdonut/core/database/seed/seed_mappers.dart';

/// Replaces the public catalog (products, banners, sections, shops) in one
/// transaction. Used by first-launch seeding and by server sync, so both
/// paths write exactly the same way. Rows missing from the new data are
/// removed; a mapping error rolls everything back and keeps the old cache.
class CatalogWriter {
  const CatalogWriter(this._database);

  final AppDatabase _database;

  Future<void> replaceCatalog({
    required List<Json> products,
    required List<Json> banners,
    required List<Json> sections,
    required List<Json> shops,
  }) {
    final db = _database;
    // Map first: a FormatException here leaves the DB untouched.
    final productRows = products.map(productFromJson).toList();
    final bannerRows = banners.map(bannerFromJson).toList();
    final sectionRows = sections.map(sectionFromJson).toList();
    final linkRows = sections.expand(sectionProductsFromJson).toList();
    final shopRows = shops.map(shopFromJson).toList();
    return db.transaction(
      () => db.batch((batch) {
        batch
          ..deleteAll(db.sectionProducts)
          ..deleteAll(db.sections)
          ..deleteAll(db.banners)
          ..deleteAll(db.products)
          ..deleteAll(db.shops)
          ..insertAll(db.products, productRows)
          ..insertAll(db.banners, bannerRows)
          ..insertAll(db.sections, sectionRows)
          ..insertAll(db.sectionProducts, linkRows)
          ..insertAll(db.shops, shopRows);
      }),
    );
  }
}
