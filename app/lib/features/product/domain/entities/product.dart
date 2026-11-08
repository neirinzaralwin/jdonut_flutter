import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String code,
    required String name,
    required int priceMmk,
    required String description,
    @Default(false) bool isNew,
    int? discountPercent,
    String? imageUrl,
    String? assetPath,
  }) = _Product;
}
