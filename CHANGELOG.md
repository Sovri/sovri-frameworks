# Changelog

All notable changes to this project are documented in this file. The format is
based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [0.2.0] - 2026-07-02

### Added
- Framework catalog repository structure: stable family directories
  (gdpr-eprivacy, iso27001, nis2, dora, ai-act, custom, internal) with a
  versioned `versions/<year>/` layout, per-family `framework.yaml` and
  control/mapping/rule paths, and framework-neutral control ids. A control can
  map to multiple framework references. (MAT-84)
- GDPR/ePrivacy consent-control placeholder seeded under the GDPR/ePrivacy
  family for the MAT-114 vertical slice, with its mapping and tracker-detection
  rule. (MAT-84)
- Documentation for adding a new framework through catalog files only, with no
  engine-code changes, tied to the stable path convention. (MAT-84)
- Initial catalog scaffold: placeholder family directories, documented
  per-family layout, offline structure and lint checks, Apache-2.0 licensing,
  SHA-pinned CI gates, and Community/Open Core plus air-gap docs. (MAT-81)

[Unreleased]: https://github.com/Sovri/sovri-frameworks/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/Sovri/sovri-frameworks/releases/tag/v0.2.0
