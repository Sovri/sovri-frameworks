#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
README="$ROOT/frameworks/README.md"

# Given the repository "sovri-frameworks" contains "frameworks/README.md"
if [ ! -f "$README" ]; then
  echo "expected frameworks/README.md to exist" >&2
  exit 1
fi

examples=(
  "eu-cyber-resilience-act|2024|frameworks/eu-cyber-resilience-act/versions/2024/"
  "internal-risk-baseline|2026|frameworks/internal-risk-baseline/versions/2026/"
)

# When I read "frameworks/README.md"
readme_content="$(cat "$README")"

for example in "${examples[@]}"; do
  IFS="|" read -r family version version_root <<< "$example"

  # Then it explains adding family "<family>" version "<version>" under "<version root>"
  if [[ "$readme_content" != *"$family"* ]] ||
    [[ "$readme_content" != *"$version"* ]] ||
    [[ "$readme_content" != *"$version_root"* ]]; then
    echo "expected add-framework docs for $family version $version under $version_root" >&2
    exit 1
  fi
done

# And it instructs maintainers to add "framework.yaml"
if [[ "$readme_content" != *"framework.yaml"* ]]; then
  echo "expected add-framework docs to mention framework.yaml" >&2
  exit 1
fi

# And it instructs maintainers to add control, rule, and mapping files under that version directory
if [[ "$readme_content" != *"controls/"* ]] ||
  [[ "$readme_content" != *"rules/"* ]] ||
  [[ "$readme_content" != *"mappings/"* ]]; then
  echo "expected add-framework docs to mention controls/, rules/, and mappings/" >&2
  exit 1
fi

# And it states that engine code does not need a per-framework registration change
if ! grep -Eiq 'engine code (does not|doesn'\''t) need a per-framework registration change|does not require per-framework engine registration|without per-framework engine code changes' "$README"; then
  echo "expected add-framework docs to reject per-framework engine registration changes" >&2
  exit 1
fi

echo "add-framework catalog-only docs OK"
