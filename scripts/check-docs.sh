#!/usr/bin/env bash
set -euo pipefail
# Verify the catalog README documents the lint + structure-validation commands
# (R-01) and the Community/Open Core boundary + air-gap sections (R-05).
README="${1:-README.md}"
fail=0
grep -qE '^##[[:space:]]+Development' "$README" || { echo "MISSING: ## Development section"; fail=1; }
grep -qE 'scripts/lint-catalogs\.sh|lint.*catalog' "$README" || { echo "MISSING: a command that lints the catalogs"; fail=1; }
grep -qE 'scripts/check-structure\.sh|validate.*structure' "$README" || { echo "MISSING: a command that validates the catalog structure offline"; fail=1; }
grep -qiE '^##[[:space:]]+Community and Open Core' "$README" || { echo "MISSING: Community and Open Core section"; fail=1; }
grep -qF 'Apache-2.0' "$README" || { echo "MISSING: Apache-2.0 license statement"; fail=1; }
grep -qiE '^##[[:space:]]+Air.?gap' "$README" || { echo "MISSING: air-gap section"; fail=1; }
if [ "$fail" -eq 0 ]; then echo "docs OK"; else exit 1; fi
