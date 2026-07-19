#!/usr/bin/env bash
# foreman dispatch — the real execution engine.
#
# Runs the builder→inspector→verdict loop by actually invoking agent CLIs
# and feeding verdicts into foreman-run.sh's 3-strike state machine.
#
# Usage:
#   foreman dispatch --task "<prompt>" [--template <name>] [--stage <name>]
#                     [--project <name>] [--dry-run] [--max-attempts <n>]
#                     [--builder-cmd "<cmd>"] [--inspector-cmd "<cmd>"]
#                     [--provider <name>] [--workspace <dir>]
#
# When --dry-run is set, plans the dispatch but does not invoke any agents.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
CONFIG_DIR="${FOREMAN_CONFIG_DIR:-$HOME/.foreman}"
PROFILE_FILE="$CONFIG_DIR/profile.json"
RUNS_SCRIPT="$SCRIPT_DIR/foreman-run.sh"
BRAIN_SCRIPT="$ROOT/scripts/foreman-brain.py"

# Colors
G='\033[0;32m' R='\033[0;31m' Y='\033[1;33m' B='\033[0;34m' CYAN='\033[0;36m' BOLD='\033[1m' DIM='\033[2m' NC='\033[0m'

# ─── Parse arguments ──────────────────────────────────────────────────────────

TASK=""
TEMPLATE=""
STAGE=""
PROJECT=""
DRY_RUN=false
MAX_ATTEMPTS=3
BUILDER_CMD_OVERRIDE=""
INSPECTOR_CMD_OVERRIDE=""
PROVIDER=""
WORKSPACE=""
LAUNCH=false
SKIP_LAUNCH=false

usage() {
  cat <<'EOF'
Usage: foreman dispatch --task "<prompt>" [options]

Run the builder→inspector→verdict execution loop.

Options:
  --task "<prompt>"        The task to dispatch (required)
  --template <name>        Module template to use (default: auto-detect or 'software')
  --stage <name>           Stage to start at (default: first stage in manifest)
  --project <name>         Project name (default: dispatch-<timestamp>)
  --dry-run                Plan without invoking agents
  --max-attempts <n>       Max builder attempts before giving up (default: 3)
  --builder-cmd "<cmd>"    Override builder CLI command from profile
  --inspector-cmd "<cmd>"  Override inspector CLI command from profile
  --provider <name>        Force the builder onto a specific provider
                           (agent/cursor/claude/codex/ollama/hermes)
  --workspace <dir>        Working directory for agent output
  --launch                 Run launch phase after successful completion
  --skip-launch            Stop after QA even when the template enables launch
  -h, --help               Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task)         TASK="$2";       shift 2 ;;
    --template)     TEMPLATE="$2";   shift 2 ;;
    --stage)        STAGE="$2";      shift 2 ;;
    --project)      PROJECT="$2";    shift 2 ;;
    --dry-run)      DRY_RUN=true;    shift   ;;
    --max-attempts) MAX_ATTEMPTS="$2"; shift 2 ;;
    --builder-cmd)  BUILDER_CMD_OVERRIDE="$2"; shift 2 ;;
    --inspector-cmd) INSPECTOR_CMD_OVERRIDE="$2"; shift 2 ;;
    --provider)     PROVIDER="$2";   shift 2 ;;
    --workspace)    WORKSPACE="$2";  shift 2 ;;
    --launch)       LAUNCH=true;     shift   ;;
    --skip-launch)  SKIP_LAUNCH=true; shift  ;;
    -h|--help)      usage; exit 0    ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$TASK" ]]; then
  echo "Error: --task is required" >&2
  usage >&2
  exit 1
fi

# ─── Load profile ─────────────────────────────────────────────────────────────

if [[ ! -f "$PROFILE_FILE" ]]; then
  echo -e "${R}No Foreman profile found. Run ${BOLD}foreman init${NC} first." >&2
  exit 1
fi

# Source secrets if available
[[ -f "$CONFIG_DIR/secrets.env" ]] && source "$CONFIG_DIR/secrets.env" 2>/dev/null || true

# Extract role commands from profile.json
BUILDER_CMD=$(python3 -c "import json; d=json.load(open('$PROFILE_FILE')); print(d.get('roles',{}).get('builder',{}).get('command',''))" 2>/dev/null || echo "")
INSPECTOR_CMD=$(python3 -c "import json; d=json.load(open('$PROFILE_FILE')); print(d.get('roles',{}).get('inspector',{}).get('command',''))" 2>/dev/null || echo "")
CHEAP_CMD=$(python3 -c "import json; d=json.load(open('$PROFILE_FILE')); print(d.get('roles',{}).get('cheap',{}).get('command',''))" 2>/dev/null || echo "")
BUILDER_NAME=$(python3 -c "import json; d=json.load(open('$PROFILE_FILE')); print(d.get('roles',{}).get('builder',{}).get('name','unknown'))" 2>/dev/null || echo "unknown")
INSPECTOR_NAME=$(python3 -c "import json; d=json.load(open('$PROFILE_FILE')); print(d.get('roles',{}).get('inspector',{}).get('name','unknown'))" 2>/dev/null || echo "unknown")

# ─── Fleet discovery + provider→command resolution ───────────────────────────
#
# Mirrors the discovery order used by the builder (foreman-blast.sh) and the
# role-assignment logic in foreman-init.sh, so dispatch can resolve a runnable
# command for a provider name without a re-init. Used by:
#   - the --provider passthrough (BUG 2): force the builder onto a provider
#   - the inspector fleet-fallback (BUG 1): pick a reachable inspector when the
#     configured one (e.g. 'claude') is not installed.

discover_providers() {
  local found=()
  for c in agent cursor-agent cursor claude codex hermes ollama; do
    if command -v "$c" >/dev/null 2>&1; then
      found+=("$c")
    fi
  done
  echo "${found[*]}"
}

