#!/usr/bin/env bash
# dispatch provider + inspector-fallback smoke test.
#
# Covers two regressions:
#   BUG 1 — inspector hard-defaults to the 'claude' CLI. When 'claude' is not on
#           PATH, dispatch must fall back to a reachable inspector from the fleet
#           instead of failing preflight. The displayed name must reflect the
#           CLI that actually runs (never lie).
#   BUG 2 — `foreman blast --provider <name>` must forward the provider to the
#           dispatch engine so the builder the engine runs actually uses it
#           (previously cosmetic — it only set the displayed PROVIDERS array).
#
# Hermetic: a stub provider CLI is prepended to PATH so discovery is
# deterministic and no real agent is ever invoked (everything runs --dry-run).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FOREMAN="$ROOT/scripts/foreman"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

export FOREMAN_CONFIG_DIR="$TMP/.foreman"
mkdir -p "$FOREMAN_CONFIG_DIR"

# ── Stub provider CLIs ─────────────────────────────────────────────────────────
# 'agent' is first in Foreman's discovery order, so it wins deterministically as
# the inspector fallback regardless of what real CLIs the host has installed.
# 'codex' is used to prove --provider forwarding resolves to a runnable command.
STUB_BIN="$TMP/bin"
mkdir -p "$STUB_BIN"
for p in agent codex; do
  cat > "$STUB_BIN/$p" <<EOF
#!/usr/bin/env bash
# stub $p — never actually invoked under --dry-run; only needs to exist on PATH
# and answer 'models'/'--version' harmlessly.
echo "stub-$p \$*"
EOF
  chmod +x "$STUB_BIN/$p"
done
# Put stubs first so they shadow any host install of the same name.
export PATH="$STUB_BIN:$PATH"

PASS=0
FAIL=0
check() {
  local label="$1" cond="$2"
  if [[ "$cond" == "ok" ]]; then echo "  ✓ $label"; PASS=$((PASS + 1))
  else echo "  ✗ $label"; FAIL=$((FAIL + 1)); fi
}

echo "dispatch provider + inspector-fallback smoke"

# ── Profile whose inspector points at 'claude' (deliberately NOT on PATH) ──
# Builder uses the 'agent' stub so we can prove the fallback prefers a DIFFERENT
# provider when possible (here: codex), but any reachable CLI is acceptable.
cat > "$FOREMAN_CONFIG_DIR/profile.json" <<'JSON'
{
  "version": "0.2.0",
  "fleet_mode": "multi-provider",
  "roles": {
    "inspector": { "name": "Claude Opus",  "command": "claude -p --model opus" },
    "builder":   { "name": "Stub Agent",   "command": "agent --trust" },
    "cheap":     { "name": "Stub Cheap",   "command": "agent --trust" }
  },
  "brain": { "provider": "none", "model": "none", "key_env": "" },
  "paperclip": { "url": "", "company_id": "" }
}
JSON

# Make sure the test premise holds: 'claude' must be absent on this PATH.
if command -v claude >/dev/null 2>&1; then
  echo "  (skipping BUG 1 assertions — 'claude' is present on PATH in this env)"
else
  # ── BUG 1: dispatch must fall back instead of erroring on missing 'claude' ──
  FB_OUT=$("$FOREMAN" dispatch --task "Fix the flaky login test" --dry-run 2>&1) || {
    echo "  ✗ dispatch --dry-run errored when inspector CLI 'claude' was absent"
    echo "$FB_OUT"
    exit 1
  }
  check "dispatch did not die on missing 'claude' inspector" "ok"

  # The fallback warning should fire and name the missing binary.
  if echo "$FB_OUT" | grep -qiE "Inspector CLI 'claude' not found"; then
    check "fallback warning names the missing 'claude' inspector" "ok"
  else
    check "fallback warning names the missing 'claude' inspector" "no"; echo "$FB_OUT"
  fi

  # The resolved inspector command must NOT still be claude.
  INSPECTOR_CMD_LINE=$(echo "$FB_OUT" | grep -A1 "Inspector:" | grep "Command:" | head -1)
  if echo "$INSPECTOR_CMD_LINE" | grep -q "claude"; then
    check "inspector command no longer resolves to claude" "no"; echo "$INSPECTOR_CMD_LINE"
  else
    check "inspector command no longer resolves to claude" "ok"
  fi

  # BUG 3: the displayed inspector NAME must reflect the fallback, not 'Claude Opus'.
  if echo "$FB_OUT" | grep -qE "Inspector: +Claude Opus"; then
    check "inspector label is honest (not stale 'Claude Opus')" "no"; echo "$FB_OUT"
  else
    check "inspector label is honest (not stale 'Claude Opus')" "ok"
  fi
fi

# ── BUG 3 (override path): --inspector-cmd relabels the displayed name ──
OV_OUT=$("$FOREMAN" dispatch --task "Fix the flaky login test" \
  --inspector-cmd "codex review" --dry-run 2>&1)
if echo "$OV_OUT" | grep -qE "Inspector: +Claude Opus"; then
  check "overridden inspector label is not the stale profile name" "no"; echo "$OV_OUT"
else
  check "overridden inspector label is not the stale profile name" "ok"
fi
if echo "$OV_OUT" | grep -qE "Command: +codex review"; then
  check "overridden inspector command is honored" "ok"
