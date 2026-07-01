#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'command -v trash >/dev/null 2>&1 && trash "$TMP_DIR" || true' EXIT

# Given the repository "sovri-frameworks" has been scaffolded
# And the repository root contains "farameworks/iso27001"
mkdir -p "$TMP_DIR/farameworks/iso27001"
test -d "$TMP_DIR/farameworks/iso27001"

# And the repository root does not contain "frameworks/iso27001"
test ! -e "$TMP_DIR/frameworks/iso27001"

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

# And it reports that the catalog root must be "frameworks/"
if [[ "$output" != *"catalog root must be frameworks/"* ]]; then
  echo "expected canonical catalog root output" >&2
  echo "$output" >&2
  exit 1
fi

echo "legacy misspelled catalog root rejection OK"
