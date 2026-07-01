#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHECK="$ROOT/scripts/check-catalog-naming.sh"
control_id="consent.tracker.prior-consent"

control_files=(
  "frameworks/gdpr-eprivacy/versions/2016/controls/consent.tracker.prior-consent/control.yaml"
  "frameworks/gdpr-eprivacy/versions/2002/controls/consent.tracker.prior-consent/control.yaml"
)

mapping_examples=(
  "gdpr:2016:article-6|frameworks/gdpr-eprivacy/versions/2016/mappings/consent.tracker.prior-consent/mapping.yaml"
  "eprivacy:2002:article-5-3|frameworks/gdpr-eprivacy/versions/2002/mappings/consent.tracker.prior-consent/mapping.yaml"
)

# Given the catalog contains control file "frameworks/gdpr-eprivacy/versions/2016/controls/consent.tracker.prior-consent/control.yaml"
# And the catalog contains control file "frameworks/gdpr-eprivacy/versions/2002/controls/consent.tracker.prior-consent/control.yaml"
for control_file in "${control_files[@]}"; do
  if [ ! -f "$ROOT/$control_file" ]; then
    echo "expected control file: $control_file" >&2
    exit 1
  fi

  # And both files declare id "consent.tracker.prior-consent"
  if ! grep -qx "id: $control_id" "$ROOT/$control_file"; then
    echo "expected control id $control_id in $control_file" >&2
    exit 1
  fi
done

# When the catalog naming check runs
if ! output="$("$CHECK" "$ROOT/frameworks" 2>&1)"; then
  echo "expected catalog naming check to pass for both versioned controls" >&2
  echo "$output" >&2
  exit 1
fi

# Then validation passes for both "control.yaml" files
for control_file in "${control_files[@]}"; do
  if [[ "$output" != *"validated control.yaml: $control_file"* ]]; then
    echo "expected naming validation output for $control_file" >&2
    echo "$output" >&2
    exit 1
  fi
done

# And the framework-specific references stay in "mapping.yaml"
for mapping_example in "${mapping_examples[@]}"; do
  IFS="|" read -r framework_reference mapping_file <<< "$mapping_example"
  if [ ! -f "$ROOT/$mapping_file" ]; then
    echo "expected mapping file: $mapping_file" >&2
    exit 1
  fi
  if ! grep -qx "  - $framework_reference" "$ROOT/$mapping_file"; then
    echo "expected framework reference $framework_reference in $mapping_file" >&2
    exit 1
  fi
done

echo "stable control id across versioned catalogs OK"