else
  check "overridden inspector command is honored" "no"; echo "$OV_OUT"
fi

# ── BUG 2: blast --provider must FORWARD to the dispatch engine ──
# blast's own --dry-run short-circuits before calling dispatch, so to prove the
# forwarding we copy the script tree, replace foreman-dispatch.sh with an
# arg-echoing stub, and run blast for real (no --dry-run). The stub records the
# args blast handed it — which must include `--provider codex`.
STUB_SCRIPTS="$TMP/scripts"
mkdir -p "$STUB_SCRIPTS"
cp "$ROOT/scripts/foreman-blast.sh" "$STUB_SCRIPTS/"
# modules/ live next to scripts/ via ROOT="$(dirname)/.." — link them in.
ln -s "$ROOT/modules" "$TMP/modules"
DISPATCH_ARGS_LOG="$TMP/dispatch_args.txt"
cat > "$STUB_SCRIPTS/foreman-dispatch.sh" <<EOF
#!/usr/bin/env bash
# arg-echoing dispatch stub
printf '%s\n' "\$@" > "$DISPATCH_ARGS_LOG"
exit 0
EOF
chmod +x "$STUB_SCRIPTS/foreman-dispatch.sh"

zsh "$STUB_SCRIPTS/foreman-blast.sh" "Fix the broken build" --provider codex >/dev/null 2>&1 || true
if grep -qx -- "--provider" "$DISPATCH_ARGS_LOG" 2>/dev/null \
   && grep -qx "codex" "$DISPATCH_ARGS_LOG" 2>/dev/null; then
  check "blast --provider codex forwards '--provider codex' to dispatch" "ok"
else
  check "blast --provider codex forwards '--provider codex' to dispatch" "no"
  echo "  dispatch received: $(tr '\n' ' ' < "$DISPATCH_ARGS_LOG" 2>/dev/null)"
fi

# Direct dispatch --provider should also resolve the builder command.
DISP_OUT=$("$FOREMAN" dispatch --task "Fix the broken build" \
  --provider codex --dry-run 2>&1)
DISP_BUILDER_LINE=$(echo "$DISP_OUT" | grep -A1 "Builder:" | grep "Command:" | head -1)
if echo "$DISP_BUILDER_LINE" | grep -q "codex"; then
  check "dispatch --provider codex resolves builder command" "ok"
else
  check "dispatch --provider codex resolves builder command" "no"; echo "$DISP_OUT"
fi

# ── BUG 4: codex must resolve to the stdin-safe `codex exec` form ──
# The builder/inspector invocation pipes the prompt to the command's stdin
# (`cat prompt | eval "$CMD"`). Bare `codex` launches an interactive TUI and
# dies with "stdin is not a terminal", so the resolver MUST emit `codex exec`,
# which reads a piped prompt from stdin. Assert the BUILDER command (which goes
# through the same stdin pipe) resolves to `codex exec ...`, never bare `codex`.
if echo "$DISP_BUILDER_LINE" | grep -qE "codex[[:space:]]+exec"; then
  check "codex resolves to stdin-safe 'codex exec' form" "ok"
else
  check "codex resolves to stdin-safe 'codex exec' form" "no"; echo "$DISP_BUILDER_LINE"
fi
# Guard against a regression to bare `codex` (no exec) as the whole command.
if echo "$DISP_BUILDER_LINE" | grep -qE "Command:[[:space:]]+codex([[:space:]]*$|[[:space:]]+--)"; then
  check "codex does not resolve to the bare interactive TUI command" "no"; echo "$DISP_BUILDER_LINE"
else
  check "codex does not resolve to the bare interactive TUI command" "ok"
fi

# ── BUG 4 (hermes): no confirmed stdin-safe invocation → treated as unusable ──
# hermes has no verified stdin-friendly non-interactive mode (its -z/--oneshot
# and `chat -q` forms take the prompt as an argument, not via stdin), and bare
# `hermes` is a TUI. The resolver must therefore return an EMPTY command for
# hermes so the fleet-fallback skips it and --provider hermes refuses cleanly
# rather than piping into a TUI. Prove it via a hermes stub on PATH.
cat > "$STUB_BIN/hermes" <<'EOF'
#!/usr/bin/env bash
echo "stub-hermes $*"
EOF
chmod +x "$STUB_BIN/hermes"
HERMES_OUT=$("$FOREMAN" dispatch --task "Fix the broken build" \
  --provider hermes --dry-run 2>&1)
# --provider hermes must NOT switch the builder onto a hermes command; it should
# warn that hermes is not usable and keep the configured (stub agent) builder.
if echo "$HERMES_OUT" | grep -qE "Builder:.*[Hh]ermes" \
   || echo "$HERMES_OUT" | grep -A1 "Builder:" | grep "Command:" | grep -qw "hermes"; then
  check "hermes is not selected as a builder command (no stdin-safe form)" "no"; echo "$HERMES_OUT"
else
  check "hermes is not selected as a builder command (no stdin-safe form)" "ok"
fi

echo ""
if [[ "$FAIL" -eq 0 ]]; then
  echo "dispatch provider + inspector-fallback smoke passed"
  exit 0
else
  echo "dispatch provider + inspector-fallback smoke FAILED ($FAIL failures)"
  exit 1
fi
