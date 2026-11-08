import 'package:jdonut/core/database/seed/seed_mappers.dart';
import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/core/network/api_client.dart';
import 'package:jdonut/core/network/api_paths.dart';

typedef CatalogPayload = ({
  List<Json> products,
  List<Json> banners,
  List<Json> sections,
  List<Json> shops,
});

/// `/v1` catalog endpoints. All four must succeed, so the DB is never
/// updated with a half catalog.
class CatalogRemoteDataSource {
  const CatalogRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Result<CatalogPayload>> fetchCatalog() async {
    final results = await Future.wait([
      _client.get(ApiPaths.products, _list),
      _client.get(ApiPaths.banners, _list),
      _client.get(ApiPaths.sections, _list),
      _client.get(ApiPaths.shops, _list),
    ]);
    for (final result in results) {
      if (result case Err(:final failure)) return Err(failure);
    }
    final [products, banners, sections, shops] = [
      for (final result in results) (result as Ok<List<Json>>).value,
    ];
    return Ok((
      products: products,
      banners: banners,
      sections: sections,
      shops: shops,
    ));
  }

  /// Every item must be a JSON object; anything else is malformed.
  static List<Json> _list(Object data) {
    if (data is! List<dynamic>) throw const FormatException('Expected a list');
    return [
      for (final item in data)
        if (item is Json) item else throw const FormatException('Bad item'),
    ];
  }
}
