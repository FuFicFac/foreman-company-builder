#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export FOREMAN_CONFIG_DIR="$TMP/.foreman"

out="$("$ROOT/scripts/foreman-run.sh" start publishing --project memoir --stage metadata-positioning --task "Create metadata package")"
echo "$out"
run_id="$(printf '%s\n' "$out" | awk '/run_/ {print $NF; exit}')"
[[ "$run_id" == run_* ]]

python3 "$ROOT/tests/json/validate-run-ledger.py" "$FOREMAN_CONFIG_DIR/runs.json"
python3 - <<'PY'
import json, os
s=json.load(open(os.environ['FOREMAN_CONFIG_DIR'] + '/runs.json'))
r=s['runs'][0]
assert r['id'].startswith('run_')
assert r['module'] == 'publishing'
assert r['project'] == 'memoir'
assert r['stage'] == 'metadata-positioning'
assert r['task'] == 'Create metadata package'
assert r['status'] == 'running'
assert r['events'][-1]['type'] == 'run_started'
PY

"$ROOT/scripts/foreman-run.sh" status "$run_id" | grep -q "running"
"$ROOT/scripts/foreman-run.sh" pause "$run_id"
python3 - <<'PY'
import json, os
s=json.load(open(os.environ['FOREMAN_CONFIG_DIR'] + '/runs.json'))
assert s['runs'][0]['status'] == 'paused'
assert s['runs'][0]['events'][-1]['type'] == 'run_paused'
PY

"$ROOT/scripts/foreman-run.sh" resume "$run_id"
python3 - <<'PY'
import json, os
s=json.load(open(os.environ['FOREMAN_CONFIG_DIR'] + '/runs.json'))
assert s['runs'][0]['status'] == 'running'
assert s['runs'][0]['events'][-1]['type'] == 'run_resumed'
PY

"$ROOT/scripts/foreman-run.sh" inspect "$run_id" --verdict pass --notes "Looks good"
python3 - <<'PY'
import json, os
s=json.load(open(os.environ['FOREMAN_CONFIG_DIR'] + '/runs.json'))
r=s['runs'][0]
assert r['status'] == 'completed'
assert r['inspections'][-1]['verdict'] == 'pass'
assert r['events'][-1]['type'] == 'run_inspected'
PY

echo "run lifecycle smoke passed"
