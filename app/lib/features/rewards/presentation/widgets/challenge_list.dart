import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/entrance_controller_mixin.dart';
import 'package:jdonut/core/widgets/staggered_entrance.dart';
import 'package:jdonut/features/rewards/domain/entities/challenge.dart';
import 'package:jdonut/features/rewards/presentation/widgets/challenge_card.dart';

/// Cards enter staggered and their artwork fills in after them. Give each
/// tab its own key so switching tabs replays the entrance.
class ChallengeList extends StatefulWidget {
  const ChallengeList({required this.challenges, super.key});

  final List<Challenge> challenges;

  @override
  State<ChallengeList> createState() => _ChallengeListState();
}

class _ChallengeListState extends State<ChallengeList>
    with SingleTickerProviderStateMixin, EntranceControllerMixin {
  @override
  Duration get entranceDuration => AppDurations.challengeEntrance;

  @override
  Widget build(BuildContext context) {
    if (widget.challenges.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.s6),
        child: Text(
          context.l10n.challengesEmpty,
          textAlign: TextAlign.center,
          style: context.text.bodyMedium,
        ),
      );
    }
    return Column(
      children: [
        for (final (index, challenge) in widget.challenges.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s4),
            child: StaggeredEntrance(
              animation: entrance,
              slot: AppStagger.challengeCards,
              index: index,
              child: ChallengeCard(
                challenge: challenge,
                artReveal: CurvedAnimation(
                  parent: entrance,
                  curve: AppStagger.challengeArt.interval(index),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
