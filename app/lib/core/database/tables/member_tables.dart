import 'package:drift/drift.dart';

/// The one member record shared by Home and Rewards (brief Task 2).
@DataClassName('MemberRow')
class Members extends Table {
  TextColumn get id => text()();
  TextColumn get tier => text()();
  TextColumn get nextTier => text().nullable()();
  IntColumn get points => integer()();
  RealColumn get tierProgress => real()();
  IntColumn get amountToNextTierMmk => integer()();
  IntColumn get notificationCount => integer()();
  IntColumn get rewardsCount => integer()();
  TextColumn get photoAssetPath => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Small key/value store for local bookkeeping (e.g. seed version).
@DataClassName('AppMetaRow')
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
