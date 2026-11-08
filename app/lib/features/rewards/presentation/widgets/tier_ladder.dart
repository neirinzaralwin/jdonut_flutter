import 'package:flutter/material.dart';
import 'package:jdonut/core/constants/app_assets.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/utils/formatters.dart';
import 'package:jdonut/core/widgets/staggered_entrance.dart';
import 'package:jdonut/features/member/member.dart';

/// Silver → Gold → Platinum. Tiers appear in order, the current one is
/// highlighted, and the line to the next tier fills to the member's progress.
class TierLadder extends StatelessWidget {
  const TierLadder({required this.member, required this.entrance, super.key});

  final Member member;
  final Animation<double> entrance;

  static const List<MemberTier> tiers = [
    MemberTier.silver,
    MemberTier.gold,
    MemberTier.platinum,
  ];

  static const double _iconSize = 40;
  static const double _connectorHeight = 64;
  static const double _lineWidth = 3;

  /// Long subtitles ("500 pts remaining to become Gold") wrap, not clip.
  static const int _subtitleLines = 3;

  @override
  Widget build(BuildContext context) {
    final currentIndex = tiers.indexOf(member.tier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, tier) in tiers.indexed) ...[
          if (index > 0)
            _Connector(
              fill: _fillFor(index - 1, currentIndex),
              animation: CurvedAnimation(
                parent: entrance,
                curve: AppStagger.tierLine.interval(0),
              ),
            ),
          StaggeredEntrance(
            animation: entrance,
            slot: AppStagger.tierLadder,
            index: index,
            from: const Offset(-AppMotionValues.entranceSlideFraction, 0),
            child: _TierRow(
              tier: tier,
              isCurrent: index == currentIndex,
              subtitle: _subtitle(context, index, currentIndex),
            ),
          ),
        ],
      ],
    );
  }

  /// Gap below tier [gapIndex]: full if passed, member progress if it leads
  /// to the next tier, empty otherwise.
  double _fillFor(int gapIndex, int currentIndex) {
    if (gapIndex < currentIndex) return 1;
    if (gapIndex == currentIndex) return member.tierProgress;
    return 0;
  }

  String _subtitle(BuildContext context, int index, int currentIndex) {
    final l10n = context.l10n;
    if (index == currentIndex) return l10n.tierHereNow;
    if (index < currentIndex) return l10n.tierUnlocked;
    if (index == currentIndex + 1) {
      final locale = Localizations.localeOf(context).toString();
      return l10n.tierPointsRemaining(
        formatNumber(member.pointsToNextTier, locale),
        tierLabel(context, tiers[index]),
      );
    }
    return l10n.tierSoon;
  }

  static String iconFor(MemberTier tier) => switch (tier) {
    MemberTier.gold => AppAssets.tierGold,
    MemberTier.platinum => AppAssets.tierPlatinum,
    MemberTier.silver || MemberTier.bronze => AppAssets.tierSilver,
  };
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.tier,
    required this.isCurrent,
    required this.subtitle,
  });

  final MemberTier tier;
  final bool isCurrent;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cacheSize =
        (TierLadder._iconSize * MediaQuery.devicePixelRatioOf(context)).round();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedScale(
          scale: isCurrent ? AppMotionValues.tierCurrentScale : 1,
          duration: AppDurations.medium,
          child: Image.asset(
            TierLadder.iconFor(tier),
            width: TierLadder._iconSize,
            height: TierLadder._iconSize,
            cacheWidth: cacheSize,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(width: AppSpacing.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tierLabel(context, tier), style: context.text.titleMedium),
              Text(
                subtitle,
                maxLines: TierLadder._subtitleLines,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall?.copyWith(
                  color: isCurrent
                      ? context.colors.onSurface
                      : context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Vertical line between two tier icons; the dark part grows to [fill].
class _Connector extends StatelessWidget {
  const _Connector({required this.fill, required this.animation});

  final double fill;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(
      left: (TierLadder._iconSize - TierLadder._lineWidth) / 2,
    ),
    child: SizedBox(
      width: TierLadder._lineWidth,
      height: TierLadder._connectorHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.outlineVariant,
          borderRadius: BorderRadius.circular(TierLadder._lineWidth),
        ),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) => Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              heightFactor: fill * animation.value,
              widthFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.appColors.textSecondary,
                  borderRadius: BorderRadius.circular(TierLadder._lineWidth),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
