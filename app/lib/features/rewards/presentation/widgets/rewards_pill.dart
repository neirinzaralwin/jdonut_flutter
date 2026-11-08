import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/count_badge.dart';
import 'package:jdonut/core/widgets/pressable.dart';

/// Orange "Rewards (3)" pill on the right edge. The count badge pops in
/// during [AppStagger.rewardsBadge]. Visual feedback only (brief).
class RewardsPill extends StatelessWidget {
  const RewardsPill({required this.count, required this.entrance, super.key});

  final int count;
  final Animation<double> entrance;

  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    AppSpacing.s5,
    AppSpacing.s3,
    AppSpacing.s4,
    AppSpacing.s3,
  );

  @override
  Widget build(BuildContext context) {
    final pop = CurvedAnimation(
      parent: entrance,
      curve: AppStagger.rewardsBadge.interval(0, curve: AppCurves.pop),
    );
    return Semantics(
      button: true,
      label: context.l10n.rewardsCountLabel(count),
      excludeSemantics: true,
      child: Pressable(
        onTap: () {},
        alignment: Alignment.centerRight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.appColors.badge,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(AppRadii.pill),
            ),
          ),
          child: Padding(padding: _padding, child: _label(context, pop)),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, Animation<double> pop) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        context.l10n.rewardsPill,
        style: context.text.titleMedium?.copyWith(
          color: context.colors.onPrimary,
        ),
      ),
      const SizedBox(width: AppSpacing.s2),
      ScaleTransition(
        scale: pop,
        child: CountBadge(count: count),
      ),
    ],
  );
}
