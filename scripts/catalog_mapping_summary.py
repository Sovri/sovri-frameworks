#!/usr/bin/env python3
import sys

import yaml


def main() -> int:
    try:
        with open(sys.argv[1], encoding="utf-8") as handle:
            data = yaml.safe_load(handle)
    except yaml.YAMLError as error:
        print(f"invalid mapping YAML: {error}", file=sys.stderr)
        return 1

    if data is None:
        data = {}
    if not isinstance(data, dict):
        print("mapping metadata must be a mapping", file=sys.stderr)
        return 1

    if "framework_reference" in data:
        print("framework_references must be used instead of framework_reference", file=sys.stderr)
        return 1

    control_id = data.get("control_id", "")
    framework_references = data.get("framework_references") or []
    if isinstance(framework_references, list):
        if not framework_references:
            print("framework_references must contain at least one reference", file=sys.stderr)
            return 1
        if not all(isinstance(reference, str) for reference in framework_references):
            print("framework_references must be a list of strings", file=sys.stderr)
            return 1
        seen_references = set()
        for reference in framework_references:
            if reference in seen_references:
                print(f"duplicate framework reference: {reference}", file=sys.stderr)
                return 1
            seen_references.add(reference)
    else:
        framework_references = []

    print(control_id)
    print(len(framework_references))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
