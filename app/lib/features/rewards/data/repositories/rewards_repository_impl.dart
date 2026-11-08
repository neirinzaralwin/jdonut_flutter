import 'package:drift/drift.dart';
import 'package:jdonut/core/database/app_database.dart';
import 'package:jdonut/features/rewards/domain/entities/challenge.dart';
import 'package:jdonut/features/rewards/domain/repositories/rewards_repository.dart';

class RewardsRepositoryImpl implements RewardsRepository {
  const RewardsRepositoryImpl(this._database);

  final AppDatabase _database;

  static const Map<ChallengeTab, String> _tabIds = {
    ChallengeTab.eatMore: 'eat_more',
    ChallengeTab.gift: 'gift',
  };

  @override
  Stream<List<Challenge>> watchChallenges(ChallengeTab tab) {
    final query = _database.select(_database.challenges)
      ..where((row) => row.tab.equals(_tabIds[tab]!))
      ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]);
    return query.watch().map((rows) => rows.map(_toEntity).toList());
  }

  Challenge _toEntity(ChallengeRow row) => Challenge(
    id: row.id,
    tab: ChallengeTab.fromId(row.tab),
    title: row.title,
    artwork: ChallengeArtwork.fromId(row.artwork),
    progress: row.progress,
    goal: row.goal,
    rewardPoints: row.rewardPoints,
  );
}
