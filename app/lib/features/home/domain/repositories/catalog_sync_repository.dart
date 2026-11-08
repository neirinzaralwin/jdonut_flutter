import 'package:jdonut/core/error/result.dart';

/// Pulls the public catalog from the server into the local DB.
/// The UI never reads the network directly; it re-renders from the DB.
abstract interface class CatalogSyncRepository {
  Future<Result<void>> refresh();
}
