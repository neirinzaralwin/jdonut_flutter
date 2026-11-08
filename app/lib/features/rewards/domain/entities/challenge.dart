import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge.freezed.dart';

enum ChallengeTab {
  eatMore,
  gift;

  static ChallengeTab fromId(String id) =>
      id == 'gift' ? ChallengeTab.gift : ChallengeTab.eatMore;
}

/// Which artwork shows the progress: donut quarters or a drink arc.
enum ChallengeArtwork {
  donut,
  drink;

  static ChallengeArtwork fromId(String id) =>
      id == 'drink' ? ChallengeArtwork.drink : ChallengeArtwork.donut;
}

@freezed
abstract class Challenge with _$Challenge {
  const factory Challenge({
    required String id,
    required ChallengeTab tab,
    required String title,
    required ChallengeArtwork artwork,
    required int progress,
    required int goal,
    required int rewardPoints,
  }) = _Challenge;

  const Challenge._();

  bool get isComplete => progress >= goal;

  /// 0.0–1.0, safe for a zero goal.
  double get fraction => goal <= 0 ? 0 : (progress / goal).clamp(0, 1);
}
