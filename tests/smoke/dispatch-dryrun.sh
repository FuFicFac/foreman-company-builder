#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FOREMAN="$ROOT/scripts/foreman"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export FOREMAN_CONFIG_DIR="$TMP/.foreman"
mkdir -p "$FOREMAN_CONFIG_DIR"

# ── Create a minimal profile so dispatch can load builder/inspector commands ──
# In dry-run mode the commands are printed but never invoked, so fake commands are fine.
cat > "$FOREMAN_CONFIG_DIR/profile.json" <<'JSON'
{
  "version": "0.2.0",
  "fleet_mode": "single-provider",
  "roles": {
    "inspector": { "name": "Test Inspector", "command": "echo inspector-dry-run" },
    "builder":   { "name": "Test Builder",   "command": "echo builder-dry-run" },
    "cheap":     { "name": "Test Cheap",     "command": "echo cheap-dry-run" }
  },
  "brain": { "provider": "none", "model": "none", "key_env": "" },
  "paperclip": { "url": "", "company_id": "" }
}
JSON

echo "dispatch dry-run smoke"

# ── foreman dispatch --dry-run should plan without invoking agents ──
DRY_OUT=$("$FOREMAN" dispatch --task "Fix the flaky login test" --dry-run 2>&1) || {
  echo "  ✗ dispatch --dry-run failed with exit $?"
  echo "$DRY_OUT"
  exit 1
}

# Assert it mentions DRY RUN and the execution plan
if echo "$DRY_OUT" | grep -qF "[DRY RUN]"; then
  echo "  ✓ dispatch --dry-run shows [DRY RUN] plan"
else
  echo "  ✗ dispatch --dry-run did not show [DRY RUN] marker"
  echo "$DRY_OUT"
  exit 1
fi

if echo "$DRY_OUT" | grep -qF "No agents invoked"; then
  echo "  ✓ dispatch --dry-run declares no agents invoked"
else
  echo "  ✗ dispatch --dry-run missing 'No agents invoked' message"
  echo "$DRY_OUT"
  exit 1
fi

# Assert the plan mentions the builder and inspector commands
if echo "$DRY_OUT" | grep -qF "builder-dry-run"; then
  echo "  ✓ dispatch --dry-run plans builder command"
else
  echo "  ✗ dispatch --dry-run did not show builder command"
  echo "$DRY_OUT"
  exit 1
fi

if echo "$DRY_OUT" | grep -qF "inspector-dry-run"; then
  echo "  ✓ dispatch --dry-run plans inspector command"
else
  echo "  ✗ dispatch --dry-run did not show inspector command"
  echo "$DRY_OUT"
  exit 1
fi

# Assert no run was actually started (runs.json should not exist or be empty)
if [[ -f "$FOREMAN_CONFIG_DIR/runs.json" ]]; then
  RUN_COUNT=$(python3 -c "import json; print(len(json.load(open('$FOREMAN_CONFIG_DIR/runs.json')).get('runs',[])))" 2>/dev/null || echo "0")
  if [[ "$RUN_COUNT" -eq 0 ]]; then
    echo "  ✓ dispatch --dry-run created no runs"
  else
    echo "  ✗ dispatch --dry-run created $RUN_COUNT run(s) — should have created none"
    exit 1
  fi
else
  echo "  ✓ dispatch --dry-run created no runs (no runs.json)"
fi

# ── foreman <unknown> should exit 1 ──
UNKNOWN_OUT=$("$FOREMAN" bogus-command-xyz 2>&1) && UNKNOWN_EXIT=0 || UNKNOWN_EXIT=$?
if [[ "$UNKNOWN_EXIT" -eq 1 ]]; then
  echo "  ✓ foreman <unknown> exits 1"
else
  echo "  ✗ foreman <unknown> exited $UNKNOWN_EXIT (expected 1)"
  echo "$UNKNOWN_OUT"
  exit 1
fi

if echo "$UNKNOWN_OUT" | grep -qF "Unknown command"; then
  echo "  ✓ foreman <unknown> shows 'Unknown command'"
else
  echo "  ✗ foreman <unknown> did not show 'Unknown command'"
  echo "$UNKNOWN_OUT"
  exit 1
fi

echo "dispatch dry-run smoke passed"