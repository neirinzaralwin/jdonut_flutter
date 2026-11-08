import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/skeleton.dart';
import 'package:jdonut/features/home/domain/entities/home_section.dart';
import 'package:jdonut/features/home/presentation/widgets/banner_carousel.dart';
import 'package:jdonut/features/home/presentation/widgets/product_tile.dart';

class CarouselSkeleton extends StatelessWidget {
  const CarouselSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Center(
      child: Skeleton(
        width: width * BannerCarousel.viewportFraction,
        height: BannerCarousel.heightFor(width),
        radius: AppRadii.banner,
      ),
    );
  }
}

class SectionSkeleton extends StatelessWidget {
  const SectionSkeleton({super.key});

  static const int _tileCount = 3;
  static const double _titleWidth = 160;
  static const double _titleHeight = 24;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(
            width: _titleWidth,
            height: _titleHeight,
            radius: AppRadii.input,
          ),
          const SizedBox(height: AppSpacing.s3),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                for (var index = 0; index < _tileCount; index++)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s4),
                    child: Skeleton(
                      width: ProductTile.widthFor(
                        SectionLayout.standard,
                        width,
                      ),
                      height: ProductTile.cardHeightFor(
                        SectionLayout.standard,
                        width,
                      ),
                      radius: AppRadii.tile,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline per-section error (other sections keep working).
class SectionError extends StatelessWidget {
  const SectionError({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.screenHorizontal,
    ),
    child: Row(
      children: [
        Icon(Icons.error_outline_rounded, color: context.colors.error),
        const SizedBox(width: AppSpacing.s2),
        Expanded(
          child: Text(
            context.l10n.sectionError,
            style: context.text.bodyMedium,
          ),
        ),
      ],
    ),
  );
}

/// Inline per-section empty state.
class SectionEmpty extends StatelessWidget {
  const SectionEmpty({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.screenHorizontal,
    ),
    child: Text(message, style: context.text.bodyMedium),
  );
}
