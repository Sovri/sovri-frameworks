#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'command -v trash >/dev/null 2>&1 && trash "$TMP_DIR" || true' EXIT

control_id="consent.tracker.prior-consent"
rule_id="consent.detect-trackers-without-consent-evidence"
control_file="frameworks/gdpr-eprivacy/versions/2016/controls/$control_id/control.yaml"
rule_file="frameworks/gdpr-eprivacy/versions/2016/rules/$rule_id/rule.yaml"

cp -R "$ROOT/frameworks" "$TMP_DIR/"

# Given the catalog contains "frameworks/gdpr-eprivacy/versions/2016/controls/consent.tracker.prior-consent/control.yaml"
if [ ! -f "$TMP_DIR/$control_file" ]; then
  echo "expected control fixture: $control_file" >&2
  exit 1
fi

# And the catalog does not contain "frameworks/gdpr-eprivacy/versions/2016/rules/consent.detect-trackers-without-consent-evidence/rule.yaml"
if [ ! -f "$TMP_DIR/$rule_file" ]; then
  echo "expected rule fixture before removing it: $rule_file" >&2
  exit 1
fi
mv "$TMP_DIR/$rule_file" "$TMP_DIR/missing-rule.yaml"

# When the catalog layout check runs
if output="$("$ROOT/scripts/check-structure.sh" "$TMP_DIR/frameworks" 2>&1)"; then
  echo "expected catalog layout check to fail for missing MAT-114 rule" >&2
  echo "$output" >&2
  exit 1
fi

# Then it fails
# And it names the missing rule "consent.detect-trackers-without-consent-evidence"
if [[ "$output" != *"missing rule $rule_id"* ]]; then
  echo "expected missing MAT-114 rule output" >&2
  echo "$output" >&2
  exit 1
fi

echo "missing MAT-114 rule detection OK"
