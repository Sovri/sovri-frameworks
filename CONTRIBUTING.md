# Contributing

Thanks for contributing to Sovri Community (Apache-2.0).

## Local setup

No toolchain, secrets, or network access are required — only POSIX shell.

```sh
./scripts/check-structure.sh   # validate the family structure offline
./scripts/lint-catalogs.sh     # lint catalog YAML (when present)
```

Install the local Git hooks (they mirror CI, per ADR-012):

```sh
lefthook install
```

## Gates

Every pull request must pass the CI gates in `.github/workflows/`: catalog
structure, catalog lint, docs, secrets scan, and action-pin check. Do not bypass
hooks (`--no-verify` is forbidden).

## Branch protection

See `docs/branch-protection.md` for the `main` protection settings.
