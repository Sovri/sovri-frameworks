#!/usr/bin/env bash
set -euo pipefail
# Lint catalog YAML files. Placeholders only for now, so this passes when no
# catalog YAML exists yet. Validates YAML syntax when files are present.
ROOT="${1:-frameworks}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
    ruby -e "require 'yaml'; YAML.safe_load(File.read(ARGV.fetch(0), encoding: 'UTF-8'))" "$y" || { echo "INVALID YAML: $y"; exit 1; }
  done
  ;;
esac

if [ "$parser" = "python" ]; then
  ROOT_ABS="$(cd "$ROOT" && pwd)"
  ROOT_NAME="$(basename "$ROOT_ABS")"
  mapfile -t mappings < <(find "$ROOT_ABS" -path "*/mappings/*/mapping.yaml" -type f | sort)
  for mapping_file in "${mappings[@]}"; do
    mapping_dir="$(cd "$(dirname "$mapping_file")" && pwd)"
    mapping_abs="$mapping_dir/$(basename "$mapping_file")"
    display_file="$mapping_abs"
    case "$mapping_abs" in
    "$ROOT_ABS"/*) display_file="$ROOT_NAME/${mapping_abs#$ROOT_ABS/}" ;;
    esac

    mapping_summary="$("$SCRIPT_DIR/catalog_mapping_summary.py" "$mapping_file")"
    control_id="$(printf '%s\n' "$mapping_summary" | sed -n '1p')"
    reference_count="$(printf '%s\n' "$mapping_summary" | sed -n '2p')"
    echo "validated mapping.yaml: $display_file"
    echo "control $control_id is bound to $reference_count framework references"
  done
fi

echo "catalog lint OK (${#yamls[@]} files)"
