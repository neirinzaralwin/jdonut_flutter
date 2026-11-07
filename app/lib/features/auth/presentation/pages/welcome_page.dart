import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/router/app_routes.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/app_button.dart';
import 'package:jdonut/core/widgets/donut_art.dart';
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
  static const int _tileCount = 4;
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

  Widget _tiles(BuildContext context) {
    final colors = context.colors;
    final appColors = context.appColors;
    final tiles = [
      (colors.primaryContainer, appColors.banner),
      (appColors.authGradientTop, colors.secondary),
      (appColors.homeHeader, colors.secondary),
      (appColors.tierGold, colors.surface),
    ];
    return GridView.count(
      crossAxisCount: _columns,
      mainAxisSpacing: AppSpacing.s3,
      crossAxisSpacing: AppSpacing.s3,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var index = 0; index < _tileCount; index++)
          StaggeredEntrance(
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
              icing: tiles[index].$2,
            ),
          ),
      ],
    );
  }
}

class _DonutTile extends StatelessWidget {
  const _DonutTile({required this.background, required this.icing});

  final Color background;
  final Color icing;

  static const double _donutRatio = 0.7;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(AppRadii.card),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) => Center(
        child: DonutArt(
          icing: icing,
          size: constraints.biggest.shortestSide * _donutRatio,
        ),
      ),
    ),
  );
}
