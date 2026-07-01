#!/usr/bin/env bash
set -euo pipefail
# Validate that every required framework family directory exists (R-02/R-03).
# Runs fully offline with no secrets. Names any missing family.
ROOT="${1:-frameworks}"
# `internal` is the shared Sovri-maintained baseline family; `custom` is the
# customer-owned extension point.
FAMILIES=(gdpr-eprivacy iso27001 nis2 dora ai-act internal custom)
# Initial catalog framework versions are legal publication years.
VERSION_PATTERN='^[0-9]{4}$'
if [ ! -d "$ROOT" ]; then
  if [ "$ROOT" = "frameworks" ] && [ -d "farameworks" ]; then
    echo "catalog root must be frameworks/"
    exit 1
  fi

  echo "MISSING catalog root: $ROOT/"
  exit 1
fi

fail=0
for fam in "${FAMILIES[@]}"; do
  case "$fam" in
  *[!a-z0-9-]* | "")
    echo "INVALID family name: $fam"
    fail=1
    continue
    ;;
  esac

  if [ ! -d "$ROOT/$fam" ]; then
    echo "MISSING family: $fam"
    fail=1
    continue
  fi

  metadata_files=()
  version_root="$ROOT/$fam/versions"
  if [ -d "$version_root" ]; then
    while IFS= read -r -d '' metadata_file; do
      metadata_files+=("$metadata_file")
    done < <(find "$version_root" -mindepth 2 -maxdepth 2 -type f -name 'framework.yaml' -print0)
  fi

  if [ "${#metadata_files[@]}" -eq 0 ]; then
    echo "MISSING framework metadata: $ROOT/$fam/versions/*/framework.yaml"
    fail=1
    continue
  fi

  if [ "${#metadata_files[@]}" -ne 1 ]; then
    echo "MULTIPLE framework metadata files: $ROOT/$fam/versions/*/framework.yaml"
    fail=1
    continue
  fi

  metadata_file="${metadata_files[0]}"
  metadata_dir="${metadata_file%/framework.yaml}"
  version="${metadata_dir##*/}"
  if [[ ! "$version" =~ $VERSION_PATTERN ]]; then
    echo "INVALID framework metadata version path: $metadata_dir"
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
