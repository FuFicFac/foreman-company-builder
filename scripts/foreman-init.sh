#!/usr/bin/env zsh
# foreman init — First-run setup: discover CLIs, API keys, assign roles, boot brain.
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
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' B='\033[0;34m' CYAN='\033[0;36m' BOLD='\033[1m' DIM='\033[2m' NC='\033[0m'

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║            Foreman — Init                   ║${NC}"
echo -e "${BOLD}║   Paperclip is the company.                  ║${NC}"
echo -e "${BOLD}║   Foreman runs the crew.                      ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""

# ──────────────────────────────────────────────
# STEP 1: Permission
# ──────────────────────────────────────────────
if [[ "$SKIP_PROMPTS" != "--yes" ]]; then
  echo -e "${B}Step 1: Permission${NC} ${DIM}Foreman scans for AI CLIs and API keys on this machine.${NC}"
  echo -e "${DIM}No files are modified outside ~/.foreman/. No projects are created.${NC}"
  echo ""
  echo -e "${BOLD}Allow scan?${NC} [y/N] \c"
  read -r CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${R}Cancelled.${NC}"; exit 0
  fi
  echo ""
fi

# ──────────────────────────────────────────────
# STEP 2: Discover CLIs
# ──────────────────────────────────────────────
echo -e "${B}Step 2: Discover CLIs${NC}"
echo ""

INSPECTOR="" INSPECTOR_CMD="" BUILDER="" BUILDER_CMD="" CHEAP="" CHEAP_CMD=""
FOUND=0
COMPOSER="" COMPOSER_FAST="" CLAUDE_PATH="" OLLAMA_STRONGEST=""

# Cursor Agent
if command -v agent >/dev/null 2>&1; then
  AGENT_PATH=$(command -v agent)
  AGENT_MODELS=$(agent models 2>/dev/null || true)
  COMPOSER=$(echo "$AGENT_MODELS" | grep -oiE 'composer-[0-9]+(\.[0-9]+)*(-[a-z0-9]+)?' | sort -V | tail -1 || true)
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
CODEX_PATH=""
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
  OLLAMA_STRONGEST=$(echo "$OLLAMA_LIST" | tail -n +2 | grep -oE '^[a-zA-Z0-9][a-zA-Z0-9._:-]+' | head -1 || true)
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

if [[ $FOUND -ge 2 ]]; then
  FLEET_MODE="multi-provider"
elif [[ $FOUND -eq 1 ]]; then
  FLEET_MODE="single-provider"
else
  FLEET_MODE="none"
fi

# ──────────────────────────────────────────────
# STEP 3: API Keys & Brain Selection
# ──────────────────────────────────────────────
echo -e "${B}Step 3: API Keys & Brain${NC} ${DIM}(Foreman needs a brain for orchestration and chat)${NC}"
echo ""

# Detect existing API keys
HAS_OPENAI=false HAS_XAI=false HAS_GOOGLE=false HAS_ANTHROPIC=false
OPENAI_KEY_VAL="" XAI_KEY_VAL="" GOOGLE_KEY_VAL="" ANTHROPIC_KEY_VAL=""

if [[ -n "${OPENAI_API_KEY:-}" ]]; then
  HAS_OPENAI=true; OPENAI_KEY_VAL="${OPENAI_API_KEY:0:8}...${OPENAI_API_KEY: -4}"
  echo -e "  ${G}✓${NC} ${BOLD}OpenAI${NC} ${DIM}(GPT-4o, GPT-5, o3 — key: $OPENAI_KEY_VAL)${NC}"
else
  echo -e "  ${DIM}  ○ OpenAI (not found — set OPENAI_API_KEY or paste below)${NC}"
fi

if [[ -n "${XAI_API_KEY:-}" ]]; then
  HAS_XAI=true; XAI_KEY_VAL="${XAI_API_KEY:0:8}...${XAI_API_KEY: -4}"
  echo -e "  ${G}✓${NC} ${BOLD}xAI / Grok${NC} ${DIM}(Grok 3 — key: $XAI_KEY_VAL)${NC}"
else
  echo -e "  ${DIM}  ○ xAI / Grok (not found — set XAI_API_KEY or paste below)${NC}"
fi

if [[ -n "${GOOGLE_API_KEY:-}" ]]; then
  HAS_GOOGLE=true; GOOGLE_KEY_VAL="${GOOGLE_API_KEY:0:8}...${GOOGLE_API_KEY: -4}"
  echo -e "  ${G}✓${NC} ${BOLD}Google / Gemini${NC} ${DIM}(key: $GOOGLE_KEY_VAL)${NC}"
else
  echo -e "  ${DIM}  ○ Google / Gemini (not found — set GOOGLE_API_KEY or paste below)${NC}"
fi

if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
  HAS_ANTHROPIC=true; ANTHROPIC_KEY_VAL="${ANTHROPIC_API_KEY:0:8}...${ANTHROPIC_API_KEY: -4}"
  echo -e "  ${G}✓${NC} ${BOLD}Anthropic / Claude${NC} ${DIM}(key: $ANTHROPIC_KEY_VAL)${NC}"
  echo -e "    ${Y}⚠${NC} ${DIM}Claude API is expensive for programmatic use — recommended only for inspection${NC}"
else
  echo -e "  ${DIM}  ○ Anthropic / Claude (not found — expensive for programmatic use)${NC}"
fi

echo ""

# Offer to paste missing keys
BRAIN_PROVIDER=""
BRAIN_MODEL=""
BRAIN_KEY_ENV=""

if [[ "$SKIP_PROMPTS" != "--yes" ]]; then
  # Let user paste keys for any provider that wasn't found
  if [[ "$HAS_OPENAI" == false ]]; then
    echo -e "${BOLD}Paste OpenAI API key?${NC} (or press Enter to skip) \c"
    read -r PASTE_KEY
    if [[ -n "$PASTE_KEY" ]]; then
      export OPENAI_API_KEY="$PASTE_KEY"
      HAS_OPENAI=true
      echo -e "  ${G}✓${NC} OpenAI key saved for this session"
    fi
  fi

  if [[ "$HAS_XAI" == false ]]; then
    echo -e "${BOLD}Paste xAI / Grok API key?${NC} (or press Enter to skip) \c"
    read -r PASTE_KEY
    if [[ -n "$PASTE_KEY" ]]; then
      export XAI_API_KEY="$PASTE_KEY"
      HAS_XAI=true
      echo -e "  ${G}✓${NC} xAI key saved for this session"
    fi
  fi

  if [[ "$HAS_GOOGLE" == false ]]; then
    echo -e "${BOLD}Paste Google / Gemini API key?${NC} (or press Enter to skip) \c"
    read -r PASTE_KEY
    if [[ -n "$PASTE_KEY" ]]; then
      export GOOGLE_API_KEY="$PASTE_KEY"
      HAS_GOOGLE=true
      echo -e "  ${G}✓${NC} Google key saved for this session"
    fi
  fi

  echo ""
  echo -e "${B}Choose Foreman's brain${NC} ${DIM}(used for orchestration, planning, and chat)${NC}"
  echo ""

  OPTIONS=()
  if [[ "$HAS_OPENAI" == true ]]; then
    OPTIONS+=("OpenAI (GPT-5.4 Mini — cheap, fast, great for orchestration)")
  fi
  if [[ "$HAS_XAI" == true ]]; then
    OPTIONS+=("xAI / Grok (Grok 3 — strong reasoning, good for planning)")
  fi
  if [[ "$HAS_GOOGLE" == true ]]; then
    OPTIONS+=("Google / Gemini (Gemini 2.5 Pro — strong reasoning)")
  fi
  if [[ "$HAS_ANTHROPIC" == true ]]; then
    OPTIONS+=("Anthropic / Claude (expensive — best for judgment only)")
  fi
  if [[ -n "$OLLAMA_STRONGEST" ]]; then
    OPTIONS+=("Ollama local ($OLLAMA_STRONGEST — free, private, no API key)")
  fi

  if [[ ${#OPTIONS[@]} -eq 0 ]]; then
    echo -e "  ${Y}⚠${NC} No API keys found and no local models available."
    echo -e "  ${DIM}Foreman will run in headless mode (no conversational brain).${NC}"
    BRAIN_PROVIDER="none"
  else
    for i in "${!OPTIONS[@]}"; do
      echo -e "  ${BOLD}$((i+1)))${NC} ${OPTIONS[$i]}"
    done
    echo ""
    echo -e "${BOLD}Which should Foreman use as its brain?${NC} [1-${#OPTIONS[@]}] \c"
    read -r BRAIN_CHOICE
    BRAIN_IDX=$((BRAIN_CHOICE - 1))

    if [[ "$HAS_OPENAI" == true ]] && [[ $BRAIN_IDX -eq 0 ]] 2>/dev/null; then
      BRAIN_PROVIDER="openai"; BRAIN_MODEL="gpt-5.4-mini"; BRAIN_KEY_ENV="OPENAI_API_KEY"
    elif [[ "$HAS_XAI" == true ]]; then
      # Calculate xAI index
      XAI_IDX=0
      [[ "$HAS_OPENAI" == true ]] && XAI_IDX=$((XAI_IDX + 1))
      if [[ $BRAIN_IDX -eq $XAI_IDX ]] 2>/dev/null; then
        BRAIN_PROVIDER="xai"; BRAIN_MODEL="grok-3"; BRAIN_KEY_ENV="XAI_API_KEY"
      fi
    elif [[ "$HAS_GOOGLE" == true ]]; then
      GOO_IDX=0
      [[ "$HAS_OPENAI" == true ]] && GOO_IDX=$((GOO_IDX + 1))
      [[ "$HAS_XAI" == true ]] && GOO_IDX=$((GOO_IDX + 1))
      if [[ $BRAIN_IDX -eq $GOO_IDX ]] 2>/dev/null; then
        BRAIN_PROVIDER="google"; BRAIN_MODEL="gemini-2.5-pro"; BRAIN_KEY_ENV="GOOGLE_API_KEY"
      fi
    fi

    # Default fallback
    if [[ -z "$BRAIN_PROVIDER" ]]; then
      if [[ "$HAS_OPENAI" == true ]]; then
        BRAIN_PROVIDER="openai"; BRAIN_MODEL="gpt-5.4-mini"; BRAIN_KEY_ENV="OPENAI_API_KEY"
      elif [[ "$HAS_XAI" == true ]]; then
        BRAIN_PROVIDER="xai"; BRAIN_MODEL="grok-3"; BRAIN_KEY_ENV="XAI_API_KEY"
      elif [[ "$HAS_GOOGLE" == true ]]; then
        BRAIN_PROVIDER="google"; BRAIN_MODEL="gemini-2.5-pro"; BRAIN_KEY_ENV="GOOGLE_API_KEY"
      elif [[ "$HAS_ANTHROPIC" == true ]]; then
        BRAIN_PROVIDER="anthropic"; BRAIN_MODEL="claude-sonnet-4-20250514"; BRAIN_KEY_ENV="ANTHROPIC_API_KEY"
      elif [[ -n "$OLLAMA_STRONGEST" ]]; then
        BRAIN_PROVIDER="ollama"; BRAIN_MODEL="$OLLAMA_STRONGEST"; BRAIN_KEY_ENV=""
      else
        BRAIN_PROVIDER="none"
      fi
    fi
  fi

  echo ""
  if [[ "$BRAIN_PROVIDER" != "none" ]]; then
    echo -e "  ${G}✓${NC} Foreman brain: ${BOLD}${BRAIN_PROVIDER}/${BRAIN_MODEL}${NC}"
  else
    echo -e "  ${Y}⚠${NC} No brain selected — Foreman will run in headless mode"
  fi
else
  # --yes mode: pick best available automatically
  if [[ "$HAS_OPENAI" == true ]]; then
    BRAIN_PROVIDER="openai"; BRAIN_MODEL="gpt-5.4-mini"; BRAIN_KEY_ENV="OPENAI_API_KEY"
  elif [[ "$HAS_XAI" == true ]]; then
    BRAIN_PROVIDER="xai"; BRAIN_MODEL="grok-3"; BRAIN_KEY_ENV="XAI_API_KEY"
  elif [[ "$HAS_GOOGLE" == true ]]; then
    BRAIN_PROVIDER="google"; BRAIN_MODEL="gemini-2.5-pro"; BRAIN_KEY_ENV="GOOGLE_API_KEY"
  elif [[ -n "$OLLAMA_STRONGEST" ]]; then
    BRAIN_PROVIDER="ollama"; BRAIN_MODEL="$OLLAMA_STRONGEST"; BRAIN_KEY_ENV=""
  else
    BRAIN_PROVIDER="none"
  fi
fi
echo ""

# ──────────────────────────────────────────────
# STEP 4: Role Assignments
# ──────────────────────────────────────────────
echo -e "${B}Step 4: Role assignments${NC} ${DIM}(based on your fleet)${NC}"
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
echo -e "  ${BOLD}Brain${NC}      (orchestration, chat): ${CYAN}${BRAIN_PROVIDER:-none}/${BRAIN_MODEL:-none}${NC}"
echo -e "  ${BOLD}Fleet${NC}      (mode):             ${G}${FLEET_MODE}${NC} (${FOUND} provider(s))"
echo ""

if [[ "$FLEET_MODE" == "none" ]]; then
  echo -e "${R}⚠ No CLIs found. Install at least one to use Foreman.${NC}"
  echo -e "${DIM}  Recommended: Cursor Agent (https://cursor.com) or Claude Code (https://claude.ai/code)${NC}"
  exit 1
fi

# ──────────────────────────────────────────────
# STEP 5: Service Discovery
# ──────────────────────────────────────────────
echo -e "${B}Step 5: Services${NC} ${DIM}(detect running platforms, register Foreman)${NC}"
echo ""

PAPERCLIP_URL="" PAPERCLIP_COMPANY="" OPENCLAW_DETECTED=false

# Paperclip — check common ports
PC_PORTS=(3100 3000 8080)
PC_FOUND=false
for port in "${PC_PORTS[@]}"; do
  if curl -s "http://127.0.0.1:$port/api/health" 2>/dev/null | grep -q "ok"; then
    PC_FOUND=true
    PAPERCLIP_URL="http://127.0.0.1:$port"
    PC_VER=$(curl -s "http://127.0.0.1:$port/api/health" 2>/dev/null | grep -o '"version":"[^"]*"' | cut -d'"' -f4 || echo "available")
    echo -e "  ${G}✓${NC} ${BOLD}Paperclip${NC} ${DIM}(running at $PAPERCLIP_URL, v$PC_VER)${NC}"
    break
  fi
done
if [[ "$PC_FOUND" == false ]]; then
  echo -e "  ${DIM}  ○ Paperclip (not running)${NC}"
fi

# OpenClaw — check for CLI + gateway
if command -v openclaw >/dev/null 2>&1; then
  OPENCLAW_DETECTED=true
  OC_VER=$(openclaw --version 2>/dev/null | head -1 || echo "available")
  echo -e "  ${G}✓${NC} ${BOLD}OpenClaw${NC} ${DIM}($OC_VER)${NC}"
  # Check for running agents
  OC_AGENTS=$(openclaw status 2>/dev/null | grep -c 'agent' || echo "0")
  [[ "$OC_AGENTS" -gt 0 ]] && echo -e "    ${DIM}$OC_AGENTS agent(s) detected${NC}"
else
  echo -e "  ${DIM}  ○ OpenClaw (not found)${NC}"
fi

# Telegram bots — check for common indicators
if [[ -d "$HOME/.openclaw" ]]; then
  TG_CONFIG=$(find "$HOME/.openclaw" -name 'config*' -maxdepth 1 2>/dev/null | head -1 || true)
  if [[ -n "$TG_CONFIG" ]]; then
    echo -e "  ${G}✓${NC} ${BOLD}OpenClaw config${NC} ${DIM}($TG_CONFIG)${NC}"
  fi
fi

echo ""

# Connect to Paperclip if found
if [[ "$PC_FOUND" == true ]] && [[ "$SKIP_PROMPTS" != "--yes" ]]; then
  echo -e "${BOLD}Register Foreman in Paperclip?${NC} [Y/n] \c"
  read -r PC_REG
  if [[ ! "$PC_REG" =~ ^[Nn]$ ]]; then
    # Get company list
    PC_COMPANIES=$(curl -s "${PAPERCLIP_URL}/api/companies" 2>/dev/null || true)
    if [[ -n "$PC_COMPANIES" ]]; then
      PC_FIRST_ID=$(echo "$PC_COMPANIES" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d[0]['id'] if d else '')" 2>/dev/null || true)
      if [[ -n "$PC_FIRST_ID" ]]; then
        # Register Foreman as an agent in Paperclip
        PC_RESULT=$(curl -s "${PAPERCLIP_URL}/api/companies/$PC_FIRST_ID/agents" \
          -X POST -H "Content-Type: application/json" \
          -d '{"name":"Foreman","role":"pm"}' 2>/dev/null || true)
        PC_AGENT_ID=$(echo "$PC_RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('id',''))" 2>/dev/null || true)
        if [[ -n "$PC_AGENT_ID" ]]; then
          PAPERCLIP_URL="$PAPERCLIP_URL"
          PAPERCLIP_COMPANY="$PC_FIRST_ID"
          echo -e "  ${G}✓${NC} Foreman registered as agent in Paperclip (role: pm, id: ${PC_AGENT_ID:0:8}...)"
        else
          echo -e "  ${Y}⚠${NC} Could not register in Paperclip"
        fi
      fi
    else
      echo -e "  ${Y}⚠${NC} No Paperclip companies found. Run `paperclipai onboard` first."
    fi
  fi
elif [[ "$PC_FOUND" == true ]] && [[ "$SKIP_PROMPTS" == "--yes" ]]; then
  # Auto-register in --yes mode
  PC_COMPANIES=$(curl -s "${PAPERCLIP_URL}/api/companies" 2>/dev/null || true)
  PC_FIRST_ID=$(echo "$PC_COMPANIES" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d[0]['id'] if d else '')" 2>/dev/null || true)
  if [[ -n "$PC_FIRST_ID" ]]; then
    PC_RESULT=$(curl -s "${PAPERCLIP_URL}/api/companies/$PC_FIRST_ID/agents" \
      -X POST -H "Content-Type: application/json" \
      -d '{"name":"Foreman","role":"pm"}' 2>/dev/null || true)
    PC_AGENT_ID=$(echo "$PC_RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('id',''))" 2>/dev/null || true)
    if [[ -n "$PC_AGENT_ID" ]]; then
      PAPERCLIP_URL="$PAPERCLIP_URL"
      PAPERCLIP_COMPANY="$PC_FIRST_ID"
      echo -e "  ${G}✓${NC} Foreman auto-registered in Paperclip (role: pm, id: ${PC_AGENT_ID:0:8}...)"
    fi
  fi
fi

# Register with OpenClaw if found
if [[ "$OPENCLAW_DETECTED" == true ]] && [[ "$SKIP_PROMPTS" != "--yes" ]]; then
  echo -e "${BOLD}Register Foreman with OpenClaw?${NC} [Y/n] \c"
  read -r OC_REG
  if [[ ! "$OC_REG" =~ ^[Nn]$ ]]; then
    echo -e "  ${G}✓${NC} Foreman detected OpenClaw. Install script will be generated for OpenClaw integration."
    # Create a skill installation note
    mkdir -p "$CONFIG_DIR"
    echo "# Foreman can be installed as an OpenClaw skill" >> "$CONFIG_DIR/openclaw-integration.md"
    echo "Run: openclaw skill install foreman" >> "$CONFIG_DIR/openclaw-integration.md"
  fi
elif [[ "$OPENCLAW_DETECTED" == true ]] && [[ "$SKIP_PROMPTS" == "--yes" ]]; then
  mkdir -p "$CONFIG_DIR"
  echo -e "  ${G}✓${NC} OpenClaw detected. Integration note saved."
  echo "# Foreman can be installed as an OpenClaw skill" > "$CONFIG_DIR/openclaw-integration.md"
  echo "Run: openclaw skill install foreman" > "$CONFIG_DIR/openclaw-integration.md"
fi
echo ""

# ──────────────────────────────────────────────
# STEP 6: Save Profile
# ──────────────────────────────────────────────
mkdir -p "$CONFIG_DIR"

# Build brain config
BRAIN_JSON=""
if [[ "$BRAIN_PROVIDER" == "none" ]]; then
  BRAIN_JSON='{ "provider": "none", "model": "none", "key_env": "" }'
else
  BRAIN_JSON="{ \"provider\": \"$BRAIN_PROVIDER\", \"model\": \"$BRAIN_MODEL\", \"key_env\": \"${BRAIN_KEY_ENV:-}\" }"
fi

cat > "$PROFILE_FILE" << EOF
{
  "version": "0.2.0",
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "fleet_mode": "$FLEET_MODE",
  "roles": {
    "inspector": { "name": "${INSPECTOR:-none}", "command": "${INSPECTOR_CMD:-}" },
    "builder":   { "name": "${BUILDER:-none}",   "command": "${BUILDER_CMD:-}" },
    "cheap":     { "name": "${CHEAP:-none}",     "command": "${CHEAP_CMD:-}" }
  },
  "brain": $BRAIN_JSON,
  "paperclip": { "url": "${PAPERCLIP_URL}", "company_id": "${PAPERCLIP_COMPANY}" }
}
EOF

echo -e "${G}✓${NC} Profile saved to ${DIM}$PROFILE_FILE${NC}"

# Save keys to a gitignored secrets file (not the profile itself)
SECRETS_FILE="$CONFIG_DIR/secrets.env"
cat > "$SECRETS_FILE" << EOF
# Foreman API keys — DO NOT COMMIT
# Generated by foreman init on $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

[[ -n "${OPENAI_API_KEY:-}" ]] && echo "export OPENAI_API_KEY=\"\$OPENAI_API_KEY\"" >> "$SECRETS_FILE"
[[ -n "${XAI_API_KEY:-}" ]] && echo "export XAI_API_KEY=\"\$XAI_API_KEY\"" >> "$SECRETS_FILE"
[[ -n "${GOOGLE_API_KEY:-}" ]] && echo "export GOOGLE_API_KEY=\"\$GOOGLE_API_KEY\"" >> "$SECRETS_FILE"
[[ -n "${ANTHROPIC_API_KEY:-}" ]] && echo "export ANTHROPIC_API_KEY=\"\$ANTHROPIC_API_KEY\"" >> "$SECRETS_FILE"

chmod 600 "$SECRETS_FILE"
echo -e "${G}✓${NC} API key references saved to ${DIM}$SECRETS_FILE${NC} ${DIM}(gitignored, chmod 600)${NC}"
echo ""

# ──────────────────────────────────────────────
# Done
# ──────────────────────────────────────────────
echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║         Foreman is ready.                    ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Inspector:  ${G}${INSPECTOR:-none}${NC}"
echo -e "  Builder:    ${G}${BUILDER:-none}${NC}"
echo -e "  Cheap:      ${G}${CHEAP:-none}${NC}"
echo -e "  Brain:      ${CYAN}${BRAIN_PROVIDER:-none}/${BRAIN_MODEL:-none}${NC}"
echo -e "  Mode:       ${G}${FLEET_MODE}${NC}"
echo ""
echo -e "  ${DIM}foreman dispatch --task \"Fix the bug\"${NC}"
echo -e "  ${DIM}foreman fleet${NC}  ${DIM}# re-scan${NC}"
echo -e "  ${DIM}foreman init${NC}  ${DIM}# reconfigure${NC}"
echo -e "  ${DIM}foreman chat${NC}  ${DIM}# talk to the brain${NC}"
echo ""