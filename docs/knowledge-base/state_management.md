# State Management — Riverpod

**Choice:** Riverpod (3.x) with code generation (`riverpod_annotation`). Rationale for README: one tool for DI + state, compile-safe, providers overridable in tests, no BuildContext needed in domain/data wiring, `AsyncValue` gives loading/error/data for free.

## Provider types
| Need | Use |
|---|---|
| DI of a service/repo | `@Riverpod(keepAlive: true) AuthRepository authRepository(Ref ref) => FakeAuthRepository(...)` |
| Reactive DB data | `StreamProvider` / `@riverpod Stream<T>` over a repo `watch…()` |
| Keyed fetch (`/product/:id`) | family: `@riverpod Stream<Product?> productDetail(Ref ref, String id)` |
| Mutable feature state (form step, OTP) | `@riverpod class XNotifier extends _$XNotifier` (`Notifier`) |
| Async one-shot + actions | `AsyncNotifier` |
| Session (router guard) | `keepAlive` `StreamNotifier` over secure-storage session |

**Not used:** `StateNotifier`, `StateProvider`, `ChangeNotifierProvider` (legacy).

## Rules
- State classes immutable (`freezed`), updated via `state = state.copyWith(...)`.
- Notifiers call **use cases / repositories**, never Dio/Drift directly.
- Side effects (navigation excluded) live in notifier methods; navigation happens in the widget via `ref.listen`.
- `ref.watch` in `build`, `ref.read` in callbacks, `ref.listen` for one-shot effects (snackbars, navigation, shake).
- Screen-scoped providers are `autoDispose` (default with codegen); app-scoped ones `keepAlive: true`.
- Single-flight submit: notifier ignores calls while `isSubmitting`; button also disabled (double tap = one request — brief).
- Registration draft lives in one `keepAlive` `RegistrationDraftNotifier` so Back keeps values; cleared on success/logout.

## Testing
- `ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(mock)])` for notifiers.
- `ProviderScope(overrides: …)` in widget tests. Never mutate globals.
