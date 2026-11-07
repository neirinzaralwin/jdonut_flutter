# Folder structure

```
jdonut_flutter/                    ← git repo root
├── AGENTS.md / CLAUDE.md          ← agent entry points (both point to docs/)
├── README.md                      ← submission README (required sections in docs/code-test/07)
├── docs/                          ← specs + feature diagrams + decisions
│   ├── diagrams/                  ← Mermaid feature flows and file maps (`<feature>-diagram.md`)
│   ├── code-test/                 ← task requirements
│   └── knowledge-base/            ← engineering rules
├── mock_server/                   ← json-server (Node) — optional /v1 API
│   ├── server.js                  ← envelope {data,error,meta}, /v1 rewrite, latency/offline toggles
│   ├── data/db.json               ← canonical public data (products, banners, sections, shops)
│   ├── public/images/             ← images served at /static/images/...
│   └── scripts/sync-seed.js       ← copies db.json slices into app/assets/seed/
├── app/                           ← Flutter project
│   ├── assets/{seed,images,fonts}/
│   ├── lib/
│   │   ├── main.dart / app.dart / bootstrap.dart
│   │   ├── l10n/                  ← app_en.arb, app_my.arb
│   │   ├── core/
│   │   │   ├── config/            ← env (base URL, flavors)
│   │   │   ├── constants/         ← app-wide named constants
│   │   │   ├── database/          ← Drift AppDatabase, tables, migrations, seed service
│   │   │   ├── error/             ← Failure, Result
│   │   │   ├── network/           ← Dio client, interceptors, ApiEnvelope, connectivity
│   │   │   ├── storage/           ← secure storage wrapper
│   │   │   ├── router/            ← go_router, routes, auth guard
│   │   │   ├── theme/             ← tokens: colors, typography, spacing, radii
│   │   │   ├── motion/            ← app_motion.dart (all durations/curves)
│   │   │   ├── utils/             ← formatters (MMK), extensions
│   │   │   └── widgets/           ← shared UI: buttons, skeleton, offline banner, cached image
│   │   └── features/
│   │       ├── auth/              ← onboarding, phone, otp, name, dob, welcome
│   │       ├── home/
│   │       ├── product/
│   │       ├── rewards/
│   │       ├── member/            ← shared member profile (Home + Rewards)
│   │       ├── shell/             ← bottom nav + placeholder tabs
│   │       └── settings/          ← Log out row
│   │           (each: data/{datasources,models,repositories}
│   │                  domain/{entities,repositories,usecases[,validators]}
│   │                  presentation/{pages,widgets,providers})
│   ├── test/                      ← mirrors lib/ (unit + widget)
│   └── integration_test/          ← register → home → product detail
```

## Placement rules
- Domain imports only `dart:` and other domain files. Never `package:flutter`.
- A file used by ≥2 features goes to `core/` (or `member/` for the member record).
- Generated files (`*.g.dart`, `*.freezed.dart`) are committed? → **No**; run build_runner (see README).
- Design screenshots → `design_refs/` (git-ignored). Never commit them.
