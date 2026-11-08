# START — run J'Donuts in 5 minutes

Needs: Flutter (stable), Node 18+, an iOS simulator or Android emulator running.

## 1. Install (once)
```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

```bash
cd ../mock_server
npm install
```

## 2. Start the mock server (optional — the app works fully offline)
New terminal, from the repo root:
```bash
cd mock_server
npm start
```

## 3. Run the app
```bash
cd app
flutter devices
```
```bash
flutter run -d <device-id>
```
Real phone instead of simulator/emulator: add `--dart-define=API_BASE_URL=http://<your-computer-ip>:3000`.

## 4. Try it
| Step | Enter |
|---|---|
| Phone | `09254135592` (any valid Myanmar number) |
| OTP | `123456` |
| Name, date of birth | anything valid (must be 13+) |

Then: Home → tap a donut → Product detail → Reward tab → tap **Earn** on a completed challenge.

## 5. Demo: new data arrives when back online
1. Stop the mock server (`Ctrl+C`). The app shows **You're offline**.
2. Add two server-only products:
   ```bash
   cd mock_server
   npm run incoming:add
   ```
3. Start the server again:
   ```bash
   npm start
   ```
4. Within ~5 s the toast turns green; **Lavender Sugar Donut** and **Chocolate Trio Box** appear first in their rows (or pull to refresh).

Reset (server stopped):
```bash
npm run incoming:remove
```

## 6. Start with an empty catalog (empty states)
Uninstall first, then run with the bundled catalog skipped:
```bash
xcrun simctl uninstall booted com.madivizion.jdonut && xcrun simctl keychain booted reset   # iOS simulator
adb shell pm clear com.madivizion.jdonut                                                   # Android emulator
```
```bash
flutter run -d <device-id> --dart-define=SKIP_SEED=true
```
Server stopped → empty states. Server running → catalog comes only from the server.

## 7. Tests
```bash
cd app
flutter analyze
flutter test
```
```bash
flutter test integration_test -d <device-id>
```

More: `README.md` (overview), `DEVELOPER_GUIDE.md` (details, reset commands), `DECISIONS.md` (why).
