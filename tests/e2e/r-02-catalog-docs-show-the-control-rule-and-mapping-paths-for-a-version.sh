#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
README="$ROOT/frameworks/README.md"

# Given the repository "sovri-frameworks" contains "frameworks/README.md"
if [ ! -f "$README" ]; then
  echo "expected frameworks/README.md to exist" >&2
  exit 1
fi

required_paths=(
  "frameworks/gdpr-eprivacy/versions/2016/controls/consent.tracker.prior-consent/control.yaml"
  "frameworks/gdpr-eprivacy/versions/2016/rules/consent.detect-trackers-without-consent-evidence/rule.yaml"
  "frameworks/gdpr-eprivacy/versions/2016/mappings/consent.tracker.prior-consent/mapping.yaml"
)

for path in "${required_paths[@]}"; do
  # When I read "frameworks/README.md"
  if ! grep -Fq -- "$path" "$README"; then
    echo "expected frameworks/README.md to document $path" >&2
    exit 1
  fi
done

echo "versioned catalog child paths documented OK"
