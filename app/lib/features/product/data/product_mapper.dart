import 'package:jdonut/core/database/app_database.dart';
import 'package:jdonut/features/product/domain/entities/product.dart';

extension ProductRowMapper on ProductRow {
  Product toEntity() => Product(
    id: id,
    code: code,
    name: name,
    priceMmk: priceMmk,
    description: description,
    isNew: isNew,
    discountPercent: discountPercent,
    imageUrl: imageUrl,
    assetPath: assetPath,
  );
}
