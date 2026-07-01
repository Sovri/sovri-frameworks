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

# Given the repository "sovri-frameworks" contains "frameworks/README.md"
cp "$ROOT/frameworks/README.md" "$README"

# And "frameworks/README.md" says to edit "sovri-agent/src" when adding
# framework family "eu-cyber-resilience-act"
printf '\nWhen adding framework family `eu-cyber-resilience-act`, edit `sovri-agent/src` to register the new framework.\n' >> "$README"
grep -Fq -- "eu-cyber-resilience-act" "$README"
grep -Fq -- "sovri-agent/src" "$README"

# When the catalog docs check runs
if output="$("$ROOT/scripts/check-docs.sh" "$README" 2>&1)"; then
  echo "expected catalog docs check to fail for engine registration instructions" >&2
  echo "$output" >&2
  exit 1
fi

# Then it fails
# And it reports that adding a framework must not require engine code changes
expected="adding a framework must not require engine code changes"
if [[ "$output" != *"$expected"* ]]; then
  echo "expected engine-code registration failure message" >&2
  echo "$output" >&2
  exit 1
fi

echo "engine registration docs violation detection OK"
