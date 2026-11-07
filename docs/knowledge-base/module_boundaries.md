# Module Boundaries

A module = a feature (`lib/features/<f>/`) or a core sub-module (`lib/core/<x>/`).

## Layer rule (brief)
```
presentation ──▶ domain ◀── data
```
- `domain/` imports only `dart:*`, `core/error`, `core/constants` and other domain files. **No Flutter, Dio, Drift, Riverpod.**
- `data/` implements `domain/repositories/*`. May import Drift, Dio, `core/network`, `core/database`, `core/storage`.
- `presentation/` imports domain + its own providers. Never imports `data/` except in the DI provider file (`presentation/providers/<f>_dependencies.dart`) — the composition seam.

## Feature public surface
Each feature has a barrel `lib/features/<f>/<f>.dart` exporting only:
- domain entities and repository **interfaces** others need,
- the providers other features read,
- pages only if a route needs them (router imports barrels).

Never export `*RepositoryImpl`, DTOs, internal widgets.

## Allowed coupling
| From | To | How |
|---|---|---|
| Feature A | Feature B | `import 'package:jdonut/features/b/b.dart';` |
| Any feature | core | direct import |
| home, rewards | member | via `member.dart` barrel (`memberProvider`) — single member record |
| router | auth | `sessionProvider` for the redirect guard |

## Forbidden
- Importing another feature's internals (`features/b/data/...`, `features/b/presentation/widgets/...`).
- A repository in A calling B's repository — compose in a use case or provider.
- Widgets importing `core/network`, `core/database`, `core/storage`.
- Two features mutating each other's state.

## When a boundary feels wrong
Stop, find the missing seam (use case, provider, core service), add it, then go through it. No "temporary" reach-across.

## Checklist before finishing a task
- [ ] `grep -r "package:flutter" lib/features/*/domain` returns nothing
- [ ] No cross-feature import bypasses a barrel
- [ ] No widget imports data/ or core/network|database|storage
- [ ] New routes registered in `app_routes.dart`
