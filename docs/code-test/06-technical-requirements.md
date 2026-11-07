# 06 — Technical requirements

Latest stable Flutter + Dart, clean architecture; list versions in README.

## 3 layers, offline-first
Presentation → domain ← data. Data implements domain interfaces, so replacing fake auth or the mock server never touches UI.

| Area | Requirement |
|---|---|
| Structure | Feature-first (`auth`, `home`, `product`, `rewards`), each split into presentation / domain / data. **Domain has no Flutter imports.** |
| State management | Riverpod or BLoC; explain in README |
| DI | Riverpod providers or get_it; **no services created inside widgets** |
| Navigation | go_router with **auth redirect guard** and `/product/:id` route |
| Local DB | Drift (SQLite) recommended; ObjectBox or Hive CE accepted; **versioned migrations** |
| Session | flutter_secure_storage |
| Network (if server) | Dio with timeouts + retry + logging interceptors |
| Models | Immutable: freezed + json_serializable, or Dart 3 sealed classes/records |
| Errors | Typed failures returned as a **Result type**; no swallowed exceptions; every screen has loading, error, empty states |
| Images | cached_network_image (disk cache); seed images bundled as assets |
| Connectivity | connectivity_plus **plus a real reachability check** |
| Theme | Colours, type, spacing as design tokens in one theme; **no hard-coded colours in widgets** |
| Text | Strings in ARB via gen-l10n; Burmese locale = bonus |
| Layout | Portrait phones 4.7"–6.9"; text scale up to 1.3 without overflow |
| Code quality | `flutter analyze` clean (flutter_lints / very_good_analysis); functions ≈ ≤20 lines, files ≈ ≤300; named constants, no magic numbers; descriptive names |
| Tests | Unit: validators + use cases. Widget: login + registration validation. Integration: Register → Home → Product detail. Test names describe behaviour |
