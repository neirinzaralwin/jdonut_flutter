import 'package:flutter/material.dart';
import 'package:jdonut/core/constants/app_assets.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/app_image.dart';
import 'package:jdonut/features/home/domain/entities/shop.dart';

/// Last Home section: sky-and-grass background that runs under the floating
/// bottom nav, a white title, "Explore now", and shop cards.
/// Display only (brief): the buttons give press feedback but do nothing.
class NearbyShopsSection extends StatelessWidget {
  const NearbyShopsSection({
    required this.shops,
    this.bottomInset = 0,
    super.key,
  });

  final List<Shop> shops;

  /// Space kept at the bottom so the grass shows behind the floating nav.
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadii.sheet),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.shopsBackground,
              fit: BoxFit.cover,
              // Grass stays visible at the bottom on every screen height.
              alignment: Alignment.bottomCenter,
              excludeFromSemantics: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.s8, bottom: bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(count: shops.length),
                const SizedBox(height: AppSpacing.s6),
                _ShopList(shops: shops),
                const SizedBox(height: AppSpacing.s8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.screenHorizontal,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.shopsNearYou(count),
          style: context.text.headlineMedium?.copyWith(
            color: context.colors.surface,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        _PressablePill(label: context.l10n.exploreNow),
      ],
    ),
  );
}

class _ShopList extends StatelessWidget {
  const _ShopList({required this.shops});

  final List<Shop> shops;

  static const double _cardWidthFraction = 0.64;

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.sizeOf(context).width * _cardWidthFraction;
    return SizedBox(
      height: _ShopCard.heightFor(context, cardWidth),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        itemCount: shops.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s4),
        itemBuilder: (context, index) => SizedBox(
          width: cardWidth,
          child: _ShopCard(shop: shops[index]),
        ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({required this.shop});

  final Shop shop;

  static const double _imageAspect = 1.45;
  static const int _addressLines = 2;

  /// Card height from its width and the text styles (follows text scale).
  static double heightFor(BuildContext context, double width) {
    final scaler = MediaQuery.textScalerOf(context);
    double line(TextStyle? style) =>
        scaler.scale((style?.fontSize ?? 0) * (style?.height ?? 1));
    final text = context.text;
    final imageHeight = (width - AppSpacing.s3 * 2) / _imageAspect;
    return AppSpacing.s3 * 2 +
        imageHeight +
        AppSpacing.s3 +
        line(text.titleMedium) +
        AppSpacing.s1 +
        line(text.bodyMedium) * _addressLines +
        AppSpacing.s2 +
        line(text.labelLarge);
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(AppRadii.tile),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _photo(),
          const SizedBox(height: AppSpacing.s3),
          Text(
            shop.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s1),
          Text(
            shop.address,
            maxLines: _addressLines,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodyMedium?.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          const Spacer(),
          _OrderOnline(label: context.l10n.orderOnline),
        ],
      ),
    ),
  );

  Widget _photo() => AspectRatio(
    aspectRatio: _imageAspect,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: AppImage(
        assetPath: shop.assetPath,
        imageUrl: shop.imageUrl,
        semanticLabel: shop.name,
      ),
    ),
  );
}

/// "Order Online" — pink text with press feedback, no action (brief).
class _OrderOnline extends StatelessWidget {
  const _OrderOnline({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () {},
    borderRadius: BorderRadius.circular(AppRadii.input),
    child: Text(
      label,
      style: context.text.labelLarge?.copyWith(color: context.appColors.link),
    ),
  );
}

/// White "EXPLORE NOW" pill that scales on press, no action (brief).
class _PressablePill extends StatefulWidget {
  const _PressablePill({required this.label});

  final String label;

  @override
  State<_PressablePill> createState() => _PressablePillState();
}

class _PressablePillState extends State<_PressablePill> {
  bool _isPressed = false;

  void _setPressed(bool value) => setState(() => _isPressed = value);

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: widget.label,
    excludeSemantics: true,
    child: GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: () {},
      child: AnimatedScale(
        scale: _isPressed ? AppMotionValues.pressedScale : 1,
        duration: context.motion(AppDurations.fast),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s5,
              vertical: AppSpacing.s3,
            ),
            child: Text(
              widget.label.toUpperCase(),
              style: context.text.labelLarge?.copyWith(
                color: context.colors.primary,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
