#!/bin/bash
# dispatch verdict-parsing smoke test.
#
# Covers two regressions found dogfooding 2026-07-10 (issues #12, #13):
#   BUG A — under `set -euo pipefail`, an inspector response with NO explicit
#           'VERDICT:' line made the no-match grep kill the whole script before
#           the default-to-fail branch could run. A missing verdict must count
#           as a fail (strike), never end the pipeline mid-loop.
#   BUG B — an inspector emitting TTY/reasoning noise around its verdict must
#           still parse (ANSI stripping + whole-output VERDICT search).
#
# Hermetic: builder and inspector are stub scripts; FOREMAN_SKIP_PROBE=1 skips
# the liveness preflight (stubs don't answer READY).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FOREMAN="$ROOT/scripts/foreman"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export FOREMAN_CONFIG_DIR="$TMP/.foreman"
export FOREMAN_SKIP_PROBE=1
mkdir -p "$FOREMAN_CONFIG_DIR"

STUB_BIN="$TMP/bin"
mkdir -p "$STUB_BIN"

# Builder stub: always "succeeds" and reports a deliverable.
cat > "$STUB_BIN/stub-builder" <<'EOF'
#!/usr/bin/env bash
cat > /dev/null
echo "Deliverable complete. Wrote the thing."
EOF

# Inspector stub 1: reasoning noise, NO VERDICT line at all.
cat > "$STUB_BIN/stub-inspector-noverdict" <<'EOF'
#!/usr/bin/env bash
cat > /dev/null
printf 'Thinking... the work looks plausible but I forgot my instructions.\n'
printf 'Assessment: seems fine I guess.\n'
EOF

# Inspector stub 2: ANSI/TTY noise around an explicit pass verdict.
cat > "$STUB_BIN/stub-inspector-noisy-pass" <<'EOF'
#!/usr/bin/env bash
cat > /dev/null
printf '\033[?25l\033[2K spinner noise \033[?25h\n'
printf 'Thinking... done thinking.\n'
printf 'Assessment: correct and complete.\n'
printf '\033[1mVERDICT: pass\033[0m\n'
EOF

chmod +x "$STUB_BIN"/stub-*

write_profile() { # $1 = inspector command
  cat > "$FOREMAN_CONFIG_DIR/profile.json" <<JSON
{
  "version": "0.2.0",
  "fleet_mode": "single-provider",
  "roles": {
    "inspector": { "name": "Stub Inspector", "command": "$1" },
    "builder":   { "name": "Stub Builder",   "command": "$STUB_BIN/stub-builder" },
    "cheap":     { "name": "Stub Cheap",     "command": "echo cheap" }
  },
  "brain": { "provider": "none", "model": "none", "key_env": "" },
  "paperclip": { "url": "", "company_id": "" }
}
JSON
}

echo "dispatch verdict-parsing smoke"

# ── Case 1: inspector never emits VERDICT → default to fail, strike out, exit 1 ──
write_profile "$STUB_BIN/stub-inspector-noverdict"
WS1="$TMP/ws1"; mkdir -p "$WS1"
set +e
OUT1=$("$FOREMAN" dispatch --task "smoke: no-verdict inspector" --template software \
  --project verdict-smoke-1 --workspace "$WS1" 2>&1)
RC1=$?
set -e

if [[ $RC1 -ne 0 ]]; then
  echo "  ✓ no-verdict run exits non-zero (rc=$RC1)"
else
  echo "  ✗ no-verdict run exited 0"; echo "$OUT1"; exit 1
fi

if echo "$OUT1" | grep -q "No explicit VERDICT line found"; then
  echo "  ✓ missing verdict hit the default-to-fail branch (not a mid-loop death)"
else
  echo "  ✗ default-to-fail branch never ran — set -e landmine is back"
  echo "$OUT1"; exit 1
fi

if echo "$OUT1" | grep -qE "3-strike escalation|Retrying"; then
  echo "  ✓ missing verdicts counted as strikes (retry/escalation engaged)"
else
  echo "  ✗ no retry/escalation after defaulted fail"; echo "$OUT1"; exit 1
fi

# ── Case 2: noisy inspector with explicit pass → parses, completes, exit 0 ──
write_profile "$STUB_BIN/stub-inspector-noisy-pass"
WS2="$TMP/ws2"; mkdir -p "$WS2"
set +e
OUT2=$("$FOREMAN" dispatch --task "smoke: noisy pass inspector" --template software \
  --project verdict-smoke-2 --workspace "$WS2" 2>&1)
RC2=$?
set -e

if [[ $RC2 -eq 0 ]] && echo "$OUT2" | grep -q "Verdict: pass"; then
  echo "  ✓ ANSI-noisy explicit verdict parsed as pass (rc=0)"
else
  echo "  ✗ noisy pass verdict did not parse cleanly (rc=$RC2)"
  echo "$OUT2"; exit 1
fi

echo "verdict-parsing smoke passed"
