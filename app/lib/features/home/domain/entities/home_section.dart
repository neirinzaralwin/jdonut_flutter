import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jdonut/features/product/product.dart';

part 'home_section.freezed.dart';

/// `featured` = wide cards (Seasonal specials), `standard` = tall cards.
enum SectionLayout {
  featured,
  standard;

  static SectionLayout fromId(String id) =>
      values.where((layout) => layout.name == id).firstOrNull ?? standard;
}

@freezed
abstract class HomeSection with _$HomeSection {
  const factory HomeSection({
    required String id,
    required String title,
    required SectionLayout layout,
    required List<Product> products,
  }) = _HomeSection;
}
