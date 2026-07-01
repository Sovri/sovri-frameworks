# Framework catalogs

Each family directory under `frameworks/` is the source of truth for versioned
compliance framework catalogs. The agent reads framework text from these
catalogs — never from an external API at runtime.

## Per-family layout

Each family stores catalog content under `versions/<version>/` so a framework
can evolve without changing loader code or moving stable controls later.

```text
frameworks/<family>/versions/<version>/
  framework.yaml      # framework metadata (id, version, jurisdiction)
  controls/           # one directory per stable control id
  rules/              # deterministic rules referencing controls
  mappings/           # cross-framework control mappings
```

For the GDPR / ePrivacy 2016 catalog, the stable child paths are:

- `frameworks/gdpr-eprivacy/versions/2016/controls/consent.tracker.prior-consent/control.yaml`
- `frameworks/gdpr-eprivacy/versions/2016/rules/consent.detect-trackers-without-consent-evidence/rule.yaml`
- `frameworks/gdpr-eprivacy/versions/2016/mappings/consent.tracker.prior-consent/mapping.yaml`

## Adding a framework family

Add a new framework as catalog files under its version root. For example:

- Add family `eu-cyber-resilience-act` version `2024` under
  `frameworks/eu-cyber-resilience-act/versions/2024/`.
- Add family `internal-risk-baseline` version `2026` under
  `frameworks/internal-risk-baseline/versions/2026/`.

For each version root, add:

- `framework.yaml` at the version root.
- Control files under `controls/<stable-control-id>/control.yaml`.
- Rule files under `rules/<rule-id>/rule.yaml`.
- Mapping files under `mappings/<stable-control-id>/mapping.yaml`.

For `frameworks/eu-cyber-resilience-act/versions/2024/`, that resolves to:

- `frameworks/eu-cyber-resilience-act/versions/2024/framework.yaml`
- `frameworks/eu-cyber-resilience-act/versions/2024/controls/<stable-control-id>/control.yaml`
- `frameworks/eu-cyber-resilience-act/versions/2024/rules/<rule-id>/rule.yaml`
- `frameworks/eu-cyber-resilience-act/versions/2024/mappings/<stable-control-id>/mapping.yaml`

Adding a framework is a catalog-data change only. Engine code does not need a per-framework registration change.

## Families

| Directory       | Framework family                                  |
|-----------------|---------------------------------------------------|
| `gdpr-eprivacy` | GDPR / ePrivacy                                   |
| `iso27001`      | ISO/IEC 27001                                     |
| `nis2`          | NIS2                                              |
| `dora`          | DORA                                              |
| `ai-act`        | EU AI Act                                         |
| `internal`      | Shared Sovri-maintained baseline                  |
| `custom`        | Customer-specific extension point                 |

The framework content and the id naming conventions are not defined here; they
are delivered by a later ticket (MAT-84).
