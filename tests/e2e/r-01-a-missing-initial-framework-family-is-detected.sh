#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'command -v trash >/dev/null 2>&1 && trash "$TMP_DIR" || true' EXIT

mkdir -p "$TMP_DIR/frameworks"
for family in gdpr-eprivacy nis2 dora ai-act internal custom; do
  mkdir -p "$TMP_DIR/frameworks/$family"
done

# Given the repository "sovri-frameworks" has been scaffolded
# And the "frameworks/gdpr-eprivacy" directory exists
test -d "$TMP_DIR/frameworks/gdpr-eprivacy"

# And the "frameworks/iso27001" directory is absent
test ! -e "$TMP_DIR/frameworks/iso27001"

# When the catalog layout check runs
if output="$("$ROOT/scripts/check-structure.sh" "$TMP_DIR/frameworks" 2>&1)"; then
  echo "expected catalog layout check to fail" >&2
  exit 1
fi

# Then it fails
# And it names the missing family "iso27001"
if [[ "$output" != *"MISSING family: iso27001"* ]]; then
  echo "expected missing family output for iso27001" >&2
  echo "$output" >&2
  exit 1
fi

echo "missing initial framework family detection OK"
