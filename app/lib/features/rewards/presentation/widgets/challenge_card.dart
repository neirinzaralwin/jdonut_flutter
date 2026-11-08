import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/utils/formatters.dart';
import 'package:jdonut/features/rewards/domain/entities/challenge.dart';
import 'package:jdonut/features/rewards/presentation/providers/rewards_providers.dart';
import 'package:jdonut/features/rewards/presentation/widgets/challenge_art.dart';
import 'package:jdonut/features/rewards/presentation/widgets/earn_button.dart';
import 'package:jdonut/features/rewards/presentation/widgets/points_flight.dart';

/// White card: artwork on the left; title, progress, Earn and points.
class ChallengeCard extends ConsumerWidget {
  const ChallengeCard({
    required this.challenge,
    required this.artReveal,
    super.key,
  });

  final Challenge challenge;
  final Animation<double> artReveal;

  static const double _artSize = 120;

  @override
  Widget build(BuildContext context, WidgetRef ref) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(AppRadii.sheet),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.s5),
      child: Row(
        children: [
          ChallengeArt(challenge: challenge, reveal: artReveal, size: _artSize),
          const SizedBox(width: AppSpacing.s5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge.title, style: context.text.titleLarge),
                const SizedBox(height: AppSpacing.s1),
                Text(
                  context.l10n.challengeProgress(
                    challenge.progress,
                    challenge.goal,
                  ),
                  style: context.text.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.s4),
                _earnRow(context, ref),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _earnRow(BuildContext context, WidgetRef ref) {
    final isEarned = ref.watch(
      earnedRewardsProvider.select((e) => e.containsKey(challenge.id)),
    );
    final locale = Localizations.localeOf(context).toString();
    return Row(
      children: [
        EarnButton(
          isActive: challenge.isComplete,
          isEarned: isEarned,
          onEarn: (from) => _earn(context, ref, from),
        ),
        const SizedBox(width: AppSpacing.s4),
        Flexible(
          child: Text(
            context.l10n.pointsShort(
              formatNumber(challenge.rewardPoints, locale),
            ),
            style: context.text.bodyLarge,
          ),
        ),
      ],
    );
  }

  /// Demo: the button flips to "Earned" at once; the points join the total
  /// when the flying chip lands on the ring.
  void _earn(BuildContext context, WidgetRef ref, RenderBox from) {
    // Read notifiers up front: the card may be gone (tab switch) on landing.
    final pending = ref.read(pendingEarnsProvider.notifier);
    if (!ref.read(earnedRewardsProvider.notifier).earn(challenge)) return;
    pending.add(challenge.id);
    unawaited(HapticFeedback.mediumImpact());
    flyPoints(
      context,
      from: from,
      points: challenge.rewardPoints,
      onArrive: () {
        pending.remove(challenge.id);
        unawaited(HapticFeedback.lightImpact());
      },
    );
  }
}
