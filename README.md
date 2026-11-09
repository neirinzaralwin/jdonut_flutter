# Educational Purpose Project for Code Test

**▶ Demo video (app walkthrough + code explanation):** https://drive.google.com/file/d/1-BX3y4Yq-In29AOiuc4MM5tGWsw9ZoZm/view?usp=drive_link

**Run it in 5 minutes:** [`START.md`](START.md) — copy-paste steps for reviewers.

**Decisions I made and why** (packages, architecture, offline, UI deviations): [`DECISIONS.md`](DECISIONS.md)

**For developers** (setup, daily commands, data reset, adding a feature): [`DEVELOPER_GUIDE.md`](DEVELOPER_GUIDE.md)

---

## Deliverables

| # | Asked for | Where |
|---|---|---|
| 1 | Public Git repo, small readable commits | https://github.com/neirinzaralwin/jdonut_flutter |
| 2 | Release `.apk` (Android) | [Download `.apk`](https://drive.google.com/file/d/1Lu-YfzMeT8Et_ocnNhQcldhbB4C4VM0C/view?usp=drive_link) · build: `flutter build apk --release` |
| 2 | Zipped iOS Simulator `.app` | [Download `.zip`](https://drive.google.com/file/d/1XcKKVX_bg1t1qE9FRgOMT2hbhJVsotN_/view?usp=sharing) · build: `flutter build ios --simulator` |
| 3 | 2–4 min screen recording (register, log out, log in, Home, Product, Rewards, then airplane mode) | [Demo video](https://drive.google.com/file/d/1-BX3y4Yq-In29AOiuc4MM5tGWsw9ZoZm/view?usp=drive_link) |
| 4 | README (run, versions, architecture, state, offline, animations, OTP, gaps, time) | This file |
| — | Optional: mock server + how to run | [`mock_server/`](mock_server/) · [`docs/mock-server.md`](docs/mock-server.md) |

Design screenshots are **not** in the repo (client-owned; `design_refs/` is git-ignored).

---

## How to run

```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # freezed / riverpod / drift code
flutter gen-l10n                                            # strings from ARB
flutter devices
flutter run -d <device-id>
```

- **Fake OTP code: `123456`** · any valid Myanmar number, e.g. `09254135592` · age must be 13+.
- **Mock server is optional** — the app works fully offline. To show background refresh:
  ```bash
  cd mock_server && npm install && npm start      # http://localhost:3000/v1
  ```
  The app finds it on its own (iOS simulator `localhost`, Android emulator `10.0.2.2`). Real device: `--dart-define=API_BASE_URL=http://<computer-ip>:3000`.
- Step-by-step demos (new data arriving when back online, empty states): [`START.md`](START.md).

**Install the builds:**
- Android: download the `.apk` onto a phone or emulator and open it (allow installs from unknown sources), or `adb install app-release.apk`.
- iOS Simulator: unzip, boot a simulator, then drag `Runner.app` onto it, or `xcrun simctl install booted Runner.app` and `xcrun simctl launch booted com.madivizion.jdonut`.

## Versions

| | |
|---|---|
| Flutter | 3.47.9 (stable) |
| Dart | 3.13.7 |
| Min SDK constraint | `sdk: ^3.8.0` |

---

## What's built

| Task | Screens | Highlights |
|---|---|---|
| **1 — Auth** | Onboarding, Phone, OTP, Name, Date of birth, Welcome | Every validation rule as a pure domain function with unit tests · fake `AuthRepository` (1 s delay) · OTP shake + 3-try lock + 5:00 resend · back keeps input · session kept across relaunch (secure storage) · Log out in Settings |
| **2 — Offline Home + Product** | Home, Product detail | Drift DB is the single source of truth · bundled seed on first launch · background + pull-to-refresh sync from the mock server · disk image cache with bundled fallbacks · offline toast · Hero image, MMK prices, live total |
| **3 — Rewards** | Rewards | Tier ladder, `CustomPainter` points ring with count-up, sliding tab pill, donut/coffee progress art, staggered cards, pulsing Earn, one entrance replayed on each visit |

Flow and screens: [`docs/diagrams/architecture-overview.md`](docs/diagrams/architecture-overview.md).

## Architecture

Clean architecture, **feature-first**, three layers: **presentation → domain ← data**. The domain is pure Dart (no Flutter, Dio, Drift or Riverpod), so swapping fake auth or the mock server for a real back end never touches UI.

```
app/lib/
  core/            shared: database (Drift), network (Dio), router, theme, motion, l10n, widgets
  features/
    auth/          Task 1   ─┐
    home/          Task 2    │ each: domain/ (entities, repository contracts, validators, use cases)
    product/       Task 2    │       data/   (repository impls, data sources, mappers)
    member/        shared    │       presentation/ (pages, widgets, providers)
    rewards/       Task 3    │       <feature>.dart barrel — the only import other features use
    shell/         bottom nav┘
    settings/      Log out
  l10n/            English + Burmese ARB
```

- Repositories return a `Result<T>` with typed `Failure`s — no swallowed exceptions.
- Dependency injection through Riverpod providers; nothing is constructed inside widgets.
- Navigation: go_router with an auth redirect guard and a `/product/:id` route.

| Diagram | Shows |
|---|---|
| [Architecture overview](docs/diagrams/architecture-overview.md) | Layers, features, startup |
| [Auth](docs/diagrams/auth-diagram.md) | Task 1 flow, guard, session |
| [Offline data](docs/diagrams/offline-data-diagram.md) | Seed, sync, offline detection, image cache |
| [Home + Product](docs/diagrams/home-product-diagram.md) | Task 2 screens, navigation, motion |
| [Rewards](docs/diagrams/rewards-diagram.md) | Task 3 data flow and widgets |

Every package and design choice, with a one-line reason: [`DECISIONS.md`](DECISIONS.md). Coding rules: [`docs/knowledge-base/`](docs/knowledge-base/).

## State management — Riverpod 3 (with code generation)

- **Compile-safe DI and state in one tool:** repositories, the database and the API client are providers, so tests swap them with one override.
- **Fits a stream-driven, offline-first app:** screens watch Drift streams through `AsyncValue`, which gives loading / error / data states for free.
- **Form flows** (phone, OTP, register) are `Notifier`s with immutable freezed state; double taps are guarded in the notifier, so one tap = one request.
- BLoC would work too; Riverpod needed less boilerplate for this many small, independent pieces of state.

## Offline strategy

1. **First launch:** bundled JSON (`app/assets/seed/`) is copied into **Drift (SQLite)** before the first frame. Images for seeded items are bundled as assets.
2. **The UI reads only the database** (reactive `watch()` queries) — never the network or JSON directly.
3. **Refresh:** when online, a background sync (at launch, on reconnect, and on pull-to-refresh) fetches `/v1/...` from the mock server and replaces the catalog in **one transaction**; the UI updates by itself.
4. **Images:** `cached_network_image` on a 30-day disk cache; bundled asset first, network image cached after the first view, placeholder and error states.
5. **Connectivity:** `connectivity_plus` **plus** a real `/health` reachability check — a toast shows *You're offline · showing saved data* and *You're back online*.
6. **Retries:** GET only, 3 tries with backoff for timeouts and 5xx; no retry on "connection refused" or 4xx.
7. **One member record** feeds Home and Rewards, so both screens always agree.

In airplane mode after first launch, Home, Product detail and Rewards all render with images. Details: [`docs/diagrams/offline-data-diagram.md`](docs/diagrams/offline-data-diagram.md).

## Animations built

All durations, curves and stagger slots are named constants in [`app_motion.dart`](app/lib/core/motion/app_motion.dart). **Reduce Motion** (`MediaQuery.disableAnimations`) is respected everywhere — animations jump to their end state.

| Where | What moves |
|---|---|
| Onboarding | Donut circles drift in from the edges; title and buttons enter staggered |
| Registration steps | Shared-axis transitions; progress ring 25 → 50 → 75 → 100%, then morphs into a check |
| Inputs | Animated focus and error states; OTP boxes shake on a wrong code |
| Buttons | Scale on press; Continue morphs into a loading state |
| Welcome | Donut tiles slide in staggered, then the title fades up |
| Home | Shimmer skeletons; staggered sections; auto-playing carousel; header collapses with overlap; donut pull-to-refresh; offline/online toast |
| Product | Hero image from tile to detail; rolling quantity number; Add to cart bar slides up |
| Tab switch | Bottom-nav pill slides between tabs |
| Rewards | Ladder steps in, current tier scales, connector fills; ring sweeps while points count up; badge pops; tab pill slides; cards and progress art reveal staggered; Earn pulses — and (demo) flies "+100 pts" into the ring |

## Tests

```bash
cd app
flutter analyze                                 # clean
flutter test                                    # 108 tests: unit, widget, layout
flutter test integration_test -d <device-id>    # Register → Home → Product detail → Rewards
```

- **Unit:** every validator rule, use cases, retry policy, seed + migrations, sync.
- **Widget:** login and registration validation, Date of birth, connection banner, product detail, Rewards.
- **Layout:** every screen on a 4.7" and a 6.9" phone at **text scale 1.3** with the real fonts — any overflow fails.
- **Integration:** the real app on a fresh database, new user to Product detail.

## Known gaps

Deliberate choices that differ from the brief:
- **Earn does something (demo).** The brief asks for press feedback only. A completed challenge's Earn flies "+100 pts" into the ring and the total counts up — in memory only (the brief has no earn endpoint), reset on restart.
- **Quantity starts at 0 on Product detail.** The design hides Add to cart until the first +, so the stepper starts at 0 instead of the brief's minimum of 1. From 1 up it behaves as specified.
- **Date of birth uses the native picker.** The Month / Day / Year boxes match the design; tapping one opens the platform picker (iOS wheel, Android calendar), so only real calendar dates can be picked.
- **Social sign-in, Terms and Privacy** show a placeholder sheet (no integration, as the brief allows).
- **Not done:** CI pipeline (optional in the brief).

## Timeline and time spent

| When | What |
|---|---|
| Nov 7, evening | Brief broken into specs, architecture, coding rules, project setup |
| Nov 8 | Task 1 (auth + validation tests), Task 2 (offline data, Home, Product detail, mock server) |
| Nov 8 – 9 | Task 3 (Rewards), animations polish, layout + integration tests, docs |

**Time spent:** 2-4 hrs per day = 10-12 hrs elapsed in total, within the 2-day window.

---

**More reading:** [`START.md`](START.md) (run + demos) · [`DEVELOPER_GUIDE.md`](DEVELOPER_GUIDE.md) (daily commands, data reset) · [`DECISIONS.md`](DECISIONS.md) (why) · [`docs/`](docs/) (specs, rules, diagrams)
