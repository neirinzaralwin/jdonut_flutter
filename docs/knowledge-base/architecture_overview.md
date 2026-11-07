# Architecture

## Decisions
| Concern | Choice | Why |
|---|---|---|
| State + DI | **Riverpod** (`flutter_riverpod` + `riverpod_annotation`) | One tool for DI and state; providers are overridable in tests; no BuildContext lookups |
| Navigation | **go_router** with `redirect` guard on session state | Required; `/product/:id` deep-linkable |
| Local DB | **Drift** (SQLite) with `schemaVersion` + `MigrationStrategy` | Recommended in brief; reactive `watch()` streams drive UI |
| Session | **flutter_secure_storage** | Required |
| Network | **Dio** + timeout, retry, logging interceptors | Required if server exists |
| Models | **freezed** + json_serializable | Immutable, `copyWith`, unions for state |
| Errors | `Result<T>` sealed class (`Ok` / `Err(Failure)`) | Typed failures, nothing swallowed |
| Images | cached_network_image + bundled seed assets | Offline images on first launch |
| Connectivity | connectivity_plus + reachability ping (`GET /v1/health` or DNS lookup) | connectivity_plus alone lies on captive Wi-Fi |

## Layers (per feature)
```
presentation  (widgets, pages, Riverpod notifiers)  ──depends on──▶  domain
data          (Drift DAOs, Dio APIs, DTOs, repo impls) ──implements──▶ domain
domain        (entities, repository interfaces, use cases, validators)  — pure Dart, no Flutter
```

## Offline-first data flow (Task 2)
```
first launch:  assets/seed/*.json ──▶ SeedService ──▶ Drift (if empty)
UI reads:      Drift.watch() ──▶ Repository stream ──▶ Notifier ──▶ Widget
refresh:       connectivity online / pull-to-refresh ──▶ Dio GET /v1/... ──▶ upsert into Drift
                                                        (Drift stream re-emits; UI never reads network directly)
```
- The DB is the **only** thing the UI reads. Network failure = keep cached data + offline banner.
- `meta.version` / `updatedAt` from the server decide whether to upsert.
- Member record lives only in Drift and is shared by Home and Rewards (resolves the mock-up mismatch).

## Auth (Task 1)
- `AuthRepository` (domain) ← `FakeAuthRepository` (data): 1 s delay, users stored in Drift `users` table, session token in secure storage.
- `sessionProvider` is a stream the router listens to (`refreshListenable`) for redirects.
- Registration draft (phone, names, dob) is kept in a `RegistrationDraft` notifier so back navigation preserves inputs.

## Motion (Task 3)
- All durations/curves in `core/motion/app_motion.dart`.
- `MotionScope` helper returns `Duration.zero` when `MediaQuery.disableAnimationsOf(context)` is true.
- Painters live in `features/rewards/presentation/painters/`.
