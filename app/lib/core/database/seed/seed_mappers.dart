import 'package:drift/drift.dart';
import 'package:jdonut/core/database/app_database.dart';

/// JSON (seed files and the `/v1` API share one shape) → Drift rows.
/// Throws [FormatException] on malformed data, so callers keep the cache.
typedef Json = Map<String, dynamic>;

ProductsCompanion productFromJson(Json json) => ProductsCompanion.insert(
  id: _string(json, 'id'),
  code: _string(json, 'code'),
  name: _string(json, 'name'),
  priceMmk: _int(json, 'priceMmk'),
  isNew: Value(json['isNew'] as bool? ?? false),
  discountPercent: Value(json['discountPercent'] as int?),
  imageUrl: Value(json['imageUrl'] as String?),
  assetPath: Value(json['assetPath'] as String?),
  description: _string(json, 'description'),
);

BannersCompanion bannerFromJson(Json json) => BannersCompanion.insert(
  id: _string(json, 'id'),
  title: _string(json, 'title'),
  subtitle: Value(json['subtitle'] as String?),
  imageUrl: Value(json['imageUrl'] as String?),
  assetPath: Value(json['assetPath'] as String?),
  productId: Value(json['productId'] as String?),
  sortOrder: _int(json, 'order'),
);

SectionsCompanion sectionFromJson(Json json) => SectionsCompanion.insert(
  id: _string(json, 'id'),
  title: _string(json, 'title'),
  layout: _string(json, 'layout'),
  sortOrder: _int(json, 'order'),
);

List<SectionProductsCompanion> sectionProductsFromJson(Json json) {
  final sectionId = _string(json, 'id');
  final productIds = (json['productIds'] as List<dynamic>).cast<String>();
  return [
    for (final (position, productId) in productIds.indexed)
      SectionProductsCompanion.insert(
        sectionId: sectionId,
        productId: productId,
        position: position,
      ),
  ];
}

ShopsCompanion shopFromJson(Json json) => ShopsCompanion.insert(
  id: _string(json, 'id'),
  name: _string(json, 'name'),
  address: _string(json, 'address'),
  distanceKm: (json['distanceKm'] as num).toDouble(),
  openHours: _string(json, 'openHours'),
  imageUrl: Value(json['imageUrl'] as String?),
  assetPath: Value(json['assetPath'] as String?),
);

MembersCompanion memberFromJson(Json json) => MembersCompanion.insert(
  id: _string(json, 'id'),
  tier: _string(json, 'tier'),
  nextTier: Value(json['nextTier'] as String?),
  points: _int(json, 'points'),
  tierProgress: (json['tierProgress'] as num).toDouble(),
  amountToNextTierMmk: _int(json, 'amountToNextTierMmk'),
  notificationCount: _int(json, 'notificationCount'),
  rewardsCount: _int(json, 'rewardsCount'),
  photoAssetPath: Value(json['photoAssetPath'] as String?),
);

String _string(Json json, String key) => switch (json[key]) {
  final String value => value,
  _ => throw FormatException('Missing string "$key"', json),
};

int _int(Json json, String key) => switch (json[key]) {
  final int value => value,
  _ => throw FormatException('Missing int "$key"', json),
};
