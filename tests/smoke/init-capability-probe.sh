#!/usr/bin/env bash
# init capability-probe smoke test.
#
# Proves Step 3.5 of `foreman init` does real capability gating, not just
# presence detection:
#   - A provider that PASSES the probe (echoes READY) is certified.
#   - A provider that is installed but FAILS the probe (never says READY) is
#     NOT certified, even though discovery sees it.
#   - Roles are drawn only from certified providers, and the inspector is a
#     DIFFERENT provider from the builder (independent verification).
#
# Hermetic: stub CLIs on PATH, no real provider calls, isolated config dir.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FOREMAN="$ROOT/scripts/foreman"
PASS=0
FAIL=0

check() {  # $1 label  $2 ok(true/false)  [$3 detail]
  if [[ "$2" == "true" ]]; then
    echo "  ✓ $1"; PASS=$((PASS + 1))
  else
    echo "  ✗ $1${3:+ — $3}"; FAIL=$((FAIL + 1))
  fi
}

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
BIN="$WORK/bin"
mkdir -p "$BIN"

# Stub `agent` (Cursor): advertises composer models; PASSES the probe.
cat > "$BIN/agent" << 'STUB'
#!/usr/bin/env bash
case "${1:-}" in
  models) echo "composer-2.5"; echo "composer-2.5-fast" ;;
  *) cat >/dev/null 2>&1; echo "READY" ;;
esac
STUB

# Stub `codex`: exec reads stdin and PASSES the probe.
cat > "$BIN/codex" << 'STUB'
#!/usr/bin/env bash
case "${1:-}" in
  --help) echo "  --model gpt-test" ;;
  exec) cat >/dev/null 2>&1; echo "READY" ;;
  *) cat >/dev/null 2>&1; echo "READY" ;;
esac
STUB

# Stub `ollama`: installed and discoverable, but FAILS the probe (never READY).
cat > "$BIN/ollama" << 'STUB'
#!/usr/bin/env bash
case "${1:-}" in
  --version) echo "ollama version is 0.0-test" ;;
  list) printf 'NAME\tID\tSIZE\ntestmodel:latest\tabc123\t1GB\n' ;;
  run) cat >/dev/null 2>&1; echo "I will not comply" ;;
  *) echo "" ;;
esac
STUB

# Stub `curl`: make Paperclip/service detection a no-op (no real network/registration).
cat > "$BIN/curl" << 'STUB'
#!/usr/bin/env bash
exit 1
STUB

chmod +x "$BIN/agent" "$BIN/codex" "$BIN/ollama" "$BIN/curl"

export FOREMAN_CONFIG_DIR="$WORK/cfg"
export PATH="$BIN:$PATH"

# Run real init (probe ACTIVE — FOREMAN_SKIP_PROBE intentionally unset).
OUT=$("$FOREMAN" init --yes 2>&1 || true)
PROFILE="$FOREMAN_CONFIG_DIR/profile.json"

if [[ ! -f "$PROFILE" ]]; then
  echo "  ✗ init did not write a profile"
  echo "$OUT" | tail -20
  exit 1
fi

CERTIFIED=$(python3 -c "import json; print(','.join(json.load(open('$PROFILE')).get('certified',[])))" 2>/dev/null || echo "")
INDEP=$(python3 -c "import json; print(str(json.load(open('$PROFILE')).get('independent_inspection',False)).lower())" 2>/dev/null || echo "false")
B_CMD=$(python3 -c "import json; print(json.load(open('$PROFILE'))['roles']['builder']['command'])" 2>/dev/null || echo "")
I_CMD=$(python3 -c "import json; print(json.load(open('$PROFILE'))['roles']['inspector']['command'])" 2>/dev/null || echo "")
B_BIN=$(echo "$B_CMD" | awk '{print $1}')
I_BIN=$(echo "$I_CMD" | awk '{print $1}')

echo "  certified=[$CERTIFIED] independent=$INDEP builder=$B_BIN inspector=$I_BIN"

# Probe certifies the providers that actually ran a job.
echo "$CERTIFIED" | grep -q "cursor" && check "cursor (probe passed) is certified" true || check "cursor (probe passed) is certified" false "$CERTIFIED"
echo "$CERTIFIED" | grep -q "codex"  && check "codex (probe passed) is certified" true || check "codex (probe passed) is certified" false "$CERTIFIED"

# The key gate: discovered-but-broken provider must NOT be certified.
if echo "$CERTIFIED" | grep -q "ollama"; then
  check "ollama (probe FAILED) is excluded from certified" false "still certified despite failing probe"
else
  check "ollama (probe FAILED) is excluded from certified" true
fi

# Roles only come from certified providers, inspector independent of builder.
[[ -n "$B_BIN" && "$B_BIN" != "ollama" ]] && check "builder is a certified provider" true || check "builder is a certified provider" false "$B_BIN"
[[ "$INDEP" == "true" ]] && check "independent_inspection flag is true" true || check "independent_inspection flag is true" false
[[ -n "$I_BIN" && "$I_BIN" != "$B_BIN" ]] && check "inspector is a DIFFERENT provider from builder" true || check "inspector is a DIFFERENT provider from builder" false "builder=$B_BIN inspector=$I_BIN"

echo ""
if [[ $FAIL -gt 0 ]]; then
  echo "init capability-probe smoke FAILED ($FAIL failure(s))"
  exit 1
fi
echo "init capability-probe smoke passed ($PASS checks)"