# Resolve a runnable CLI command for a provider name. Returns empty if the
# provider's binary is not reachable on PATH. Model names are queried from the
# live CLI (never hardcoded); Ollama uses the placeholder tokens that
# resolve_command() expands later.
provider_command() {
  local provider="$1"
  case "$provider" in
    agent|cursor|cursor-agent)
      command -v agent >/dev/null 2>&1 || { echo ""; return; }
      local composer
      composer=$(agent models 2>/dev/null | grep -oiE 'composer[a-zA-Z0-9._-]*' | head -1 || true)
      if [[ -n "$composer" ]]; then
        echo "agent --trust --model $composer"
      else
        echo "agent --trust"
      fi
      ;;
    claude)
      command -v claude >/dev/null 2>&1 && echo "claude -p --model sonnet" || echo ""
      ;;
    codex)
      # Bare `codex` launches the interactive TUI and dies on piped stdin
      # ("stdin is not a terminal"). The dispatch invocation pipes the prompt
      # via `cat prompt | eval "$CMD"`, so we MUST use the non-interactive
      # `codex exec` form, which reads the prompt from stdin when none is given
      # as an argument (per `codex exec --help`).
      #
      # `--skip-git-repo-check` is required because the inspector/builder run
      # inside a throwaway workspace dir that is not a git repo; without it
      # codex refuses with "Not inside a trusted directory". (The Cursor builder
      # has the equivalent via `agent --trust`.)
      command -v codex >/dev/null 2>&1 && echo "codex exec --skip-git-repo-check" || echo ""
      ;;
    hermes)
      # hermes -z/--oneshot takes the prompt as an ARGUMENT, not stdin, while
      # builder/inspector invocations pipe the prompt ('cat file | eval CMD').
      # The '$(cat)' wrapper bridges the two: it reads the piped prompt and
      # hands it to -z as the argument. Verified stdin-safe 2026-07-10
      # (printf 'READY probe' | sh -c 'hermes -z "$(cat)"' → answers).
      command -v hermes >/dev/null 2>&1 && echo 'hermes -z "$(cat)"' || echo ""
      ;;
    ollama)
      command -v ollama >/dev/null 2>&1 && echo "ollama run <mid-tier-model>" || echo ""
      ;;
    *)
      # Unknown name — if it happens to be a binary on PATH, run it bare.
      command -v "$provider" >/dev/null 2>&1 && echo "$provider" || echo ""
      ;;
  esac
}

# The bare binary name a provider resolves to (for "different provider" checks).
provider_bin() {
  provider_command "$1" | awk '{print $1}'
}

# Apply overrides
[[ -n "$BUILDER_CMD_OVERRIDE" ]]   && BUILDER_CMD="$BUILDER_CMD_OVERRIDE"
[[ -n "$INSPECTOR_CMD_OVERRIDE" ]] && INSPECTOR_CMD="$INSPECTOR_CMD_OVERRIDE"

# ─── BUG 2: --provider forwarding ─────────────────────────────────────────────
# When --provider is set (and the builder command wasn't explicitly overridden),
# resolve that provider's builder command so the engine actually runs on it.
if [[ -n "$PROVIDER" ]] && [[ -z "$BUILDER_CMD_OVERRIDE" ]]; then
  PROVIDER_BUILDER_CMD="$(provider_command "$PROVIDER")"
  if [[ -n "$PROVIDER_BUILDER_CMD" ]]; then
    BUILDER_CMD="$PROVIDER_BUILDER_CMD"
    BUILDER_NAME="$PROVIDER"
  else
    echo -e "${Y}⚠ --provider '$PROVIDER' is not reachable on PATH; keeping configured builder.${NC}" >&2
  fi
fi

# ─── BUG 3: keep the displayed name honest when a command is overridden ───────
# If the inspector/builder command was overridden directly, the profile name no
# longer describes what actually runs. Relabel from the resolved binary so the
# printed label never lies. (The fleet-fallback below relabels too.)
if [[ -n "$INSPECTOR_CMD_OVERRIDE" ]]; then
  INSPECTOR_NAME="$(echo "$INSPECTOR_CMD_OVERRIDE" | awk '{print $1}')"
fi
if [[ -n "$BUILDER_CMD_OVERRIDE" ]]; then
  BUILDER_NAME="$(echo "$BUILDER_CMD_OVERRIDE" | awk '{print $1}')"
fi

# ─── Resolve template ─────────────────────────────────────────────────────────

detect_template() {
  local prompt="$1"
  local lc_prompt
  lc_prompt="$(echo "$prompt" | tr '[:upper:]' '[:lower:]')"
  if echo "$lc_prompt" | grep -qE '\b(write|story|book|chapter|novel|fiction|prose|manuscript)\b'; then
    echo "creative-writing"; return
  fi
  if echo "$lc_prompt" | grep -qE '\b(code|build|fix|app|deploy|debug|refactor|implement|feature|bug|api|server|database|test)\b'; then
    echo "software"; return
  fi
  if echo "$lc_prompt" | grep -qE '\b(market|ad|copy|campaign|email|brand|landing|funnel|seo|social media|newsletter)\b'; then
    echo "marketing"; return
  fi
  if echo "$lc_prompt" | grep -qE '\b(video|youtube|thumbnail|retention|channel|subscriber)\b'; then
    echo "youtube"; return
  fi
  if echo "$lc_prompt" | grep -qE '\b(publish|launch|metadata|storefront|isbn|epub|kindle|kdp)\b'; then
    echo "publishing"; return
  fi
  echo "software"
}

if [[ -z "$TEMPLATE" ]]; then
  TEMPLATE="$(detect_template "$TASK")"
fi

MODULE_DIR="$ROOT/modules/$TEMPLATE"
if [[ ! -d "$MODULE_DIR" ]]; then
  echo -e "${R}Error: template '$TEMPLATE' not found in modules/${NC}" >&2
  echo "Available templates:" >&2
  ls "$ROOT/modules" 2>/dev/null | grep -v departments >&2
  exit 1
fi
if [[ ! -f "$MODULE_DIR/module.json" ]]; then
  echo -e "${R}Error: module.json missing for template '$TEMPLATE'${NC}" >&2
  exit 1
fi

MANIFEST_JSON="$(cat "$MODULE_DIR/module.json")"

