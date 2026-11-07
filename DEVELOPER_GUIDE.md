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
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000 # Android emulator
```
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
| Integration test | `flutter test integration_test` |
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

## 4. Commit routine
- One concern per commit, conventional message:
  `feat(cart): add cart repository` · `test(auth): cover OTP lock` · `fix(auth): ignore double tap` · `refactor(core): …` · `docs: …`
- Before each commit: `flutter analyze && flutter test`.
- Never commit design screenshots (keep them in `design_refs/`).

## 5. Quick "don't" list
- No hard-coded colours, sizes, durations, strings or **data** in widgets.
- No `package:flutter` in `domain/`.
- No services/repositories created in widgets — use providers.
- No importing another feature's internals — use its barrel.
- No `sealed` unless the cases carry different data (see `coding_rules.md`).

## 6. Troubleshooting
| Problem | Fix |
|---|---|
| `Undefined name 'xxxProvider'` / missing `_$Foo` | Run build_runner; check the `part '...g.dart';` line. A syntax error in the file silently skips generation — run `flutter analyze` on it. |
| `AppLocalizations` getter missing | `flutter gen-l10n` |
| build_runner conflicts | add `--delete-conflicting-outputs` |
| DB crash after changing a table | bump `schemaVersion` + migration, or uninstall the app during dev |
| Weird stale state | `flutter clean && flutter pub get` then build_runner + gen-l10n |
