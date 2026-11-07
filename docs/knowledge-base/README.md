# Knowledge base — jdonut_flutter

Our engineering rules. `../code-test/` is **what** to build; this folder is **how** we build it.

## Precedence (highest first)
1. `../code-test/*` — the brief. If a rule here conflicts with it, the brief wins; fix this doc.
2. This knowledge base.
3. General Flutter/Dart community practice.

## Files
| File | Read when |
|---|---|
| `architecture_overview.md` | Any change — layers, data flow, offline strategy |
| `folder_structure.md` | Creating any file |
| `coding_rules.md` | Any code change — naming, constants, async safety, forbidden list |
| `state_management.md` | Providers, notifiers, async state |
| `module_boundaries.md` | Importing across features or layers |
| `solid_principles.md` | Adding classes/interfaces |
| `resilience_and_offline.md` | Network, DB, auth, multi-step flows — **mandatory** for Task 1/2 |
| `motion_rules.md` | Any animation (Task 3, transitions) |
| `testing_rules.md` | Writing or changing tests |
| `graphify_guide.md` | Exploring code with the knowledge graph |

Origin: adapted from the `vint_flutter` knowledge base, reshaped for the code test's 3-layer clean architecture.
