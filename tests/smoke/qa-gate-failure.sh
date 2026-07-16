#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FOREMAN="$ROOT/scripts/foreman"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export FOREMAN_CONFIG_DIR="$TMP/.foreman"
export FOREMAN_SKIP_PROBE=1
mkdir -p "$FOREMAN_CONFIG_DIR" "$TMP/bin"

echo "qa gate failure smoke"

cat > "$TMP/bin/stub-builder" <<'EOF'
#!/usr/bin/env bash
cat > /dev/null
echo "Built and verified the requested software change."
EOF

cat > "$TMP/bin/stub-inspector" <<'EOF'
#!/usr/bin/env bash
PROMPT="$(cat)"
if grep -qF "You are a QA reviewer" <<<"$PROMPT"; then
  echo "The QA checklist fails."
  echo "VERDICT: fail"
else
  echo "The build output satisfies the task."
  echo "VERDICT: pass"
fi
EOF

# Launch is enabled for the software template. Keep its provider hermetic too;
# a correct QA failure must prevent this stub from being reached.
cat > "$TMP/bin/ollama" <<'EOF'
#!/usr/bin/env bash
echo "Launch should not run after a failed QA gate." >&2
exit 1
EOF

chmod +x "$TMP/bin/stub-builder" "$TMP/bin/stub-inspector" "$TMP/bin/ollama"
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
  "brain": {"provider": "ollama", "model": "test-tier", "key_env": ""},
  "paperclip": {"url": "", "company_id": ""}
}
JSON

WORKSPACE="$TMP/software-project"
set +e
OUTPUT="$($FOREMAN dispatch --task "Ship a tiny tested utility" \
  --template software --project qa-gate-failure-smoke --workspace "$WORKSPACE" 2>&1)"
RC=$?
set -e

if [[ $RC -eq 0 ]]; then
  echo "  ✗ QA-gate failure was reported as success" >&2
  echo "$OUTPUT" >&2
  exit 1
fi

if ! grep -qF "FAILED the QA gate" <<<"$OUTPUT"; then
  echo "  ✗ QA-gate failure message was not reported" >&2
  echo "$OUTPUT" >&2
  exit 1
fi

if [[ -d "$WORKSPACE/launch" ]]; then
  echo "  ✗ launch directory was created after QA failed" >&2
  echo "$OUTPUT" >&2
  exit 1
fi

echo "  ✓ failed QA exits nonzero and prevents launch assets"
echo "qa gate failure smoke passed"