# Extract manifest fields
MODULE_NAME="$(echo "$MANIFEST_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("name",""))')"
LOOP_MODE="$(echo "$MANIFEST_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("loop_mode","lean"))')"
FIRST_STAGE="$(echo "$MANIFEST_JSON" | python3 -c 'import json,sys; stages=json.load(sys.stdin).get("stages",[]); print(stages[0] if stages else "unknown")')"
QA_ROLES_JSON="$(echo "$MANIFEST_JSON" | python3 -c 'import json,sys; print(json.dumps(json.load(sys.stdin).get("qa_roles",[])))')"
LAUNCH_ENABLED="$(echo "$MANIFEST_JSON" | python3 -c 'import json,sys; lp=json.load(sys.stdin).get("launch_phase",{}); print("yes" if lp.get("enabled") else "no")')"
LAUNCH_ASSETS_JSON="$(echo "$MANIFEST_JSON" | python3 -c 'import json,sys; print(json.dumps(json.load(sys.stdin).get("launch_phase",{}).get("assets",[])))')"

if [[ -z "$STAGE" ]]; then
  STAGE="$FIRST_STAGE"
fi

if [[ -z "$PROJECT" ]]; then
  PROJECT="dispatch-$(date +%s)"
fi

if [[ -z "$WORKSPACE" ]]; then
  WORKSPACE="$(mktemp -d -t foreman-dispatch-XXXXXX)"
fi
mkdir -p "$WORKSPACE"

# ─── Validate builder/inspector commands ─────────────────────────────────────

# Check if builder command contains a placeholder that needs resolving
resolve_command() {
  local cmd="$1"
  local resolved="$cmd"
  # Handle Ollama placeholder models: <cheapest-model>, <mid-tier-model>, <strongest-model>
  if echo "$cmd" | grep -qE '<(cheapest|mid-tier|strongest)-model>'; then
    if command -v ollama >/dev/null 2>&1; then
      local model_list
      model_list=$(ollama list 2>/dev/null | tail -n +2 | grep -oE '^[a-zA-Z0-9][a-zA-Z0-9._:-]+' || true)
      local cheapest mid strongest
      # First listed model is often the smallest/cheapest, last is strongest
      cheapest=$(echo "$model_list" | head -1 || true)
      mid=$(echo "$model_list" | head -1 || true)
      strongest=$(echo "$model_list" | tail -1 || true)
      [[ -n "$cheapest" ]] && resolved=$(echo "$resolved" | sed "s|<cheapest-model>|$cheapest|g")
      [[ -n "$mid" ]]      && resolved=$(echo "$resolved" | sed "s|<mid-tier-model>|$mid|g")
      [[ -n "$strongest" ]] && resolved=$(echo "$resolved" | sed "s|<strongest-model>|$strongest|g")
    else
      echo "$cmd"  # can't resolve — return as-is
    fi
  fi
  echo "$resolved"
}

BUILDER_CMD_RESOLVED=$(resolve_command "$BUILDER_CMD")
INSPECTOR_CMD_RESOLVED=$(resolve_command "$INSPECTOR_CMD")

# Extract the executable name (first token) for availability check
builder_bin=$(echo "$BUILDER_CMD_RESOLVED" | awk '{print $1}')
inspector_bin=$(echo "$INSPECTOR_CMD_RESOLVED" | awk '{print $1}')

# ─── BUG 1: inspector fleet-fallback ──────────────────────────────────────────
# The configured/default inspector resolves to a CLI (often 'claude') that may
# not be installed. If that binary is NOT on PATH — and the user did not pass an
# explicit --inspector-cmd — pick a reachable inspector from the actual fleet
# instead of dying in preflight. Prefer a provider DIFFERENT from the builder so
# verification stays independent; fall back to any reachable CLI.
if [[ -z "$INSPECTOR_CMD_OVERRIDE" ]] && ! command -v "$inspector_bin" >/dev/null 2>&1; then
  FLEET="$(discover_providers)"
  if [[ -n "$FLEET" ]]; then
    # shellcheck disable=SC2206
    FLEET_ARR=($FLEET)
    FALLBACK_CMD=""
    FALLBACK_NAME=""
    # First pass: prefer a provider whose binary differs from the builder's.
    for p in "${FLEET_ARR[@]}"; do
      cand="$(provider_command "$p")"
      [[ -z "$cand" ]] && continue
      cand_bin="$(echo "$cand" | awk '{print $1}')"
      if [[ "$cand_bin" != "$builder_bin" ]]; then
        FALLBACK_CMD="$cand"; FALLBACK_NAME="$p"; break
      fi
    done
    # Second pass: accept any reachable provider (even same as builder).
    if [[ -z "$FALLBACK_CMD" ]]; then
      for p in "${FLEET_ARR[@]}"; do
        cand="$(provider_command "$p")"
        if [[ -n "$cand" ]]; then
          FALLBACK_CMD="$cand"; FALLBACK_NAME="$p"; break
        fi
      done
    fi
    if [[ -n "$FALLBACK_CMD" ]]; then
      echo -e "${Y}⚠ Inspector CLI '$inspector_bin' not found on PATH — falling back to '$FALLBACK_NAME'.${NC}" >&2
      INSPECTOR_CMD="$FALLBACK_CMD"
      INSPECTOR_CMD_RESOLVED="$(resolve_command "$INSPECTOR_CMD")"
      inspector_bin=$(echo "$INSPECTOR_CMD_RESOLVED" | awk '{print $1}')
      # BUG 3: relabel so the displayed name reflects what truly runs.
      INSPECTOR_NAME="$FALLBACK_NAME"
    fi
  fi
fi

# ─── Print dispatch summary ───────────────────────────────────────────────────

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║         Foreman — Dispatch                  ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo "  Task:       $TASK"
echo "  Template:   $MODULE_NAME"
echo "  Stage:      $STAGE"
echo "  Project:    $PROJECT"
echo "  Loop:       $LOOP_MODE"
echo ""
echo "  Builder:    $BUILDER_NAME"
echo "  Command:    $BUILDER_CMD_RESOLVED"
echo "  Inspector:  $INSPECTOR_NAME"
echo "  Command:    $INSPECTOR_CMD_RESOLVED"
echo ""
echo "  Workspace:  $WORKSPACE"
echo "  Dry run:    $DRY_RUN"
echo ""

# ─── Dry run mode ─────────────────────────────────────────────────────────────

