#!/usr/bin/env bash
# Local graphify (npm @sentropic/graphify) — same setup as vint_flutter.
# Usage: bash scripts/graphify.sh query "<q>" | path "<A>" "<B>" | explain "<c>" | update . | rebuild
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GRAPHIFY="$ROOT/.graphify-local/node_modules/.bin/graphify"

if [ ! -x "$GRAPHIFY" ]; then
  echo "[graphify] installing into .graphify-local/ ..." >&2
  npm install --prefix "$ROOT/.graphify-local" --silent
fi

if [ $# -eq 0 ]; then
  sed -n 3p "$0"; exit 1
fi

cd "$ROOT"
if [ "$1" = "rebuild" ]; then
  exec "$GRAPHIFY" update . --force --no-description --no-label
fi
exec "$GRAPHIFY" "$@"
