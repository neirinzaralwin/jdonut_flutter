import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/router/app_routes.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/app_image.dart';
import 'package:jdonut/features/home/domain/entities/home_section.dart';
import 'package:jdonut/features/product/product.dart';

/// White image card with the name underneath; New / discount badge from data.
class ProductTile extends StatelessWidget {
  const ProductTile({
    required this.product,
    required this.layout,
    required this.heroScope,
    super.key,
  });

  final Product product;
  final SectionLayout layout;

  /// Section id — keeps the Hero tag unique across sections.
  final String heroScope;

  static const double _featuredWidthFraction = 0.58;
  static const double _standardWidthFraction = 0.4;
  static const double _featuredAspect = 1.5;
  static const double _standardAspect = 0.68;
  static const double _imageInset = AppSpacing.s4;

  static double widthFor(SectionLayout layout, double screenWidth) =>
      screenWidth *
      (layout == SectionLayout.featured
          ? _featuredWidthFraction
          : _standardWidthFraction);

  static double cardHeightFor(SectionLayout layout, double screenWidth) =>
      widthFor(layout, screenWidth) /
      (layout == SectionLayout.featured ? _featuredAspect : _standardAspect);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return SizedBox(
      width: widthFor(layout, screenWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _card(context, cardHeightFor(layout, screenWidth)),
          const SizedBox(height: AppSpacing.s2),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleSmall,
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, double height) => Material(
    color: context.colors.surface,
    borderRadius: BorderRadius.circular(AppRadii.tile),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () =>
          context.push(AppRoutes.productPath(product.id, heroScope: heroScope)),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(_imageInset),
                child: Hero(
                  tag: productHeroTag(product.id, scope: heroScope),
                  child: AppImage(
                    assetPath: product.assetPath,
                    imageUrl: product.imageUrl,
                    fit: BoxFit.contain,
                    semanticLabel: product.name,
                  ),
                ),
              ),
            ),
            if (_badgeText(context) case final text?)
              Positioned(
                bottom: AppSpacing.s3,
                right: AppSpacing.s3,
                child: _Badge(text: text),
              ),
          ],
        ),
      ),
    ),
  );

  /// Discount wins over "New" when both are set.
  String? _badgeText(BuildContext context) {
    if (product.discountPercent case final percent?) {
      return context.l10n.badgeDiscount(percent);
    }
    return product.isNew ? context.l10n.badgeNew : null;
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.appColors.badge,
      borderRadius: BorderRadius.circular(AppRadii.pill),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s3,
        vertical: AppSpacing.s1,
      ),
      child: Text(
        text,
        style: context.text.labelLarge?.copyWith(
          color: context.colors.onPrimary,
        ),
      ),
    ),
  );
}
