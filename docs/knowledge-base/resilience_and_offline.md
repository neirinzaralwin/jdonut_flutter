# Resilience & Offline — checklist

> Don't only check that a feature works. Check that it **fails safely, recovers, and stays consistent** under offline, timeout, double tap, app kill and bad data. Mandatory for Task 1 (auth) and Task 2 (data).

## Offline-first (Task 2 — 20% of score)
- [ ] UI reads **only** Drift streams. Network results are upserted into Drift; never rendered directly.
- [ ] First launch seeds Drift from `assets/seed/*.json` inside **one transaction**, guarded by a `seed_version` flag (re-seed only on version bump).
- [ ] Airplane mode after first launch: Home, Product detail, Rewards render, **images included** (asset fallback when cache misses).
- [ ] Refresh triggers: app start (background), connectivity regained, pull-to-refresh. Refresh failures keep cached data and show a non-blocking message.
- [ ] Online = `connectivity_plus` **and** reachability (`GET /v1/health`, short timeout). Wi-Fi without internet = offline.
- [ ] Offline banner animates in/out, doesn't shift layout jankily.
- [ ] Upserts are idempotent (by id) and atomic (batch/transaction). Rows absent from a full server list are deleted in the same transaction.
- [ ] Malformed envelope / JSON → `ServerFailure`, cache untouched.
- [ ] Drift `schemaVersion` + `MigrationStrategy` with stepwise migrations; migration test exists.

## Network (Dio)
- [ ] Connect/receive/send timeouts from constants.
- [ ] Retry interceptor: **GET only**, max 3 attempts, exponential backoff + jitter, never on 4xx.
- [ ] Logging interceptor in debug only.
- [ ] Every `DioException` type mapped to a `Failure`.
- [ ] Envelope parsed once in `ApiEnvelope<T>`; `error != null` → `ServerFailure(code)`.

## Auth & session (Task 1)
- [ ] Session in `flutter_secure_storage` only; read at bootstrap before first frame decides route (no flash of Onboarding).
- [ ] Corrupt/unreadable secure storage → treat as logged out, clear it, don't crash.
- [ ] Single-flight: Continue disabled + notifier guard → double tap = one request.
- [ ] OTP lock state (3 wrong) survives back/forward within the flow; Resend resets attempts + timer.
- [ ] Countdown derived from a stored `expiresAt`, not by decrementing — survives app backgrounding.
- [ ] Registration writes user + session as one operation; a failure leaves no half-registered user.
- [ ] Log out clears session + registration draft; router redirects immediately.

## Images
- [ ] `cached_network_image` disk cache; placeholder (skeleton) + error widget (asset fallback, then icon).
- [ ] Seed images bundled; `assetPath` preferred when offline and not cached.

## Questions to ask for every feature
- What if the network drops mid-request? Times out? Returns garbage?
- What if the user taps twice? Leaves the screen mid-request? Kills the app?
- What does the user see in each case — and is it localized?
