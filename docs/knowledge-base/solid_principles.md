# SOLID — applied here

- **S** — Notifier = one screen/concern. Repository = one resource. Validator = one field. Widget = render only. File > 300 lines or a class doing I/O + UI → split.
- **O** — Add a new data source by adding a new `*RepositoryImpl`, not `if (useServer)` branches. New tile variant = new widget composing existing ones, not boolean flags.
- **L** — `FakeAuthRepository` and a future `ApiAuthRepository` must return the same `Result`/`Failure` types for the same situations (e.g. unknown phone → `AuthFailure.notRegistered`). Test fakes honour the same contract.
- **I** — Keep repo interfaces narrow: `CatalogRepository` (products/sections/banners) separate from `ShopRepository`, `MemberRepository`, `AuthRepository`. Widgets get specific callbacks (`onTap`) not notifiers.
- **D** — Presentation depends on domain interfaces; concrete classes chosen only in DI providers. Riverpod is the only DI container. Tests swap via overrides.

## Pragmatism
Don't add an interface that will only ever have one impl and no test double — **except** where the brief demands it (AuthRepository, repositories across layers). Use cases may be skipped for trivial pass-through reads; document it (`// simplification:`) and keep validators + multi-step logic in use cases.
