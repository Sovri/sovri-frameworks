#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-frameworks}"
fail=0

mapfile -t control_files < <(find "$ROOT" -path '*/controls/*/control.yaml' -type f | sort)
if [ "${#control_files[@]}" -eq 0 ]; then
  echo "catalog naming OK (no control files yet)"
  exit 0
fi

for control_file in "${control_files[@]}"; do
  display_file="$control_file"
  case "$display_file" in
  "$PWD"/*) display_file="${display_file#$PWD/}" ;;
  esac

  control_id="$(awk -F':[[:space:]]*' '$1 == "id" { gsub(/^"|"$/, "", $2); print $2; exit }' "$control_file")"
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

  mapfile -t framework_references < <(
    awk '
      /^framework_references:/ { in_refs = 1; next }
      in_refs && /^  - / {
        sub(/^  - /, "")
        gsub(/^"|"$/, "")
        print
        next
      }
      in_refs && /^[^[:space:]]/ { in_refs = 0 }
    ' "$control_file"
  )
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
