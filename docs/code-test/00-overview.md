# 00 — Overview (J'Donuts Senior Flutter Code Test)

Source: `Madivizion_Flutter_Code_Test.pdf` (Nov 7, 2026). This folder is the PDF split into agent-friendly files. **The PDF wins if anything conflicts.**

## Goal
Build a working slice of the J'Donuts customer app: onboarding with fake login + registration, offline-first Home and Product detail, and an animated Rewards screen. Match the designs closely.

- **Scope:** 3 tasks across 10 screens, first launch → Rewards tab.
- **Platforms:** Android + iOS. Must run on iOS Simulator and Android emulator.
- **Back end:** none required; everything runs on local data. Own mock server is optional (we use `json-server`, see `../mock-server.md`).
- **Time allowed:** 2 days.

## What reviewers look at
1. How data is controlled offline (Task 2).
2. Motion design and screen presentation (Task 3 + transitions across the whole flow).
3. Clean architecture and code quality on current Flutter.
4. UI fidelity to the designs.
5. Validation and flow correctness (Task 1).

## Hard fail conditions
- Doesn't build from README steps.
- Crashes in the main flow.
- Data hard-coded inside widgets.

## Index
| File | Content |
|---|---|
| 01-screens-and-flow.md | 10 screens, 2 entry paths, bottom nav |
| 02-task1-auth.md | Fake login/registration + validation table |
| 03-task2-offline-home-product.md | Offline data, Home, Product detail |
| 04-task3-rewards.md | Rewards screen motion |
| 05-animations.md | Minimum animation table + motion rules |
| 06-technical-requirements.md | Architecture, packages, quality, tests |
| 07-deliverables.md | What to submit |
| 08-evaluation.md | Scoring weights |
