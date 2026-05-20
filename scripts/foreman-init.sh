#!/usr/bin/env zsh
# foreman init — First-run setup: discover CLIs, assign roles, save profile.
# Run once. Profile saved to ~/.foreman/ so you never do this again.
#
# Usage: foreman init          # interactive
#        foreman init --yes   # skip all prompts, accept defaults

set -euo pipefail

CONFIG_DIR="${FOREMAN_CONFIG_DIR:-$HOME/.foreman}"
PROFILE_FILE="$CONFIG_DIR/profile.json"
FLEET_FILE="$CONFIG_DIR/fleet.json"
SKIP_PROMPTS="${1:-}"

# Colors
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' B='\033[0;34m' BOLD='\033[1m' DIM='\033[2m' NC='\033[0m'

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║            Foreman — Init                   ║${NC}"
echo -e "${BOLD}║   Paperclip is the company.                  ║${NC}"
echo -e "${BOLD}║   Foreman runs the crew.                      ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""

# --- Permission ---
if [[ "$SKIP_PROMPTS" != "--yes" ]]; then
  echo -e "${B}Permission${NC} ${DIM}Foreman scans for AI CLIs on this machine.${NC}"
  echo -e "${DIM}No files are modified. No projects are created.${NC}"
  echo ""
  echo -e "${BOLD}Allow scan?${NC} [y/N] \c"
  read -r CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${R}Cancelled.${NC}"; exit 0
  fi
  echo ""
fi

# --- Discover ---
echo -e "${B}Discovering CLIs...${NC}"
echo ""

INSPECTOR="" INSPECTOR_CMD="" BUILDER="" BUILDER_CMD="" CHEAP="" CHEAP_CMD=""
FOUND=0

# Cursor Agent
if command -v agent >/dev/null 2>&1; then
  AGENT_PATH=$(command -v agent)
  AGENT_MODELS=$(agent models 2>/dev/null || true)
  COMPOSER=$(echo "$AGENT_MODELS" | grep -oiE 'composer-[0-9]+(\.[0-9]+)*(-[a-z0-9]+)?' | head -1 || true)
  COMPOSER_FAST="${COMPOSER%-fast}-fast"
  echo -e "  ${G}✓${NC} ${BOLD}Cursor Agent${NC} ${DIM}($AGENT_PATH)${NC}"
  [[ -n "$COMPOSER" ]] && echo -e "    ${G}✓${NC} Models: ${DIM}$COMPOSER${NC}"
  FOUND=$((FOUND + 1))
else
  echo -e "  ${R}✗${NC} Cursor Agent ${DIM}(not found)${NC}"
fi

# Claude Code
if command -v claude >/dev/null 2>&1; then
  CLAUDE_PATH=$(command -v claude)
  CLAUDE_VER=$(claude --version 2>/dev/null | head -1 || echo "available")
  echo -e "  ${G}✓${NC} ${BOLD}Claude Code${NC} ${DIM}($CLAUDE_VER)${NC}"
  FOUND=$((FOUND + 1))
else
  echo -e "  ${R}✗${NC} Claude Code ${DIM}(not found)${NC}"
fi

# Codex
if command -v codex >/dev/null 2>&1; then
  CODEX_PATH=$(command -v codex)
  echo -e "  ${G}✓${NC} ${BOLD}Codex${NC} ${DIM}($CODEX_PATH)${NC}"
  FOUND=$((FOUND + 1))
else
  echo -e "  ${R}✗${NC} Codex ${DIM}(not found)${NC}"
fi

# Ollama
if command -v ollama >/dev/null 2>&1; then
  OLLAMA_PATH=$(command -v ollama)
  OLLAMA_VER=$(ollama --version 2>/dev/null | head -1 || echo "available")
  OLLAMA_LIST=$(ollama list 2>/dev/null || true)
  OLLAMA_COUNT=$(echo "$OLLAMA_LIST" | grep -c '^[a-zA-Z]' 2>/dev/null || echo "0")
  OLLAMA_STRONGEST=$(echo "$OLLAMA_LIST" | grep -oE '^[a-zA-Z0-9._:-]+' | head -1 || true)
  echo -e "  ${G}✓${NC} ${BOLD}Ollama${NC} ${DIM}($OLLAMA_VER, $OLLAMA_COUNT models)${NC}"
  FOUND=$((FOUND + 1))
else
  echo -e "  ${R}✗${NC} Ollama ${DIM}(not found)${NC}"
fi

# Hermes
if command -v hermes >/dev/null 2>&1; then
  HERMES_PATH=$(command -v hermes)
  echo -e "  ${G}✓${NC} ${BOLD}Hermes${NC} ${DIM}($HERMES_PATH)${NC}"
  FOUND=$((FOUND + 1))
else
  echo -e "  ${R}✗${NC} Hermes ${DIM}(not found)${NC}"
fi

echo ""

# --- Assign roles ---
echo -e "${B}Role assignments${NC} ${DIM}(based on your fleet)${NC}"
echo ""

# Inspector: strongest available
if [[ -n "$CLAUDE_PATH" ]]; then
  INSPECTOR="Claude Opus"; INSPECTOR_CMD="claude -p --model opus"
elif [[ -n "$COMPOSER" ]]; then
  INSPECTOR="Cursor $COMPOSER"; INSPECTOR_CMD="agent --trust --model $COMPOSER"
elif [[ -n "$OLLAMA_STRONGEST" ]]; then
  INSPECTOR="Ollama $OLLAMA_STRONGEST"; INSPECTOR_CMD="ollama run $OLLAMA_STRONGEST"
fi

# Builder: Cursor Composer preferred, then Claude Sonnet, then Ollama mid
if [[ -n "$COMPOSER" ]]; then
  BUILDER="Cursor $COMPOSER"; BUILDER_CMD="agent --trust --model $COMPOSER"
elif [[ -n "$CLAUDE_PATH" ]]; then
  BUILDER="Claude Sonnet"; BUILDER_CMD="claude -p --model sonnet"
elif [[ -n "$OLLAMA_STRONGEST" ]]; then
  BUILDER="Ollama (mid-tier)"; BUILDER_CMD="ollama run <mid-tier-model>"
fi

# Cheap: Ollama cheapest, then Composer-fast, then Claude Haiku
if [[ -n "$OLLAMA_STRONGEST" ]]; then
  CHEAP="Ollama (cheapest)"; CHEAP_CMD="ollama run <cheapest-model>"
elif [[ -n "$COMPOSER_FAST" ]]; then
  CHEAP="Cursor $COMPOSER_FAST"; CHEAP_CMD="agent --trust --model $COMPOSER_FAST"
elif [[ -n "$CLAUDE_PATH" ]]; then
  CHEAP="Claude Haiku"; CHEAP_CMD="claude -p --model haiku"
fi

echo -e "  ${BOLD}Inspector${NC}  (review, judgment):  ${G}${INSPECTOR:-none}${NC}"
echo -e "  ${BOLD}Builder${NC}    (code, implement):  ${G}${BUILDER:-none}${NC}"
echo -e "  ${BOLD}Cheap${NC}      (classify, brainstorm): ${G}${CHEAP:-none}${NC}"

if [[ $FOUND -ge 2 ]]; then
  FLEET_MODE="multi-provider"
elif [[ $FOUND -eq 1 ]]; then
  FLEET_MODE="single-provider"
else
  FLEET_MODE="none"
fi
echo -e "  ${BOLD}Fleet${NC}     (mode):             ${G}${FLEET_MODE}${NC} (${FOUND} provider(s))"
echo ""

if [[ "$FLEET_MODE" == "none" ]]; then
  echo -e "${R}⚠ No CLIs found. Install at least one to use Foreman.${NC}"
  echo -e "${DIM}  Recommended: Cursor Agent (https://cursor.com) or Claude Code (https://claude.ai/code)${NC}"
  exit 1
fi

# --- Paperclip (optional) ---
PAPERCLIP_URL="" PAPERCLIP_COMPANY=""
if [[ "$SKIP_PROMPTS" != "--yes" ]]; then
  echo -e "${B}Paperclip${NC} ${DIM}(optional — adds dashboards and worktrees)${NC}"
  echo -e "${BOLD}Connect to Paperclip?${NC} [y/N] \c"
  read -r PC_ANSWER
  if [[ "$PC_ANSWER" =~ ^[Yy]$ ]]; then
    echo -e "  Paperclip URL [http://127.0.0.1:3100]: \c"
    read -r PAPERCLIP_URL
    PAPERCLIP_URL="${PAPERCLIP_URL:-http://127.0.0.1:3100}"
    echo -e "  Company ID: \c"
    read -r PAPERCLIP_COMPANY
    if curl -s "${PAPERCLIP_URL}/api/health" 2>/dev/null | grep -q "ok"; then
      echo -e "  ${G}✓${NC} Connected to Paperclip at $PAPERCLIP_URL"
    else
      echo -e "  ${Y}⚠${NC} Could not reach Paperclip at $PAPERCLIP_URL"
      PAPERCLIP_URL="" PAPERCLIP_COMPANY=""
    fi
  fi
fi
echo ""

# --- Save ---
mkdir -p "$CONFIG_DIR"

cat > "$PROFILE_FILE" << EOF
{
  "version": "0.1.0",
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "fleet_mode": "$FLEET_MODE",
  "roles": {
    "inspector": { "name": "${INSPECTOR:-none}", "command": "${INSPECTOR_CMD:-}" },
    "builder":   { "name": "${BUILDER:-none}",   "command": "${BUILDER_CMD:-}" },
    "cheap":     { "name": "${CHEAP:-none}",     "command": "${CHEAP_CMD:-}" }
  },
  "paperclip": { "url": "${PAPERCLIP_URL}", "company_id": "${PAPERCLIP_COMPANY}" }
}
EOF

echo -e "${G}✓${NC} Profile saved to ${DIM}$PROFILE_FILE${NC}"
echo ""

# --- Done ---
echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║         Foreman is ready.                    ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Inspector:  ${G}${INSPECTOR:-none}${NC}"
echo -e "  Builder:    ${G}${BUILDER:-none}${NC}"
echo -e "  Cheap:      ${G}${CHEAP:-none}${NC}"
echo -e "  Mode:       ${G}${FLEET_MODE}${NC}"
echo ""
echo -e "  ${DIM}foreman dispatch --task \"Fix the bug\"${NC}"
echo -e "  ${DIM}foreman fleet${NC}  ${DIM}# re-scan${NC}"
echo -e "  ${DIM}foreman init${NC}  ${DIM}# reconfigure${NC}"
echo ""