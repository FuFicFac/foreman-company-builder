#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export FOREMAN_CONFIG_DIR="$TMP/.foreman"

# ── Start a run ──
out="$("$ROOT/scripts/foreman-run.sh" start publishing --project memoir --stage metadata-positioning --task "Create metadata package")"
run_id="$(printf '%s\n' "$out" | awk '/run_/ {print $NF; exit}')"
[[ "$run_id" == run_* ]]

# ── Single fail does NOT escalate ──
"$ROOT/scripts/foreman-run.sh" inspect "$run_id" --verdict fail --notes "First failure"
python3 - "$FOREMAN_CONFIG_DIR" <<'PY'
import json, os, sys
s = json.load(open(os.path.join(sys.argv[1], "runs.json")))
r = s["runs"][0]
assert r["status"] == "failed", f"expected failed after 1 strike, got {r['status']}"
assert r["escalation"]["strike_count"] == 1, f"expected strike_count=1, got {r['escalation']['strike_count']}"
assert r["escalation"]["status"] == "none", f"expected escalation.status=none after 1 strike, got {r['escalation']['status']}"
print("  ✓ single fail does not escalate (status=failed, strike=1, escalation=none)")
PY

# ── Second fail: strike_count=2, still not escalated ──
"$ROOT/scripts/foreman-run.sh" resume "$run_id"
"$ROOT/scripts/foreman-run.sh" inspect "$run_id" --verdict fail --notes "Second failure"
python3 - "$FOREMAN_CONFIG_DIR" <<'PY'
import json, os, sys
s = json.load(open(os.path.join(sys.argv[1], "runs.json")))
r = s["runs"][0]
assert r["status"] == "failed", f"expected failed after 2 strikes, got {r['status']}"
assert r["escalation"]["strike_count"] == 2, f"expected strike_count=2, got {r['escalation']['strike_count']}"
assert r["escalation"]["status"] == "none", f"expected escalation.status=none after 2 strikes, got {r['escalation']['status']}"
print("  ✓ two fails do not escalate (status=failed, strike=2, escalation=none)")
PY

# ── Third fail: 3-strike escalation → status=blocked, escalation.status=escalated ──
"$ROOT/scripts/foreman-run.sh" resume "$run_id"
"$ROOT/scripts/foreman-run.sh" inspect "$run_id" --verdict fail --notes "Third failure — 3-strike"
python3 - "$FOREMAN_CONFIG_DIR" <<'PY'
import json, os, sys
s = json.load(open(os.path.join(sys.argv[1], "runs.json")))
r = s["runs"][0]
assert r["status"] == "blocked", f"expected blocked after 3 strikes, got {r['status']}"
assert r["escalation"]["strike_count"] == 3, f"expected strike_count=3, got {r['escalation']['strike_count']}"
assert r["escalation"]["status"] == "escalated", f"expected escalation.status=escalated after 3 strikes, got {r['escalation']['status']}"
assert r["escalation"]["reason"] == "Third failure — 3-strike", f"expected reason preserved, got {r['escalation']['reason']!r}"
assert r["inspections"][-1]["verdict"] == "fail"
assert r["events"][-1]["type"] == "run_inspected"
print("  ✓ three fails trigger escalation (status=blocked, strike=3, escalation=escalated)")
PY

# ── Validate the run ledger is still well-formed ──
python3 "$ROOT/tests/json/validate-run-ledger.py" "$FOREMAN_CONFIG_DIR/runs.json"

echo "escalation smoke passed"