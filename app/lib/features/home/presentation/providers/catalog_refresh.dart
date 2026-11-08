import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jdonut/core/database/catalog_writer.dart';
import 'package:jdonut/core/database/database_provider.dart';
import 'package:jdonut/core/error/failure.dart';
import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/core/images/app_image_cache.dart';
import 'package:jdonut/core/images/image_prefetcher.dart';
import 'package:jdonut/core/network/network_providers.dart';
import 'package:jdonut/core/network/network_status.dart';
import 'package:jdonut/features/home/data/datasources/catalog_remote_data_source.dart';
import 'package:jdonut/features/home/data/repositories/catalog_sync_repository_impl.dart';
import 'package:jdonut/features/home/domain/repositories/catalog_sync_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalog_refresh.freezed.dart';
part 'catalog_refresh.g.dart';

@Riverpod(keepAlive: true)
CatalogSyncRepository catalogSyncRepository(Ref ref) =>
    CatalogSyncRepositoryImpl(
      remote: CatalogRemoteDataSource(ref.watch(apiClientProvider)),
      writer: CatalogWriter(ref.watch(appDatabaseProvider)),
      prefetcher: ImagePrefetcher(AppImageCache.instance),
    );

@freezed
abstract class SyncStatus with _$SyncStatus {
  const factory SyncStatus({
    @Default(false) bool isSyncing,
    DateTime? lastSyncedAt,
    Failure? lastFailure,
  }) = _SyncStatus;
}

/// One refresh at a time; background and pull-to-refresh share it.
@Riverpod(keepAlive: true)
class CatalogRefresh extends _$CatalogRefresh {
  Future<Result<void>>? _inFlight;

  @override
  SyncStatus build() => const SyncStatus();

  Future<Result<void>> refresh() =>
      _inFlight ??= _run().whenComplete(() => _inFlight = null);

  Future<Result<void>> _run() async {
    state = state.copyWith(isSyncing: true);
    final result = await ref.read(catalogSyncRepositoryProvider).refresh();
    state = switch (result) {
      Ok() => SyncStatus(lastSyncedAt: DateTime.now()),
      Err(:final failure) => state.copyWith(
        isSyncing: false,
        lastFailure: failure,
      ),
    };
    return result;
  }
}

/// Background refresh: on app start when online, and every time the
/// connection comes back. Kept alive from bootstrap.
@Riverpod(keepAlive: true)
void backgroundCatalogSync(Ref ref) {
  ref.listen(networkStatusProvider, (previous, next) {
    final wasOnline = previous?.value == NetworkStatus.online;
    if (next.value == NetworkStatus.online && !wasOnline) {
      unawaited(ref.read(catalogRefreshProvider.notifier).refresh());
    }
  }, fireImmediately: true);
}
