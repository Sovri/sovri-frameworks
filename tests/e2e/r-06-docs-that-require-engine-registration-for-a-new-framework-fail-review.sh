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

instructions=(
  'When adding framework family `eu-cyber-resilience-act`, edit `sovri-agent/src` to register the new framework.'
  'To add framework family `eu-cyber-resilience-act`, register it in `../sovri-agent/src`.'
  'When adding framework family `eu-cyber-resilience-act`, edit `./sovri-agent/src`.'
  'To add framework family eu-cyber-resilience-act, first register it in sovri-agent/src.'
  'When adding framework family eu-cyber-resilience-act, edit ../sovri-agent/src/.'
  'To add framework family `eu-cyber-resilience-act`, register it in `/absolute/path/to/sovri-agent/src`.'
)

for instruction in "${instructions[@]}"; do
  cp "$SOURCE_README" "$README"

  # And "frameworks/README.md" says to edit "sovri-agent/src" when adding
  # framework family "eu-cyber-resilience-act"
  printf '\n%s\n' "$instruction" >> "$README"
  grep -Fq -- "eu-cyber-resilience-act" "$README"

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
done

allowed_references=(
  'See `sovri-agent/src` for implementation details.'
  'Review `sovri-agent/src` for examples before changing catalog files.'
  'When adding framework family eu-cyber-resilience-act, review `sovri-agent/src` for examples.'
  'When adding framework family eu-cyber-resilience-act, edit my-sovri-agent/src-file documentation.'
)

for reference in "${allowed_references[@]}"; do
  cp "$SOURCE_README" "$README"
  printf '\n%s\n' "$reference" >> "$README"

  if ! output="$("$ROOT/scripts/check-docs.sh" "$README" 2>&1)"; then
    echo "false positive for non-registration engine path reference" >&2
    echo "$output" >&2
    exit 1
  fi
done

echo "engine registration docs violation detection OK"