if $DRY_RUN; then
  echo "  [DRY RUN] Execution plan:"
  echo "    1. Start run:    foreman-run.sh start $TEMPLATE --project $PROJECT --stage $STAGE --task \"$TASK\""
  echo "    2. Builder:      $BUILDER_CMD_RESOLVED"
  echo "    3. Inspector:    $INSPECTOR_CMD_RESOLVED"
  echo "    4. Verdict loop: pass→complete | fail→retry (up to $MAX_ATTEMPTS) | blocked→stop"
  if ! $SKIP_LAUNCH && { [[ "$LAUNCH_ENABLED" == "yes" ]] || $LAUNCH; }; then
    echo "    5. Launch phase: generate shipping assets via foreman-brain.py"
  elif $SKIP_LAUNCH; then
    echo "    5. Launch phase: skipped by --skip-launch"
  fi
  echo ""
  echo "  [DRY RUN] No agents invoked. Remove --dry-run to execute."
  exit 0
fi

# ─── Validate agent availability ──────────────────────────────────────────────

if [[ -z "$BUILDER_CMD_RESOLVED" ]]; then
  echo -e "${R}Error: no builder command configured in profile.${NC}" >&2
  echo -e "${DIM}Run: foreman init${NC}" >&2
  exit 1
fi

if [[ -z "$INSPECTOR_CMD_RESOLVED" ]]; then
  echo -e "${R}Error: no inspector command configured in profile.${NC}" >&2
  echo -e "${DIM}Run: foreman init${NC}" >&2
  exit 1
fi

if ! command -v "$builder_bin" >/dev/null 2>&1; then
  echo -e "${R}Error: builder CLI '$builder_bin' not found on PATH.${NC}" >&2
  echo -e "${DIM}Run: foreman init to reconfigure, or pass --builder-cmd${NC}" >&2
  exit 1
fi

if ! command -v "$inspector_bin" >/dev/null 2>&1; then
  echo -e "${R}Error: inspector CLI '$inspector_bin' not found on PATH.${NC}" >&2
  echo -e "${DIM}Run: foreman init to reconfigure, or pass --inspector-cmd${NC}" >&2
  exit 1
fi

# ─── Inspector liveness preflight ─────────────────────────────────────────────
# PATH presence is not health: a CLI can exist but be unable to run a job (e.g.
# claude installed but logged out for headless use). Without this probe the
# builder burns a full attempt before the dead inspector is discovered. Probe
# with one tiny job; on failure, fall back to a live provider from the fleet
# (prefer one whose binary differs from the builder's, so verification stays
# independent). FOREMAN_SKIP_PROBE=1 skips live calls (CI/tests, stub CLIs).

_preflight_timeout() {
  local secs="$1"; shift
  if command -v timeout >/dev/null 2>&1; then timeout "$secs" "$@"
  elif command -v gtimeout >/dev/null 2>&1; then gtimeout "$secs" "$@"
  else "$@"; fi
}

# Pass = exit 0 AND output contains READY (same contract as init's Step 3.5).
_preflight_probe() {
  local cmd="$1" dir out rc=0
  dir="$(mktemp -d)"
  out=$( cd "$dir" && printf 'Reply with the single word READY and nothing else.' | _preflight_timeout 90 sh -c "$cmd" 2>&1 ) || rc=$?
  rm -rf "$dir"
  [[ $rc -eq 0 ]] && printf '%s' "$out" | grep -qiE 'ready'
}

if [[ "${FOREMAN_SKIP_PROBE:-}" != "1" ]]; then
  if ! _preflight_probe "$INSPECTOR_CMD_RESOLVED"; then
    echo -e "${Y}⚠ Inspector '$INSPECTOR_NAME' is on PATH but failed a live probe (not logged in, or cannot run headless).${NC}" >&2
    PROBE_FALLBACK_CMD=""
    PROBE_FALLBACK_NAME=""
    FLEET="$(discover_providers)"
    if [[ -n "$FLEET" ]]; then
      # shellcheck disable=SC2206
      FLEET_ARR=($FLEET)
      # Two passes: first prefer a provider whose binary differs from both the
      # dead inspector and the builder; then accept any live provider.
      for pass in independent any; do
        [[ -n "$PROBE_FALLBACK_CMD" ]] && break
        for p in "${FLEET_ARR[@]}"; do
          cand="$(provider_command "$p")"
          [[ -z "$cand" ]] && continue
          cand_resolved="$(resolve_command "$cand")"
          cand_bin="$(echo "$cand_resolved" | awk '{print $1}')"
          [[ "$cand_bin" == "$inspector_bin" ]] && continue
          if [[ "$pass" == "independent" ]] && [[ "$cand_bin" == "$builder_bin" ]]; then continue; fi
          if _preflight_probe "$cand_resolved"; then
            PROBE_FALLBACK_CMD="$cand_resolved"; PROBE_FALLBACK_NAME="$p"; break
          fi
        done
      done
    fi
    if [[ -n "$PROBE_FALLBACK_CMD" ]]; then
      echo -e "${Y}⚠ Falling back to live inspector '$PROBE_FALLBACK_NAME'.${NC}" >&2
      INSPECTOR_CMD_RESOLVED="$PROBE_FALLBACK_CMD"
      inspector_bin=$(echo "$INSPECTOR_CMD_RESOLVED" | awk '{print $1}')
      INSPECTOR_NAME="$PROBE_FALLBACK_NAME"
    else
      echo -e "${R}Error: no live inspector available — refusing to dispatch a builder with no working reviewer.${NC}" >&2
      echo -e "${DIM}Fix the inspector CLI (e.g. log in), run: foreman init, or pass --inspector-cmd.${NC}" >&2
      echo -e "${DIM}Set FOREMAN_SKIP_PROBE=1 to bypass this check.${NC}" >&2
      exit 1
    fi
  fi
fi

# ─── Start the run ────────────────────────────────────────────────────────────

echo -e "${B}▶ Starting run...${NC}"
echo ""

START_OUT=$("$RUNS_SCRIPT" start "$TEMPLATE" \
  --project "$PROJECT" \
  --stage "$STAGE" \
  --task "$TASK" 2>&1) || {
    echo -e "${R}Failed to start run:${NC}" >&2
    echo "$START_OUT" >&2
    exit 1
  }

