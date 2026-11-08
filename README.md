# J'Donuts — Flutter Code Test

> Submission README — fill every section listed in `docs/deliverables-checklist.md`.

## Quick start
```bash
# 1. mock server (optional — app works fully offline without it)
cd mock_server && npm install && npm start

# 2. app
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter run                                        # iOS simulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000   # Android emulator
```
`app/tool/bootstrap.sh` is a one-time scaffolding script for the author (platform folders + adding packages); reviewers don't need it.

Fake OTP code: **123456**

## Versions
Flutter: _TBD_ · Dart: _TBD_

## Developer guide
Daily routine and commands: [`DEVELOPER_GUIDE.md`](DEVELOPER_GUIDE.md).

## Decisions
Why each package and design choice: see [`DECISIONS.md`](DECISIONS.md).

## Architecture
See `docs/knowledge-base/architecture_overview.md` and `docs/knowledge-base/folder_structure.md`.

## State management
Riverpod — _reasoning TBD_

## Offline strategy
_TBD_

## Animations
_TBD_

## Tests
```bash
cd app
flutter test                                   # unit + widget + layout (no device needed)
flutter test integration_test -d <device-id>   # Register → Home → Product detail → Rewards, on a simulator/emulator
```
- `test/app_layout_test.dart` walks every screen of the main flow on a 4.7" and a 6.9" phone at text scale 1.3 with the real fonts; any overflow fails it.
- `integration_test/app_flow_test.dart` runs the real app on a fresh in-memory database, so each run starts as a new user.

## Known gaps
Deliberate choices that differ from the brief:
- **Earn does something (demo).** The brief asks for press feedback only. Tapping a complete challenge's Earn flies "+100 pts" into the ring and the total counts up. It is kept in memory only (no earn endpoint in the brief), so it resets on restart.
- **Quantity starts at 0 on Product detail.** The design hides Add to cart until the first +, so the stepper starts at 0 instead of the brief's minimum of 1. From 1 upwards it behaves as specified (live total = quantity × price).

## Time spent
_TBD_
