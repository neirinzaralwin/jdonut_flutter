import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/features/home/domain/entities/home_section.dart';
import 'package:jdonut/features/home/presentation/widgets/product_tile.dart';
import 'package:jdonut/features/home/presentation/widgets/section_header.dart';

/// A titled horizontal row of product tiles.
class ProductSection extends StatelessWidget {
  const ProductSection({required this.section, super.key});

  final HomeSection section;

  /// Name text under the card plus its gap.
  static const double _nameHeight = 40;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final height =
        ProductTile.cardHeightFor(section.layout, screenWidth) +
        _nameHeight * textScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: section.title),
        const SizedBox(height: AppSpacing.s3),
        if (section.products.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Text(
              context.l10n.sectionEmpty,
              style: context.text.bodyMedium,
            ),
          )
        else
          SizedBox(
            height: height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              itemCount: section.products.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s4),
              itemBuilder: (context, index) => ProductTile(
                product: section.products[index],
                layout: section.layout,
                heroScope: section.id,
              ),
            ),
          ),
      ],
    );
  }
}
