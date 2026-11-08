import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_banner.freezed.dart';

@freezed
abstract class HomeBanner with _$HomeBanner {
  const factory HomeBanner({
    required String id,
    required String title,
    String? subtitle,
    String? imageUrl,
    String? assetPath,
    String? productId,
  }) = _HomeBanner;
}
