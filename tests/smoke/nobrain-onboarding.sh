#!/usr/bin/env bash
# no-brain onboarding fallback test — verifies the 6-type guided menu
# works when no AI brain is configured. Each type is tested with piped input.
# Uses a temp config dir so it never touches real foreman state.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CHAT_SCRIPT="$ROOT/scripts/foreman-chat.sh"
PASS=0
FAIL=0

TMPDIR_TEST=$(mktemp -d)
trap 'rm -rf "$TMPDIR_TEST"' EXIT

export FOREMAN_CONFIG_DIR="$TMPDIR_TEST"

# Create a profile with no brain so the fallback triggers
cat > "$TMPDIR_TEST/profile.json" << 'PROFILE'
{
  "brain": {"provider": "none", "model": "none"},
  "inspector": "",
  "builder": "",
  "cheap": ""
}
PROFILE

assert_contains() {
  local label="$1"
  local haystack="$2"
  local needle="$3"
  # Strip ANSI escape codes for matching
  local clean_haystack
  clean_haystack=$(echo "$haystack" | sed 's/\x1b\[[0-9;]*m//g')
  if echo "$clean_haystack" | grep -qF "$needle"; then
    echo "  ✓ $label"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $label (expected '$needle' in output)"
    FAIL=$((FAIL + 1))
  fi
}

assert_persisted() {
  local label="$1"
  local expected_type="$2"
  local project_file="$TMPDIR_TEST/project.json"
  local actual_type
  actual_type=$(python3 -c "import json; d=json.load(open('$project_file')); print(d.get('company_type',''))" 2>/dev/null || echo "")
  if [ "$actual_type" = "$expected_type" ]; then
    echo "  ✓ $label persisted ($expected_type)"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $label not persisted (expected $expected_type, got '$actual_type')"
    FAIL=$((FAIL + 1))
  fi
}

echo "no-brain onboarding fallback smoke"

# ── Type 1: Software ──
echo "  testing software type..."
SW_OUT=$(echo "1
MyApp
typescript
https://github.com/test/myapp" | zsh "$CHAT_SCRIPT" --onboard 2>&1 || true)
assert_contains "software shows company type menu" "$SW_OUT" "Software / app / SaaS"
assert_contains "software asks for project name" "$SW_OUT" "Project name"
assert_persisted "software type saved" "software"

# ── Type 2: Physical product ──
echo "  testing physical_product type..."
rm -rf "$TMPDIR_TEST/projects"
PP_OUT=$(echo "2
GadgetCo
A smart widget
shopify
stocked" | zsh "$CHAT_SCRIPT" --onboard 2>&1 || true)
assert_contains "physical_product shows menu" "$PP_OUT" "Physical product"
assert_contains "physical_product asks what you sell" "$PP_OUT" "What do you sell"
assert_persisted "physical_product type saved" "physical_product"

# ── Type 3: Local service ──
echo "  testing local_service type..."
rm -rf "$TMPDIR_TEST/projects"
LS_OUT=$(echo "3
Joe's Plumbing
plumbing
Online
referrals" | zsh "$CHAT_SCRIPT" --onboard 2>&1 || true)
assert_contains "local_service shows menu" "$LS_OUT" "Local service"
assert_contains "local_service asks service type" "$LS_OUT" "Service type"
assert_persisted "local_service type saved" "local_service"

# ── Type 4: Creator ──
echo "  testing creator type..."
rm -rf "$TMPDIR_TEST/projects"
CR_OUT=$(echo "4
MyChannel
tech reviews
video
weekly" | zsh "$CHAT_SCRIPT" --onboard 2>&1 || true)
assert_contains "creator shows menu" "$CR_OUT" "Creator / media / content"
assert_contains "creator asks niche" "$CR_OUT" "Niche"
assert_persisted "creator type saved" "creator"

# ── Type 5: Publishing ──
echo "  testing publishing type..."
rm -rf "$TMPDIR_TEST/projects"
PB_OUT=$(echo "5
Test Imprint
fiction
epub
yes
shopify
mailchimp
pricing,publish,ads" | zsh "$CHAT_SCRIPT" --onboard 2>&1 || true)
assert_contains "publishing shows menu" "$PB_OUT" "Publishing / books"
assert_contains "publishing asks focus" "$PB_OUT" "Publishing focus"
assert_contains "publishing asks formats" "$PB_OUT" "Formats"
assert_contains "publishing asks sell direct" "$PB_OUT" "Sell direct"
assert_persisted "publishing type saved" "publishing"

# ── Type 6: Education / community ──
echo "  testing education_community type..."
rm -rf "$TMPDIR_TEST/projects"
ED_OUT=$(echo "6
DevCommunity
coding bootcamp
skool
paid-membership" | zsh "$CHAT_SCRIPT" --onboard 2>&1 || true)
assert_contains "education shows menu" "$ED_OUT" "Education / community"
assert_contains "education asks topic" "$ED_OUT" "Topic"
assert_persisted "education_community type saved" "education_community"

# ── Invalid choice ──
echo "  testing invalid choice..."
INV_OUT=$(echo "99" | zsh "$CHAT_SCRIPT" --onboard 2>&1) && INV_EXIT=0 || INV_EXIT=$?
assert_contains "invalid choice rejected" "$INV_OUT" "Invalid choice"
if [ "$INV_EXIT" -ne 0 ]; then
  echo "  ✓ invalid choice exits non-zero (exit $INV_EXIT)"
  PASS=$((PASS + 1))
else
  echo "  ✗ invalid choice should exit non-zero"
  FAIL=$((FAIL + 1))
fi

# ── Verify all 6 types appear in the menu ──
rm -rf "$TMPDIR_TEST/projects"
FULL_MENU=$(echo "1
test
js" | zsh "$CHAT_SCRIPT" --onboard 2>&1 || true)
assert_contains "menu has all 6 options" "$FULL_MENU" "1) Software"
# Check options 2-6
for i in "2) Physical" "3) Local" "4) Creator" "5) Publishing" "6) Education"; do
  assert_contains "menu shows $i" "$FULL_MENU" "$i"
done

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "no-brain onboarding fallback smoke passed"
  exit 0
else
  echo "no-brain onboarding fallback smoke FAILED ($FAIL failures)"
  exit 1
fi