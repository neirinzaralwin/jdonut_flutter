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

## Known gaps
_TBD_

## Time spent
_TBD_
