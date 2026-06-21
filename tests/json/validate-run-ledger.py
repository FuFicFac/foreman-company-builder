#!/usr/bin/env python3
import json
import sys
from pathlib import Path

ALLOWED = {"running", "paused", "cancelled", "completed", "failed", "blocked", "needs_human"}
REQUIRED = {"id", "module", "project", "stage", "task", "status", "created_at", "updated_at", "events"}

path = Path(sys.argv[1])
state = json.loads(path.read_text())
assert state.get("schema_version") == "foreman.runs.v0"
assert isinstance(state.get("runs"), list)
seen = set()
for run in state["runs"]:
    missing = REQUIRED - set(run)
    assert not missing, f"missing fields: {missing}"
    assert run["id"] not in seen, f"duplicate run id {run['id']}"
    seen.add(run["id"])
    assert run["status"] in ALLOWED, run["status"]
    assert isinstance(run["events"], list)
    for event in run["events"]:
        assert event.get("type")
        assert event.get("timestamp")
print("run ledger valid")
