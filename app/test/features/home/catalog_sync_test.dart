import 'package:drift/native.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/database/app_database.dart';
import 'package:jdonut/core/database/catalog_writer.dart';
import 'package:jdonut/core/database/seed/seed_service.dart';
import 'package:jdonut/core/error/failure.dart';
import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/core/images/image_prefetcher.dart';
import 'package:jdonut/core/network/api_client.dart';
import 'package:jdonut/features/home/data/datasources/catalog_remote_data_source.dart';
import 'package:jdonut/features/home/data/repositories/catalog_sync_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/file_asset_bundle.dart';

class _MockCache extends Mock implements BaseCacheManager {}

class _MockApiClient extends Mock implements ApiClient {}

/// Remote that returns whatever the test sets.
class _FakeRemote extends CatalogRemoteDataSource {
  _FakeRemote() : super(_MockApiClient());

  Result<CatalogPayload> next = const Err(NetworkFailure());

  @override
  Future<Result<CatalogPayload>> fetchCatalog() async => next;
}

Map<String, dynamic> _product(String id, {Object price = 3000}) => {
  'id': id,
  'code': 'JD-$id',
  'name': 'Donut $id',
  'priceMmk': price,
  'isNew': false,
  'discountPercent': null,
  'imageUrl': '/static/images/products/$id.jpg',
  'assetPath': null,
  'description': 'desc',
};

void main() {
  late AppDatabase database;
  late _FakeRemote remote;
  late _MockCache cache;
  late CatalogSyncRepositoryImpl sync;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await SeedService(database, FileAssetBundle()).seedIfNeeded();
    remote = _FakeRemote();
    cache = _MockCache();
    when(() => cache.downloadFile(any())).thenThrow(Exception('offline'));
    sync = CatalogSyncRepositoryImpl(
      remote: remote,
      writer: CatalogWriter(database),
      prefetcher: ImagePrefetcher(cache),
    );
  });
  tearDown(() => database.close());

  Future<List<String>> productIds() async =>
      (await database.select(database.products).get())
          .map((p) => p.id)
          .toList();

  test(
    'a successful refresh replaces the catalog and drops removed items',
    () async {
      remote.next = Ok((
        products: [_product('p_new')],
        banners: [],
        sections: [
          {
            'id': 'popular',
            'title': 'Popular',
            'layout': 'standard',
            'order': 1,
            'productIds': ['p_new'],
          },
        ],
        shops: [],
      ));

      expect(await sync.refresh(), isA<Ok<void>>());
      expect(await productIds(), ['p_new']);
    },
  );

  test('downloads new images; a failed download is not an error', () async {
    remote.next = Ok((
      products: [_product('p_new')],
      banners: [],
      sections: [],
      shops: [],
    ));

    expect(await sync.refresh(), isA<Ok<void>>());
    verify(
      () => cache.downloadFile(
        any(that: endsWith('/static/images/products/p_new.jpg')),
      ),
    ).called(1);
  });

  test('offline keeps the cached catalog', () async {
    final before = await productIds();

    final result = await sync.refresh();

    expect((result as Err<void>).failure, isA<NetworkFailure>());
    expect(await productIds(), before);
  });

  test('malformed server data keeps the cached catalog', () async {
    final before = await productIds();
    remote.next = Ok((
      products: [_product('p_bad', price: 'not a number')],
      banners: [],
      sections: [],
      shops: [],
    ));

    final result = await sync.refresh();

    expect((result as Err<void>).failure, isA<ServerFailure>());
    expect(await productIds(), before);
  });
}
