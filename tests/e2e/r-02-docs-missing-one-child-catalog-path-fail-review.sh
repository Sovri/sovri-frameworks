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

control_path="frameworks/gdpr-eprivacy/versions/2016/controls/consent.tracker.prior-consent/control.yaml"
rule_path="frameworks/gdpr-eprivacy/versions/2016/rules/consent.detect-trackers-without-consent-evidence/rule.yaml"
mapping_path="frameworks/gdpr-eprivacy/versions/2016/mappings/consent.tracker.prior-consent/mapping.yaml"
missing_fragment="mappings/consent.tracker.prior-consent/mapping.yaml"

# And "frameworks/README.md" documents controls and rules for
# "frameworks/gdpr-eprivacy/versions/2016/"
grep -Fq -- "$control_path" "$README"
grep -Fq -- "$rule_path" "$README"

# And "frameworks/README.md" does not document a mappings path
grep -Fv -- "$mapping_path" "$README" > "$README.next"
mv "$README.next" "$README"
if grep -Fq -- "$mapping_path" "$README"; then
  echo "expected fixture to omit $mapping_path" >&2
  exit 1
fi

# When the catalog docs check runs
if output="$("$ROOT/scripts/check-docs.sh" "$README" 2>&1)"; then
  echo "expected catalog docs check to fail for missing mappings path" >&2
  echo "$output" >&2
  exit 1
fi

# Then it fails
# And it reports that "mappings/consent.tracker.prior-consent/mapping.yaml"
# is missing from the documented layout
expected="$missing_fragment is missing from the documented layout"
if [[ "$output" != *"$expected"* ]]; then
  echo "expected missing mappings path message" >&2
  echo "$output" >&2
  exit 1
fi

echo "missing catalog docs mapping path detection OK"
