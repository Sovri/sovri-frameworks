#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'command -v trash >/dev/null 2>&1 && trash "$TMP_DIR" || true' EXIT

control_file="frameworks/gdpr-eprivacy/versions/2016/controls/gdpr.article-6/control.yaml"
full_control_file="$TMP_DIR/$control_file"

# Given the catalog contains control file "frameworks/gdpr-eprivacy/versions/2016/controls/gdpr.article-6/control.yaml"
mkdir -p "$(dirname "$full_control_file")"

# And "control.yaml" declares id "gdpr.article-6"
cat > "$full_control_file" <<'YAML'
id: gdpr.article-6
framework_references:
  - gdpr:2016:article-6
YAML

# When the catalog naming check runs
if output="$("$ROOT/scripts/check-catalog-naming.sh" "$TMP_DIR/frameworks" 2>&1)"; then
  echo "expected catalog naming check to fail for a framework citation control id" >&2
  echo "$output" >&2
  exit 1
fi

# Then it fails
# And it reports that control ids must use framework-neutral names like "consent.tracker.prior-consent"
expected="control ids must use framework-neutral names like consent.tracker.prior-consent"
if [[ "$output" != *"$expected"* ]]; then
  echo "expected framework-neutral control id guidance" >&2
  echo "$output" >&2
  exit 1
fi

echo "framework citation control id rejection OK"
