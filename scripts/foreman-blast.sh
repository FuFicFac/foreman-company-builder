#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors
G='\033[0;32m' R='\033[0;31m' Y='\033[1;33m' B='\033[0;34m' CYAN='\033[0;36m' BOLD='\033[1m' DIM='\033[2m' NC='\033[0m'

# ─── Usage ───────────────────────────────────────────────────────────────────

usage() {
  cat <<'EOF'
Usage: foreman blast "<prompt>" [options]

Zero-friction entry point — auto-detect template, load roles, fire pipeline.

Options:
  --template <name>    Force a specific template (creative-writing, software, marketing, youtube, publishing)
  --provider <name>    Force a specific provider
  --dir <path>         Output directory (default: temp dir)
  --deluxe             Run Deluxe loop instead of Lean
  --skip-launch        Stop after QA; do not generate launch assets
  --dry-run            Show what would fire without executing
  -h, --help           Show this help

Keyword matching (automatic when no --template):
  write/story/book/chapter/novel → creative-writing
  code/build/fix/app/deploy      → software
  market/ad/copy/campaign/email  → marketing
  video/youtube/script/thumbnail  → youtube
  publish/launch/metadata/store  → publishing
  Default: software
EOF
}

# ─── Parse arguments ─────────────────────────────────────────────────────────

PROMPT=""
TEMPLATE=""
PROVIDER=""
DIR=""
DELUXE=false
DRY_RUN=false
SKIP_LAUNCH=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --template)
      TEMPLATE="$2"
      shift 2
      ;;
    --provider)
      PROVIDER="$2"
      shift 2
      ;;
    --dir)
      DIR="$2"
      shift 2
      ;;
    --deluxe)
      DELUXE=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --skip-launch)
      SKIP_LAUNCH=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [[ -z "$PROMPT" ]]; then
        PROMPT="$1"
      else
        PROMPT="$PROMPT $1"
      fi
      shift
      ;;
  esac
done

if [[ -z "$PROMPT" ]]; then
  echo "Error: prompt required. Usage: foreman blast \"<prompt>\"" >&2
  usage >&2
  exit 1
fi

# ─── Keyword matching ────────────────────────────────────────────────────────

detect_template() {
  local prompt="$1"
  local lc_prompt
  lc_prompt="$(echo "$prompt" | tr '[:upper:]' '[:lower:]')"

  # creative-writing keywords
  if echo "$lc_prompt" | grep -qE '\b(write|story|book|chapter|novel|fiction|romance|mystery|fantasy|scifi|sci-fi|narrative|prose|manuscript)\b'; then
    echo "creative-writing"
    return
  fi

  # software keywords
  if echo "$lc_prompt" | grep -qE '\b(code|build|fix|app|deploy|debug|refactor|implement|feature|bug|api|server|database|test)\b'; then
    echo "software"
    return
  fi

  # marketing keywords
  if echo "$lc_prompt" | grep -qE '\b(market|ad|copy|campaign|email|brand|landing|funnel|seo|social media|newsletter|audience)\b'; then
    echo "marketing"
    return
  fi

  # youtube keywords
  if echo "$lc_prompt" | grep -qE '\b(video|youtube|thumbnail|retention|channel|subscriber|script.*video|hook.*video)\b'; then
    echo "youtube"
    return
  fi

  # publishing keywords
  if echo "$lc_prompt" | grep -qE '\b(publish|launch|metadata|storefront|isbn|epub|kindle|kdp|edition|preorder|arc)\b'; then
    echo "publishing"
    return
  fi

  # Default to software
  echo "software"
}

# ─── Resolve template ─────────────────────────────────────────────────────────

if [[ -n "$TEMPLATE" ]]; then
  CHOSEN_TEMPLATE="$TEMPLATE"
else
  CHOSEN_TEMPLATE="$(detect_template "$PROMPT")"
fi

# Validate template exists
MODULE_DIR="$ROOT/modules/$CHOSEN_TEMPLATE"
if [[ ! -d "$MODULE_DIR" ]]; then
  echo "Error: template '$CHOSEN_TEMPLATE' not found in modules/" >&2
  echo "Available templates:" >&2
  ls "$ROOT/modules" | grep -v departments >&2
  exit 1
