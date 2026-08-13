#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FOREMAN="$ROOT/scripts/foreman"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
BIN="$WORK/bin"
mkdir -p "$BIN"

cat > "$BIN/agent" <<'STUB'
#!/usr/bin/env bash
if [[ "${1:-}" == "models" ]]; then
  echo "composer-2.5"
  echo "composer-2.5-fast"
else
  cat >/dev/null
  echo "READY"
fi
STUB

cat > "$BIN/codex" <<'STUB'
#!/usr/bin/env bash
case "${1:-}" in
  --help) echo "--model gpt-test" ;;
  *) cat >/dev/null; echo "READY" ;;
esac
STUB

cat > "$BIN/curl" <<'STUB'
#!/usr/bin/env bash
exit 1
STUB

cat > "$BIN/openclaw" <<'STUB'
#!/usr/bin/env bash
case "${1:-}" in
  --version) echo "OpenClaw test" ;;
  status) echo "gateway healthy" ;;
  *) exit 1 ;;
esac
STUB

chmod +x "$BIN/agent" "$BIN/codex" "$BIN/curl" "$BIN/openclaw"
export FOREMAN_CONFIG_DIR="$WORK/config"
export FOREMAN_SKIP_PROBE=1
export FOREMAN_ENABLE_OPENCLAW=1
export PATH="$BIN:$PATH"

OUTPUT="$($FOREMAN init --yes 2>&1)"
PROFILE="$FOREMAN_CONFIG_DIR/profile.json"

test -f "$PROFILE"
if grep -qF "bad math expression" <<<"$OUTPUT"; then
  echo "OpenClaw opt-in aborted init" >&2
  echo "$OUTPUT" >&2
  exit 1
fi
grep -qF "OpenClaw" <<<"$OUTPUT"
python3 - "$PROFILE" <<'PY'
import json, sys
profile = json.load(open(sys.argv[1]))
assert profile["roles"]["builder"]["command"], profile
assert profile["roles"]["inspector"]["command"], profile
print("  ✓ OpenClaw opt-in is best-effort and init writes a profile")
PY

echo "openclaw optional smoke passed"
