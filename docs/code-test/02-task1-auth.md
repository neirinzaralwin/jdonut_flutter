# 02 — Task 1: Fake login and registration, real validation

Login/registration are fake, **every validation rule must work**.

> **Scope note (our decision):** Task 1 is fully local. It does **not** use the json-server mock server (`docs/mock-server.md` serves only public catalog data and is read-only). No Dio / `core/network` imports in `features/auth`. Users → Drift `users` table; session → `flutter_secure_storage`; fake delay → `AppConstants.fakeAuthDelay`. A future `ApiAuthRepository` would replace `FakeAuthRepository` in one provider without touching UI.

## Repository contract
- Auth sits behind an `AuthRepository` interface (domain).
- Fake implementation waits ~1 s and stores users locally, so a real API can replace it without touching UI.

## Flows
- **Register** (Let's get started): Phone → OTP → Name → Date of birth → Welcome → Home.
- **Log in** (Already have an account? Log in): Phone → OTP → Home. An unregistered number gets an **inline message with a link to register**.
- **Session:** relaunch while logged in → Home; logged out → Onboarding. Settings tab has a **Log out** row.
- **Back arrow:** returns to the previous step and **keeps what was entered**.
- **Google / Apple / Facebook / Terms of Use / Privacy Policy:** no integration; show placeholder sheet or snackbar.

## Validation rules
| Field | Rule | On failure |
|---|---|---|
| Phone | After +95, strip spaces, dashes, and one leading 0; result must be `9` followed by 7–9 digits (`09254135592` → `+959254135592`) | Continue disabled; inline message once field loses focus |
| OTP | 6 digits; fake code `123456` passes, anything else fails | Boxes shake and clear, message under boxes; **3 wrong codes lock entry until Resend** |
| OTP input | Auto-advance per digit, backspace moves back, paste fills all 6, numeric keyboard, SMS autofill hint | — |
| Resend | Countdown from 5:00; Resend active at 0:00 and restarts timer | — |
| First name | Required; 1–50 chars after trim; letters and spaces, **Myanmar script included**; no digits | Inline message |
| Last name | Optional; same character rules (many Myanmar names have no family name) | Inline message |
| Date of birth | Real calendar date (no 31 April; 29 Feb only in leap years), not in future, age ≥ 13 (**named constant**) | Inline message; Continue disabled |
| Every step | Continue shows loading during fake call; **double tap sends one request** | — |

## Implementation requirements
- Validators are **pure functions in the domain layer** (no Flutter imports).
- **Unit tests for each rule.**
- Widget tests for login and registration validation (see 06).

## Agent notes
- Regex for Myanmar script: Unicode block U+1000–U+109F (+ extended A/B U+AA60–U+AA7F, U+A9E0–U+A9FF).
- Myanmar digits (U+1040–U+1049) count as digits → reject them in names.
- Normalise phone in a single `normalizePhone()` and reuse it in validator + repository.
