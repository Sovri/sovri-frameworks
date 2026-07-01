#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'command -v trash >/dev/null 2>&1 && trash "$TMP_DIR" || true' EXIT

control_id="consent.tracker.prior-consent"
gdpr_version_root="frameworks/gdpr-eprivacy/versions/2016"
gdpr_control_file="$gdpr_version_root/controls/$control_id/control.yaml"
internal_control_file="frameworks/internal/versions/2026/controls/$control_id/control.yaml"

cp -R "$ROOT/frameworks" "$TMP_DIR/"

# Given the catalog contains "frameworks/internal/versions/2026/controls/consent.tracker.prior-consent/control.yaml"
if [ ! -f "$TMP_DIR/$gdpr_control_file" ]; then
  echo "expected GDPR/ePrivacy control fixture before moving it: $gdpr_control_file" >&2
  exit 1
fi
mkdir -p "$(dirname "$TMP_DIR/$internal_control_file")"
mv "$TMP_DIR/$gdpr_control_file" "$TMP_DIR/$internal_control_file"
if [ ! -f "$TMP_DIR/$internal_control_file" ]; then
  echo "expected internal control fixture: $internal_control_file" >&2
  exit 1
fi

# And the catalog does not contain "frameworks/gdpr-eprivacy/versions/2016/controls/consent.tracker.prior-consent/control.yaml"
if [ -f "$TMP_DIR/$gdpr_control_file" ]; then
  echo "expected GDPR/ePrivacy control to be absent: $gdpr_control_file" >&2
  exit 1
fi

# When the catalog layout check runs
if output="$("$ROOT/scripts/check-structure.sh" "$TMP_DIR/frameworks" 2>&1)"; then
  echo "expected catalog layout check to fail for misplaced MAT-114 placeholder" >&2
  echo "$output" >&2
  exit 1
fi

# Then it fails
# And it reports that the MAT-114 placeholder must live under "frameworks/gdpr-eprivacy/versions/2016/"
if [[ "$output" != *"MAT-114 placeholder must live under $gdpr_version_root/"* ]]; then
  echo "expected MAT-114 required root output" >&2
  echo "$output" >&2
  exit 1
fi

echo "MAT-114 placeholder family location OK"
