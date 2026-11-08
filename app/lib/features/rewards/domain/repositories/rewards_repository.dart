import 'package:jdonut/features/rewards/domain/entities/challenge.dart';

/// Rewards data from the local DB (same store as Home).
abstract interface class RewardsRepository {
  Stream<List<Challenge>> watchChallenges(ChallengeTab tab);
}
