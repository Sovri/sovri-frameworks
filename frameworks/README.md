# Framework catalogs

Each family directory under `frameworks/` is the source of truth for versioned
compliance framework catalogs. The agent reads framework text from these
catalogs — never from an external API at runtime.

## Per-family layout

Each family stores catalog content under `versions/<version>/` so a framework
can evolve without changing loader code or moving stable controls later.

```
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
