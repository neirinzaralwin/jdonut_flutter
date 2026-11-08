import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/features/rewards/domain/entities/challenge.dart';

Challenge _challenge(int progress, int goal) => Challenge(
  id: 'c',
  tab: ChallengeTab.eatMore,
  title: 'Eat donuts',
  artwork: ChallengeArtwork.donut,
  progress: progress,
  goal: goal,
  rewardPoints: 100,
);

void main() {
  test('fraction is progress over goal, clamped to 0..1', () {
    expect(_challenge(1, 4).fraction, 0.25);
    expect(_challenge(9, 12).fraction, 0.75);
    expect(_challenge(6, 4).fraction, 1);
    expect(_challenge(0, 0).fraction, 0);
  });

  test('only a reached goal is complete (and can be earned)', () {
    expect(_challenge(4, 4).isComplete, isTrue);
    expect(_challenge(3, 4).isComplete, isFalse);
  });
}
