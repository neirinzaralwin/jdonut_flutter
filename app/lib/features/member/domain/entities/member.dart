import 'package:freezed_annotation/freezed_annotation.dart';

part 'member.freezed.dart';

enum MemberTier {
  bronze,
  silver,
  gold,
  platinum;

  static MemberTier? fromId(String? id) =>
      values.where((tier) => tier.name == id).firstOrNull;
}

/// The one member record read by Home and Rewards.
@freezed
abstract class Member with _$Member {
  const factory Member({
    required String id,
    required MemberTier tier,
    required int points,
    required double tierProgress,
    required int pointsToNextTier,
    required int notificationCount,
    required int rewardsCount,
    MemberTier? nextTier,
    String? photoAssetPath,
  }) = _Member;
}
