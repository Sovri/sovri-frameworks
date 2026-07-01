#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHECK="$ROOT/scripts/check-structure.sh"

control_id="consent.tracker.prior-consent"
rule_id="consent.detect-trackers-without-consent-evidence"
control_file="frameworks/gdpr-eprivacy/versions/2016/controls/$control_id/control.yaml"
rule_file="frameworks/gdpr-eprivacy/versions/2016/rules/$rule_id/rule.yaml"
mapping_file="frameworks/gdpr-eprivacy/versions/2016/mappings/$control_id/mapping.yaml"

fail=0

# Given the repository "sovri-frameworks" has been scaffolded
if [ ! -d "$ROOT/frameworks" ]; then
  echo "expected frameworks/ catalog root" >&2
  exit 1
fi

# And the catalog contains "frameworks/gdpr-eprivacy/versions/2016/controls/consent.tracker.prior-consent/control.yaml"
if [ ! -f "$ROOT/$control_file" ]; then
  echo "expected catalog file: $control_file" >&2
  fail=1
fi

# And the catalog contains "frameworks/gdpr-eprivacy/versions/2016/rules/consent.detect-trackers-without-consent-evidence/rule.yaml"
if [ ! -f "$ROOT/$rule_file" ]; then
  echo "expected catalog file: $rule_file" >&2
  fail=1
fi

# And the catalog contains "frameworks/gdpr-eprivacy/versions/2016/mappings/consent.tracker.prior-consent/mapping.yaml"
if [ ! -f "$ROOT/$mapping_file" ]; then
  echo "expected catalog file: $mapping_file" >&2
  fail=1
fi

# When the catalog layout check runs
if ! output="$("$CHECK" "$ROOT/frameworks" 2>&1)"; then
  echo "expected catalog layout check to pass for MAT-114 placeholder" >&2
  echo "$output" >&2
  exit 1
fi

# Then it reports the MAT-114 placeholder as present
if [[ "$output" != *"MAT-114 placeholder present"* ]]; then
  echo "expected MAT-114 placeholder presence output" >&2
  echo "$output" >&2
  fail=1
fi

# And the placeholder control id is "consent.tracker.prior-consent"
if [[ "$output" != *"placeholder control id: $control_id"* ]]; then
  echo "expected MAT-114 placeholder control id output" >&2
  echo "$output" >&2
  fail=1
fi

# And the placeholder rule id is "consent.detect-trackers-without-consent-evidence"
if [[ "$output" != *"placeholder rule id: $rule_id"* ]]; then
  echo "expected MAT-114 placeholder rule id output" >&2
  echo "$output" >&2
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi

echo "MAT-114 consent-control placeholder OK"
