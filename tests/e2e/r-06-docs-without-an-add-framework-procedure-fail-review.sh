#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
cleanup() {
  if command -v trash >/dev/null 2>&1; then
    trash "$TMP_DIR"
  fi
}
trap cleanup EXIT

mkdir -p "$TMP_DIR/frameworks"
README="$TMP_DIR/frameworks/README.md"
SOURCE_README="$ROOT/frameworks/README.md"

# Given the repository "sovri-frameworks" contains "frameworks/README.md"
if [ ! -f "$SOURCE_README" ]; then
  echo "expected frameworks/README.md to exist" >&2
  exit 1
fi
cp "$SOURCE_README" "$README"

# And "frameworks/README.md" lists the initial families but has no
# add-framework procedure
grep -Fq -- '| `gdpr-eprivacy` |' "$README"
grep -Fq -- '| `iso27001`      |' "$README"
awk '
  /^## Adding a framework family$/ { skipping = 1; next }
  /^## Families$/ { skipping = 0 }
  !skipping { print }
' "$README" > "$README.next"
mv "$README.next" "$README"

if grep -Fq -- '## Adding a framework family' "$README"; then
  echo "expected fixture to omit the add-framework procedure" >&2
  exit 1
fi
grep -Fq -- '| `gdpr-eprivacy` |' "$README"
grep -Fq -- '| `iso27001`      |' "$README"

# When the catalog docs check runs
if output="$("$ROOT/scripts/check-docs.sh" "$README" 2>&1)"; then
  echo "expected catalog docs check to fail without add-framework instructions" >&2
  echo "$output" >&2
  exit 1
fi

# Then it fails
# And it reports that instructions for adding a new framework are missing
expected="instructions for adding a new framework are missing"
if [[ "$output" != *"$expected"* ]]; then
  echo "expected missing add-framework instructions message" >&2
  echo "$output" >&2
  exit 1
fi

echo "missing add-framework docs procedure detection OK"
