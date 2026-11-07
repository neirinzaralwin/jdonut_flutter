# 08 — How we evaluate

Offline data, motion and architecture = 60% combined.

| Area | What they look for | Weight |
|---|---|---|
| Offline data (Task 2) | Local DB as source of truth; airplane mode works; refresh + image caching | 20% |
| Motion & presentation (Task 3 + flow) | Smooth, purposeful animation; polished Rewards | 20% |
| Architecture & code quality | Clean layers, DI, testable code, analyzer clean, clear names | 20% |
| UI fidelity | Matches 10 screens: spacing, type, colour, states | 15% |
| Validation & flow (Task 1) | Every rule enforced, clear errors, session kept across relaunch | 10% |
| Tests | Meaningful unit, widget, integration tests that pass | 10% |
| Delivery | README, .apk + .app, recording, commit history | 5% |

**Instant fail:** doesn't build from README, crashes in main flow, data hard-coded in widgets.
