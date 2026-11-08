import 'package:jdonut/core/database/app_database.dart';
import 'package:jdonut/features/product/data/product_mapper.dart';
import 'package:jdonut/features/product/domain/entities/product.dart';
import 'package:jdonut/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Stream<Product?> watchProduct(String id) {
    final query = _database.select(_database.products)
      ..where((product) => product.id.equals(id));
    return query.watchSingleOrNull().map((row) => row?.toEntity());
  }
}
