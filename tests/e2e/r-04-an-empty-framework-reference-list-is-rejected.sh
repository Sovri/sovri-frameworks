#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'command -v trash >/dev/null 2>&1 && trash "$TMP_DIR" || true' EXIT

mapping_file="frameworks/gdpr-eprivacy/versions/2016/mappings/consent.tracker.prior-consent/mapping.yaml"
full_mapping_file="$TMP_DIR/$mapping_file"

# Given the catalog contains mapping file "frameworks/gdpr-eprivacy/versions/2016/mappings/consent.tracker.prior-consent/mapping.yaml"
cp -R "$ROOT/frameworks" "$TMP_DIR/"
if [ ! -f "$full_mapping_file" ]; then
  echo "expected mapping file: $mapping_file" >&2
  exit 1
fi

# And "mapping.yaml" declares control_id "consent.tracker.prior-consent"
# And "mapping.yaml" declares framework_references as an empty list
cat > "$full_mapping_file" <<'YAML'
control_id: consent.tracker.prior-consent
framework_references: []
YAML

# When the catalog layout check runs
if output="$("$ROOT/scripts/lint-catalogs.sh" "$TMP_DIR/frameworks" 2>&1)"; then
  echo "expected catalog layout check to fail for empty framework_references" >&2
  echo "$output" >&2
  exit 1
fi

# Then validation fails for "mapping.yaml"
if [[ "$output" != *"INVALID mapping.yaml: $mapping_file"* ]]; then
  echo "expected invalid mapping output for $mapping_file" >&2
  echo "$output" >&2
  exit 1
fi

# And the validation error reports that "framework_references" must contain at least one reference
expected="framework_references must contain at least one reference"
if [[ "$output" != *"$expected"* ]]; then
  echo "expected empty framework_references validation error" >&2
  echo "$output" >&2
  exit 1
fi

echo "empty framework reference list rejection OK"
