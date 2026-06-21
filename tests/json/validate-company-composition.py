#!/usr/bin/env python3
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
COMPOSE = ROOT / "scripts" / "compose-company-from-departments.py"
CATALOG = ROOT / "modules" / "departments" / "catalog.json"

catalog = json.loads(CATALOG.read_text())
company_types = catalog.get("company_types", [])
assert company_types, "catalog missing company_types"

for company_type in company_types:
    result = subprocess.run(
        [sys.executable, str(COMPOSE), "--company-type", company_type, "--name", f"test-{company_type}"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 0, f"{company_type}: compose failed: {result.stderr}"
    profile = json.loads(result.stdout)
    for key in ["company_type", "departments", "capabilities", "roles", "inspectors", "tool_manifest"]:
        assert profile.get(key) is not None, f"{company_type}: missing {key}"
    assert profile["company_type"] == company_type
    assert profile["departments"], f"{company_type}: empty departments"
    defaults = catalog.get("default_department_sets", {}).get(company_type, [])
    if defaults:
        assert profile["departments"] == defaults, f"{company_type}: default department set mismatch"

print(f"company composition valid ({len(company_types)} company types)")
