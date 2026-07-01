#!/usr/bin/env bash
set -euo pipefail
# Validate that every required framework family directory exists (R-02/R-03).
# Runs fully offline with no secrets. Names any missing family.
ROOT="${1:-frameworks}"
FAMILIES=(gdpr-eprivacy iso27001 nis2 dora ai-act custom)
if [ ! -d "$ROOT" ]; then
  echo "MISSING catalog root: $ROOT/"
  exit 1
fi

fail=0
for fam in "${FAMILIES[@]}"; do
  if [ ! -d "$ROOT/$fam" ]; then
    echo "MISSING family: $fam"
    fail=1
  fi
done
if [ "$fail" -eq 0 ]; then
  echo "catalog structure OK (${#FAMILIES[@]} families under $ROOT/)"
else
  exit 1
fi
