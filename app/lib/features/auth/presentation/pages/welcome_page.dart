import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonut/core/constants/app_assets.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/router/app_routes.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/app_button.dart';
import 'package:jdonut/core/widgets/entrance_controller_mixin.dart';
import 'package:jdonut/core/widgets/staggered_entrance.dart';
import 'package:jdonut/features/auth/presentation/providers/session_notifier.dart';

/// Screen 7: donut tiles slide in staggered, then the title fades up.
class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage>
    with SingleTickerProviderStateMixin, EntranceControllerMixin {
  /// The right column starts this share of the tile area lower.
  static const double _rightColumnDrop = 0.12;
  static const int _columns = 2;

  void _explore() {
    ref.read(sessionProvider.notifier).welcomeSeen();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _tiles(context)),
              const SizedBox(height: AppSpacing.s6),
              StaggeredEntrance(
                animation: entrance,
                slot: AppStagger.welcomeTitle,
                child: Text(
                  context.l10n.welcomeTitle,
                  textAlign: TextAlign.center,
                  style: context.text.displayLarge,
                ),
              ),
              const SizedBox(height: AppSpacing.s6),
              StaggeredEntrance(
                animation: entrance,
                slot: AppStagger.welcomeAction,
                child: AppButton(
                  label: context.l10n.letsExplore,
                  onPressed: _explore,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Two columns, the right one dropped a little (like the design). Tiles
  /// share the available height, so nothing overflows on short phones.
  Widget _tiles(BuildContext context) {
    final backdrops = context.appColors.backdrops;
    final tiles = [
      (backdrops.mist, AppAssets.donutWhiteSprinkle),
      (backdrops.blush, AppAssets.donutChocolateDrizzle),
      (backdrops.peach, AppAssets.donutPinkSprinkle),
      (backdrops.apricot, AppAssets.donutAlmondCrunch),
    ];
    Widget tile(int index) => Expanded(
      child: StaggeredEntrance(
        animation: entrance,
        slot: AppStagger.welcomeTiles,
        index: index,
        from: Offset(
          index.isEven
              ? -AppMotionValues.tileSlideFraction
              : AppMotionValues.tileSlideFraction,
          0,
        ),
        child: _DonutTile(
          background: tiles[index].$1,
          imageAsset: tiles[index].$2,
        ),
      ),
    );
    Widget column(int first, {double top = 0}) => Expanded(
      child: Padding(
        padding: EdgeInsets.only(top: top),
        child: Column(
          children: [
            tile(first),
            const SizedBox(height: AppSpacing.s3),
            tile(first + _columns),
          ],
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          column(0),
          const SizedBox(width: AppSpacing.s3),
          column(1, top: constraints.maxHeight * _rightColumnDrop),
        ],
      ),
    );
  }
}

class _DonutTile extends StatelessWidget {
  const _DonutTile({required this.background, required this.imageAsset});

  final Color background;
  final String imageAsset;

  static const double _donutRatio = 0.78;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(AppRadii.sheet),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide * _donutRatio;
        return Center(
          child: Image.asset(
            imageAsset,
            width: size,
            height: size,
            fit: BoxFit.contain,
            cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
            excludeFromSemantics: true,
          ),
        );
      },
    ),
  );
}
