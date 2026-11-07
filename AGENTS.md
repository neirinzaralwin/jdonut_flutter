# AGENTS.md — jdonut_flutter

Rules for every AI coding agent (Claude Code, Cursor, Codex, …). `CLAUDE.md` imports this file — one source of truth.

## 0. Precedence
1. **The code test** — `docs/code-test/` (split from the PDF). Listen to it first.
2. **Knowledge base** — `docs/knowledge-base/` (our practices; fills what the brief leaves open).
3. General Flutter practice.
If 2 conflicts with 1, follow 1 and fix the doc.

## 1. Read before every task
- `docs/README.md`, then `docs/knowledge-base/README.md`.
- Always: `coding_rules.md`, `module_boundaries.md`, `folder_structure.md`.
- By task:
  | Task touches | Read |
  |---|---|
  | auth / validation / session | `code-test/02-task1-auth.md`, `knowledge-base/resilience_and_offline.md` |
  | home / product / data / images | `code-test/03-task2-offline-home-product.md`, `knowledge-base/resilience_and_offline.md`, `docs/mock-server.md` |
  | rewards / any animation | `code-test/04-task3-rewards.md`, `code-test/05-animations.md`, `knowledge-base/motion_rules.md` |
  | providers / notifiers | `knowledge-base/state_management.md` |
  | tests | `knowledge-base/testing_rules.md` |
  | new classes / interfaces | `knowledge-base/solid_principles.md` |
Don't load docs unrelated to the task.

## 2. Graphify — map first, then files
Local knowledge graph in `.graphify/` (see `docs/knowledge-base/graphify_guide.md`).
- Use **before** Read/Grep/Glob when you don't know which files are involved:
  `bash scripts/graphify.sh query "<question>"` · `path "<A>" "<B>"` · `explain "<concept>"`
- Skip it for commands, git, tests/lint, docs, or line edits in a known file, or if `.graphify/graph.json` is missing.
- After changing code: `bash scripts/graphify.sh update .`
- Pass this rule to every subagent that explores code.

## 3. Repo layout
- `app/` — Flutter project (run Flutter commands here)
- `mock_server/` — json-server (`npm start`), contract in `docs/mock-server.md`
- `docs/` — spec (`code-test/`) + rules (`knowledge-base/`)
- `DECISIONS.md` — why each package/architecture choice; update it when a choice changes

## 4. Commands
```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze            # must be clean
flutter test               # must pass
flutter test integration_test
cd ../mock_server && npm start
```

## 5. Engineering mindset — lazy senior dev
Efficient, not careless. Before writing code: needed at all? → already in repo? → SDK does it? → installed package does it? → then minimum code. Understand and trace the real flow first. Fix root causes once in the shared function. No unrequested abstractions, deps or boilerplate — but the brief's required structure (3 layers, `AuthRepository`, `Result`, DI) is requested.
Never lazy about: validation, offline behaviour, error/empty/loading states, Reduce Motion, accessibility, tests.

## 6. Non-negotiables (full list: `knowledge-base/coding_rules.md`)
- Domain: pure Dart, no `package:flutter`/Dio/Drift/Riverpod.
- UI reads only Drift via repositories; network only upserts into Drift.
- Repos return `Result<T>`; specific exceptions mapped to `Failure`; `return await` inside `try`.
- Validators = pure functions in `features/auth/domain/validators/`, unit test per rule.
- No hard-coded colours, spacing, strings, durations, magic numbers in widgets — tokens / ARB / `app_motion.dart` / `AppConstants`.
- Riverpod only (state + DI); `Notifier`/`AsyncNotifier`, no `StateNotifier`. No services built in widgets.
- Shared widgets in `core/widgets/` (AppButton, AppTextField, AppNetworkImage, Skeleton, empty/error states) — reuse, don't re-roll.
- Every screen: loading (skeleton), empty, error. Double tap = one request.
- Respect `MediaQuery.disableAnimationsOf`.
- Cross-feature imports only through `<feature>/<feature>.dart` barrels.
- Never commit design screenshots (`design_refs/` is ignored).
- Small conventional commits.

## 7. Definition of done
`flutter analyze` clean · `flutter test` green · module-boundary checklist passes · graph updated · relevant `docs/` updated if a decision changed · `docs/deliverables-checklist.md` ticked.
