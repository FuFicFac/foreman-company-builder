#!/usr/bin/env python3
"""Compose a company profile from FCB department primitives."""

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = ROOT / "modules" / "departments" / "catalog.json"
DEPT_ROOT = ROOT / "modules" / "departments"

RELEVANCE_INCLUDE = {"required", "recommended"}


def load_json(path):
    return json.loads(path.read_text())


def load_department_module(slug):
    path = DEPT_ROOT / slug / "module.json"
    if not path.exists():
        raise ValueError(f"unknown department slug: {slug}")
    return load_json(path)


def departments_for_type(catalog, company_type, explicit=None):
    if explicit:
        return explicit
    defaults = catalog.get("default_department_sets", {})
    if company_type in defaults:
        return defaults[company_type]
    slugs = []
    for entry in catalog.get("departments", []):
        mapping = entry.get("company_type_mappings", {}).get(company_type, {})
        if mapping.get("relevance") in RELEVANCE_INCLUDE:
            slugs.append(entry["slug"])
    return slugs


def merge_tool_manifest(target, source):
    for capability, tools in source.items():
        existing = target.setdefault(capability, [])
        for tool in tools:
            if tool not in existing:
                existing.append(tool)


def namespace_role(slug, role, seen):
    if role not in seen:
        seen.add(role)
        return role
    namespaced = f"{slug}-{role}"
    seen.add(namespaced)
    return namespaced


def compose(company_type, name="", template="", departments=None, extra=None):
    catalog = load_json(CATALOG_PATH)
    company_types = set(catalog.get("company_types", []))
    if company_type not in company_types:
        raise ValueError(f"unknown company_type: {company_type}")

    dept_slugs = departments_for_type(catalog, company_type, departments)
    if not dept_slugs:
        raise ValueError(f"no departments resolved for company_type: {company_type}")

    capabilities = []
    roles = []
    role_seen = set()
    inspectors = []
    inspector_seen = set()
    gates = []
    gate_seen = set()
    stages = []
    stage_seen = set()
    tool_manifest = {}
    department_records = []

    for slug in dept_slugs:
        module = load_department_module(slug)
        department_records.append(
            {
                "slug": slug,
                "name": module.get("name", slug),
                "capabilities": module.get("capabilities", []),
            }
        )
        for capability in module.get("capabilities", []):
            if capability not in capabilities:
                capabilities.append(capability)
        for role in module.get("roles", []):
            roles.append(namespace_role(slug, role, role_seen))
        for inspector in module.get("inspectors", []):
            if inspector not in inspector_seen:
                inspector_seen.add(inspector)
                inspectors.append(inspector)
        for gate in module.get("human_approval_gates", []):
            if gate not in gate_seen:
                gate_seen.add(gate)
                gates.append(gate)
        for stage in module.get("stages", []):
            if stage not in stage_seen:
                stage_seen.add(stage)
                stages.append(stage)
        merge_tool_manifest(tool_manifest, module.get("tool_manifest", {}))

    profile = {
        "company_type": company_type,
        "name": name or "unnamed",
        "template": template or company_type,
        "departments": dept_slugs,
        "capabilities": capabilities,
        "roles": roles,
        "inspectors": inspectors,
        "human_approval_gates": gates,
        "stages": stages,
        "tool_manifest": tool_manifest,
        "department_records": department_records,
        "composition_source": "modules/departments/catalog.json",
    }
    if extra:
        profile.update(extra)
    return profile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--company-type", required=True)
    parser.add_argument("--name", default="")
    parser.add_argument("--template", default="")
    parser.add_argument("--departments", default="", help="Comma-separated department slugs")
    parser.add_argument("--output", default="-", help="Output path or - for stdout")
    args = parser.parse_args()

    departments = [s.strip() for s in args.departments.split(",") if s.strip()] or None
    profile = compose(args.company_type, name=args.name, template=args.template, departments=departments)
    payload = json.dumps(profile, indent=2) + "\n"
    if args.output == "-":
        print(payload, end="")
    else:
        Path(args.output).write_text(payload)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
