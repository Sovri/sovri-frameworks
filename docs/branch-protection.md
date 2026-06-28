# Branch protection — `main`

`main` is the protected trunk. Recommended GitHub settings (they back the CI
gates and follow ADR-012 reciprocity between local hooks and CI):

- Require a pull request before merging; require at least 1 approval; require
  review from Code Owners (`.github/CODEOWNERS`).
- Require these status checks to pass, and require branches to be up to date:
  - `catalog-structure`
  - `catalog-lint`
  - `docs-check`
  - `secrets-scan`
  - `action-pins`
- Require conversation resolution before merging.
- Block force pushes and branch deletion.
- Include administrators.

These mirror `.github/workflows/ci.yml`.
