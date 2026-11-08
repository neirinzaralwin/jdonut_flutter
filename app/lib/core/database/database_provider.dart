import 'package:flutter/services.dart';
import 'package:jdonut/core/database/app_database.dart';
import 'package:jdonut/core/database/seed/seed_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
}

@Riverpod(keepAlive: true)
SeedService seedService(Ref ref) =>
    SeedService(ref.watch(appDatabaseProvider), rootBundle);
