# Framework catalogs

Each family directory under `frameworks/` is the versioned source of truth for a
compliance framework's controls, rules, and mappings. The agent reads framework
text from these catalogs — never from an external API at runtime.

## Per-family layout

The layout below is delivered by a later ticket (MAT-84). These directories ship
now as placeholders so that schema and rule work can land without restructuring
the repository.

```
frameworks/<family>/
  framework.yaml      # versioned framework metadata (id, version, source URLs)
  controls/           # one file per control
  rules/              # deterministic rules referencing controls
  mappings/           # cross-framework control mappings
```

Each family will hold a versioned `framework.yaml`, plus the `controls/`,
`rules/`, and `mappings/` paths shown above.

## Families

| Directory       | Framework family                                  |
|-----------------|---------------------------------------------------|
| `gdpr-eprivacy` | GDPR / ePrivacy                                   |
| `iso27001`      | ISO/IEC 27001                                     |
| `nis2`          | NIS2                                              |
| `dora`          | DORA                                              |
| `ai-act`        | EU AI Act                                         |
| `custom`        | Internal / customer-specific families             |

The framework content and the id naming conventions are not defined here; they
are delivered by a later ticket (MAT-84).
