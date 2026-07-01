#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
FRAMEWORKS_DIR="$ROOT/frameworks"

# Given the repository "sovri-frameworks" has been scaffolded
if [ ! -d "$FRAMEWORKS_DIR" ]; then
  echo "MISSING catalog root: frameworks/" >&2
  exit 1
fi

# When I list the "frameworks/" directory
# Then it contains a directory "<family>"
# And the directory path is "frameworks/<family>"
families=(gdpr-eprivacy iso27001 nis2 dora ai-act internal custom)
for family in "${families[@]}"; do
  if [ ! -d "$FRAMEWORKS_DIR/$family" ]; then
    echo "MISSING family directory: frameworks/$family" >&2
    exit 1
  fi
done

echo "initial framework family directories OK"
