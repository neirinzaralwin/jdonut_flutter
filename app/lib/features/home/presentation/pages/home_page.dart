import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonut/core/constants/app_assets.dart';
import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/donut_refresh_control.dart';
import 'package:jdonut/core/widgets/entrance_controller_mixin.dart';
import 'package:jdonut/core/widgets/staggered_entrance.dart';
import 'package:jdonut/features/auth/auth.dart';
import 'package:jdonut/features/home/presentation/providers/catalog_refresh.dart';
import 'package:jdonut/features/home/presentation/providers/home_providers.dart';
import 'package:jdonut/features/home/presentation/widgets/banner_carousel.dart';
import 'package:jdonut/features/home/presentation/widgets/collapsing_header_delegate.dart';
import 'package:jdonut/features/home/presentation/widgets/home_header.dart';
import 'package:jdonut/features/home/presentation/widgets/home_skeletons.dart';
import 'package:jdonut/features/home/presentation/widgets/nearby_shops_section.dart';
import 'package:jdonut/features/home/presentation/widgets/notification_pill.dart';
import 'package:jdonut/features/home/presentation/widgets/product_section.dart';
import 'package:jdonut/features/member/member.dart';
import 'package:jdonut/features/shell/shell.dart';

/// Screen 8. Everything comes from the local DB via providers; each part
/// has its own loading (skeleton), empty and error state.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin, EntranceControllerMixin {
  /// Pull-to-refresh. Offline or failing → keep cached data, say so.
  Future<void> _refresh() async {
    final result = await ref.read(catalogRefreshProvider.notifier).refresh();
    if (result is Ok || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.refreshFailed)));
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final notificationCount =
        ref.watch(memberProvider).value?.notificationCount ?? 0;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomScrollView(
              // Bounce is what lets the donut refresh control pull open
              // (also on Android); always-scrollable keeps it working when
              // everything fits on screen.
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                DonutRefreshControl(
                  onRefresh: _refresh,
                  backgroundColor: context.appColors.homeHeader,
                ),
                SliverPersistentHeader(
                  delegate: CollapsingHeaderDelegate(
                    expandedHeight: _HeaderWithCarousel.heightFor(context),
                    child: const _HeaderWithCarousel(),
                  ),
                ),
                _SectionsSliver(entrance: entrance),
                const SliverToBoxAdapter(child: _ShopsBlock()),
              ],
            ),
          ),
          Positioned(
            top: topInset + AppSpacing.s6,
            right: 0,
            child: NotificationPill(count: notificationCount),
          ),
        ],
      ),
    );
  }
}

/// Sky header that runs behind the top part of the carousel.
class _HeaderWithCarousel extends ConsumerWidget {
  const _HeaderWithCarousel();

  /// Share of the carousel height that sits on the sky header.
  static const double _headerOverlap = 0.55;

  /// Space between the carousel and the first section.
  static const double _carouselBottomGap = AppSpacing.s2;

  /// Full height when expanded: safe area + header + carousel + gap.
  static double heightFor(BuildContext context) =>
      MediaQuery.paddingOf(context).top +
      HomeHeader.heightFor(context) +
      BannerCarousel.heightFor(MediaQuery.sizeOf(context).width) +
      _carouselBottomGap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final name = session is Authenticated
        ? [session.user.firstName, ?session.user.lastName].join(' ')
        : '';
    final carouselHeight = BannerCarousel.heightFor(
      MediaQuery.sizeOf(context).width,
    );
    return Stack(
      children: [
        Positioned.fill(
          bottom: carouselHeight * (1 - _headerOverlap) + _carouselBottomGap,
          child: _background(context),
        ),
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              HomeHeader(name: name, member: ref.watch(memberProvider).value),
              _banners(ref),
              const SizedBox(height: _carouselBottomGap),
            ],
          ),
        ),
      ],
    );
  }

  Widget _background(BuildContext context) => ColoredBox(
    color: context.appColors.homeHeader,
    child: Image.asset(
      AppAssets.homeBackground,
      fit: BoxFit.cover,
      // Keeps the hexagon on the right as the height changes.
      alignment: Alignment.centerRight,
      excludeFromSemantics: true,
    ),
  );

  /// No banners: the carousel simply isn't shown (the header still fits).
  Widget _banners(WidgetRef ref) => switch (ref.watch(homeBannersProvider)) {
    AsyncData(:final value) when value.isNotEmpty => BannerCarousel(
      banners: value,
    ),
    AsyncData() => const SizedBox.shrink(),
    AsyncError() => const SectionError(),
    AsyncLoading() => const CarouselSkeleton(),
  };
}

class _SectionsSliver extends ConsumerWidget {
  const _SectionsSliver({required this.entrance});

  final Animation<double> entrance;

  static const int _skeletonCount = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = switch (ref.watch(homeSectionsProvider)) {
      AsyncData(:final value) => [
        for (final (index, section) in value.indexed)
          StaggeredEntrance(
            animation: entrance,
            slot: AppStagger.homeSections,
            index: index,
            child: ProductSection(section: section),
          ),
      ],
      AsyncError() => [const SectionError()],
      AsyncLoading() => [
        for (var index = 0; index < _skeletonCount; index++)
          const SectionSkeleton(),
      ],
    };
    return SliverPadding(
      // Breathing room above "Seasonal specials".
      padding: const EdgeInsets.only(top: AppSpacing.s5),
      sliver: SliverList.separated(
        itemCount: children.length,
        itemBuilder: (_, index) => children[index],
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s6),
      ),
    );
  }
}

class _ShopsBlock extends ConsumerWidget {
  const _ShopsBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The shops section paints its background under the floating nav;
    // without it, plain space keeps the last section clear of the nav.
    final navSpace = AppBottomNav.overlapHeight(context);
    final content = switch (ref.watch(nearbyShopsProvider)) {
      AsyncData(:final value) when value.isEmpty => SectionEmpty(
        message: context.l10n.shopsEmpty,
      ),
      AsyncData(:final value) => NearbyShopsSection(
        shops: value,
        bottomInset: navSpace,
      ),
      AsyncError() => const SectionError(),
      AsyncLoading() => const SectionSkeleton(),
    };
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s8),
      child: content is NearbyShopsSection
          ? content
          : Column(
              children: [
                content,
                SizedBox(height: navSpace),
              ],
            ),
    );
  }
}
