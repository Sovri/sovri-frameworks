#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Given the repository "sovri-frameworks" has been scaffolded
if [ ! -d "$ROOT/frameworks" ]; then
  echo "expected frameworks/ catalog root" >&2
  exit 1
fi

examples=(
  "frameworks/gdpr-eprivacy/versions/2016/controls/consent.tracker.prior-consent/control.yaml|consent control metadata"
  "frameworks/gdpr-eprivacy/versions/2016/rules/consent.detect-trackers-without-consent-evidence/rule.yaml|tracker detection rule"
  "frameworks/gdpr-eprivacy/versions/2016/mappings/consent.tracker.prior-consent/mapping.yaml|framework reference mapping"
)

for example in "${examples[@]}"; do
  IFS="|" read -r catalog_file placeholder_role <<< "$example"
  full_catalog_file="$ROOT/$catalog_file"

  # When I inspect "<catalog file>"
  # Then it exists
  if [ ! -f "$full_catalog_file" ]; then
    echo "expected catalog file: $catalog_file" >&2
    exit 1
  fi

  # And it provides the MAT-114 placeholder role "<placeholder role>"
  if ! grep -qx "placeholder_role: $placeholder_role" "$full_catalog_file"; then
    echo "expected MAT-114 placeholder role '$placeholder_role' in $catalog_file" >&2
    exit 1
  fi
done

echo "MAT-114 placeholder catalog roles OK"
