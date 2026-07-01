#!/usr/bin/env python3
import sys

import yaml


def main() -> int:
    with open(sys.argv[1], encoding="utf-8") as handle:
        data = yaml.safe_load(handle) or {}

    if not isinstance(data, dict):
        data = {}

    control_id = data.get("control_id", "")
    framework_references = data.get("framework_references") or []
    if not isinstance(framework_references, list):
        framework_references = []

    print(control_id)
    print(len(framework_references))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
