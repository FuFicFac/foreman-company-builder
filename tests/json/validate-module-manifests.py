#!/usr/bin/env python3
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
required_profile = {
    "pause_resume_runs",
    "unified_execution_and_business_state",
    "stateless_reducer_loop",
}
for path in sorted(root.glob("*/module.json")):
    data = json.loads(path.read_text())
    for key in ["name", "version", "description"]:
        assert data.get(key), f"{path}: missing {key}"
    assert data.get("stages"), f"{path}: missing stages"
    assert data.get("inspection_standards"), f"{path}: missing inspection_standards"
    profile = data.get("twelve_factor_profile", {})
    missing = [k for k in required_profile if profile.get(k) is not True]
    assert not missing, f"{path}: twelve_factor_profile missing/false {missing}"
print("module manifests valid")
