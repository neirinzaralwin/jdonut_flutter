import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/utils/formatters.dart';
import 'package:jdonut/core/widgets/app_image.dart';
import 'package:jdonut/features/product/domain/entities/product.dart';
import 'package:jdonut/features/product/presentation/product_hero.dart';

/// White card: code, name, price, New badge and the hero image.
/// [bottomOverlay] (the quantity stepper) sits half over the bottom edge.
class ProductInfoCard extends StatelessWidget {
  const ProductInfoCard({
    required this.product,
    required this.bottomOverlay,
    this.heroScope,
    super.key,
  });

  final Product product;
  final Widget bottomOverlay;
  final String? heroScope;

  static const double _imageAspect = 1.15;
  static const double _overlayHalfHeight = 28;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: _overlayHalfHeight),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadii.sheet),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s5,
                AppSpacing.s5,
                AppSpacing.s5,
                AppSpacing.s10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _titleRow(context),
                  const SizedBox(height: AppSpacing.s4),
                  AspectRatio(
                    aspectRatio: _imageAspect,
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
                ],
              ),
            ),
          ),
        ),
        bottomOverlay,
      ],
    );
  }

  Widget _titleRow(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.code,
                style: context.text.bodySmall?.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
              Text(product.name, style: context.text.headlineLarge),
              Text(
                context.l10n.priceMmk(formatNumber(product.priceMmk, locale)),
                style: context.text.titleSmall,
              ),
            ],
          ),
        ),
        if (product.isNew) _NewBadge(label: context.l10n.badgeNew),
      ],
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.appColors.badge,
      borderRadius: BorderRadius.circular(AppRadii.input),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s3,
        vertical: AppSpacing.s1,
      ),
      child: Text(
        label,
        style: context.text.labelSmall?.copyWith(
          color: context.colors.onPrimary,
        ),
      ),
    ),
  );
}
