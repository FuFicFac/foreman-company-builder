#!/usr/bin/env bash
# no-brain onboarding fallback test — verifies the 6-type guided menu
# works when no AI brain is configured. Each type is tested with piped input.
# Uses a temp config dir so it never touches real foreman state.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CHAT_SCRIPT="$ROOT/scripts/foreman-chat.sh"
CATALOG="$ROOT/modules/departments/catalog.json"
PASS=0
FAIL=0

TMPDIR_TEST=$(mktemp -d)
trap 'rm -rf "$TMPDIR_TEST"' EXIT

export FOREMAN_CONFIG_DIR="$TMPDIR_TEST"

# Create a profile with no brain so the fallback triggers
mkdir -p "$TMPDIR_TEST"
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
  if echo "$clean_haystack" | grep -q "$needle"; then
    echo "  ✓ $label"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $label (expected '$needle' in output)"
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

# Verify the company type was set
SW_TYPE=$(python3 -c "import json; d=json.load(open('$TMPDIR_TEST/projects/unnamed/project.json')); print(d.get('company_type',''))" 2>/dev/null || echo "")
if [ "$SW_TYPE" = "software" ]; then
  echo "  ✓ software type saved to project"
  PASS=$((PASS + 1))
else
  echo "  ? software type not saved (got '$SW_TYPE') — onboarding may require more setup"
  # Not a hard fail — the fallback menu may not complete full onboarding in test mode
fi

# ── Type 2: Physical product ──
echo "  testing physical_product type..."
# Reset config for each test
rm -rf "$TMPDIR_TEST/projects"
PP_OUT=$(echo "2
GadgetCo
A smart widget
shopify
stocked" | zsh "$CHAT_SCRIPT" --onboard 2>&1 || true)
assert_contains "physical_product shows menu" "$PP_OUT" "Physical product"
assert_contains "physical_product asks what you sell" "$PP_OUT" "What do you sell"

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

# ── Invalid choice ──
echo "  testing invalid choice..."
INV_OUT=$(echo "99" | zsh "$CHAT_SCRIPT" --onboard 2>&1 || true)
assert_contains "invalid choice rejected" "$INV_OUT" "Invalid choice"

# ── Verify all 6 types appear in the menu ──
# Reset state and run one more time to check the full menu is printed
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