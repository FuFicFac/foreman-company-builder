#!/bin/zsh
set -euo pipefail

CONFIG_DIR="${FOREMAN_CONFIG_DIR:-$HOME/.foreman}"
RUNS_FILE="$CONFIG_DIR/runs.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ACTION="${1:-help}"
shift || true

mkdir -p "$CONFIG_DIR"

usage() {
  cat <<'EOF'
Usage:
  foreman-run.sh start <module> --project <name> --stage <stage> [--task "..."]
  foreman-run.sh status [run_id]
  foreman-run.sh list
  foreman-run.sh pause <run_id>
  foreman-run.sh resume <run_id>
  foreman-run.sh cancel <run_id>
  foreman-run.sh inspect <run_id> [--verdict pass|fail|blocked|needs-human] [--notes "..."]
  foreman-run.sh qa <run_id> --result pass|fail [--notes "..."]
  foreman-run.sh launch <run_id> --result pass|fail [--notes "..."]
EOF
}

case "$ACTION" in
  start|status|list|pause|resume|cancel|inspect|qa|launch)
    FOREMAN_CONFIG_DIR="$CONFIG_DIR" RUNS_FILE="$RUNS_FILE" REPO_ROOT="$REPO_ROOT" ACTION="$ACTION" python3 - "$@" <<'PY'
import json
import os
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

config_dir = Path(os.environ["FOREMAN_CONFIG_DIR"])
runs_file = Path(os.environ["RUNS_FILE"])
repo_root = Path(os.environ["REPO_ROOT"])
action = os.environ["ACTION"]
args = sys.argv[1:]

TERMINAL = {"cancelled", "completed", "blocked", "needs_human", "qa_failed", "launch_failed"}


def now():
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def empty_state():
    return {"schema_version": "foreman.runs.v0", "next_id": 1, "runs": []}


def load_state():
    if not runs_file.exists():
        return empty_state()
    return json.loads(runs_file.read_text())


def save_state(state):
    runs_file.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix="runs.", suffix=".json", dir=str(runs_file.parent))
    with os.fdopen(fd, "w") as f:
        json.dump(state, f, indent=2, ensure_ascii=False)
        f.write("\n")
    os.replace(tmp, runs_file)


def parse_flags(items):
    out = {"_": []}
    i = 0
    while i < len(items):
        item = items[i]
        if item.startswith("--"):
            key = item[2:].replace("-", "_")
            if i + 1 >= len(items) or items[i + 1].startswith("--"):
                out[key] = True
                i += 1
            else:
                out[key] = items[i + 1]
                i += 2
        else:
            out["_"].append(item)
            i += 1
    return out


def find_run(state, run_id):
    for run in state["runs"]:
        if run["id"] == run_id:
            return run
    raise SystemExit(f"Run not found: {run_id}")


def event(run, event_type, **data):
    evt = {"type": event_type, "timestamp": now()}
    if data:
        evt["data"] = data
    run.setdefault("events", []).append(evt)
    run["updated_at"] = evt["timestamp"]


def module_manifest(module):
    candidates = [
        config_dir / "modules" / module / "module.json",
        repo_root / "modules" / module / "module.json",
    ]
    for path in candidates:
        if path.exists():
            return json.loads(path.read_text()), str(path)
    raise SystemExit(f"Unknown module: {module}")


def validate_stage(manifest, stage):
    stages = manifest.get("stages") or []
    if stages and stage not in stages:
        raise SystemExit(f"Stage '{stage}' not found in module {manifest.get('name')}. Try one of: {', '.join(stages)}")


def cmd_start():
    if not args:
        raise SystemExit("start requires a module name")
    module = args[0]
    flags = parse_flags(args[1:])
    project = flags.get("project")
    stage = flags.get("stage")
    task = flags.get("task", "Untitled task")
    if not project or not stage:
        raise SystemExit("start requires --project and --stage")
    manifest, manifest_path = module_manifest(module)
    validate_stage(manifest, stage)
    state = load_state()
    run_num = state.get("next_id", 1)
    run_id = f"run_{run_num}"
    state["next_id"] = run_num + 1
    stamp = now()
    run = {
        "id": run_id,
        "module": module,
        "company": module,
        "project": project,
        "stage": stage,
        "task": task,
        "status": "running",
        "created_at": stamp,
        "updated_at": stamp,
        "module_file": manifest_path,
        "loop_mode": manifest.get("loop_mode", "lean"),
        "roles": manifest.get("roles", []),
        "builders": manifest.get("builders", []),
        "inspectors": manifest.get("inspectors", []),
        "qa_roles": manifest.get("qa_roles", []),
        "inspection_standards": manifest.get("inspection_standards", []),
        "attempts": [],
        "inspections": [],
        "human_decisions": [],
        "artifacts": [],
        "blockers": [],
        "escalation": {"status": "none", "strike_count": 0, "reason": None},
        "events": [],
    }
    event(run, "run_started", stage=stage, task=task)
    state["runs"].append(run)
    save_state(state)
    print(f"Started {run_id}")


