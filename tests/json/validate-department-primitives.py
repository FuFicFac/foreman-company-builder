#!/usr/bin/env python3
import json
import sys
from pathlib import Path

ROOT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("modules/departments")
REGISTRY_PATH = ROOT / "capability-registry.json"
CATALOG_PATH = ROOT / "catalog.json"

REQUIRED_PROFILE = {
    "pause_resume_runs",
    "unified_execution_and_business_state",
    "stateless_reducer_loop",
}
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
    try:
        return json.loads(path.read_text())
    except json.JSONDecodeError as exc:
        raise AssertionError(f"{path}: invalid JSON: {exc}") from exc


assert REGISTRY_PATH.exists(), f"{REGISTRY_PATH}: missing capability registry"
registry = load_json(REGISTRY_PATH)
capabilities = registry.get("capabilities", {})
assert registry.get("version"), f"{REGISTRY_PATH}: missing version"
assert isinstance(capabilities, dict) and capabilities, f"{REGISTRY_PATH}: missing capabilities"
registered = set(capabilities)


def assert_registered(path, values, field):
    missing = sorted(set(values) - registered)
    assert not missing, f"{path}: {field} references unknown capabilities {missing}"


def validate_company_type_mappings(path, mappings):
    assert isinstance(mappings, dict), f"{path}: company_type_mappings must be an object"
    missing_types = sorted(REQUIRED_COMPANY_TYPES - set(mappings))
    assert not missing_types, f"{path}: company_type_mappings missing {missing_types}"
    for company_type, mapping in mappings.items():
        relevance = mapping.get("relevance")
        assert relevance in VALID_RELEVANCE, (
            f"{path}: company_type_mappings.{company_type}.relevance must be one of "
            f"{sorted(VALID_RELEVANCE)}"
        )
        assert mapping.get("notes"), f"{path}: company_type_mappings.{company_type}.notes missing"


def validate_department_record(path, data, *, require_module_fields=False):
    base_required = [
        "purpose",
        "universal_responsibilities",
        "workflows",
        "capabilities",
        "roles",
        "inspectors",
        "human_approval_gates",
        "smoke_tests",
        "company_type_mappings",
    ]
    for key in base_required:
        assert data.get(key) is not None and data.get(key) != [], f"{path}: missing {key}"

    if require_module_fields:
        for key in ["name", "version", "description", "stages", "inspection_standards"]:
            assert data.get(key), f"{path}: missing {key}"

        profile = data.get("twelve_factor_profile", {})
        missing_profile = [key for key in REQUIRED_PROFILE if profile.get(key) is not True]
        assert not missing_profile, f"{path}: twelve_factor_profile missing/false {missing_profile}"

    assert_registered(path, data.get("capabilities", []), "capabilities")
    assert_registered(path, data.get("required_capabilities", []), "required_capabilities")
    assert_registered(path, data.get("recommended_capabilities", []), "recommended_capabilities")

    for condition, values in data.get("conditional_capabilities", {}).items():
        assert isinstance(values, list), f"{path}: conditional_capabilities.{condition} must be a list"
        assert_registered(path, values, f"conditional_capabilities.{condition}")

    for capability in data.get("tool_manifest", {}):
        assert capability in registered, f"{path}: tool_manifest references unknown capability {capability}"

    validate_company_type_mappings(path, data.get("company_type_mappings"))


assert CATALOG_PATH.exists(), f"{CATALOG_PATH}: missing department catalog"
catalog = load_json(CATALOG_PATH)
assert catalog.get("version"), f"{CATALOG_PATH}: missing version"
missing_company_types = sorted(REQUIRED_COMPANY_TYPES - set(catalog.get("company_types", [])))
assert not missing_company_types, f"{CATALOG_PATH}: company_types missing {missing_company_types}"
catalog_departments = catalog.get("departments", [])
assert isinstance(catalog_departments, list) and catalog_departments, f"{CATALOG_PATH}: missing departments"

catalog_slugs = set()
for index, department in enumerate(catalog_departments):
    slug = department.get("slug")
    assert slug, f"{CATALOG_PATH}: departments[{index}] missing slug"
    assert slug not in catalog_slugs, f"{CATALOG_PATH}: duplicate department slug {slug}"
    catalog_slugs.add(slug)
    assert department.get("name"), f"{CATALOG_PATH}: {slug} missing name"
    validate_department_record(f"{CATALOG_PATH}:{slug}", department)

default_sets = catalog.get("default_department_sets", {})
missing_defaults = sorted(REQUIRED_COMPANY_TYPES - set(default_sets))
assert not missing_defaults, f"{CATALOG_PATH}: default_department_sets missing {missing_defaults}"
for company_type, slugs in default_sets.items():
    unknown = sorted(set(slugs) - catalog_slugs)
    assert not unknown, f"{CATALOG_PATH}: default_department_sets.{company_type} unknown departments {unknown}"

for index, department in enumerate(catalog_departments):
    slug = department.get("slug")
    for dep in department.get("depends_on_departments", []):
        assert dep in catalog_slugs, f"{CATALOG_PATH}:{slug}: depends_on_departments references unknown {dep}"


department_paths = sorted(path for path in ROOT.glob("*/module.json") if path.is_file())
for path in department_paths:
    data = load_json(path)

    assert data.get("kind") == "department", f"{path}: kind must be department"
    assert data.get("department_slug") == path.parent.name, (
        f"{path}: department_slug must match directory name"
    )
    assert data.get("department_slug") in catalog_slugs, (
        f"{path}: department_slug missing from catalog"
    )
    validate_department_record(path, data, require_module_fields=True)

    for dep in data.get("depends_on_departments", []):
        assert dep in catalog_slugs, f"{path}: depends_on_departments references unknown {dep}"

print(
    f"department primitives valid ({len(department_paths)} department manifests, "
    f"{len(catalog_slugs)} catalog departments, {len(registered)} capabilities)"
)
