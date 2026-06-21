#!/usr/bin/env bash
# foreman issues smoke test — exercises create, list, show, assign, close lifecycle
# Uses a temp config dir so it never touches real foreman state.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ISSUES_SCRIPT="$ROOT/scripts/foreman-issues.sh"
PASS=0
FAIL=0

# Use a temp config dir
TMPDIR_TEST=$(mktemp -d)
trap 'rm -rf "$TMPDIR_TEST"' EXIT

export FOREMAN_CONFIG_DIR="$TMPDIR_TEST"

run() {
  echo "  $ $*" >&2
  "$@" 2>&1
}

assert_contains() {
  local label="$1"
  local haystack="$2"
  local needle="$3"
  if echo "$haystack" | grep -q "$needle"; then
    echo "  ✓ $label"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $label (expected '$needle' in output)"
    FAIL=$((FAIL + 1))
  fi
}

assert_json_field() {
  local label="$1"
  local json_file="$2"
  local field="$3"
  local expected="$4"
  local actual
  actual=$(python3 -c "import json; d=json.load(open('$json_file')); print(d$expected)" 2>/dev/null || echo "PARSE_ERROR")
  if [ "$actual" != "PARSE_ERROR" ] && [ "$actual" = "$field" ]; then
    echo "  ✓ $label"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $label (expected $expected=$field, got $actual)"
    FAIL=$((FAIL + 1))
  fi
}

echo "foreman issues smoke"

# ── list on empty store ──
echo "  testing list (empty)..."
LIST_OUT=$(run zsh "$ISSUES_SCRIPT" list)
assert_contains "empty list shows header" "$LIST_OUT" "Open Issues"
assert_contains "empty list shows no issues" "$LIST_OUT" "No open issues"

# ── add issue 1 ──
echo "  testing add..."
ADD_OUT=$(run zsh "$ISSUES_SCRIPT" add "Fix the homepage bug")
assert_contains "add shows created message" "$ADD_OUT" "Created issue #1"
assert_contains "add shows title" "$ADD_OUT" "Fix the homepage bug"

# ── add issue 2 ──
ADD2_OUT=$(run zsh "$ISSUES_SCRIPT" add "Write marketing copy")
assert_contains "add second issue" "$ADD2_OUT" "Created issue #2"

# ── list with issues ──
echo "  testing list (populated)..."
LIST2_OUT=$(run zsh "$ISSUES_SCRIPT" list)
assert_contains "list shows issue 1" "$LIST2_OUT" "#1"
assert_contains "list shows issue 2" "$LIST2_OUT" "#2"
assert_contains "list shows issue 1 title" "$LIST2_OUT" "Fix the homepage bug"
assert_contains "list shows issue 2 title" "$LIST2_OUT" "Write marketing copy"

# ── show issue 1 ──
echo "  testing show..."
SHOW_OUT=$(run zsh "$ISSUES_SCRIPT" show 1)
assert_contains "show displays id" "$SHOW_OUT" "id: 1"
assert_contains "show displays title" "$SHOW_OUT" "Fix the homepage bug"
assert_contains "show displays status" "$SHOW_OUT" "status: open"

# ── assign issue 1 ──
echo "  testing assign..."
ASSIGN_OUT=$(run zsh "$ISSUES_SCRIPT" assign 1 builder)
assert_contains "assign confirms" "$ASSIGN_OUT" "Assigned issue #1"
assert_contains "assign shows role" "$ASSIGN_OUT" "builder"

# ── verify assignee in JSON ──
ASSIGNEE=$(python3 -c "import json; d=json.load(open('$TMPDIR_TEST/issues.json')); i=[x for x in d['issues'] if x['id']==1][0]; print(i.get('assignee',''))" 2>/dev/null || echo "")
if [ "$ASSIGNEE" = "builder" ]; then
  echo "  ✓ assignee persisted in JSON"
  PASS=$((PASS + 1))
else
  echo "  ✗ assignee not persisted (got '$ASSIGNEE')"
  FAIL=$((FAIL + 1))
fi

# ── list shows assignee ──
LIST3_OUT=$(run zsh "$ISSUES_SCRIPT" list)
assert_contains "list shows assignee" "$LIST3_OUT" "builder"

# ── close issue 1 ──
echo "  testing close..."
CLOSE_OUT=$(run zsh "$ISSUES_SCRIPT" close 1)
assert_contains "close confirms" "$CLOSE_OUT" "Closed issue #1"

# ── verify issue 1 is closed in JSON ──
STATUS=$(python3 -c "import json; d=json.load(open('$TMPDIR_TEST/issues.json')); i=[x for x in d['issues'] if x['id']==1][0]; print(i['status'])" 2>/dev/null || echo "")
if [ "$STATUS" = "closed" ]; then
  echo "  ✓ issue 1 status is closed in JSON"
  PASS=$((PASS + 1))
else
  echo "  ✗ issue 1 status not closed (got '$STATUS')"
  FAIL=$((FAIL + 1))
fi

# ── list no longer shows closed issue ──
LIST4_OUT=$(run zsh "$ISSUES_SCRIPT" list)
assert_contains "list still shows open issue 2" "$LIST4_OUT" "#2"
if echo "$LIST4_OUT" | grep -q "Fix the homepage bug"; then
  echo "  ✗ closed issue 1 should not appear in open list"
  FAIL=$((FAIL + 1))
else
  echo "  ✓ closed issue 1 not in open list"
  PASS=$((PASS + 1))
fi

# ── next_id incremented correctly ──
NEXT_ID=$(python3 -c "import json; d=json.load(open('$TMPDIR_TEST/issues.json')); print(d['next_id'])" 2>/dev/null || echo "")
if [ "$NEXT_ID" = "3" ]; then
  echo "  ✓ next_id is 3"
  PASS=$((PASS + 1))
else
  echo "  ✗ next_id should be 3 (got '$NEXT_ID')"
  FAIL=$((FAIL + 1))
fi

# ── show non-existent issue ──
SHOW_MISS=$(run zsh "$ISSUES_SCRIPT" show 999 2>&1 || true)
assert_contains "show missing issue reports error" "$SHOW_MISS" "not found"

# ── add with empty title fails ──
ADD_EMPTY=$(zsh "$ISSUES_SCRIPT" add "" 2>&1 || true)
assert_contains "empty title rejected" "$ADD_EMPTY" "Usage"

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "foreman issues smoke passed"
  exit 0
else
  echo "foreman issues smoke FAILED ($FAIL failures)"
  exit 1
fi