#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FOREMAN="$ROOT/scripts/foreman"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export FOREMAN_CONFIG_DIR="$TMP/.foreman"
export FOREMAN_SKIP_PROBE=1
mkdir -p "$FOREMAN_CONFIG_DIR" "$TMP/bin"

echo "launch phase smoke"

python3 - "$ROOT" <<'PY'
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
expected = {
    "creative-writing": ["blurb", "hook", "series-callback", "funnel-copy"],
    "software": ["release-notes", "readme", "deploy-script"],
    "youtube": ["description", "tags", "community-post"],
    "marketing": ["ad-copy-variants", "email-sequence", "landing-page-copy"],
}

for template, asset_types in expected.items():
    manifest = json.loads((root / "modules" / template / "module.json").read_text())
    launch = manifest.get("launch_phase", {})
    assert launch.get("enabled") is True, f"{template}: launch is not enabled"
    actual = [asset.get("type") for asset in launch.get("assets", [])]
    assert actual == asset_types, f"{template}: launch assets mismatch: {actual!r}"
    assert manifest.get("stages", [])[-1] == "launch", f"{template}: launch is not final stage"
    print(f"  ✓ {template}: {len(actual)} launch assets load")
PY

cat > "$TMP/bin/stub-builder" <<'EOF'
#!/usr/bin/env bash
cat > /dev/null
echo "Built and verified the requested software change."
EOF

cat > "$TMP/bin/stub-inspector" <<'EOF'
#!/usr/bin/env bash
PROMPT="$(cat)"
if grep -qF "You are a QA reviewer" <<<"$PROMPT"; then
  echo "The QA checklist passes."
else
  echo "The build output satisfies the task."
fi
echo "VERDICT: pass"
EOF

# foreman-brain.py invokes `ollama run <configured-tier> <prompt>`. This local
# stub makes the launch leg deterministic while still exercising the real
# launch orchestration and file-writing path.
cat > "$TMP/bin/ollama" <<'EOF'
#!/usr/bin/env bash
if [[ "${STUB_OLLAMA_FAIL:-}" == "1" ]]; then
  echo "simulated launch provider failure" >&2
  exit 1
fi
echo "# Launch asset"
echo "Generated from the completed build for shipping."
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
OUTPUT="$($FOREMAN dispatch --task "Ship a tiny tested utility" \
  --template software --project launch-smoke --workspace "$WORKSPACE" 2>&1)"

grep -qF "Verdict: pass" <<<"$OUTPUT"
grep -qF "QA gate passed" <<<"$OUTPUT"
grep -qF "Launch assets generated" <<<"$OUTPUT"
for asset in release-notes readme deploy-script; do
  test -s "$WORKSPACE/launch/$asset.md"
  grep -qF "# Launch asset" "$WORKSPACE/launch/$asset.md"
done
echo "  ✓ build → inspect → QA → launch wrote all software assets"

SKIPPED_WORKSPACE="$TMP/skipped-project"
SKIPPED_OUTPUT="$($FOREMAN dispatch --task "Build without shipping assets" \
  --template software --project launch-skip-smoke --workspace "$SKIPPED_WORKSPACE" \
  --skip-launch 2>&1)"
test ! -d "$SKIPPED_WORKSPACE/launch"
if grep -qF "Launch Phase: generating" <<<"$SKIPPED_OUTPUT"; then
  echo "  ✗ --skip-launch still ran launch" >&2
  exit 1
fi
echo "  ✓ --skip-launch preserves the build/inspect/QA pipeline without assets"

FAILED_WORKSPACE="$TMP/failed-project"
export STUB_OLLAMA_FAIL=1
set +e
FAILED_OUTPUT="$($FOREMAN dispatch --task "Build with a failed launch provider" \
  --template software --project launch-failure-smoke --workspace "$FAILED_WORKSPACE" 2>&1)"
FAILED_RC=$?
set -e
unset STUB_OLLAMA_FAIL
if [[ $FAILED_RC -eq 0 ]] || ! grep -qF "FAILED the launch phase" <<<"$FAILED_OUTPUT"; then
  echo "  ✗ launch provider failure was reported as success" >&2
  echo "$FAILED_OUTPUT" >&2
  exit 1
fi
echo "  ✓ asset generation failure makes dispatch fail honestly"

echo "launch phase smoke passed"