RUN_ID=$(echo "$START_OUT" | awk '/^Started/ {print $NF}')
if [[ -z "$RUN_ID" ]] || [[ "$RUN_ID" != run_* ]]; then
  echo -e "${R}Could not parse run ID from start output:${NC}" >&2
  echo "$START_OUT" >&2
  exit 1
fi

echo -e "  ${G}✓${NC} Started: ${BOLD}$RUN_ID${NC}"
echo ""

# ─── Execution loop ───────────────────────────────────────────────────────────
#
# For each attempt (up to MAX_ATTEMPTS):
#   1. Invoke builder CLI with the task (+ prior failure context if retry)
#   2. Invoke inspector CLI to review the builder's output
#   3. Parse inspector verdict: pass / fail / blocked
#   4. Feed verdict to foreman-run.sh inspect (which handles 3-strike escalation)
#   5. If pass → done. If fail → loop. If blocked → stop.
#
# The state machine in foreman-run.sh handles:
#   - pass → status=completed
#   - fail → strike_count++, status=failed (then blocked at 3 strikes)
#   - blocked → status=blocked

# Extract the inspector's findings for the ledger. Prefer the explicit
# FINDINGS: block the prompts request — everything after the last line that is
# exactly 'FINDINGS:' — which structurally excludes provider preamble (banners,
# model/workdir dumps always precede the marker). Fall back to the
# tail-of-output heuristic for CLIs/models that ignore the marker; either way
# keep the TRAILING chars (findings sit just before the VERDICT line).
extract_notes() {
  local output="$1" maxlen="$2" block
  block=$(echo "$output" | awk 'toupper($0) ~ /^[[:space:]]*FINDINGS:[[:space:]]*$/{buf=""; found=1; next} found{buf=buf $0 "\n"} END{printf "%s", buf}')
  if [[ -z "${block//[[:space:]]/}" ]]; then
    block="$output"
  fi
  echo "$block" | sed '/VERDICT:/Id' | grep -vE '^[[:space:]]*$' | tail -10 | tr '\n' ' ' | sed 's/  */ /g; s/ $//' | awk -v m="$maxlen" '{n=length($0); print (n>m) ? substr($0,n-m+1) : $0}' || true
}

BUILDER_PROMPT_FILE="$WORKSPACE/builder_prompt.txt"
BUILDER_OUTPUT_FILE="$WORKSPACE/builder_output.txt"
INSPECTOR_PROMPT_FILE="$WORKSPACE/inspector_prompt.txt"
INSPECTOR_OUTPUT_FILE="$WORKSPACE/inspector_output.txt"
INSPECTOR_VERDICT_FILE="$WORKSPACE/verdict.txt"

ATTEMPT=0
FINAL_VERDICT=""
PREV_FAILURES=""

while [[ $ATTEMPT -lt $MAX_ATTEMPTS ]]; do
  ATTEMPT=$((ATTEMPT + 1))
  echo -e "${B}── Attempt $ATTEMPT/$MAX_ATTEMPTS ──${NC}"
  echo ""

  # ── Step 1: Build the builder prompt ──
  if [[ $ATTEMPT -eq 1 ]]; then
    cat > "$BUILDER_PROMPT_FILE" <<PROMPT
You are a builder in a Foreman crew. You are not the final reviewer.
Implement the assigned task. Keep the write set bounded.
List changed files and exact verification commands.
Do not broaden scope. If you hit the same problem 3 times, STOP and report back.

TASK: $TASK
STAGE: $STAGE
TEMPLATE: $MODULE_NAME
WORKSPACE: $WORKSPACE

Produce the work now.
PROMPT
  else
    # Include prior failure context for retries
    cat > "$BUILDER_PROMPT_FILE" <<PROMPT
You are a builder in a Foreman crew. You are not the final reviewer.
This is attempt $ATTEMPT. A previous attempt was rejected by the inspector.
Fix the issues identified below and produce corrected work.

TASK: $TASK
STAGE: $STAGE
TEMPLATE: $MODULE_NAME
WORKSPACE: $WORKSPACE

PREVIOUS INSPECTOR FEEDBACK:
$PREV_FAILURES

Produce the corrected work now.
PROMPT
  fi

  # ── Step 2: Invoke the builder ──
  echo -e "  ${DIM}▶ Invoking builder: $BUILDER_NAME${NC}"
  # The builder prompt is piped as stdin; the CLI command runs with the workspace as cwd
  set +e
  (cd "$WORKSPACE" && cat "$BUILDER_PROMPT_FILE" | eval "$BUILDER_CMD_RESOLVED") > "$BUILDER_OUTPUT_FILE" 2>&1
  BUILDER_EXIT=$?
  set -e

  if [[ $BUILDER_EXIT -ne 0 ]]; then
    echo -e "  ${Y}⚠ Builder exited with code $BUILDER_EXIT${NC}"
    echo -e "  ${DIM}Builder output saved to $BUILDER_OUTPUT_FILE${NC}"
  else
    echo -e "  ${G}✓${NC} Builder completed"
  fi

  # Strip ANSI/control noise that TTY-driven CLIs (e.g. ollama) emit even when
  # piped, so downstream parsing and run notes stay clean.
  BUILDER_OUTPUT=$(sed -E "s/$(printf '\033')\[[0-9;?]*[A-Za-z]//g" "$BUILDER_OUTPUT_FILE" | tr -d '\r')

  # ── FIX 4: Auto-fail if builder crashed or produced empty output ──
  # Don't waste an inspector invocation on a builder that didn't run.
  if [[ $BUILDER_EXIT -ne 0 ]] || [[ -z "$BUILDER_OUTPUT" ]]; then
    REASON="builder exited with code $BUILDER_EXIT"
    [[ -z "$BUILDER_OUTPUT" ]] && REASON="builder produced empty output"
    echo -e "  ${Y}⚠ Auto-fail: $REASON — skipping inspector${NC}"
    echo ""
    VERDICT="fail"
    INSPECTOR_NOTES="Auto-fail: $REASON"

    # ── Feed verdict to the run state machine (fail path) ──
    INSPECT_OUT=$("$RUNS_SCRIPT" inspect "$RUN_ID" --verdict "$VERDICT" --notes "$INSPECTOR_NOTES" 2>&1) || {
      echo -e "${R}Run inspect failed:${NC}" >&2
      echo "$INSPECT_OUT" >&2
      FINAL_VERDICT="$VERDICT"
      break
    }
    echo -e "  ${DIM}$INSPECT_OUT${NC}"
    FINAL_VERDICT="$VERDICT"

    # Check if the run has been escalated to blocked (3 strikes)
    RUN_STATUS=$("$RUNS_SCRIPT" status "$RUN_ID" 2>&1 | head -1 | awk -F': ' '{print $2}')
    if [[ "$RUN_STATUS" == "blocked" ]]; then
      echo ""
      echo -e "  ${R}✗ Task BLOCKED after $ATTEMPT failed attempts (3-strike escalation)${NC}"
      FINAL_VERDICT="blocked"
      break
    fi
    echo -e "  ${Y}↻ Retrying (attempt $ATTEMPT failed)...${NC}"
    echo ""
    continue
  fi

  echo -e "  ${DIM}Output: $(echo "$BUILDER_OUTPUT" | head -3 | tr '\n' ' ')...${NC}"
  echo ""

  # ── Step 3: Build the inspector prompt ──
  cat > "$INSPECTOR_PROMPT_FILE" <<PROMPT
