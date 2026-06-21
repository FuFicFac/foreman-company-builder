#!/usr/bin/env python3
import json
import sys
from pathlib import Path

ROOT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("modules/departments")
CATALOG_PATH = ROOT / "catalog.json"
REGISTRY_PATH = ROOT / "capability-registry.json"

REQUIRED_COMPANY_TYPES = {
    "software",
    "physical_product",
    "local_service",
    "creator",
    "publishing",
    "education_community",
}
VALID_RELEVANCE = {"required", "recommended", "optional", "not_applicable"}


def load_json(path):
    return json.loads(path.read_text())


assert CATALOG_PATH.exists(), f"{CATALOG_PATH}: missing catalog"
assert REGISTRY_PATH.exists(), f"{REGISTRY_PATH}: missing capability registry"

catalog = load_json(CATALOG_PATH)
registry = load_json(REGISTRY_PATH)
registered = set(registry.get("capabilities", {}))

departments = catalog.get("departments", [])
assert departments, f"{CATALOG_PATH}: no departments"

slugs = []
for dept in departments:
    slug = dept.get("slug")
    assert slug, "catalog department missing slug"
    slugs.append(slug)
    for key in ["name", "purpose", "universal_responsibilities", "workflows", "capabilities", "company_type_mappings"]:
        assert dept.get(key), f"catalog {slug}: missing {key}"

    missing_caps = sorted(set(dept.get("capabilities", [])) - registered)
    assert not missing_caps, f"catalog {slug}: unknown capabilities {missing_caps}"

    missing_types = sorted(REQUIRED_COMPANY_TYPES - set(dept["company_type_mappings"]))
    assert not missing_types, f"catalog {slug}: company_type_mappings missing {missing_types}"
    for company_type, mapping in dept["company_type_mappings"].items():
        assert mapping.get("relevance") in VALID_RELEVANCE, f"catalog {slug}: invalid relevance for {company_type}"
        assert mapping.get("notes"), f"catalog {slug}: notes missing for {company_type}"

assert len(slugs) == len(set(slugs)), "catalog contains duplicate department slugs"

defaults = catalog.get("default_department_sets", {})
for company_type, dept_list in defaults.items():
    assert company_type in REQUIRED_COMPANY_TYPES, f"default_department_sets unknown type {company_type}"
    unknown = sorted(set(dept_list) - set(slugs))
    assert not unknown, f"default_department_sets.{company_type} references unknown slugs {unknown}"

print(f"department catalog valid ({len(departments)} departments, {len(registered)} capabilities)")
