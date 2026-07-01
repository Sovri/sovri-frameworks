#!/usr/bin/env bash
set -euo pipefail
# Verify the catalog README documents the lint + structure-validation commands
# (R-01) and the Community/Open Core boundary + air-gap sections (R-05).
README="${1:-README.md}"
fail=0

if grep -qE '^#[[:space:]]+Framework catalogs' "$README"; then
  required_catalog_paths=(
    "frameworks/gdpr-eprivacy/versions/2016/controls/consent.tracker.prior-consent/control.yaml"
    "frameworks/gdpr-eprivacy/versions/2016/rules/consent.detect-trackers-without-consent-evidence/rule.yaml"
    "frameworks/gdpr-eprivacy/versions/2016/mappings/consent.tracker.prior-consent/mapping.yaml"
  )

  for path in "${required_catalog_paths[@]}"; do
    if ! grep -Fq -- "$path" "$README"; then
      echo "${path#frameworks/gdpr-eprivacy/versions/2016/} is missing from the documented layout"
      fail=1
    fi
  done

  if [ "$fail" -eq 0 ]; then echo "catalog docs OK"; else exit 1; fi
else
  grep -qE '^##[[:space:]]+Development' "$README" || { echo "MISSING: ## Development section"; fail=1; }
  grep -qE 'scripts/lint-catalogs\.sh|lint.*catalog' "$README" || { echo "MISSING: a command that lints the catalogs"; fail=1; }
  grep -qE 'scripts/check-structure\.sh|validate.*structure' "$README" || { echo "MISSING: a command that validates the catalog structure offline"; fail=1; }
  grep -qiE '^##[[:space:]]+Community and Open Core' "$README" || { echo "MISSING: Community and Open Core section"; fail=1; }
  grep -qF 'Apache-2.0' "$README" || { echo "MISSING: Apache-2.0 license statement"; fail=1; }
  grep -qiE '^##[[:space:]]+Air.?gap' "$README" || { echo "MISSING: air-gap section"; fail=1; }
  if [ "$fail" -eq 0 ]; then echo "docs OK"; else exit 1; fi
fi