You are the inspector in a Foreman crew. Your job is judgment, not implementation.
Inspect the builder's work for correctness, regressions, missing tests, integration risks.
Do NOT fix. Report first.

TASK: $TASK
STAGE: $STAGE
TEMPLATE: $MODULE_NAME

BUILDER OUTPUT:
$BUILDER_OUTPUT

Review the builder's work above. On the LAST line of your response, emit EXACTLY one of:
VERDICT: pass
VERDICT: fail
VERDICT: blocked

Use "pass" if the work is correct and complete.
Use "fail" if there are issues that the builder can fix.
Use "blocked" if the problem requires human intervention or cannot be resolved by the builder.

Before the verdict line, provide your assessment and any issues found.
Start your assessment with a line containing exactly:
FINDINGS:
PROMPT

  # ── Step 4: Invoke the inspector ──
  echo -e "  ${DIM}▶ Invoking inspector: $INSPECTOR_NAME${NC}"
  set +e
  (cd "$WORKSPACE" && cat "$INSPECTOR_PROMPT_FILE" | eval "$INSPECTOR_CMD_RESOLVED") > "$INSPECTOR_OUTPUT_FILE" 2>&1
  INSPECTOR_EXIT=$?
  set -e

  if [[ $INSPECTOR_EXIT -ne 0 ]]; then
    echo -e "  ${Y}⚠ Inspector exited with code $INSPECTOR_EXIT${NC}"
  else
    echo -e "  ${G}✓${NC} Inspector completed"
  fi

  # Strip ANSI/control noise (ollama and other TTY CLIs emit it even when piped).
  INSPECTOR_OUTPUT=$(sed -E "s/$(printf '\033')\[[0-9;?]*[A-Za-z]//g" "$INSPECTOR_OUTPUT_FILE" | tr -d '\r')
  echo -e "  ${DIM}Output: $(echo "$INSPECTOR_OUTPUT" | head -3 | tr '\n' ' ')...${NC}"
  echo ""

  # ── Step 5: Parse the verdict ──
  # FIX 3: Parse ONLY from explicit 'VERDICT:' lines in the inspector response.
  # Never keyword-infer 'pass' from body text (e.g. prompt echoes like
  # "use pass if correct"). When no explicit VERDICT line is found, default
  # to 'fail' — never assume pass.
  # '|| true' is load-bearing: under set -euo pipefail a no-match grep exits 1,
  # which would kill the script here and never reach the default-to-fail branch
  # below (a missing verdict must count as a strike, not end the pipeline).
  VERDICT=$(echo "$INSPECTOR_OUTPUT" | grep -oiE 'VERDICT:[[:space:]]*(pass|fail|blocked)' | tail -1 | sed -E 's/VERDICT:[[:space:]]*//' | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]' || true)

  if [[ -z "$VERDICT" ]]; then
    # No explicit VERDICT line found — default to fail, never keyword-infer pass.
    # Only 'blocked' may be inferred from explicit blocked-language, since that
    # is a strictly safer default than fail and still never grants a pass.
    if echo "$INSPECTOR_OUTPUT" | grep -qiE '\b(block|stuck|human|cannot|unable)\b'; then
      VERDICT="blocked"
    else
      VERDICT="fail"
    fi
    echo -e "  ${Y}⚠ No explicit VERDICT line found; defaulting to: $VERDICT${NC}"
  fi

  INSPECTOR_NOTES=$(extract_notes "$INSPECTOR_OUTPUT" 500)

  echo -e "  ${BOLD}Verdict: ${VERDICT}${NC}"
  echo ""

  # ── Step 6: Feed verdict to the run state machine ──
  # foreman-run.sh inspect handles the 3-strike escalation:
  #   pass → completed, fail → strike++ (blocked at 3), blocked → blocked
  INSPECT_OUT=$("$RUNS_SCRIPT" inspect "$RUN_ID" --verdict "$VERDICT" --notes "$INSPECTOR_NOTES" 2>&1) || {
    echo -e "${R}Run inspect failed:${NC}" >&2
    echo "$INSPECT_OUT" >&2
    # The run may have reached terminal state — break out
    FINAL_VERDICT="$VERDICT"
    break
  }
  echo -e "  ${DIM}$INSPECT_OUT${NC}"

  FINAL_VERDICT="$VERDICT"

  if [[ "$VERDICT" == "pass" ]]; then
    echo ""
    echo -e "  ${G}✓ Task PASSED on attempt $ATTEMPT${NC}"
    break
  elif [[ "$VERDICT" == "blocked" ]]; then
    echo ""
    echo -e "  ${R}✗ Task BLOCKED on attempt $ATTEMPT${NC}"
    break
  elif [[ "$VERDICT" == "fail" ]]; then
    PREV_FAILURES="$INSPECTOR_NOTES"
    # Check if the run has been escalated to blocked (3 strikes)
    RUN_STATUS=$("$RUNS_SCRIPT" status "$RUN_ID" 2>&1 | head -1 | awk -F': ' '{print $2}')
    if [[ "$RUN_STATUS" == "blocked" ]]; then
      echo ""
      echo -e "  ${R}✗ Task BLOCKED after $ATTEMPT failed attempts (3-strike escalation)${NC}"
      FINAL_VERDICT="blocked"
      break
    fi
    echo -e "  ${Y}↻ Retrying (attempt $ATTEMPT failed)...${NC}"
    echo ""
  fi
