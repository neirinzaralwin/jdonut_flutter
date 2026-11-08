import 'package:drift/drift.dart';

/// Public catalog data — seeded from assets, refreshed from the server later.
@DataClassName('ProductRow')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  IntColumn get priceMmk => integer()();
  BoolColumn get isNew => boolean().withDefault(const Constant(false))();
  IntColumn get discountPercent => integer().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get assetPath => text().nullable()();
  TextColumn get description => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('BannerRow')
class Banners extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get assetPath => text().nullable()();
  TextColumn get productId => text().nullable()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SectionRow')
class Sections extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get layout => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Which products appear in a section, in order.
@DataClassName('SectionProductRow')
class SectionProducts extends Table {
  TextColumn get sectionId => text().references(Sections, #id)();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get position => integer()();

  @override
  Set<Column<Object>> get primaryKey => {sectionId, productId};
}

@DataClassName('ShopRow')
class Shops extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text()();
  RealColumn get distanceKm => real()();
  TextColumn get openHours => text()();

  /// Added in schema v3 (shop photos).
  TextColumn get imageUrl => text().nullable()();
  TextColumn get assetPath => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
