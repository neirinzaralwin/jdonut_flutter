import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/utils/formatters.dart';
import 'package:jdonut/core/widgets/app_image.dart';
import 'package:jdonut/features/home/presentation/widgets/tier_label.dart';
import 'package:jdonut/features/member/member.dart';

/// Avatar, name, tier and "kyats left" chip on the sky header.
class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.name, required this.member, super.key});

  final String name;
  final Member? member;

  /// Laid-out height, derived from the text styles so it follows text scale.
  static double heightFor(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    double lineHeight(TextStyle? style) =>
        scaler.scale((style?.fontSize ?? 0) * (style?.height ?? 1));
    final text = context.text;
    final nameBlock =
        lineHeight(text.headlineMedium) + lineHeight(text.bodyMedium);
    final chip = AppSpacing.s2 * 2 + lineHeight(text.bodySmall);
    return AppSpacing.s6 +
        math.max(AppSizes.avatarL, nameBlock) +
        AppSpacing.s4 +
        chip +
        AppSpacing.s4;
  }

  /// Leaves room for the pinned notification pill on the right.
  static const double _pillClearance = 96;
  static const double _avatarRing = 3;
  static const double _avatarGap = 2;

  @override
  Widget build(BuildContext context) {
    final member = this.member;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.s6,
        _pillClearance,
        AppSpacing.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _avatar(context, member),
              const SizedBox(width: AppSpacing.s3),
              Expanded(child: _nameAndTier(context, member)),
            ],
          ),
          if (member?.nextTier != null) ...[
            const SizedBox(height: AppSpacing.s4),
            _NextTierChip(member: member!),
          ],
        ],
      ),
    );
  }

  /// Photo inside a ring in the member's tier gradient (silver, gold …),
  /// with a thin white gap so the ring reads as a badge.
  Widget _avatar(BuildContext context, Member? member) => Container(
    width: AppSizes.avatarL,
    height: AppSizes.avatarL,
    padding: const EdgeInsets.all(_avatarRing),
    decoration: BoxDecoration(
      gradient: member == null
          ? null
          : tierColors(context, member.tier).gradient,
      color: member == null ? context.colors.outlineVariant : null,
      shape: BoxShape.circle,
    ),
    child: Container(
      padding: const EdgeInsets.all(_avatarGap),
      decoration: BoxDecoration(
        color: context.colors.surface,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: AppImage(assetPath: member?.photoAssetPath, semanticLabel: name),
      ),
    ),
  );

  Widget _nameAndTier(BuildContext context, Member? member) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.text.headlineMedium,
      ),
      if (member != null)
        Text(
          context.l10n.memberTierLabel(tierLabel(context, member.tier)),
          style: context.text.bodyMedium?.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
    ],
  );
}

class _NextTierChip extends StatelessWidget {
  const _NextTierChip({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s2,
        ),
        child: Text(
          context.l10n.amountToNextTier(
            formatNumber(member.amountToNextTierMmk, locale),
            tierLabel(context, member.nextTier!),
          ),
          style: context.text.bodySmall,
        ),
      ),
    );
  }
}
