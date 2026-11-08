# Testing Rules (10% of score)

## Required by the brief
| Kind | Scope | Location |
|---|---|---|
| Unit | **every validator rule** (phone, OTP, first/last name, DOB) + use cases | `test/features/<f>/domain/...` |
| Unit | repositories (fake auth timing/storage, catalog upsert/offline) | `test/features/<f>/data/...` |
| Widget | login + registration validation (inline errors, disabled Continue, shake, lock) | `test/features/auth/presentation/...` |
| Integration | Register → Home → Product detail | `integration_test/register_to_product_test.dart` |

## Rules
- `test/` mirrors `lib/`.
- Names describe behaviour: `test('locks OTP entry after 3 wrong codes until Resend', ...)`. Group by rule.
- Arrange / Act / Assert, one behaviour per test.
- Table-driven tests for validators (valid + invalid lists, incl. Myanmar script, 29 Feb leap/non-leap, 31 April, today-13y boundary).
- Inject a `Clock` (`DateTime Function() now`) into anything date-based — no real `DateTime.now()` in tests.
- Fake delays: inject the delay `Duration`; tests pass `Duration.zero` or use `fakeAsync`.
- Mocks: `mocktail`. Override providers, never globals.
- Drift: in-memory `NativeDatabase.memory()` for repo tests.
- No golden tests unless time allows.
- Run `flutter analyze && flutter test` before every commit.
- Screens: one overflow test with real fonts across small phone / large text / Burmese (see `rewards_page_layout_test.dart`).
