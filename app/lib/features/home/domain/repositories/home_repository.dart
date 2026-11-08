import 'package:jdonut/features/home/domain/entities/home_banner.dart';
import 'package:jdonut/features/home/domain/entities/home_section.dart';
import 'package:jdonut/features/home/domain/entities/shop.dart';

/// Home data, read from the local DB (single source of truth).
abstract interface class HomeRepository {
  Stream<List<HomeBanner>> watchBanners();
  Stream<List<HomeSection>> watchSections();
  Stream<List<Shop>> watchShops();
}
