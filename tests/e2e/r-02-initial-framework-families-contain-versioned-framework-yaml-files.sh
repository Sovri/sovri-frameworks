#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Given the repository "sovri-frameworks" has been scaffolded
# And the catalog contains "<framework file>"
# When the catalog layout check runs
output="$("$ROOT/scripts/check-structure.sh" 2>&1)"

examples=(
  "gdpr-eprivacy|2016|frameworks/gdpr-eprivacy/versions/2016/framework.yaml"
  "iso27001|2022|frameworks/iso27001/versions/2022/framework.yaml"
  "nis2|2022|frameworks/nis2/versions/2022/framework.yaml"
  "dora|2022|frameworks/dora/versions/2022/framework.yaml"
  "ai-act|2024|frameworks/ai-act/versions/2024/framework.yaml"
  "internal|2026|frameworks/internal/versions/2026/framework.yaml"
  "custom|2026|frameworks/custom/versions/2026/framework.yaml"
)

for example in "${examples[@]}"; do
  IFS="|" read -r family version framework_file <<< "$example"

  # Then it accepts framework family "<family>" version "<version>"
  if [[ "$output" != *"accepted framework family $family version $version"* ]]; then
    echo "expected accepted family/version output for $family $version" >&2
    echo "$output" >&2
    exit 1
  fi

  # And it reports "<framework file>" as the version metadata file
  if [[ "$output" != *"framework metadata: $framework_file"* ]]; then
    echo "expected framework metadata output for $framework_file" >&2
    echo "$output" >&2
    exit 1
  fi

  if ! grep -qx "id: $family" "$ROOT/$framework_file"; then
    echo "expected id field for $family in $framework_file" >&2
    exit 1
  fi

  if ! grep -qx "version: \"$version\"" "$ROOT/$framework_file"; then
    echo "expected version field for $version in $framework_file" >&2
    exit 1
  fi

  if ! grep -q "^jurisdiction: " "$ROOT/$framework_file"; then
    echo "expected jurisdiction field in $framework_file" >&2
    exit 1
  fi
done

echo "versioned framework metadata files OK"