done

# ─── Check final run status ──
RUN_STATUS=$("$RUNS_SCRIPT" status "$RUN_ID" 2>&1 | head -1 | awk -F': ' '{print $2}')

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║         Dispatch Result                     ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo "  Run:        $RUN_ID"
echo "  Status:     $RUN_STATUS"
echo "  Verdict:    $FINAL_VERDICT"
echo "  Attempts:   $ATTEMPT"
echo "  Workspace:  $WORKSPACE"
echo ""

# ─── QA Roles gate (P1) ──
# If the module manifest defines qa_roles, run them as an additional inspection step
QA_GATE_FAILED=false
QA_COUNT=$(echo "$QA_ROLES_JSON" | python3 -c 'import json,sys; print(len(json.load(sys.stdin)))' 2>/dev/null || echo "0")

if [[ "$QA_COUNT" -gt 0 ]] && [[ "$RUN_STATUS" == "completed" ]]; then
  echo -e "${B}▶ QA Gate: $QA_COUNT role(s)${NC}"
  echo ""

  QA_FAILED=false
  echo "$QA_ROLES_JSON" | python3 -c "
import json, sys
roles = json.load(sys.stdin)
for r in roles:
    print(r.get('name', 'unnamed') + '|' + '|'.join(r.get('checklist', [])))
" | while IFS='|' read -r qa_name qa_checklist_1 qa_checklist_2 qa_checklist_3 qa_checklist_4 qa_checklist_5 qa_checklist_6; do
    echo -e "  ${DIM}QA Role: $qa_name${NC}"

    # Build checklist text
    CHECKLIST_ITEMS=()
    [[ -n "$qa_checklist_1" ]] && CHECKLIST_ITEMS+=("$qa_checklist_1")
    [[ -n "$qa_checklist_2" ]] && CHECKLIST_ITEMS+=("$qa_checklist_2")
    [[ -n "$qa_checklist_3" ]] && CHECKLIST_ITEMS+=("$qa_checklist_3")
    [[ -n "$qa_checklist_4" ]] && CHECKLIST_ITEMS+=("$qa_checklist_4")
    [[ -n "$qa_checklist_5" ]] && CHECKLIST_ITEMS+=("$qa_checklist_5")
    [[ -n "$qa_checklist_6" ]] && CHECKLIST_ITEMS+=("$qa_checklist_6")

    CHECKLIST_TEXT=$(printf '%s\n' "${CHECKLIST_ITEMS[@]}")

    # Use the inspector CLI for QA review (it's the judgment role)
    QA_PROMPT="You are a QA reviewer: $qa_name
Review the builder's work against this checklist:
$CHECKLIST_TEXT

TASK: $TASK
BUILDER OUTPUT:
$(cat "$BUILDER_OUTPUT_FILE")

Start your assessment with a line containing exactly:
FINDINGS:
On the LAST line, emit: VERDICT: pass  or  VERDICT: fail"

    QA_OUT_FILE="$WORKSPACE/qa_${qa_name// /_}.txt"
    set +e
    (cd "$WORKSPACE" && echo "$QA_PROMPT" | eval "$INSPECTOR_CMD_RESOLVED") > "$QA_OUT_FILE" 2>&1
    QA_EXIT=$?
    set -e

    # Strip ANSI/control noise BEFORE parsing, same as the main verdict parse —
    # TTY CLIs (ollama) emit cursor codes that can split 'VERDICT' mid-word
    # (VERDI\e[?25l\e[?25hCT), silently turning a pass into a default fail.
    QA_OUTPUT_CLEAN=$(sed -E "s/$(printf '\033')\[[0-9;?]*[A-Za-z]//g" "$QA_OUT_FILE" | tr -d '\r')
    # '|| true': same set -e landmine as the main parse — no-match grep must
    # not kill the QA gate before its own missing-verdict handling runs.
    QA_VERDICT=$(echo "$QA_OUTPUT_CLEAN" | grep -oiE 'VERDICT:[[:space:]]*(pass|fail)' | tail -1 | sed -E 's/VERDICT:[[:space:]]*//' | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]' || true)
    [[ -z "$QA_VERDICT" ]] && QA_VERDICT="fail"

    if [[ "$QA_VERDICT" == "pass" ]]; then
      echo -e "    ${G}✓${NC} $qa_name: pass"
    else
      echo -e "    ${R}✗${NC} $qa_name: fail"
      echo "QA_FAILED" > "$WORKSPACE/qa_failed.flag"
      # Capture the reviewer's actual findings (tail of output, before the
      # verdict line) so the ledger records why QA failed, not just that it did.
      QA_NOTES=$(extract_notes "$QA_OUTPUT_CLEAN" 300)
      echo "$qa_name: $QA_NOTES" >> "$WORKSPACE/qa_failed_notes.txt"
    fi
  done

  if [[ -f "$WORKSPACE/qa_failed.flag" ]]; then
    QA_GATE_FAILED=true
    # Record the QA failure as the run's terminal state so the ledger — not
    # just the exit code and transcripts — shows the true outcome.
    QA_FAIL_NOTES=$(tr '\n' ' ' < "$WORKSPACE/qa_failed_notes.txt" 2>/dev/null | sed 's/  */ /g' | cut -c1-500 || true)
    QA_LEDGER_OUT=$("$RUNS_SCRIPT" qa "$RUN_ID" --result fail --notes "$QA_FAIL_NOTES" 2>&1) || \
      echo -e "  ${Y}⚠ Could not record QA failure in ledger: $QA_LEDGER_OUT${NC}" >&2
    echo ""
    echo -e "  ${R}✗ QA gate FAILED. Work completed the loop but did not pass QA review.${NC}"
    echo -e "  ${DIM}See qa_*.txt in: $WORKSPACE${NC}"
    echo -e "  ${DIM}Launch phase will be skipped.${NC}"
  else
    QA_GATE_FAILED=false
    QA_LEDGER_OUT=$("$RUNS_SCRIPT" qa "$RUN_ID" --result pass 2>&1) || \
      echo -e "  ${Y}⚠ Could not record QA pass in ledger: $QA_LEDGER_OUT${NC}" >&2
    echo -e "  ${G}✓ QA gate passed${NC}"
  fi
  echo ""
