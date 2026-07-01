#!/usr/bin/env bash
set -euo pipefail
# Lint catalog YAML files. Placeholders only for now, so this passes when no
# catalog YAML exists yet. Validates YAML syntax when files are present.
ROOT="${1:-frameworks}"
mapfile -t yamls < <(find "$ROOT" -type f \( -name '*.yaml' -o -name '*.yml' \) 2>/dev/null || true)
if [ ${#yamls[@]} -eq 0 ]; then
  echo "catalog lint OK (no catalog YAML yet)"
  exit 0
fi

if command -v python3 >/dev/null 2>&1 && python3 -c "import yaml" >/dev/null 2>&1; then
  parser=python
elif command -v ruby >/dev/null 2>&1; then
  parser=ruby
else
  echo "ERROR: no YAML parser available for ${#yamls[@]} catalog files (install Python PyYAML or Ruby)"
  exit 1
fi

case "$parser" in
python)
  for y in "${yamls[@]}"; do
    python3 -c 'import sys, yaml; yaml.safe_load(open(sys.argv[1], encoding="utf-8"))' "$y" || { echo "INVALID YAML: $y"; exit 1; }
  done
  ;;
ruby)
  for y in "${yamls[@]}"; do
    ruby -e "require 'yaml'; YAML.load_file(ARGV.fetch(0))" "$y" || { echo "INVALID YAML: $y"; exit 1; }
  done
  ;;
esac

echo "catalog lint OK (${#yamls[@]} files)"