fi

if [[ ! -f "$MODULE_DIR/module.json" ]]; then
  echo "Error: module.json missing for template '$CHOSEN_TEMPLATE'" >&2
  exit 1
fi

# ─── Load module manifest ────────────────────────────────────────────────────

MANIFEST_JSON="$(cat "$MODULE_DIR/module.json")"

# Parse key fields from manifest
MODULE_NAME="$(echo "$MANIFEST_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("name",""))')"
MODULE_DESC="$(echo "$MANIFEST_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("description",""))')"
LOOP_MODE="$(echo "$MANIFEST_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("loop_mode","lean"))')"
STAGES="$(echo "$MANIFEST_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(", ".join(d.get("stages",[])))')"
ROLES="$(echo "$MANIFEST_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(", ".join(d.get("roles",[])))')"
BUILDERS="$(echo "$MANIFEST_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(", ".join(d.get("builders",[])))')"
INSPECTORS="$(echo "$MANIFEST_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(", ".join(d.get("inspectors",[])))')"
QA_ROLES="$(echo "$MANIFEST_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); qas=d.get("qa_roles",[]); print(", ".join(q.get("name","") for q in qas))')"
QA_CHECKLIST="$(echo "$MANIFEST_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); print("\n".join("      - " + item for role in d.get("qa_roles",[]) for item in role.get("checklist",[])))')"
HAS_LAUNCH="$(echo "$MANIFEST_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); lp=d.get("launch_phase",{}); print("yes" if lp.get("enabled") else "no")')"
LAUNCH_ASSETS="$(echo "$MANIFEST_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); assets=d.get("launch_phase",{}).get("assets",[]); print(", ".join(a.get("type","") for a in assets))')"

# Determine effective loop mode
if $DELUXE; then
  EFFECTIVE_LOOP="deluxe"
elif [[ "$LOOP_MODE" == "deluxe" ]]; then
  EFFECTIVE_LOOP="deluxe"
else
  EFFECTIVE_LOOP="lean"
fi

# ─── Resolve workspace ────────────────────────────────────────────────────────

if [[ -n "$DIR" ]]; then
  WORKSPACE="$DIR"
else
  WORKSPACE="$(mktemp -d -t foreman-blast-XXXXXX)"
fi

mkdir -p "$WORKSPACE"

# ─── Discover providers ─────────────────────────────────────────────────────

discover_providers() {
  local found=()
  for c in agent cursor-agent cursor claude codex hermes ollama; do
    if command -v "$c" >/dev/null 2>&1; then
      found+=("$c")
    fi
  done
  echo "${found[*]}"
}

if [[ -n "$PROVIDER" ]]; then
  PROVIDERS=("$PROVIDER")
else
  PROVIDER_LIST="$(discover_providers)"
  if [[ -z "$PROVIDER_LIST" ]]; then
    PROVIDERS=()
  else
    # shellcheck disable=SC2206
    PROVIDERS=($PROVIDER_LIST)
  fi
fi

# ─── Determine first stage ──────────────────────────────────────────────────

FIRST_STAGE="$(echo "$MANIFEST_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); stages=d.get("stages",[]); print(stages[0] if stages else "unknown")')"

# ─── Print summary ──────────────────────────────────────────────────────────

echo "╔══════════════════════════════════════════╗"
echo "║         Foreman Blast                   ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "  Prompt:    $PROMPT"
echo "  Template:  $MODULE_NAME"
echo "  Desc:      $MODULE_DESC"
echo "  Loop:      $EFFECTIVE_LOOP"
echo "  Stages:    $STAGES"
echo ""
echo "  Roles:     $ROLES"
echo "  Builders:  $BUILDERS"
echo "  Inspectors: $INSPECTORS"
echo "  QA Roles:  $QA_ROLES"
echo ""
if [[ "$HAS_LAUNCH" == "yes" ]] && $SKIP_LAUNCH; then
  echo "  Launch:    skipped by --skip-launch"
elif [[ "$HAS_LAUNCH" == "yes" ]]; then
  echo "  Launch:    yes"
  echo "  Launch Assets: $LAUNCH_ASSETS"