fi

# ─── Launch phase (P1) ──
# If launch is enabled in the manifest (or --launch flag set) and run completed,
# generate shipping assets using foreman-brain.py
LAUNCH_PHASE_FAILED=false
if [[ "$RUN_STATUS" == "completed" ]] && [[ "$QA_GATE_FAILED" == false ]] && ! $SKIP_LAUNCH && { [[ "$LAUNCH_ENABLED" == "yes" ]] || $LAUNCH; }; then
  echo -e "${B}▶ Launch Phase: generating shipping assets${NC}"
  echo ""

  # Get brain config from profile
  BRAIN_PROVIDER=$(python3 -c "import json; d=json.load(open('$PROFILE_FILE')); print(d.get('brain',{}).get('provider','none'))" 2>/dev/null || echo "none")
  BRAIN_MODEL=$(python3 -c "import json; d=json.load(open('$PROFILE_FILE')); print(d.get('brain',{}).get('model','none'))" 2>/dev/null || echo "none")

  if [[ "$BRAIN_PROVIDER" == "none" ]]; then
    echo -e "  ${Y}⚠ No brain configured — cannot generate launch assets.${NC}"
    echo -e "  ${DIM}Run: foreman init to configure a brain${NC}"
  elif [[ ! -f "$BRAIN_SCRIPT" ]]; then
    echo -e "  ${Y}⚠ foreman-brain.py not found — skipping asset generation.${NC}"
  else
    # Create launch output directory
    LAUNCH_DIR="$WORKSPACE/launch"
    mkdir -p "$LAUNCH_DIR"
    rm -f "$WORKSPACE/launch_failed.flag"

    # Generate each asset type via the brain
    echo "$LAUNCH_ASSETS_JSON" | python3 -c "
import json, sys
assets = json.load(sys.stdin)
for a in assets:
    print(a.get('type','unknown') + '|' + a.get('description',''))
" | while IFS='|' read -r asset_type asset_desc; do
      echo -e "  ${DIM}Generating: $asset_type${NC}"

      ASSET_PROMPT="You are generating a shipping asset for a completed task.
ASSET TYPE: $asset_type
DESCRIPTION: $asset_desc
TASK: $TASK
TEMPLATE: $MODULE_NAME

BUILDER OUTPUT (summary):
$(cat "$BUILDER_OUTPUT_FILE" | head -50)

Generate the $asset_type now. Be concise and practical."

      ASSET_FILE="$LAUNCH_DIR/${asset_type}.md"
      ASSET_HISTORY="$LAUNCH_DIR/${asset_type}_history.json"

      set +e
      # '< /dev/null' is load-bearing: this runs inside a piped while-read
      # loop, and without it python inherits the pipe as stdin and eats the
      # remaining asset lines — only the first asset ever generates.
      python3 "$BRAIN_SCRIPT" \
        --provider "$BRAIN_PROVIDER" \
        --model "$BRAIN_MODEL" \
        --system-prompt "You are a shipping asset generator. Produce clean, ready-to-use content." \
        --history "$ASSET_HISTORY" \
        --user-msg "$ASSET_PROMPT" < /dev/null > "$ASSET_FILE" 2>&1
      BRAIN_EXIT=$?
      set -e

      if [[ $BRAIN_EXIT -eq 0 ]] && [[ -s "$ASSET_FILE" ]]; then
        echo -e "    ${G}✓${NC} $asset_type → $ASSET_FILE"
      else
        echo -e "    ${R}✗${NC} $asset_type generation failed (see $ASSET_FILE)"
        echo "$asset_type" >> "$WORKSPACE/launch_failed.flag"
      fi
    done

    if [[ -f "$WORKSPACE/launch_failed.flag" ]]; then
      LAUNCH_PHASE_FAILED=true
      FAILED_ASSETS=$(tr '\n' ' ' < "$WORKSPACE/launch_failed.flag" | sed 's/ *$//')
      LAUNCH_LEDGER_OUT=$("$RUNS_SCRIPT" launch "$RUN_ID" --result fail --notes "asset generation failed: $FAILED_ASSETS" 2>&1) || \
        echo -e "  ${Y}⚠ Could not record launch failure in ledger: $LAUNCH_LEDGER_OUT${NC}" >&2
      echo ""
      echo -e "  ${R}✗ Launch phase failed; one or more assets were not generated.${NC}"
    else
      LAUNCH_LEDGER_OUT=$("$RUNS_SCRIPT" launch "$RUN_ID" --result pass 2>&1) || \
        echo -e "  ${Y}⚠ Could not record launch pass in ledger: $LAUNCH_LEDGER_OUT${NC}" >&2
      echo ""
      echo -e "  ${G}✓ Launch assets generated in: $LAUNCH_DIR${NC}"
    fi
  fi
  echo ""
fi

# ─── Final result ──
echo "  Run 'foreman run status $RUN_ID' for full run details."
echo ""

if [[ "$RUN_STATUS" == "completed" ]] && [[ "$LAUNCH_PHASE_FAILED" == true ]]; then
  echo -e "${R}✗ Dispatch completed build/inspection but FAILED the launch phase.${NC}"
  exit 1
elif [[ "$RUN_STATUS" == "completed" ]] && [[ "$QA_GATE_FAILED" == true ]]; then
  echo -e "${R}✗ Dispatch finished the loop but FAILED the QA gate.${NC}"
  exit 1
elif [[ "$RUN_STATUS" == "completed" ]]; then
  echo -e "${G}✓ Dispatch complete: task passed.${NC}"
  exit 0
elif [[ "$RUN_STATUS" == "blocked" ]]; then
  echo -e "${R}✗ Dispatch blocked: task could not be completed.${NC}"
  exit 1
else
  echo -e "${Y}⚠ Dispatch ended with status: $RUN_STATUS${NC}"
  exit 1
fi
