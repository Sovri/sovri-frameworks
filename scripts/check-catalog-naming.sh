#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-frameworks}"
fail=0

if ! command -v python3 >/dev/null 2>&1 || ! python3 -c "import yaml" >/dev/null 2>&1; then
  echo "ERROR: Python PyYAML is required for catalog naming check"
  exit 1
fi

ROOT_ABS="$(cd "$ROOT" && pwd)"
ROOT_NAME="$(basename "$ROOT_ABS")"

mapfile -t control_files < <(find "$ROOT" -path '*/controls/*/control.yaml' -type f | sort)
if [ "${#control_files[@]}" -eq 0 ]; then
  echo "catalog naming OK (no control files yet)"
  exit 0
fi

for control_file in "${control_files[@]}"; do
  control_dir="$(cd "$(dirname "$control_file")" && pwd)"
  control_abs="$control_dir/$(basename "$control_file")"
  display_file="$control_abs"
  case "$control_abs" in
  "$ROOT_ABS"/*) display_file="$ROOT_NAME/${control_abs#$ROOT_ABS/}" ;;
  esac

  metadata="$(
    python3 - "$control_file" <<'PY'
import sys
import yaml

with open(sys.argv[1], encoding="utf-8") as handle:
    data = yaml.safe_load(handle) or {}

if not isinstance(data, dict):
    raise SystemExit("control metadata must be a mapping")

print(data.get("id", ""))
for reference in data.get("framework_references") or []:
    print(reference)
PY
  )" || {
    echo "INVALID control metadata: $display_file"
    fail=1
    continue
  }

  control_id="$(printf '%s\n' "$metadata" | sed -n '1p')"
  expected_id="$(basename "$(dirname "$control_file")")"
  if [ -z "$control_id" ]; then
    echo "MISSING control id: $display_file"
    fail=1
    continue
  fi
  if [ "$control_id" != "$expected_id" ]; then
    echo "control id must match path: $display_file"
    fail=1
    continue
  fi

  mapfile -t framework_references < <(printf '%s\n' "$metadata" | sed '1d')
  if [ "${#framework_references[@]}" -eq 0 ]; then
    echo "MISSING framework reference: $display_file"
    fail=1
    continue
  fi

  echo "validated control.yaml: $display_file"
  echo "control id: $control_id"
  for framework_reference in "${framework_references[@]}"; do
    if [ "$control_id" = "$framework_reference" ]; then
      echo "framework reference must stay outside the control id: $display_file"
      fail=1
      continue
    fi
    echo "framework reference kept outside control id: $framework_reference"
  done
done

if [ "$fail" -eq 0 ]; then
  echo "catalog naming OK (${#control_files[@]} control files)"
else
  exit 1
fi
