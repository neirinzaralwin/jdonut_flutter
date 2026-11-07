#!/usr/bin/env bash
# First-time setup: generate platform folders and add latest-stable dependencies.
set -euo pipefail
cd "$(dirname "$0")/.."

flutter create . --project-name jdonut --org com.madivizion --platforms android,ios

flutter pub add flutter_riverpod riverpod_annotation go_router \
  drift drift_flutter \
  flutter_secure_storage dio connectivity_plus cached_network_image \
  freezed_annotation json_annotation intl shimmer
flutter pub add --dev build_runner riverpod_generator freezed json_serializable \
  drift_dev very_good_analysis mocktail

dart run build_runner build --delete-conflicting-outputs || true
flutter gen-l10n
flutter analyze || true
echo "Done. Run: flutter run"
