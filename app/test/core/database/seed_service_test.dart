import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/database/app_database.dart';
import 'package:jdonut/core/database/seed/seed_service.dart';
import 'package:jdonut/features/home/data/repositories/home_repository_impl.dart';
import 'package:jdonut/features/home/domain/entities/home_section.dart';

import '../../helpers/file_asset_bundle.dart';

void main() {
  late AppDatabase database;
  late SeedService seed;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    seed = SeedService(database, FileAssetBundle());
  });
  tearDown(() => database.close());

  test('first launch fills the DB from bundled JSON', () async {
    await seed.seedIfNeeded();

    expect(await database.select(database.products).get(), isNotEmpty);
    expect(await database.select(database.members).get(), hasLength(1));
  });

  test(
    'SKIP_SEED: member only, empty catalog; a normal run seeds it later',
    () async {
      await seed.seedIfNeeded(withCatalog: false);

      expect(await database.select(database.products).get(), isEmpty);
      expect(await database.select(database.shops).get(), isEmpty);
      expect(await database.select(database.members).get(), hasLength(1));
      expect(await database.select(database.challenges).get(), isNotEmpty);

      await seed.seedIfNeeded();

      expect(await database.select(database.products).get(), isNotEmpty);
    },
  );

  test('seeding again does not duplicate or wipe data', () async {
    await seed.seedIfNeeded();
    final count = (await database.select(database.products).get()).length;

    await seed.seedIfNeeded();

    expect(await database.select(database.products).get(), hasLength(count));
  });

  test(
    'home sections come back in order with their products in order',
    () async {
      await seed.seedIfNeeded();

      final sections = await HomeRepositoryImpl(database).watchSections().first;

      expect(sections.first.id, 'seasonal');
      expect(sections.first.layout, SectionLayout.featured);
      expect(sections.first.products.first.id, 'p_strawberry_ring');
      expect(sections.every((section) => section.products.isNotEmpty), isTrue);
    },
  );
}
