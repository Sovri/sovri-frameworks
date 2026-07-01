#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'command -v trash >/dev/null 2>&1 && trash "$TMP_DIR" || true' EXIT

control_id="consent.tracker.prior-consent"
control_file="frameworks/gdpr-eprivacy/versions/2016/controls/$control_id/control.yaml"

# Given the repository "sovri-frameworks" has been scaffolded
cp -R "$ROOT/frameworks" "$TMP_DIR/"

# And the catalog does not contain "frameworks/gdpr-eprivacy/versions/2016/controls/consent.tracker.prior-consent/control.yaml"
if [ ! -f "$TMP_DIR/$control_file" ]; then
  echo "expected control fixture before removing it: $control_file" >&2
  exit 1
fi
mv "$TMP_DIR/$control_file" "$TMP_DIR/missing-control.yaml"

# When the catalog layout check runs
if output="$("$ROOT/scripts/check-structure.sh" "$TMP_DIR/frameworks" 2>&1)"; then
  echo "expected catalog layout check to fail for missing MAT-114 control" >&2
  echo "$output" >&2
  exit 1
fi

# Then it fails
# And it names the missing control "consent.tracker.prior-consent"
if [[ "$output" != *"missing control $control_id"* ]]; then
  echo "expected missing MAT-114 control output" >&2
  echo "$output" >&2
  exit 1
fi

echo "missing MAT-114 control detection OK"
