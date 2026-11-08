import 'package:jdonut/core/database/database_provider.dart';
import 'package:jdonut/features/product/data/repositories/product_repository_impl.dart';
import 'package:jdonut/features/product/domain/cart_quantity.dart';
import 'package:jdonut/features/product/domain/entities/product.dart';
import 'package:jdonut/features/product/domain/repositories/product_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_providers.g.dart';

@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) =>
    ProductRepositoryImpl(ref.watch(appDatabaseProvider));

@riverpod
Stream<Product?> productDetail(Ref ref, String id) =>
    ref.watch(productRepositoryProvider).watchProduct(id);

/// Quantity on the Product detail screen (screen-scoped, per product).
@riverpod
class ProductQuantity extends _$ProductQuantity {
  @override
  int build(String productId) => CartQuantity.initial;

  void increment() => state = CartQuantity.increment(state);

  void decrement() => state = CartQuantity.decrement(state);
}