def cmd_status():
    state = load_state()
    if not args:
        for run in state["runs"]:
            print(f"{run['id']}\t{run['status']}\t{run['module']}\t{run['project']}\t{run['stage']}\t{run['task']}")
        return
    run = find_run(state, args[0])
    print(f"{run['id']}: {run['status']}")
    print(f"module: {run['module']}")
    print(f"project: {run['project']}")
    print(f"stage: {run['stage']}")
    print(f"task: {run['task']}")
    if run.get("events"):
        print(f"last_event: {run['events'][-1]['type']}")


def transition(run, new_status, event_type):
    if run["status"] in TERMINAL:
        raise SystemExit(f"Cannot transition terminal run {run['id']} from {run['status']}")
    run["status"] = new_status
    event(run, event_type)


def cmd_pause():
    if not args:
        raise SystemExit("pause requires run_id")
    state = load_state()
    run = find_run(state, args[0])
    if run["status"] != "running":
        raise SystemExit(f"Can only pause running runs; current status is {run['status']}")
    transition(run, "paused", "run_paused")
    save_state(state)
    print(f"Paused {run['id']}")


def cmd_resume():
    if not args:
        raise SystemExit("resume requires run_id")
    state = load_state()
    run = find_run(state, args[0])
    if run["status"] not in {"paused", "failed"}:
        raise SystemExit(f"Can only resume paused/failed runs; current status is {run['status']}")
    run["status"] = "running"
    event(run, "run_resumed")
    save_state(state)
    print(f"Resumed {run['id']}")


def cmd_cancel():
    if not args:
        raise SystemExit("cancel requires run_id")
    state = load_state()
    run = find_run(state, args[0])
    if run["status"] in TERMINAL:
        raise SystemExit(f"Run already terminal: {run['status']}")
    run["status"] = "cancelled"
    event(run, "run_cancelled")
    save_state(state)
    print(f"Cancelled {run['id']}")


def cmd_inspect():
    if not args:
        raise SystemExit("inspect requires run_id")
    flags = parse_flags(args[1:])
    verdict = flags.get("verdict")
    notes = flags.get("notes", "")
    state = load_state()
    run = find_run(state, args[0])
    if verdict is None:
        print(json.dumps(run, indent=2, ensure_ascii=False))
        return
    if run["status"] in TERMINAL:
        raise SystemExit(f"Cannot inspect terminal run {run['id']} from {run['status']}")
    if verdict not in {"pass", "fail", "blocked", "needs-human"}:
        raise SystemExit("--verdict must be pass, fail, blocked, or needs-human")
    inspection = {"verdict": verdict, "notes": notes, "timestamp": now()}
    run["inspections"].append(inspection)
    # Every inspect verdict corresponds to one builder attempt — mirror it into
    # the attempts array so the ledger holds durable per-attempt evidence.
    attempts = run.setdefault("attempts", [])
    attempts.append({
        "attempt": len(attempts) + 1,
        "verdict": verdict,
        "inspector_notes": notes,
        "timestamp": inspection["timestamp"],
    })
    if verdict == "pass":
        run["status"] = "completed"
    elif verdict == "fail":
        run["escalation"]["strike_count"] += 1
        if run["escalation"]["strike_count"] >= 3:
            run["status"] = "blocked"
            run["escalation"]["status"] = "escalated"
            run["escalation"]["reason"] = notes
        else:
            run["status"] = "failed"
    elif verdict == "blocked":
        run["status"] = "blocked"
        run["blockers"].append({"notes": notes, "timestamp": inspection["timestamp"]})
    else:
        run["status"] = "needs_human"
        run["human_decisions"].append({"prompt": notes, "timestamp": inspection["timestamp"]})
    event(run, "run_inspected", verdict=verdict, notes=notes)
    save_state(state)
    print(f"Inspected {run['id']}: {verdict}")


def _post_completion_outcome(kind):
    # Records the QA-gate / launch-phase outcome for a run that already
    # completed the inspector loop. A failure here is terminal: qa_failed /
    # launch_failed, so the ledger — not just exit codes — shows the truth.
    if not args:
        raise SystemExit(f"{kind} requires run_id")
    flags = parse_flags(args[1:])
    result = flags.get("result")
    notes = flags.get("notes", "")
    if result not in {"pass", "fail"}:
        raise SystemExit("--result must be pass or fail")
    state = load_state()
    run = find_run(state, args[0])
    if run["status"] != "completed":
        raise SystemExit(f"{kind} outcome only applies to completed runs; current status is {run['status']}")
    entry = {"result": result, "notes": notes, "timestamp": now()}
    run.setdefault(f"{kind}_results", []).append(entry)
    if result == "fail":
        run["status"] = f"{kind}_failed"
        event(run, f"{kind}_failed", notes=notes)
    else:
        event(run, f"{kind}_passed")
    save_state(state)
    print(f"Recorded {kind} {result} for {run['id']}")


def cmd_qa():
    _post_completion_outcome("qa")


def cmd_launch():
    _post_completion_outcome("launch")

if action in {"list", "status"}:
    cmd_status()
elif action == "start":
    cmd_start()
elif action == "pause":
    cmd_pause()
elif action == "resume":
    cmd_resume()
elif action == "cancel":
    cmd_cancel()
elif action == "inspect":
    cmd_inspect()
elif action == "qa":
    cmd_qa()
elif action == "launch":
    cmd_launch()
PY
    ;;
  help|--help|-h)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
