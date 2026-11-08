import 'package:flutter/widgets.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/features/member/domain/entities/member.dart';

String tierLabel(BuildContext context, MemberTier tier) => switch (tier) {
  MemberTier.bronze => context.l10n.tierBronze,
  MemberTier.silver => context.l10n.tierSilver,
  MemberTier.gold => context.l10n.tierGold,
  MemberTier.platinum => context.l10n.tierPlatinum,
};

/// Ring / badge colours for a tier (match the reward shield icons).
TierColors tierColors(BuildContext context, MemberTier tier) {
  final colors = context.appColors;
  return switch (tier) {
    MemberTier.bronze => colors.tierBronze,
    MemberTier.silver => colors.tierSilver,
    MemberTier.gold => colors.tierGold,
    MemberTier.platinum => colors.tierPlatinum,
  };
}
