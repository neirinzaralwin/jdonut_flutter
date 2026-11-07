# Decisions — packages & architecture

Short rationale for each choice. "Brief" = the code test requirement it answers.

## Packages

| Area | Picked | Over | Why |
|---|---|---|---|
| State management | **Riverpod 3** (+ `riverpod_annotation`) | BLoC, Provider, GetX | One tool for **state and DI** (brief allows either). Providers are compile-safe, testable with `overrides`, need no `BuildContext`, and `AsyncValue` gives loading/error/data for every screen. BLoC would need events + states + get_it for DI — more boilerplate for a 2-day test. |
| Dependency injection | **Riverpod providers** | get_it | Same container as state → one DI mechanism; swap `FakeAuthRepository` for a real one by changing one provider. |
| Navigation | **go_router** | Navigator 2 by hand, auto_route | Required by brief; `redirect` gives the auth guard, `/product/:id` path params, no codegen. |
| Local DB | **Drift (SQLite)** | Hive CE, ObjectBox, Isar | Recommended by brief. Relational data (sections → products), reactive `watch()` streams for offline-first UI, typed **versioned migrations**, in-memory DB for tests. |
| Session | **flutter_secure_storage** | shared_preferences | Required by brief; token stored in Keychain/Keystore. |
| Network | **Dio** | http | Required by brief (if server). Interceptors for timeout, retry and logging. |
| Models | **freezed + json_serializable** | Hand-written classes | Immutable, `copyWith`, `==`, unions for state, JSON mapping without hand code. |
| Images | **cached_network_image** | Image.network | Disk cache + placeholder + error builder (brief); bundled assets as offline fallback. |
| Connectivity | **connectivity_plus** + `/v1/health` ping | connectivity_plus alone | It only reports the interface; a reachability call detects "Wi-Fi with no internet". |
| Lints | **very_good_analysis** | flutter_lints | Stricter; brief scores "analyze clean". |
| Tests | **mocktail** | mockito | No codegen, null-safe mocks. |
| l10n | **gen-l10n (ARB)** | easy_localization | Required by brief; built into Flutter; adds Burmese (`my`). |
| Animation | **Flutter APIs + CustomPainter** | Lottie / Rive | Brief: most motion should use Flutter's own APIs; ring and progress art drawn with CustomPainter. |
| Fonts | **Nunito** (headings) + **Nunito Sans** (body), bundled TTFs | google_fonts | Bundled so the first launch offline renders the right font (brief: airplane mode). Variable fonts; weight via `FontVariation`. |
| Value equality | **freezed** | equatable | freezed already generates `==`/`hashCode`; adding equatable would duplicate it. |
| Mock server | **json-server 0.17** | Express by hand, no server | Optional in brief. Zero-code REST from `db.json`, plus a small wrapper for `/v1` and the `{data, error, meta}` envelope. |

## Architecture decisions

| Decision | Why |
|---|---|
| Feature-first folders, each `presentation / domain / data` | Brief requirement; features stay independent. |
| Domain is pure Dart | Brief; validators and use cases unit-test without Flutter. |
| Repositories return `Result<T>` with typed `Failure` | Brief: typed failures, no swallowed exceptions. |
| Local DB is the **single source of truth** | UI only reads Drift; network only upserts into Drift → works in airplane mode with no extra code paths. |
| Seed from bundled JSON on first launch | First launch must work offline (brief). Same JSON is generated from the mock server's `db.json` (`npm run sync-seed`), so both sources match. |
| Member record + challenges are local-only | Mock-ups disagree (Bronze/1,290 vs Silver/500); one record read by Home and Rewards (brief). |
| `AuthRepository` interface + `FakeAuthRepository` (1 s delay) | Brief; real API replaces it without touching UI. |
| Countdown from stored `expiresAt` | Survives backgrounding; no drift from a decrementing timer. |
| All durations/curves in `app_motion.dart` | Brief: named constants in one motion file; one place to honour Reduce Motion. |
| Design tokens in one theme (`ColorScheme` + `ThemeExtension`) | Brief: no hard-coded colours in widgets. Palette sampled from the PDF screens; see `docs/knowledge-base/design_system.md`. |
| Monorepo: `app/`, `mock_server/`, `docs/` | App, optional server and specs are kept together. |
