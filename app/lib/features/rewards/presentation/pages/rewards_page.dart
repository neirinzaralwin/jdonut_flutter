import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/entrance_controller_mixin.dart';
import 'package:jdonut/core/widgets/skeleton.dart';
import 'package:jdonut/core/widgets/staggered_entrance.dart';
import 'package:jdonut/features/member/member.dart';
import 'package:jdonut/features/rewards/domain/entities/challenge.dart';
import 'package:jdonut/features/rewards/presentation/providers/rewards_providers.dart';
import 'package:jdonut/features/rewards/presentation/widgets/challenge_list.dart';
import 'package:jdonut/features/rewards/presentation/widgets/challenge_tabs.dart';
import 'package:jdonut/features/rewards/presentation/widgets/points_flight.dart';
import 'package:jdonut/features/rewards/presentation/widgets/points_ring.dart';
import 'package:jdonut/features/rewards/presentation/widgets/rewards_pill.dart';
import 'package:jdonut/features/rewards/presentation/widgets/tier_ladder.dart';
import 'package:jdonut/features/shell/shell.dart';

/// Screen 10. Reads the same member record as Home. The entrance replays
/// every time the Reward tab becomes visible.
class RewardsPage extends ConsumerStatefulWidget {
  const RewardsPage({super.key});

  @override
  ConsumerState<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends ConsumerState<RewardsPage>
    with SingleTickerProviderStateMixin, EntranceControllerMixin {
  bool _wasVisible = false;
  final GlobalKey _ringKey = GlobalKey();

  @override
  Duration get entranceDuration => AppDurations.rewardsEntrance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inactive shell tabs run with tickers disabled; replay on becoming active.
    final isVisible = TickerMode.valuesOf(context).enabled;
    if (isVisible && !_wasVisible) replayEntrance();
    _wasVisible = isVisible;
  }

  @override
  Widget build(BuildContext context) {
    final member = ref.watch(memberProvider);
    return PointsTarget(
      ringKey: _ringKey,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: switch (member) {
                AsyncData(value: final Member member) => _Summary(
                  member: member,
                  entrance: entrance,
                  ringKey: _ringKey,
                  bonus: ref.watch(landedPointsProvider),
                ),
                AsyncError() || AsyncData() => const SizedBox.shrink(),
                AsyncLoading() => const _SummarySkeleton(),
              },
            ),
            SliverToBoxAdapter(
              child: StaggeredEntrance(
                animation: entrance,
                slot: AppStagger.rewardsTabs,
                child: const _TabsBar(),
              ),
            ),
            const SliverToBoxAdapter(child: _Challenges()),
            SliverToBoxAdapter(
              child: SizedBox(height: AppBottomNav.overlapHeight(context)),
            ),
          ],
        ),
      ),
    );
  }
}

/// White top area: title, Rewards pill, tier ladder and points ring.
class _Summary extends StatelessWidget {
  const _Summary({
    required this.member,
    required this.entrance,
    required this.ringKey,
    required this.bonus,
  });

  final GlobalKey ringKey;
  final int bonus;

  final Member member;
  final Animation<double> entrance;

  static const double _ringSizeFraction = 0.6;

  /// The ring bleeds past the right edge, like the design.
  static const double _ringBleed = 0.16;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colors.surface,
    child: SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.s6),
          StaggeredEntrance(
            animation: entrance,
            slot: AppStagger.rewardsHeader,
            child: _titleRow(context),
          ),
          const SizedBox(height: AppSpacing.s8),
          _ladderAndRing(context),
        ],
      ),
    ),
  );

  Widget _titleRow(BuildContext context) => Row(
    children: [
      const SizedBox(width: AppSpacing.screenHorizontal),
      Expanded(
        child: Text(
          context.l10n.rewardsTitle,
          style: context.text.headlineMedium,
        ),
      ),
      RewardsPill(count: member.rewardsCount, entrance: entrance),
    ],
  );

  /// No fixed height: the row grows with the ladder text (long locales,
  /// large text sizes), so it can never overflow.
  Widget _ladderAndRing(BuildContext context) {
    final ringSize = MediaQuery.sizeOf(context).width * _ringSizeFraction;
    return ClipRect(
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.screenHorizontal),
          Expanded(
            child: TierLadder(member: member, entrance: entrance),
          ),
          Transform.translate(
            offset: Offset(ringSize * _ringBleed, 0),
            child: SizedBox.square(
              dimension: ringSize,
              child: PointsRing(
                key: ringKey,
                points: member.points,
                bonus: bonus,
                progress: member.tierProgress,
                entrance: entrance,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  static const double _height = 380;

  @override
  Widget build(BuildContext context) => const SafeArea(
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Skeleton(height: _height),
    ),
  );
}

/// Tabs sit on the seam between the white top and the grey list.
class _TabsBar extends ConsumerWidget {
  const _TabsBar();

  static const double _seam = 0.5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surface = context.colors.surface;
    final background = Theme.of(context).scaffoldBackgroundColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // Same stop twice = a hard edge: white above, grey below, so the
          // tabs sit across the seam like the design.
          stops: const [_seam, _seam],
          colors: [surface, background],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
        child: Center(
          child: ChallengeTabs(
            selected: ref.watch(selectedChallengeTabProvider),
            onSelected: ref.read(selectedChallengeTabProvider.notifier).select,
          ),
        ),
      ),
    );
  }
}

/// The selected tab's cards; switching slides the old list out and the new
/// one in from the side of the tab that was chosen.
class _Challenges extends ConsumerWidget {
  const _Challenges();

  static const double _loadingHeight = AppSpacing.s12 * 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(selectedChallengeTabProvider);
    final challenges = ref.watch(challengesProvider(tab));
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s4,
        AppSpacing.s4,
        AppSpacing.s4,
        0,
      ),
      child: AnimatedSwitcher(
        duration: context.motion(AppDurations.tabSwitch),
        switchInCurve: AppCurves.standard,
        switchOutCurve: AppCurves.exit,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topCenter,
          children: [...previous, ?current],
        ),
        transitionBuilder: (child, animation) => _slide(child, animation, tab),
        child: KeyedSubtree(
          key: ValueKey(tab),
          child: switch (challenges) {
            AsyncData(:final value) => ChallengeList(
              key: ValueKey('list-$tab'),
              challenges: value,
            ),
            AsyncError() => _ErrorMessage(context.l10n.challengesError),
            AsyncLoading() => const Skeleton(height: _loadingHeight),
          },
        ),
      ),
    );
  }

  /// The new list comes in from the side of the chosen tab (Gift is on the
  /// right); the old one leaves the other way.
  Widget _slide(Widget child, Animation<double> animation, ChallengeTab tab) {
    final direction = tab == ChallengeTab.gift ? 1.0 : -1.0;
    final isIncoming = child.key == ValueKey(tab);
    final from =
        AppMotionValues.tabSlideFraction * direction * (isIncoming ? 1 : -1);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: Offset(from, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.s6),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: context.text.bodyMedium,
    ),
  );
}
