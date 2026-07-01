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

# Given the repository "sovri-frameworks" has been scaffolded
cp -R "$ROOT/frameworks" "$TMP_DIR/"

# And the catalog contains "frameworks/gdpr-eprivacy/framework.yaml"
# And the catalog does not contain
# "frameworks/gdpr-eprivacy/versions/2016/framework.yaml"
mv \
  "$TMP_DIR/frameworks/gdpr-eprivacy/versions/2016/framework.yaml" \
  "$TMP_DIR/frameworks/gdpr-eprivacy/framework.yaml"

# When the catalog layout check runs
if output="$(cd "$TMP_DIR" && "$ROOT/scripts/check-structure.sh" frameworks 2>&1)"; then
  echo "expected catalog layout check to fail for unversioned framework metadata" >&2
  echo "$output" >&2
  exit 1
fi

# Then it fails
# And it reports that framework metadata must live under
# "frameworks/gdpr-eprivacy/versions/2016/framework.yaml"
expected="framework metadata must live under frameworks/gdpr-eprivacy/versions/2016/framework.yaml"
if [[ "$output" != *"$expected"* ]]; then
  echo "expected unversioned framework metadata message" >&2
  echo "$output" >&2
  exit 1
fi

echo "unversioned framework metadata rejection OK"
