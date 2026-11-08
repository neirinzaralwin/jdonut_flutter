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
- Use Dart 3 features where they fit: `switch` pattern matching, records, `final class`; `sealed` only per "When to use sealed classes" below.

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
Full spec: `design_system.md`. Import `package:jdonut/core/theme/theme.dart` once; use `context.colors`, `context.text`, `context.appColors`, static `AppSpacing`/`AppRadii`/`AppSizes`.
| What | Where |
|---|---|
| Colours | `context.colors.*` / `context.appColors.*` (raw palette `AppPalette` only inside `core/theme/`) |
| Text styles | `context.text.*` (+ `AppTypography.numeric`) — Nunito headings, Nunito Sans body |
| Spacing / gaps / padding | `AppSpacing.*` (`core/theme/app_spacing.dart`) |
| Radii / sizes | `AppRadii.*`, `AppSizes.*` (same file) |
| Durations / curves | `core/motion/app_motion.dart` |
| Business rules | `core/constants/app_constants.dart` (OTP code, min age, lengths) |
| API paths | `core/network/api_paths.dart` |
| Routes | `core/router/app_routes.dart` |
| User-facing strings | ARB (`lib/l10n/app_en.arb`, `app_my.arb`) via `context.l10n` |

- `EdgeInsets.all(24)`, `SizedBox(height: 16)`, `Color(0xff…)`, `Colors.grey`, `AppPalette.pink` in a widget, `Duration(milliseconds: 300)` inside a feature = violation.
- Text styles start from a token and extend with `.copyWith` — never `TextStyle(fontSize: …)` from scratch (it loses the font's weight variation).

## Packages
- Add a package only when it's required/recommended by the brief or saves real code. Check `DECISIONS.md` first; record any new package there with a one-line reason.
- Not used on purpose: `equatable` (freezed already gives `==`), `google_fonts` (fonts bundled for offline), `get_it` (Riverpod is the DI), `sqlite3_flutter_libs` (bundled by `drift_flutter`).

## When to use sealed classes (only when necessary)
Use a `sealed class` **only** when a value is exactly one of a fixed set of cases, the cases carry **different data**, and callers must handle every case (exhaustive `switch`). Otherwise don't.

| Use sealed | Example in jdonut |
|---|---|
| Result / failures | `Result<T>` → `Ok`/`Err`; `Failure` subtypes; `OtpOutcome` → `SignedIn(user)` / `ContinueRegistration` |
| State with case-specific data driving different UI | `SessionState` (`SessionUnknown`/`Authenticated(user)`/`Unauthenticated`), `SyncState` (`failed(failure)`) |
| Variants rendered differently | `ChallengeArtwork` → `donut(quarters)` / `coffee(filled, total)` |

| Don't use sealed | Use instead |
|---|---|
| Loading / data / error of a fetch | Riverpod `AsyncValue` (don't re-wrap) |
| Single-shape data (`Product`, `Shop`, `Member`) | freezed class |
| Cases with no data (tier, tab, online/offline, validator errors `PhoneError`/`NameError`/`DateOfBirthError`, `AuthFailureKind`) | `enum` (enhanced enum if it needs a label/colour) |
| A single flag (`isSubmitting`) | field on the state |

How to write: pure-domain types (`Result`, `Failure`, `SessionState`, `OtpOutcome`) → plain Dart 3 `sealed class` (no codegen in domain). Presentation state needing `copyWith` → freezed sealed union. Always consume with an exhaustive `switch` — no `default:` branch, so a new case fails compilation.

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
  - `ConnectionBanner` — toast-like pill: dark while offline → green "back online" → floats away (lives in `app.dart`, shows on every screen).
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

## Brief → rule checklist (code test, Technical requirements + evaluation)
Every line here is graded or a hard fail. Check before finishing a task.
| Brief says | Rule |
|---|---|
| **Fail:** data hard-coded inside widgets | Widgets never contain product/banner/shop/member/challenge data, lists or prices — all come from Drift via providers (seeded from `assets/seed/*.json`). Placeholder screens show only l10n strings. |
| **Fail:** doesn't build from README / crashes in main flow | README steps tested on a clean clone; no `!` on data that can be missing; every async path handles errors. |
| Functions ~20 lines, files ~300 | Split early; `build()` sections → private widgets/files. |
| Named constants, no magic numbers | Tokens / `AppConstants` / `app_motion.dart`. |
| Names that say what things are | See Naming. |
| `flutter analyze` clean | very_good_analysis, zero warnings/infos. |
| Domain has no Flutter imports | See `module_boundaries.md`. |
| No services created inside widgets | Riverpod providers only. |
| Typed failures as Result, no swallowed exceptions | See Errors. |
| Every screen: loading, error, empty | Skeleton / `AppErrorState` / `AppEmptyState`. |
| No hard-coded colours; tokens in one theme | `context.colors` / `context.text` / `context.appColors`. |
| Strings in ARB | `context.l10n`; Burmese keys kept in sync. |
| 4.7"–6.9", text scale 1.3 | No fixed text heights; `maxLines` + `overflow`; test at 1.3. |
| Durations/curves in one motion file, Reduce Motion | `motion_rules.md`. |
| Double tap sends one request | Disabled button + notifier guard. |
| AI tools allowed, **must explain every line** | Agents write only code that is idiomatic and explainable: no unexplained cleverness, no unused code, no copied snippets the author can't justify. Non-obvious decisions get a one-line `why` comment. |
| Small readable commits | One concern per commit, conventional message. |

## Forbidden
- Hard-coded colours/spacing/durations/strings in widgets.
- Hard-coded **data** in widgets (products, prices, member, shops, challenges) — instant fail in the brief.
- `package:flutter` in `domain/`.
- Dio outside `core/network/`; secure storage outside `core/storage/`; Drift outside `core/database/` + feature `data/`.
- Raw route strings outside `app_routes.dart`.
- Services/repositories constructed inside widgets.
- Spinners for Home loading (skeletons only).
- BLoC, GetX, Provider pkg, get_it — Riverpod only (one DI mechanism).
- Committing design screenshots.
- `// TODO` without a tracking note (`// TODO(name): …` + entry in README "Known gaps").
