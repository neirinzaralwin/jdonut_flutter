import 'package:jdonut/core/database/catalog_writer.dart';
import 'package:jdonut/core/error/failure.dart';
import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/core/images/image_prefetcher.dart';
import 'package:jdonut/core/network/api_paths.dart';
import 'package:jdonut/features/home/data/datasources/catalog_remote_data_source.dart';
import 'package:jdonut/features/home/domain/repositories/catalog_sync_repository.dart';

class CatalogSyncRepositoryImpl implements CatalogSyncRepository {
  const CatalogSyncRepositoryImpl({
    required CatalogRemoteDataSource remote,
    required CatalogWriter writer,
    required ImagePrefetcher prefetcher,
  }) : _remote = remote,
       _writer = writer,
       _prefetcher = prefetcher;

  final CatalogRemoteDataSource _remote;
  final CatalogWriter _writer;
  final ImagePrefetcher _prefetcher;

  @override
  Future<Result<void>> refresh() async {
    final fetched = await _remote.fetchCatalog();
    if (fetched case Err(:final failure)) return Err(failure);
    final catalog = (fetched as Ok<CatalogPayload>).value;
    try {
      await _writer.replaceCatalog(
        products: catalog.products,
        banners: catalog.banners,
        sections: catalog.sections,
        shops: catalog.shops,
      );
    } on FormatException catch (error) {
      return Err(ServerFailure('Malformed catalog: ${error.message}'));
      // A field with the wrong JSON type fails its cast with a TypeError.
      // It is server data, not a bug in our code, so keep the old cache.
      // ignore: avoid_catching_errors
    } on TypeError catch (error) {
      return Err(ServerFailure('Malformed catalog: $error'));
    } on Exception catch (error) {
      return Err(CacheFailure('Could not save catalog: $error'));
    }
    await _prefetcher.prefetch(_imageUrls(catalog));
    return const Ok(null);
  }

  Iterable<String> _imageUrls(CatalogPayload catalog) => [
    ...catalog.products,
    ...catalog.banners,
    ...catalog.shops,
  ].map((json) => ApiPaths.resolve(json['imageUrl'] as String?)).nonNulls;
}
