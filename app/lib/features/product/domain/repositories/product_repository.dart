import 'package:jdonut/features/product/domain/entities/product.dart';

abstract interface class ProductRepository {
  /// Emits the product from the local DB; `null` if it doesn't exist.
  Stream<Product?> watchProduct(String id);
}
