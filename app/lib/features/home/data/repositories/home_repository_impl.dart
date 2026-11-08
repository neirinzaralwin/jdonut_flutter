import 'package:drift/drift.dart';
import 'package:jdonut/core/database/app_database.dart';
import 'package:jdonut/features/home/domain/entities/home_banner.dart';
import 'package:jdonut/features/home/domain/entities/home_section.dart';
import 'package:jdonut/features/home/domain/entities/shop.dart';
import 'package:jdonut/features/home/domain/repositories/home_repository.dart';
import 'package:jdonut/features/product/product.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Stream<List<HomeBanner>> watchBanners() {
    final query = _database.select(_database.banners)
      ..orderBy([(banner) => OrderingTerm.asc(banner.sortOrder)]);
    return query.watch().map((rows) => rows.map(_toBanner).toList());
  }

  @override
  Stream<List<HomeSection>> watchSections() {
    final db = _database;
    final query =
        db.select(db.sections).join([
          leftOuterJoin(
            db.sectionProducts,
            db.sectionProducts.sectionId.equalsExp(db.sections.id),
          ),
          leftOuterJoin(
            db.products,
            db.products.id.equalsExp(db.sectionProducts.productId),
          ),
        ])..orderBy([
          OrderingTerm.asc(db.sections.sortOrder),
          OrderingTerm.asc(db.sectionProducts.position),
        ]);
    return query.watch().map(_groupSections);
  }

  @override
  Stream<List<Shop>> watchShops() {
    final query = _database.select(_database.shops)
      ..orderBy([(shop) => OrderingTerm.asc(shop.distanceKm)]);
    return query.watch().map((rows) => rows.map(_toShop).toList());
  }

  /// Joined rows (one per section × product) → sections with product lists.
  List<HomeSection> _groupSections(List<TypedResult> rows) {
    final sections = <String, HomeSection>{};
    for (final row in rows) {
      final section = row.readTable(_database.sections);
      final product = row.readTableOrNull(_database.products)?.toEntity();
      final current =
          sections[section.id] ??
          HomeSection(
            id: section.id,
            title: section.title,
            layout: SectionLayout.fromId(section.layout),
            products: const [],
          );
      sections[section.id] = product == null
          ? current
          : current.copyWith(products: [...current.products, product]);
    }
    return sections.values.toList();
  }

  HomeBanner _toBanner(BannerRow row) => HomeBanner(
    id: row.id,
    title: row.title,
    subtitle: row.subtitle,
    imageUrl: row.imageUrl,
    assetPath: row.assetPath,
    productId: row.productId,
  );

  Shop _toShop(ShopRow row) => Shop(
    id: row.id,
    name: row.name,
    address: row.address,
    distanceKm: row.distanceKm,
    openHours: row.openHours,
    imageUrl: row.imageUrl,
    assetPath: row.assetPath,
  );
}
