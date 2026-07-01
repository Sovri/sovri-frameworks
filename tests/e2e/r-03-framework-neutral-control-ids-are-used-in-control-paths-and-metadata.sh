#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHECK="$ROOT/scripts/check-catalog-naming.sh"

examples=(
  "consent.tracker.prior-consent|gdpr:2016:article-6|frameworks/gdpr-eprivacy/versions/2016/controls/consent.tracker.prior-consent/control.yaml"
  "access.logging.admin-actions|iso27001:2022:a-8-15|frameworks/iso27001/versions/2022/controls/access.logging.admin-actions/control.yaml"
  "access.logging.admin-actions|nis2:2022:article-21-2-d|frameworks/nis2/versions/2022/controls/access.logging.admin-actions/control.yaml"
)

for example in "${examples[@]}"; do
  IFS="|" read -r control_id framework_reference control_file <<< "$example"
  full_control_file="$ROOT/$control_file"

  # Given the catalog contains control file "<control file>"
  if [ ! -f "$full_control_file" ]; then
    echo "expected control file: $control_file" >&2
    exit 1
  fi

  # And "control.yaml" declares id "<control id>"
  if ! grep -qx "id: $control_id" "$full_control_file"; then
    echo "expected control id $control_id in $control_file" >&2
    exit 1
  fi

  # When the catalog naming check runs
  output="$("$CHECK" "$ROOT/frameworks" 2>&1)"

  # Then validation passes for "control.yaml"
  if [[ "$output" != *"validated control.yaml: $control_file"* ]]; then
    echo "expected naming validation output for $control_file" >&2
    echo "$output" >&2
    exit 1
  fi

  # And the control id is "<control id>"
  if [[ "$output" != *"control id: $control_id"* ]]; then
    echo "expected control id output for $control_id" >&2
    echo "$output" >&2
    exit 1
  fi

  # And framework reference "<framework reference>" is kept outside the control id
  if [[ "$output" != *"framework reference kept outside control id: $framework_reference"* ]]; then
    echo "expected separate framework reference output for $framework_reference" >&2
    echo "$output" >&2
    exit 1
  fi
done

echo "framework-neutral control ids OK"
