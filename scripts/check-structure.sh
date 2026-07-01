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
MAT_114_CONTROL_ID="consent.tracker.prior-consent"
MAT_114_RULE_ID="consent.detect-trackers-without-consent-evidence"
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

  version_root="$ROOT/$fam/versions"
  version_dirs=()
  if [ -d "$version_root" ]; then
    while IFS= read -r -d '' version_dir; do
      version_dirs+=("$version_dir")
    done < <(find "$version_root" -mindepth 1 -maxdepth 1 -type d -print0)
  fi
  metadata_files=()
  missing_metadata_dirs=()
  for version_dir in "${version_dirs[@]}"; do
    metadata_file="$version_dir/framework.yaml"
    if [ -f "$metadata_file" ]; then
      metadata_files+=("$metadata_file")
    else
      missing_metadata_dirs+=("$version_dir")
    fi
  done

  expected_version="<version>"
  if [ "${#missing_metadata_dirs[@]}" -eq 1 ]; then
    expected_version="${missing_metadata_dirs[0]##*/}"
  elif [ "${#version_dirs[@]}" -eq 1 ]; then
    expected_version="${version_dirs[0]##*/}"
  fi
  expected_metadata="$ROOT/$fam/versions/$expected_version/framework.yaml"
  if [ -f "$ROOT/$fam/framework.yaml" ]; then
    echo "framework metadata must live under $expected_metadata"
    fail=1
    continue
  fi

  if [ "${#metadata_files[@]}" -eq 0 ]; then
    echo "MISSING framework metadata: $ROOT/$fam/versions/*/framework.yaml"
    fail=1
    continue
  fi

  if [ "${#missing_metadata_dirs[@]}" -gt 0 ]; then
    echo "MISSING framework metadata: $ROOT/$fam/versions/*/framework.yaml"
    fail=1
    continue
  fi

  for metadata_file in "${metadata_files[@]}"; do
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
done
if [ "$fail" -eq 0 ]; then
  mat_114_root="$ROOT/gdpr-eprivacy/versions/2016"
  mat_114_control="$mat_114_root/controls/$MAT_114_CONTROL_ID/control.yaml"
  mat_114_rule="$mat_114_root/rules/$MAT_114_RULE_ID/rule.yaml"
  mat_114_mapping="$mat_114_root/mappings/$MAT_114_CONTROL_ID/mapping.yaml"

  if [ ! -f "$mat_114_control" ]; then
    mat_114_other_control=""
    while IFS= read -r candidate_control; do
      case "$candidate_control" in
      "$ROOT/gdpr-eprivacy/"*) continue ;;
      esac
      mat_114_other_control="$candidate_control"
      break
    done < <(find "$ROOT" -path "*/controls/$MAT_114_CONTROL_ID/control.yaml" -type f)
    if [ -n "$mat_114_other_control" ]; then
      echo "MAT-114 placeholder must live under frameworks/gdpr-eprivacy/versions/2016/ (expected frameworks/gdpr-eprivacy/versions/2016/controls/$MAT_114_CONTROL_ID/control.yaml)"
      exit 1
    fi

    echo "missing control $MAT_114_CONTROL_ID"
    exit 1
  fi

  if [ ! -f "$mat_114_rule" ]; then
    echo "missing rule $MAT_114_RULE_ID"
    exit 1
  fi

  if [ ! -f "$mat_114_mapping" ]; then
    echo "missing mapping $MAT_114_CONTROL_ID"
    exit 1
  fi

  echo "MAT-114 placeholder present"
  echo "placeholder control id: $MAT_114_CONTROL_ID"
  echo "placeholder rule id: $MAT_114_RULE_ID"

  echo "catalog structure OK (${#FAMILIES[@]} families under $ROOT/)"
else
  exit 1
fi
