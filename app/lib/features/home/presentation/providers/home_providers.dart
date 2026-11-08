import 'package:jdonut/core/database/database_provider.dart';
import 'package:jdonut/features/home/data/repositories/home_repository_impl.dart';
import 'package:jdonut/features/home/domain/entities/home_banner.dart';
import 'package:jdonut/features/home/domain/entities/home_section.dart';
import 'package:jdonut/features/home/domain/entities/shop.dart';
import 'package:jdonut/features/home/domain/repositories/home_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

@Riverpod(keepAlive: true)
HomeRepository homeRepository(Ref ref) =>
    HomeRepositoryImpl(ref.watch(appDatabaseProvider));

@riverpod
Stream<List<HomeBanner>> homeBanners(Ref ref) =>
    ref.watch(homeRepositoryProvider).watchBanners();

@riverpod
Stream<List<HomeSection>> homeSections(Ref ref) =>
    ref.watch(homeRepositoryProvider).watchSections();

@riverpod
Stream<List<Shop>> nearbyShops(Ref ref) =>
    ref.watch(homeRepositoryProvider).watchShops();
