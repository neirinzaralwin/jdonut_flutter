import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/app_bottom_fade.dart';
import 'package:jdonut/core/widgets/skeleton.dart';
import 'package:jdonut/features/product/domain/cart_quantity.dart';
import 'package:jdonut/features/product/domain/entities/product.dart';
import 'package:jdonut/features/product/presentation/providers/product_providers.dart';
import 'package:jdonut/features/product/presentation/widgets/add_to_cart_bar.dart';
import 'package:jdonut/features/product/presentation/widgets/product_info_card.dart';
import 'package:jdonut/features/product/presentation/widgets/quantity_stepper.dart';
import 'package:jdonut/features/product/presentation/widgets/whats_this.dart';

/// Screen 9. Content scrolls under a blurred, fading bottom edge; the
/// Add to cart bar springs up after the first +.
class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({required this.productId, this.heroScope, super.key});

  final String productId;
  final String? heroScope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productDetailProvider(productId));
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              tooltip: context.l10n.back,
              onPressed: () => context.canPop() ? context.pop() : null,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: switch (product) {
                AsyncData(value: final Product product) => _ProductBody(
                  product: product,
                  heroScope: heroScope,
                ),
                AsyncData() || AsyncError() => _NotFound(
                  message: context.l10n.productNotFound,
                ),
                AsyncLoading() => const _LoadingBody(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductBody extends ConsumerWidget {
  const _ProductBody({required this.product, this.heroScope});

  final Product product;
  final String? heroScope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantityProvider = productQuantityProvider(product.id);
    final quantity = ref.watch(quantityProvider);
    final notifier = ref.read(quantityProvider.notifier);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.s4,
            AppSpacing.s2,
            AppSpacing.s4,
            // Room to scroll the text clear of the fade and the bar.
            AppBottomFade.defaultHeight + AppSizes.buttonHeight + bottomInset,
          ),
          child: Column(
            children: [
              ProductInfoCard(
                product: product,
                heroScope: heroScope,
                bottomOverlay: QuantityStepper(
                  quantity: quantity,
                  onDecrease: quantity > 0 ? notifier.decrement : null,
                  onIncrease: quantity < CartQuantity.max
                      ? notifier.increment
                      : null,
                ),
              ),
              const SizedBox(height: AppSpacing.s6),
              WhatsThis(description: product.description),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AppBottomFade(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        Positioned(
          left: AppSpacing.screenHorizontal,
          right: AppSpacing.screenHorizontal,
          bottom: bottomInset + AppSpacing.s4,
          child: AddToCartBar(
            visible: quantity > 0,
            totalMmk: CartQuantity.lineTotal(quantity, product.priceMmk),
          ),
        ),
      ],
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  static const double _cardHeight = 420;

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4),
    child: Skeleton(height: _cardHeight, radius: AppRadii.sheet),
  );
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: context.text.bodyLarge,
      ),
    ),
  );
}
