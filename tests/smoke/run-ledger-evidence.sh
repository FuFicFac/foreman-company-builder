#!/usr/bin/env bash
set -euo pipefail

# Regression test for the Wave 6 dogfood ledger defects:
#   1. attempts array stayed empty even across three inspector-failed attempts
#   2. inspection notes captured provider preamble (banners, model/workdir
#      dumps) instead of the inspector's actual findings before the verdict
# The stub inspector mimics a real CLI: noisy preamble first, findings last.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FOREMAN="$ROOT/scripts/foreman"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export FOREMAN_CONFIG_DIR="$TMP/.foreman"
export FOREMAN_SKIP_PROBE=1
mkdir -p "$FOREMAN_CONFIG_DIR" "$TMP/bin"

echo "run ledger evidence smoke"

cat > "$TMP/bin/stub-builder" <<'EOF'
#!/usr/bin/env bash
cat > /dev/null
echo "Built the requested software change."
EOF

cat > "$TMP/bin/stub-inspector" <<'EOF'
#!/usr/bin/env bash
cat > /dev/null
# Mimic a real provider CLI: a dozen lines of banner/config preamble, then the
# actual assessment, then the verdict — proportions taken from the Wave 6
# dogfood transcripts where notes captured only this preamble.
echo "Reading prompt from stdin..."
echo "StubCLI v9.9.9 --------"
for kv in "workdir: /tmp" "model: stub-model" "provider: stub" "approval: never" \
          "sandbox: full" "reasoning effort: medium" "reasoning summaries: none" \
          "session id: 0000" "tools: enabled" "--------"; do
  echo "$kv"
done
echo ""
# Short findings after the FINDINGS: marker — the shape where a pure tail
# heuristic would still leak trailing preamble lines into the notes.
echo "FINDINGS:"
echo "The change is missing unit tests for the error path."
echo "These issues are fixable by the builder."
echo "VERDICT: fail"
EOF

chmod +x "$TMP/bin/stub-builder" "$TMP/bin/stub-inspector"
export PATH="$TMP/bin:$PATH"

cat > "$FOREMAN_CONFIG_DIR/profile.json" <<JSON
{
  "version": "0.2.0",
  "fleet_mode": "single-provider",
  "roles": {
    "inspector": {"name": "Stub Inspector", "command": "$TMP/bin/stub-inspector"},
    "builder": {"name": "Stub Builder", "command": "$TMP/bin/stub-builder"},
    "cheap": {"name": "Stub Cheap", "command": "$TMP/bin/stub-builder"}
  },
  "brain": {"provider": "none", "model": "none", "key_env": ""},
  "paperclip": {"url": "", "company_id": ""}
}
JSON

set +e
OUTPUT="$($FOREMAN dispatch --task "Ship a tiny tested utility" \
  --template software --project ledger-evidence-smoke --workspace "$TMP/ws" 2>&1)"
RC=$?
set -e

if [[ $RC -eq 0 ]]; then
  echo "  ✗ three failed attempts were reported as success" >&2
  echo "$OUTPUT" >&2
  exit 1
fi

python3 - "$FOREMAN_CONFIG_DIR/runs.json" <<'PY'
import json, sys
run = json.load(open(sys.argv[1]))["runs"][-1]
assert run["status"] == "blocked", run["status"]
assert len(run["attempts"]) == 3, f"expected 3 attempts, got {len(run['attempts'])}"
for i, a in enumerate(run["attempts"], start=1):
    assert a["attempt"] == i, a
    assert a["verdict"] == "fail", a
    notes = a["inspector_notes"]
    assert "missing unit tests" in notes, f"findings absent from notes: {notes!r}"
    for banned in ("Reading prompt from stdin", "StubCLI", "session id",
                   "sandbox", "reasoning", "FINDINGS"):
        assert banned not in notes, f"provider preamble/marker leaked into notes: {notes!r}"
print("  ✓ 3 failed attempts recorded with real findings, no provider preamble")
PY

# Validate the produced ledger against the schema checker too.
python3 "$ROOT/tests/json/validate-run-ledger.py" "$FOREMAN_CONFIG_DIR/runs.json"

echo "run ledger evidence smoke passed"
