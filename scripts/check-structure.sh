#!/usr/bin/env bash
set -euo pipefail
# Validate that every required framework family directory exists (R-02/R-03).
# Runs fully offline with no secrets. Names any missing family.
ROOT="${1:-frameworks}"
FAMILIES=(gdpr-eprivacy iso27001 nis2 dora ai-act internal custom)
if [ ! -d "$ROOT" ]; then
  if [ "$ROOT" = "frameworks" ] && [ -d "farameworks" ]; then
    echo "catalog root must be frameworks/"
    exit 1
  fi

  echo "MISSING catalog root: $ROOT/"
  exit 1
fi

fail=0
framework_version() {
  case "$1" in
    gdpr-eprivacy) echo "2016" ;;
    iso27001 | nis2 | dora) echo "2022" ;;
    ai-act) echo "2024" ;;
    internal | custom) echo "2026" ;;
    *) return 1 ;;
  esac
}

for fam in "${FAMILIES[@]}"; do
  if [ ! -d "$ROOT/$fam" ]; then
    echo "MISSING family: $fam"
    fail=1
    continue
  fi

  version="$(framework_version "$fam")"
  metadata_file="$ROOT/$fam/versions/$version/framework.yaml"
  if [ ! -f "$metadata_file" ]; then
    echo "MISSING framework metadata: $metadata_file"
    fail=1
    continue
  fi

  echo "accepted framework family $fam version $version"
  echo "framework metadata: $metadata_file"
done
if [ "$fail" -eq 0 ]; then
  echo "catalog structure OK (${#FAMILIES[@]} families under $ROOT/)"
else
  exit 1
fi
