# Developer Guide — jdonut_flutter

Short daily routine for building features. Rules live in `AGENTS.md` and `docs/`; this file is the *how*.

## 1. First-time setup
```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # freezed / riverpod / drift code
flutter gen-l10n                                            # strings from ARB
flutter run
```
Optional mock server (Task 2 refresh only):
```bash
cd mock_server && npm install && npm start                  # http://localhost:3000/v1
```
The app finds it on its own: `localhost` on the iOS simulator, `10.0.2.2` on the Android emulator. Real device or another host: `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000`.
Fake OTP code: **123456**.

## 2. Command cheat sheet (run inside `app/`)
| When | Command |
|---|---|
| Added/changed `@freezed`, `@riverpod`, Drift table | `dart run build_runner build --delete-conflicting-outputs` |
| Editing a lot of those files | `dart run build_runner watch --delete-conflicting-outputs` |
| Added/changed a string in `lib/l10n/*.arb` | `flutter gen-l10n` |
| Format | `dart format lib test` |
| Auto-fix lints | `dart fix --apply` |
| Lint (must be clean) | `flutter analyze` |
| Tests | `flutter test` · one file: `flutter test path/to/file_test.dart` |
| Integration test (needs a simulator/emulator) | `flutter test integration_test -d <device-id>` |
| Run without the bundled catalog (debug) | `flutter run --dart-define=SKIP_SEED=true` |
| Server-only products on / off (repo `mock_server/`, server stopped) | `npm run incoming:add` · `npm run incoming:remove` |
| Added a package | `flutter pub add <pkg>` (+ a line in `DECISIONS.md`) |
| Refresh code graph (repo root) | `bash scripts/graphify.sh update .` |
| Ask the graph (repo root) | `bash scripts/graphify.sh query "how does X work"` |

Generated files (`*.g.dart`, `*.freezed.dart`, `lib/l10n/gen/`) are not committed — regenerate them.

## 3. Writing a new feature — step by step
Example: a `cart` feature. Work **inside-out**: domain → data → presentation.

**0. Read first**
- The task's spec in `docs/code-test/` and `docs/knowledge-base/coding_rules.md`.
- Unfamiliar code? `bash scripts/graphify.sh query "..."` before opening files.

**1. Folders**
```
lib/features/cart/
  domain/{entities,repositories,usecases}
  data/{datasources,models,repositories}
  presentation/{pages,widgets,providers}
  cart.dart            ← barrel: only what other features need
```

**2. Domain (pure Dart — no Flutter, Dio, Drift, Riverpod)**
- Entity: `domain/entities/cart_item.dart` (`@freezed`).
- Contract: `domain/repositories/cart_repository.dart` → `abstract interface class`, methods return `Future<Result<T>>` or `Stream<T>`.
- Rules/logic: pure functions or a use case class with `call()` in `domain/usecases/`.

**3. Data**
- Drift table? Add it in `core/database/tables/`, register in `@DriftDatabase(tables: [...])`, **bump `schemaVersion`** and add a migration step.
- Implementation: `data/repositories/cart_repository_impl.dart`. Catch specific exceptions → return `Err(Failure)`. Always `return await` inside `try`.

**4. Wire DI**
`presentation/providers/cart_dependencies.dart`:
```dart
@Riverpod(keepAlive: true)
CartRepository cartRepository(Ref ref) =>
    CartRepositoryImpl(ref.watch(appDatabaseProvider));
```

**5. State**
- Screen data → `@riverpod Stream<…>` / `Future<…>` provider (use `AsyncValue`).
- Actions/forms → `@riverpod class XNotifier` with a `@freezed` state; guard double taps (`if (state.isSubmitting) return;`).
- Then: `dart run build_runner build --delete-conflicting-outputs`

**6. UI**
- Page in `presentation/pages/`, pieces in `presentation/widgets/`.
- Styling: `import 'package:jdonut/core/theme/theme.dart';` → `context.colors`, `context.text`, `context.appColors`, `AppSpacing`, `AppRadii`, `AppSizes`.
- Text: add keys to `app_en.arb` **and** `app_my.arb` → `flutter gen-l10n` → `context.l10n.key`.
- Motion: durations/curves/staggers from `core/motion/app_motion.dart`; reuse `StaggeredEntrance`, `AppButton`, `AppTextField`.
- Handle loading (skeleton), empty, error.

**7. Route**
Add the path to `core/router/app_routes.dart`, then a `GoRoute` in `core/router/app_router.dart` (import the feature barrel).

**8. Test (only what matters)**
- Unit: every rule / use case → `test/features/cart/...` (mirrors `lib/`).
- Widget: validation or behaviour the brief grades. Helpers in `test/helpers/`.
- Names describe behaviour: `'rejects 31 April as an invalid date'`.

**9. Finish**
```bash
dart format lib test && flutter analyze && flutter test
bash ../scripts/graphify.sh update .   # from app/, or run from repo root
```
Update `docs/` / `DECISIONS.md` if a decision changed. Commit small.

