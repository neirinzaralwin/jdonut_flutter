# Coding Rules — jdonut_flutter

## Engineering mindset (lazy senior dev)
Before writing code, stop at the first rung that holds:
1. Does it need to exist? (YAGNI — the brief + scoring is the scope)
2. Does it already exist here? Reuse the helper/widget/token.
3. Does the Dart/Flutter SDK do it? Use it.
4. Does an installed dependency do it? Use it.
5. Only then write the minimum code that works.

- No abstractions beyond what the brief requires (it *does* require: `AuthRepository` interface, 3 layers, Result type, DI).
- Bug fix = root cause: grep every caller, fix the shared function once.
- Mark deliberate corner-cuts with `// simplification: <ceiling> — <upgrade path>`.
- **Not** lazy about: validation, error states, offline behaviour, accessibility, Reduce Motion, tests — these are scored.

## Language & style
- Latest stable Dart 3 / Flutter. Sound null safety.
- `very_good_analysis`; `flutter analyze` must be clean. Never weaken a lint to silence it — fix the cause. Per-line `// ignore:` needs a reason comment.
- `const` constructors wherever possible; expression bodies (`=>`) for one-liners.
- Functions ≈ ≤ 20 lines, files ≈ ≤ 300 lines (brief). `build()` with more than one logical section → extract widgets.
- No `print`; use `debugPrint` or the Dio logging interceptor (debug only).
- Prefer Dart 3 features: `sealed` + `switch` pattern matching, records, `final class`.

## Naming
| Element | Convention | Example |
|---|---|---|
| Files | `snake_case.dart` | `phone_validator.dart` |
| Classes / enums | `UpperCamelCase` | `MemberTier` |
| Vars / functions | `lowerCamelCase` | `normalizePhone` |
| Constants | `lowerCamelCase` in an `abstract final class` | `AppConstants.minimumAgeYears` |
| Providers | `<thing>Provider` | `productDetailProvider` |
| Notifiers | `<Thing>Notifier` | `OtpNotifier` |
| State | `<Thing>State` | `OtpState` |
| Repo interface (domain) | `<Thing>Repository` | `AuthRepository` |
| Repo impl (data) | `<Thing>RepositoryImpl` / `Fake<Thing>Repository` | `FakeAuthRepository` |
| Use case | verb phrase, `call()` | `VerifyOtp` |
| DTO (data) | `<Thing>Dto` | `ProductDto` |
| Entity (domain) | plain noun | `Product` |
| Screens | `<Thing>Page` | `ProductDetailPage` |
| Tests | describe behaviour | `'strips one leading 0 after +95'` |

Names say what things are — no `data`, `info`, `helper`, `manager`, `util2`.

## Imports
- `package:jdonut/...` across folders; relative imports only between siblings in the same folder.
- Cross-feature: only through the other feature's `<feature>.dart` barrel (see `module_boundaries.md`).
- Domain never imports `package:flutter/*`, Dio, Drift or Riverpod.

## Constants & tokens (no magic numbers, no hard-coded colours — brief requirement)
| What | Where |
|---|---|
| Colours | `core/theme/app_colors.dart` (`AppColors.*`) → exposed via `ThemeData`/`ThemeExtension` |
| Text styles | `core/theme/app_typography.dart` (`AppTypography.*`) |
| Spacing / gaps / padding | `core/theme/app_spacing.dart` (`AppSpacing.s4` …) |
| Radii / sizes | `core/theme/app_radii.dart`, `app_sizes.dart` |
| Durations / curves | `core/motion/app_motion.dart` |
| Business rules | `core/constants/app_constants.dart` (OTP code, min age, lengths) |
| API paths | `core/network/api_paths.dart` |
| Routes | `core/router/app_routes.dart` |
| User-facing strings | ARB (`lib/l10n/app_en.arb`, `app_my.arb`) via `context.l10n` |

- `EdgeInsets.all(24)`, `SizedBox(height: 16)`, `Color(0xff…)`, `Colors.grey`, `Duration(milliseconds: 300)` inside a feature = violation.
- Text styles start from a token and extend with `.copyWith`.

## Models
- Domain entities: immutable (`freezed` or `final class` + `==`), no JSON.
- Data DTOs: `freezed` + `json_serializable`, with `toEntity()` / `fromEntity()` mappers. JSON never leaks above the data layer.
- Drift rows map to entities in the DAO/repository, never reach widgets.

## Errors
- Repositories return `Future<Result<T>>` or `Stream<T>`; never throw across layers.
- Data layer catches **specific** exceptions (`DioException`, `SqliteException`, `PlatformException`, `FormatException`) and maps to a typed `Failure`. No bare `catch (e)` without mapping; no empty catches.
- **Always `return await` inside `try`** — `return future()` escapes the catch.
- UI maps `Failure` → localized message in presentation, not in data.

## Widgets
- Widgets are presenters: render state, dispatch intents. No I/O, no Drift, no Dio, no secure storage, no `new Repository()`.
- `ConsumerWidget` / `ConsumerStatefulWidget`; `ref.watch` in build, `ref.read(...notifier)` in callbacks.
- `setState` only for purely visual, local state (animation controllers, focus) — never for data.
- Reuse shared components in `core/widgets/` — don't hand-roll a second version:
  - `AppButton` (scale-on-press + loading morph + single-flight) — all CTAs.
  - `AppTextField` / `OtpInput` — all inputs share one focus/error animation.
  - `AppNetworkImage` (cached, asset fallback, placeholder, error) — all images.
  - `Skeleton` / shimmer — all loading states (no spinners on Home).
  - `AppEmptyState` / `AppErrorState` — every section's empty/error.
  - `OfflineBanner` — offline indicator.
- Every async screen/section handles **loading, data, empty, error** (brief).
- Layout must survive 4.7"–6.9" and text scale 1.3: use `Flexible`/`Expanded`, `maxLines` + `overflow`, no fixed text heights.

## Async context safety
- In widgets: after `await`, `if (!context.mounted) return;` before using `context`, `Navigator`, `setState`.
- In notifiers: don't sprinkle mounted checks in app-scoped notifiers. In `autoDispose` notifiers use `ref.mounted` (Riverpod 3) or cancel in `ref.onDispose`.
- Timers/countdowns: one ticker owned by a notifier or `Stream.periodic` + `StreamBuilder`; cancel in `dispose`/`ref.onDispose`. No orphan `Timer.periodic`.

## Commits
- Small, conventional: `feat(auth): add phone validator`, `test(auth): …`, `refactor(core): …`. One concern per commit (scored).
- Generated files (`*.g.dart`, `*.freezed.dart`, `lib/l10n/gen`) are not committed; README explains build_runner.

## Fixed facts
- Fake OTP: `123456`. Min age: `AppConstants.minimumAgeYears = 13`. Resend: 5:00. Max wrong OTPs: 3.

## Forbidden
- Hard-coded colours/spacing/durations/strings in widgets.
- `package:flutter` in `domain/`.
- Dio outside `core/network/`; secure storage outside `core/storage/`; Drift outside `core/database/` + feature `data/`.
- Raw route strings outside `app_routes.dart`.
- Services/repositories constructed inside widgets.
- Spinners for Home loading (skeletons only).
- BLoC, GetX, Provider pkg, get_it — Riverpod only (one DI mechanism).
- Committing design screenshots.
- `// TODO` without a tracking note (`// TODO(name): …` + entry in README "Known gaps").
