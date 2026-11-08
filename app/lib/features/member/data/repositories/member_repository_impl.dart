import 'package:jdonut/core/database/app_database.dart';
import 'package:jdonut/features/member/domain/entities/member.dart';
import 'package:jdonut/features/member/domain/repositories/member_repository.dart';

class MemberRepositoryImpl implements MemberRepository {
  const MemberRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Stream<Member?> watchMember() => (_database.select(
    _database.members,
  )..limit(1)).watchSingleOrNull().map((row) => row?._toEntity());
}

extension on MemberRow {
  Member _toEntity() => Member(
    id: id,
    tier: MemberTier.fromId(tier) ?? MemberTier.bronze,
    nextTier: MemberTier.fromId(nextTier),
    points: points,
    tierProgress: tierProgress,
    amountToNextTierMmk: amountToNextTierMmk,
    notificationCount: notificationCount,
    rewardsCount: rewardsCount,
    photoAssetPath: photoAssetPath,
  );
}
