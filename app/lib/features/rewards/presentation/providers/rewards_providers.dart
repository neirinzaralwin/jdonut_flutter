import 'package:jdonut/core/database/database_provider.dart';
import 'package:jdonut/features/rewards/data/repositories/rewards_repository_impl.dart';
import 'package:jdonut/features/rewards/domain/entities/challenge.dart';
import 'package:jdonut/features/rewards/domain/repositories/rewards_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rewards_providers.g.dart';

@Riverpod(keepAlive: true)
RewardsRepository rewardsRepository(Ref ref) =>
    RewardsRepositoryImpl(ref.watch(appDatabaseProvider));

@riverpod
Stream<List<Challenge>> challenges(Ref ref, ChallengeTab tab) =>
    ref.watch(rewardsRepositoryProvider).watchChallenges(tab);

/// Selected tab on the Rewards screen.
@riverpod
class SelectedChallengeTab extends _$SelectedChallengeTab {
  @override
  ChallengeTab build() => ChallengeTab.eatMore;

  // A method (not a setter) so it can be passed as a tab callback.
  // ignore: use_setters_to_change_properties
  void select(ChallengeTab tab) => state = tab;
}

/// Demo only: points earned this session, keyed by challenge id. Not saved —
/// restarting the app resets it (the brief has no earn endpoint).
@Riverpod(keepAlive: true)
class EarnedRewards extends _$EarnedRewards {
  @override
  Map<String, int> build() => const {};

  /// Returns false if this challenge was already earned or isn't complete.
  bool earn(Challenge challenge) {
    if (!challenge.isComplete || state.containsKey(challenge.id)) return false;
    state = {...state, challenge.id: challenge.rewardPoints};
    return true;
  }
}

/// Earned challenges whose points are still flying to the ring.
@Riverpod(keepAlive: true)
class PendingEarns extends _$PendingEarns {
  @override
  Set<String> build() => const {};

  void add(String id) => state = {...state, id};
  void remove(String id) => state = {...state}..remove(id);
}

/// Bonus shown in the ring: earned points that have landed.
@riverpod
int landedPoints(Ref ref) {
  final earned = ref.watch(earnedRewardsProvider);
  final pending = ref.watch(pendingEarnsProvider);
  return earned.entries
      .where((e) => !pending.contains(e.key))
      .fold(0, (sum, e) => sum + e.value);
}
