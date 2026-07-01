#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'command -v trash >/dev/null 2>&1 && trash "$TMP_DIR" || true' EXIT

control_id="consent.tracker.prior-consent"
rule_id="consent.detect-trackers-without-consent-evidence"
control_file="frameworks/gdpr-eprivacy/versions/2016/controls/$control_id/control.yaml"
rule_file="frameworks/gdpr-eprivacy/versions/2016/rules/$rule_id/rule.yaml"
mapping_file="frameworks/gdpr-eprivacy/versions/2016/mappings/$control_id/mapping.yaml"

cp -R "$ROOT/frameworks" "$TMP_DIR/"

# Given the catalog contains "frameworks/gdpr-eprivacy/versions/2016/controls/consent.tracker.prior-consent/control.yaml"
if [ ! -f "$TMP_DIR/$control_file" ]; then
  echo "expected control fixture: $control_file" >&2
  exit 1
fi

# And the catalog contains "frameworks/gdpr-eprivacy/versions/2016/rules/consent.detect-trackers-without-consent-evidence/rule.yaml"
if [ ! -f "$TMP_DIR/$rule_file" ]; then
  echo "expected rule fixture: $rule_file" >&2
  exit 1
fi

# And the catalog does not contain "frameworks/gdpr-eprivacy/versions/2016/mappings/consent.tracker.prior-consent/mapping.yaml"
if [ ! -f "$TMP_DIR/$mapping_file" ]; then
  echo "expected mapping fixture before removing it: $mapping_file" >&2
  exit 1
fi
mv "$TMP_DIR/$mapping_file" "$TMP_DIR/missing-mapping.yaml"

# When the catalog layout check runs
if output="$("$ROOT/scripts/check-structure.sh" "$TMP_DIR/frameworks" 2>&1)"; then
  echo "expected catalog layout check to fail for missing MAT-114 mapping" >&2
  echo "$output" >&2
  exit 1
fi

# Then it fails
# And it names the missing mapping "consent.tracker.prior-consent"
if [[ "$output" != *"missing mapping $control_id"* ]]; then
  echo "expected missing MAT-114 mapping output" >&2
  echo "$output" >&2
  exit 1
fi

echo "missing MAT-114 mapping detection OK"