else
  echo "  Launch:    no"
fi
echo ""
echo "  Workspace: $WORKSPACE"
echo "  Providers: ${PROVIDERS[*]:-none found}"
echo ""

# ─── Dry run ─────────────────────────────────────────────────────────────────

if $DRY_RUN; then
  echo "  [DRY RUN] Would fire pipeline with:"
  echo "    Template:  $MODULE_NAME"
  echo "    Loop mode: $EFFECTIVE_LOOP"
  echo "    Stage:     $FIRST_STAGE"
  if [[ -n "$QA_ROLES" ]]; then
    echo "    QA gate:   $QA_ROLES"
    echo "    QA checklist:"
    echo "$QA_CHECKLIST"
  fi
  echo "    Task:      $PROMPT"
  echo "    Project:   blast-$(date +%s)"
  echo "    Workspace: $WORKSPACE"
  if [[ ${#PROVIDERS[@]} -gt 0 ]]; then
    echo "    Providers: ${PROVIDERS[*]}"
  else
    echo "    Providers: (none discovered — install an agent CLI)"
  fi
  echo ""
  echo "  [DRY RUN] No pipeline started. Use without --dry-run to execute."
  exit 0
fi

# ─── Guard: zero providers ────────────────────────────────────────────────────
#
# If no agent CLIs were discovered AND no --provider was forced, we cannot
# run the execution loop. Error out instead of falsely reporting success.

if [[ ${#PROVIDERS[@]} -eq 0 ]]; then
  echo ""
  echo -e "  ${R}✗ No agent providers discovered.${NC}" >&2
  echo -e "  ${DIM}Install at least one agent CLI (cursor agent, claude, codex, ollama, or hermes)${NC}" >&2
  echo -e "  ${DIM}or pass --provider <name> to force one.${NC}" >&2
  echo -e "  ${DIM}Then run: foreman init to update your profile.${NC}" >&2
  echo ""
  exit 1
fi

# ─── Execute ─────────────────────────────────────────────────────────────────
#
# Blast is the zero-friction wrapper around dispatch. It auto-detects the
# template, then hands off to foreman-dispatch.sh which runs the real
# builder→inspector→verdict execution loop.

PROJECT_NAME="blast-$(date +%s)"

echo "  ▶ Starting pipeline..."
echo ""

# Build dispatch arguments
DISPATCH_ARGS=(--task "$PROMPT" --template "$CHOSEN_TEMPLATE" --project "$PROJECT_NAME" --workspace "$WORKSPACE")

# Forward an explicit --provider to the dispatch engine so the builder the
# engine actually runs uses that provider — not just the displayed PROVIDERS
# array. Without this, `foreman blast "..." --provider <name>` is cosmetic.
if [[ -n "$PROVIDER" ]]; then
  DISPATCH_ARGS+=(--provider "$PROVIDER")
fi

# Pass --launch through to dispatch if launch is enabled
if [[ "$HAS_LAUNCH" == "yes" ]] && ! $SKIP_LAUNCH; then
  DISPATCH_ARGS+=(--launch)
elif $SKIP_LAUNCH; then
  DISPATCH_ARGS+=(--skip-launch)
fi

# Hand off to the dispatch engine
if "$SCRIPT_DIR/foreman-dispatch.sh" "${DISPATCH_ARGS[@]}"; then
  echo ""
  echo "╔══════════════════════════════════════════╗"
  echo "║         Blast Complete                   ║"
  echo "╚══════════════════════════════════════════╝"
  echo ""
  echo "  Template:   $MODULE_NAME"
  echo "  Loop:       $EFFECTIVE_LOOP"
  echo "  Workspace:  $WORKSPACE"
  echo "  Project:    $PROJECT_NAME"
  echo "  Stage:      $FIRST_STAGE"
  echo "  Task:       $PROMPT"
  echo "  QA Roles:   $QA_ROLES"
  if [[ "$HAS_LAUNCH" == "yes" ]]; then
    echo "  Launch:     enabled ($LAUNCH_ASSETS)"
  fi
  echo ""
  echo "  Run 'foreman run status' to check progress."
else
  echo ""
  echo "  ✗ Pipeline failed." >&2
  exit 1
fi
