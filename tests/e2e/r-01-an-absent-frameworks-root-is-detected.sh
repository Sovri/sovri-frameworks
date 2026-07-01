#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'command -v trash >/dev/null 2>&1 && trash "$TMP_DIR" || true' EXIT
CATALOG_ROOT="$TMP_DIR/frameworks"

# Given the repository "sovri-frameworks" has been scaffolded
# And the repository root does not contain a "frameworks/" directory
if [ -e "$CATALOG_ROOT" ]; then
  echo "unexpected pre-existing frameworks fixture" >&2
  exit 1
fi

# When the catalog layout check runs
set +e
output="$(cd "$TMP_DIR" && "$REPO_ROOT/scripts/check-structure.sh" 2>&1)"
status=$?
set -e

# Then it fails
if [ "$status" -eq 0 ]; then
  echo "expected catalog layout check to fail" >&2
  exit 1
fi

# And it reports that the catalog root "frameworks/" is missing
if [[ "$output" != *"MISSING catalog root: frameworks/"* ]]; then
  echo "expected missing catalog root output" >&2
  echo "$output" >&2
  exit 1
fi

custom_root="$TMP_DIR/custom-root"
set +e
custom_output="$("$REPO_ROOT/scripts/check-structure.sh" "$custom_root" 2>&1)"
custom_status=$?
set -e

if [ "$custom_status" -eq 0 ]; then
  echo "expected custom root catalog layout check to fail" >&2
  exit 1
fi

if [[ "$custom_output" != *"MISSING catalog root: $custom_root/"* ]]; then
  echo "expected missing custom catalog root output" >&2
  echo "$custom_output" >&2
  exit 1
fi

echo "absent frameworks root detection OK"
