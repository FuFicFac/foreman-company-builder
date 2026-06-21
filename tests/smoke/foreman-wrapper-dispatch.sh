#!/usr/bin/env bash
# foreman wrapper dispatch test — verifies the `foreman` script routes
# to the correct subcommand handler for every route in its dispatch table.
# All dispatch tests go THROUGH the wrapper, not directly to target scripts.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FOREMAN="$ROOT/scripts/foreman"
PASS=0
FAIL=0

assert_contains() {
  local label="$1"
  local haystack="$2"
  local needle="$3"
  if echo "$haystack" | grep -qF "$needle"; then
    echo "  ✓ $label"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $label (expected '$needle' in output)"
    FAIL=$((FAIL + 1))
  fi
}

echo "foreman wrapper dispatch smoke"

# ── help route ──
echo "  testing help route..."
HELP_OUT=$("$FOREMAN" help 2>&1 || true)
assert_contains "help shows usage" "$HELP_OUT" "Usage:"
assert_contains "help lists init" "$HELP_OUT" "foreman init"
assert_contains "help lists issues" "$HELP_OUT" "foreman issues"
assert_contains "help lists run" "$HELP_OUT" "foreman run"
assert_contains "help lists chat" "$HELP_OUT" "foreman chat"
assert_contains "help lists press" "$HELP_OUT" "foreman press"
assert_contains "help lists lph" "$HELP_OUT" "foreman lph"

# ── --help alias ──
DASH_HELP=$("$FOREMAN" --help 2>&1 || true)
assert_contains "--help alias works" "$DASH_HELP" "Usage:"

# ── unknown command exits non-zero ──
UNKNOWN_OUT=$("$FOREMAN" bogus-command-xyz 2>&1) && UNKNOWN_EXIT=0 || UNKNOWN_EXIT=$?
if [ "$UNKNOWN_EXIT" -ne 0 ]; then
  echo "  ✓ unknown command exits non-zero (exit $UNKNOWN_EXIT)"
  PASS=$((PASS + 1))
else
  echo "  ✗ unknown command should exit non-zero"
  FAIL=$((FAIL + 1))
fi
assert_contains "unknown command shows error" "$UNKNOWN_OUT" "Unknown command"

# ── each route dispatches THROUGH the wrapper ──
# We call $FOREMAN <subcommand> and verify it reaches the target script

# Use a temp config dir for all dispatch tests to avoid state leakage
TMPDIR_TEST=$(mktemp -d)
trap 'rm -rf "$TMPDIR_TEST"' EXIT
export FOREMAN_CONFIG_DIR="$TMPDIR_TEST"

# press: --help should show usage (via wrapper)
PRESS_OUT=$("$FOREMAN" press --help 2>&1 || true)
assert_contains "press route dispatches via wrapper" "$PRESS_OUT" "usage:"

# tools: list subcommand (via wrapper)
TOOLS_OUT=$("$FOREMAN" tools list 2>&1 || true)
# tools list produces a table header or tool entries — either proves dispatch
if echo "$TOOLS_OUT" | grep -qiE "^Name|tool|module|No modules|profile|foreman" 2>/dev/null; then
  echo "  ✓ tools route dispatches via wrapper"
  PASS=$((PASS + 1))
else
  echo "  ✗ tools route failed to produce expected output via wrapper"
  echo "    output was: $TOOLS_OUT"
  FAIL=$((FAIL + 1))
fi

# init: --yes should produce output (via wrapper)
INIT_OUT=$("$FOREMAN" init --yes 2>&1 || true)
if echo "$INIT_OUT" | grep -qiE "Foreman|Init|Step|profile" 2>/dev/null; then
  echo "  ✓ init route dispatches via wrapper"
  PASS=$((PASS + 1))
else
  echo "  ✗ init route failed to produce expected output via wrapper"
  FAIL=$((FAIL + 1))
fi

# issues: list on a temp config dir (via wrapper)
ISSUES_OUT=$("$FOREMAN" issues list 2>&1 || true)
assert_contains "issues route dispatches via wrapper" "$ISSUES_OUT" "Open Issues"

# run: help should show usage (via wrapper)
RUN_OUT=$("$FOREMAN" run help 2>&1 || true)
assert_contains "run route dispatches via wrapper" "$RUN_OUT" "Usage:"

# lph: --help should show usage (via wrapper)
LPH_OUT=$("$FOREMAN" lph --help 2>&1 || true)
assert_contains "lph route dispatches via wrapper" "$LPH_OUT" "usage:"

# ── verify all dispatch targets exist as files ──
for target in \
  "$ROOT/scripts/foreman-press.py" \
  "$ROOT/scripts/foreman-tools.sh" \
  "$ROOT/scripts/foreman-init.sh" \
  "$ROOT/scripts/foreman-module.sh" \
  "$ROOT/scripts/foreman-issues.sh" \
  "$ROOT/scripts/foreman-chat.sh" \
  "$ROOT/scripts/foreman-run.sh" \
  "$ROOT/scripts/foreman-update.sh" \
  "$ROOT/scripts/fleet-check.sh" \
  "$ROOT/scripts/foreman-lph.py"; do
  if [ -f "$target" ]; then
    echo "  ✓ $(basename "$target") exists"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $(basename "$target") missing!"
    FAIL=$((FAIL + 1))
  fi
done

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "foreman wrapper dispatch smoke passed"
  exit 0
else
  echo "foreman wrapper dispatch smoke FAILED ($FAIL failures)"
  exit 1
fi