## 4. Local data: where it comes from and how to reset it
On first launch the app copies the bundled JSON in `app/assets/seed/` into the Drift database (`jdonut.sqlite`): products, banners, sections, shops, member, challenges. Screens read only the database. If the mock server is reachable, a background sync (and pull-to-refresh) replaces the catalog with the server's data. The seed runs once per `seedVersion` in `lib/core/database/seed/seed_service.dart`.

**Start without the bundled catalog** (debug builds only; release always seeds):
```bash
flutter run --dart-define=SKIP_SEED=true
```
- Products, banners, sections and shops are not seeded. The member and challenges still are, so Home's header and Rewards work.
- Mock server off → Home shows its empty states. Mock server on → the catalog comes only from the server.
- A database seeded without the catalog is not marked as seeded, so a normal `flutter run` later adds the catalog.
- Already seeded? This flag does nothing to existing data — reset first (below).

**Reset to a brand-new install** (re-seeds on next launch). Stop the app first.
```bash
# iOS simulator
xcrun simctl uninstall booted com.madivizion.jdonut
xcrun simctl keychain booted reset     # the login lives in the Keychain, which survives uninstall

# Android emulator (database and login together)
adb shell pm clear com.madivizion.jdonut
```

**Empty the catalog but keep everything else** (stays empty after relaunch; iOS simulator):
```bash
DB="$(xcrun simctl get_app_container booted com.madivizion.jdonut data)/Documents/jdonut.sqlite"
sqlite3 "$DB" "DELETE FROM section_products; DELETE FROM sections; DELETE FROM products; DELETE FROM banners; DELETE FROM shops;"
```
- Add `DELETE FROM challenges;` to empty Rewards too. Don't delete the `members` row: Home's header needs it.
- Check: `sqlite3 "$DB" "SELECT COUNT(*) FROM products; SELECT * FROM app_meta;"` → `0` and `seed_version|4`.
- Bring the seed back: `sqlite3 "$DB" "DELETE FROM app_meta;"` and relaunch.
- Android: `adb shell "run-as com.madivizion.jdonut sqlite3 app_flutter/jdonut.sqlite '<same DELETEs>'"` (only if the emulator image has `sqlite3`).

**Re-seed but stay logged in:** bump `seedVersion` in `seed_service.dart`. Next launch replaces the catalog, member and challenges; users and the login are kept.

**Demo: new products arrive when the app comes back online.** Two products exist only on the mock server, never in the bundled seed: *Lavender Sugar Donut* (first in Seasonal specials) and *Chocolate Trio Box* (first in Donut boxes). Their photos are served by the server (`mock_server/public/images/products/`), so the app downloads and caches them when the data arrives.
```bash
# 1. App running, mock server STOPPED → "You're offline" toast, seeded catalog
# 2. Add the incoming products (server must be stopped: it reads db.json only at start)
cd mock_server && npm run incoming:add
# 3. Start the server → within ~5 s the toast turns green and both products appear
npm start
# Reset afterwards (stop the server first)
npm run incoming:remove
```
- Pull-to-refresh on Home also syncs right away.
- The products stay in the app's database after the server stops: the catalog is cached, so they still show offline, photos included.
- To see them disappear again: `npm run incoming:remove`, restart the server, pull to refresh.
- Defined in `mock_server/data/incoming.json`. `npm run sync-seed` leaves them out of the app's seed on purpose.

Keep the mock server stopped while testing empty states — the next sync fills the catalog again.

## 5. Commit routine
- One concern per commit, conventional message:
  `feat(cart): add cart repository` · `test(auth): cover OTP lock` · `fix(auth): ignore double tap` · `refactor(core): …` · `docs: …`
- Before each commit: `flutter analyze && flutter test`.
- Never commit design screenshots (keep them in `design_refs/`).

## 6. Quick "don't" list
- No hard-coded colours, sizes, durations, strings or **data** in widgets.
- No `package:flutter` in `domain/`.
- No services/repositories created in widgets — use providers.
- No importing another feature's internals — use its barrel.
- No `sealed` unless the cases carry different data (see `coding_rules.md`).

## 7. Troubleshooting
| Problem | Fix |
|---|---|
| `Undefined name 'xxxProvider'` / missing `_$Foo` | Run build_runner; check the `part '...g.dart';` line. A syntax error in the file silently skips generation — run `flutter analyze` on it. |
| `AppLocalizations` getter missing | `flutter gen-l10n` |
| build_runner conflicts | add `--delete-conflicting-outputs` |
| DB crash after changing a table | bump `schemaVersion` + migration, or reset the app (section 4) |
| Seed JSON changed but the app shows old data | bump `seedVersion`, or reset the app (section 4) |
| Home stuck on skeletons after editing the DB by hand | the `members` row is missing — reset the app (section 4) |
| Weird stale state | `flutter clean && flutter pub get` then build_runner + gen-l10n |
