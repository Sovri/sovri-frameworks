#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHECK="$ROOT/scripts/lint-catalogs.sh"

examples=(
  "access.logging.admin-actions|iso27001:2022:a-8-15, nis2:2022:article-21-2-d|2|frameworks/iso27001/versions/2022/mappings/access.logging.admin-actions/mapping.yaml"
  "consent.tracker.prior-consent|gdpr:2016:article-6, eprivacy:2002:article-5-3, eprivacy:2009:article-5-3|3|frameworks/gdpr-eprivacy/versions/2016/mappings/consent.tracker.prior-consent/mapping.yaml"
)

for example in "${examples[@]}"; do
  IFS="|" read -r control_id framework_references reference_count mapping_file <<< "$example"
  full_mapping_file="$ROOT/$mapping_file"

  # Given the catalog contains mapping file "<mapping file>"
  if [ ! -f "$full_mapping_file" ]; then
    echo "expected mapping file: $mapping_file" >&2
    exit 1
  fi

  # And "mapping.yaml" declares control_id "<control id>"
  if ! grep -qx "control_id: $control_id" "$full_mapping_file"; then
    echo "expected control_id $control_id in $mapping_file" >&2
    exit 1
  fi

  # And "mapping.yaml" declares framework_references "<framework references>"
  IFS=", " read -r -a references <<< "$framework_references"
  for framework_reference in "${references[@]}"; do
    if [ -z "$framework_reference" ]; then
      continue
    fi
    if ! grep -qx "  - $framework_reference" "$full_mapping_file"; then
      echo "expected framework reference $framework_reference in $mapping_file" >&2
      exit 1
    fi
  done
done

# When the catalog layout check runs
if ! output="$("$CHECK" "$ROOT/frameworks" 2>&1)"; then
  echo "expected catalog layout check to pass for mapping files" >&2
  echo "$output" >&2
  exit 1
fi

for example in "${examples[@]}"; do
  IFS="|" read -r control_id _ reference_count mapping_file <<< "$example"

  # Then validation passes for "mapping.yaml"
  if [[ "$output" != *"validated mapping.yaml: $mapping_file"* ]]; then
    echo "expected mapping validation output for $mapping_file" >&2
    echo "$output" >&2
    exit 1
  fi

  # And control "<control id>" is bound to <reference count> framework references
  expected="control $control_id is bound to $reference_count framework references"
  if [[ "$output" != *"$expected"* ]]; then
    echo "expected mapping reference count output for $control_id" >&2
    echo "$output" >&2
    exit 1
  fi
done

echo "multi-reference mapping validation OK"
