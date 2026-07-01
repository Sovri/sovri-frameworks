#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
README="$ROOT/frameworks/README.md"

# Given the repository "sovri-frameworks" contains "frameworks/README.md"
if [ ! -f "$README" ]; then
  echo "expected frameworks/README.md to exist" >&2
  exit 1
fi

# When I read "frameworks/README.md"
readme_content="$(cat "$README")"
version_root="frameworks/eu-cyber-resilience-act/versions/2024/"

# Then it documents the example version root
# "frameworks/eu-cyber-resilience-act/versions/2024/"
if [[ "$readme_content" != *"$version_root"* ]]; then
  echo "expected add-framework docs to mention $version_root" >&2
  exit 1
fi

# And it documents that "framework.yaml" lives at the version root
if [[ "$readme_content" != *"${version_root}framework.yaml"* ]]; then
  echo "expected add-framework docs to place framework.yaml at $version_root" >&2
  exit 1
fi

# And it documents that controls, rules, and mappings live below the version root
expected_child_paths=(
  "${version_root}controls/"
  "${version_root}rules/"
  "${version_root}mappings/"
)

for child_path in "${expected_child_paths[@]}"; do
  if [[ "$readme_content" != *"$child_path"* ]]; then
    echo "expected add-framework docs to place ${child_path#"$version_root"} below $version_root" >&2
    exit 1
  fi
done

echo "add-framework stable path convention docs OK"
