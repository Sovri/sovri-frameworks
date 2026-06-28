# sovri-frameworks

Git source of truth for the Sovri compliance framework, control, and rule
catalogs. Placeholder scaffold from MAT-81; the framework content and naming
conventions land with MAT-84.

## Status

Foundational scaffold. `frameworks/` holds placeholder directories for the
initial framework families (see `frameworks/README.md`). No catalog content yet.

## Development

This repository needs no toolchain, network access, or secrets — only POSIX
shell to run the catalog checks offline.

- Lint catalogs: `./scripts/lint-catalogs.sh`
- Validate catalog structure (offline): `./scripts/check-structure.sh`

The same checks run in CI (`.github/workflows/ci.yml`) on every pull request.
Local Git hooks mirroring them are declared in `lefthook.yml`.

## Community and Open Core

Sovri follows an open-core model: an Apache-2.0 Community edition plus a
proprietary managed Cloud edition.

- This repository is **Community**, licensed under **Apache-2.0** (see
  `LICENSE`). The catalogs are public so that compliance derivation is auditable.
- Proprietary Cloud code lives in separate private repositories and never ships
  here. Cloud may consume these public catalogs; this repository never depends
  on Cloud.

## Air-gap and offline execution

The catalogs are built to be consumed in regulated, frequently air-gapped
environments.

- Official framework text and source URLs come from these versioned catalogs,
  not from a large language model.
- No external API is required during execution; the agent reads the catalogs
  from a local checkout.
- `./scripts/check-structure.sh` validates the catalog structure with no network
  connectivity and no secrets configured.

## License

Apache-2.0. See `LICENSE` and `NOTICE`.
