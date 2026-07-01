#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'command -v trash >/dev/null 2>&1 && trash "$TMP_DIR" || true' EXIT

# Given the repository "sovri-frameworks" has been scaffolded
# And the repository root does not contain a "frameworks/" directory
test ! -e "$TMP_DIR/frameworks"

# When the catalog layout check runs
set +e
output="$("$ROOT/scripts/check-structure.sh" "$TMP_DIR/frameworks" 2>&1)"
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

echo "absent frameworks root detection OK"
