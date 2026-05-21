#!/usr/bin/env zsh
# foreman chat — Talk to Foreman's brain. Starts the conversational onboarding
# if no swarm template is loaded, otherwise runs an interactive session.
#
# Usage: foreman chat            # interactive chat with Foreman's brain
#        foreman chat --onboard  # force the "What are you?" onboarding

set -euo pipefail

CONFIG_DIR="${FOREMAN_CONFIG_DIR:-$HOME/.foreman}"
PROFILE_FILE="$CONFIG_DIR/profile.json"
MODULES_DIR="$CONFIG_DIR/modules"

G='\033[0;32m' R='\033[0;31m' Y='\033[1;33m' B='\033[0;34m' CYAN='\033[0;36m' BOLD='\033[1m' DIM='\033[2m' NC='\033[0m'

# Check profile exists
if [[ ! -f "$PROFILE_FILE" ]]; then
  echo -e "${R}No Foreman profile found. Run ${BOLD}foreman init${NC} first."
  exit 1
fi

FORCE_ONBOARD="${1:-}"

# Read brain config from profile
BRAIN_PROVIDER=$(python3 -c "import json; print(json.load(open('$PROFILE_FILE'))['brain']['provider'])" 2>/dev/null || echo "none")
BRAIN_MODEL=$(python3 -c "import json; print(json.load(open('$PROFILE_FILE'))['brain']['model'])" 2>/dev/null || echo "none")
BRAIN_KEY_ENV=$(python3 -c "import json; print(json.load(open('$PROFILE_FILE'))['brain'].get('key_env',''))" 2>/dev/null || echo "")

# Source secrets if available
[[ -f "$CONFIG_DIR/secrets.env" ]] && source "$CONFIG_DIR/secrets.env" 2>/dev/null

if [[ "$BRAIN_PROVIDER" == "none" ]] && [[ "$FORCE_ONBOARD" != "--onboard" ]]; then
  echo -e "${Y}⚠${NC} No brain configured. Onboarding can still save a company profile; chat requires ${BOLD}foreman init${NC}."
fi

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║         Foreman — Chat                       ║${NC}"
echo -e "${BOLD}║   Brain: ${CYAN}${BRAIN_PROVIDER}/${BRAIN_MODEL}${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""

# ──────────────────────────────────────────────
# Check if onboarding is needed
# ──────────────────────────────────────────────
HAS_TEMPLATE=false
LOADED_TEMPLATE=""

# Check if any module is installed
if [[ -d "$MODULES_DIR" ]] && [[ -n "$(ls -A "$MODULES_DIR" 2>/dev/null)" ]]; then
  HAS_TEMPLATE=true
  LOADED_TEMPLATE=$(ls "$MODULES_DIR" | head -1)
fi

if [[ "$FORCE_ONBOARD" == "--onboard" ]] || [[ "$HAS_TEMPLATE" == false ]]; then
  # ── Onboarding mode ──
  echo -e "${B}What kind of company are you building?${NC}"
  echo ""
  echo -e "  ${BOLD}1)${NC} Software / app development"
  echo -e "  ${BOLD}2)${NC} Creative writing / fiction / novels"
  echo -e "  ${BOLD}3)${NC} Publishing / books / direct sales"
  echo -e "  ${BOLD}4)${NC} YouTube / video production"
  echo -e "  ${BOLD}5)${NC} Marketing / content agency"
  echo -e "  ${BOLD}6)${NC} Physical product / e-commerce"
  echo -e "  ${BOLD}7)${NC} Something else (describe it)"
  echo ""
  echo -e "${BOLD}Choose [1-7]:${NC} \c"
  read -r CHOICE

  TEMPLATE=""
  case "$CHOICE" in
    1) TEMPLATE="software" ;;
    2) TEMPLATE="creative-writing" ;;
    3) TEMPLATE="publishing" ;;
    4) TEMPLATE="youtube" ;;
    5) TEMPLATE="marketing" ;;
    6) TEMPLATE="software" ;;  # Default to software for now
    7) TEMPLATE="" ;;
    *) TEMPLATE="" ;;
  esac

  # If "something else", ask the brain to figure it out
  if [[ -z "$TEMPLATE" ]]; then
    echo ""
    echo -e "${B}Describe your company in a sentence or two:${NC}"
    read -r DESCRIPTION
    echo ""
    echo -e "${DIM}Asking Foreman's brain to match your company to a template...${NC}"
    # TODO: send description to brain model, get recommendation
    # For now, default to software
    TEMPLATE="software"
    echo -e "${Y}⚠${NC} Custom template matching not yet implemented. Defaulting to software."
    echo -e "${DIM}You can install additional modules with: foreman module add <name>${NC}"
  fi

  # Install the template
  BUILTIN_DIR="$(dirname "$0")/../modules"
  if [[ -d "$BUILTIN_DIR/$TEMPLATE" ]]; then
    mkdir -p "$MODULES_DIR"
    cp -r "$BUILTIN_DIR/$TEMPLATE" "$MODULES_DIR/$TEMPLATE" 2>/dev/null || true
    echo ""
    echo -e "${G}✓${NC} Loaded swarm template: ${BOLD}$TEMPLATE${NC}"
  elif [[ -d "$MODULES_DIR/$TEMPLATE" ]]; then
    echo ""
    echo -e "${G}✓${NC} Swarm template ${BOLD}$TEMPLATE${NC} already installed"
  else
    echo ""
    echo -e "${Y}⚠${NC} Template ${BOLD}$TEMPLATE${NC} not found. Install it with: foreman module add $TEMPLATE"
  fi

  # Ask follow-up questions based on template
  echo ""
  echo -e "${B}A few more questions to set up your $TEMPLATE crew:${NC}"

  case "$TEMPLATE" in
    software)
      echo -e "  ${BOLD}Project name:${NC} \c"
      read -r PROJECT_NAME
      echo -e "  ${BOLD}Primary language (js/ts/py/go/rs):${NC} \c"
      read -r PRIMARY_LANG
      echo -e "  ${BOLD}Repo URL (if exists):${NC} \c"
      read -r REPO_URL
      # Save project context
      mkdir -p "$CONFIG_DIR"
      cat > "$CONFIG_DIR/project.json" << EOF
{
  "template": "$TEMPLATE",
  "name": "${PROJECT_NAME:-unnamed}",
  "language": "${PRIMARY_LANG:-js}",
  "repo": "${REPO_URL:-}",
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
      ;;
    creative-writing)
      echo -e "  ${BOLD}Project name (novel/story):${NC} \c"
      read -r PROJECT_NAME
      echo -e "  ${BOLD}Genre:${NC} \c"
      read -r GENRE
      echo -e "  ${BOLD}Current word count (if any):${NC} \c"
      read -r WORD_COUNT
      cat > "$CONFIG_DIR/project.json" << EOF
{
  "template": "$TEMPLATE",
  "name": "${PROJECT_NAME:-unnamed}",
  "genre": "${GENRE:-fiction}",
  "word_count": "${WORD_COUNT:-0}",
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
      ;;
    publishing)
      echo -e "  ${BOLD}Imprint / publishing company name:${NC} \c"
      read -r PROJECT_NAME
      echo -e "  ${BOLD}Publishing focus (fiction/nonfiction/comics/courses/mixed):${NC} \c"
      read -r PUBLISHING_FOCUS
      echo -e "  ${BOLD}Formats (epub/pdf/print/audio/serial):${NC} \c"
      read -r FORMATS
      echo -e "  ${BOLD}Sell direct from your own site? (yes/no):${NC} \c"
      read -r SELL_DIRECT
      echo -e "  ${BOLD}Storefront/payment tools (shopify/stripe/gumroad/etc):${NC} \c"
      read -r COMMERCE_TOOLS
      echo -e "  ${BOLD}Email marketing tools (klaviyo/mailchimp/beehiiv/etc):${NC} \c"
      read -r EMAIL_TOOLS
      echo -e "  ${BOLD}Human approval gates (pricing,publish,ads,refunds,email):${NC} \c"
      read -r APPROVAL_GATES
      cat > "$CONFIG_DIR/project.json" << EOF
{
  "template": "$TEMPLATE",
  "name": "${PROJECT_NAME:-unnamed}",
  "focus": "${PUBLISHING_FOCUS:-mixed}",
  "formats": "${FORMATS:-epub}",
  "selling_direct": "${SELL_DIRECT:-no}",
  "commerce_tools": "${COMMERCE_TOOLS:-}",
  "email_tools": "${EMAIL_TOOLS:-}",
  "approval_gates": "${APPROVAL_GATES:-pricing,publish,ads,refunds,email}",
  "capabilities": ["editorial", "metadata", "launch-operations", "digital-commerce", "email-marketing", "analytics", "customer-support"],
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
      ;;
    youtube)
      echo -e "  ${BOLD}Channel name:${NC} \c"
      read -r CHANNEL_NAME
      echo -e "  ${BOLD}Niche/topic:${NC} \c"
      read -r NICHE
      echo -e "  ${BOLD}Upload frequency (daily/weekly/biweekly):${NC} \c"
      read -r FREQUENCY
      cat > "$CONFIG_DIR/project.json" << EOF
{
  "template": "$TEMPLATE",
  "channel": "${CHANNEL_NAME:-unnamed}",
  "niche": "${NICHE:-general}",
  "frequency": "${FREQUENCY:-weekly}",
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
      ;;
    marketing)
      echo -e "  ${BOLD}Brand name:${NC} \c"
      read -r BRAND_NAME
      echo -e "  ${BOLD}Industry:${NC} \c"
      read -r INDUSTRY
      echo -e "  ${BOLD}Primary channel (email/social/ads):${NC} \c"
      read -r PRIMARY_CHANNEL
      cat > "$CONFIG_DIR/project.json" << EOF
{
  "template": "$TEMPLATE",
  "brand": "${BRAND_NAME:-unnamed}",
  "industry": "${INDUSTRY:-general}",
  "channel": "${PRIMARY_CHANNEL:-email}",
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
      ;;
  esac

  echo ""
  echo -e "${G}✓${NC} Project saved. Foreman knows you're a ${BOLD}$TEMPLATE${NC} company."
  echo ""

  # Now send the project context to the brain for a welcome message
  echo -e "${DIM}Booting Foreman's brain...${NC}"
  echo ""

  SYSTEM_PROMPT="You are Foreman, a get-shit-done agent that runs the crew for a ${TEMPLATE} company. You just finished onboarding. The company is: $(cat "$CONFIG_DIR/project.json" 2>/dev/null). Welcome the user briefly. Tell them what you can do for them. Be direct and warm. 2-3 sentences max."

  case "$BRAIN_PROVIDER" in
    openai)
      if command -v curl >/dev/null 2>&1 && [[ -n "${OPENAI_API_KEY:-}" ]]; then
        RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
          -H "Authorization: Bearer $OPENAI_API_KEY" \
          -H "Content-Type: application/json" \
          -d "{\"model\":\"$BRAIN_MODEL\",\"messages\":[{\"role\":\"system\",\"content\":\"$SYSTEM_PROMPT\"},{\"role\":\"user\",\"content\":\"Hi Foreman.\"}],\"max_tokens\":200}" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin)['choices'][0]['message']['content'])" 2>/dev/null || echo "Brain connected. Let's get to work.")
        echo -e "${CYAN}${RESPONSE}${NC}"
      fi
      ;;
    xai)
      if command -v curl >/dev/null 2>&1 && [[ -n "${XAI_API_KEY:-}" ]]; then
        RESPONSE=$(curl -s https://api.x.ai/v1/chat/completions \
          -H "Authorization: Bearer $XAI_API_KEY" \
          -H "Content-Type: application/json" \
          -d "{\"model\":\"$BRAIN_MODEL\",\"messages\":[{\"role\":\"system\",\"content\":\"$SYSTEM_PROMPT\"},{\"role\":\"user\",\"content\":\"Hi Foreman.\"}],\"max_tokens\":200}" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin)['choices'][0]['message']['content'])" 2>/dev/null || echo "Brain connected. Let's get to work.")
        echo -e "${CYAN}${RESPONSE}${NC}"
      fi
      ;;
    ollama)
      if command -v ollama >/dev/null 2>&1; then
        RESPONSE=$(ollama run "$BRAIN_MODEL" "$SYSTEM_PROMPT\n\nUser: Hi Foreman." 2>/dev/null | head -5 || echo "Brain connected. Let's get to work.")
        echo -e "${CYAN}${RESPONSE}${NC}"
      fi
      ;;
    *)
      echo -e "${CYAN}Foreman is ready. What would you like to work on?${NC}"
      ;;
  esac

  echo ""
  echo -e "${DIM}foreman dispatch --task \"Your task here\"${NC}"
  echo -e "${DIM}foreman issues add \"Something to track\"${NC}"
  echo ""

else
  # ── Normal chat mode ──
  if [[ "$BRAIN_PROVIDER" == "none" ]]; then
    echo -e "${R}No brain configured. Run ${BOLD}foreman init${NC} to set up a brain model, or use ${BOLD}foreman chat --onboard${NC} to save a company profile.${NC}"
    exit 1
  fi
  echo -e "${G}Template loaded:${NC} ${BOLD}$LOADED_TEMPLATE${NC}"
  echo -e "${DIM}Type your message and Foreman's brain will respond. Type 'exit' to quit.${NC}"
  echo ""

  # Interactive loop
  while true; do
    echo -e "${BOLD}You:${NC} \c"
    read -r USER_MSG
    [[ "$USER_MSG" == "exit" ]] || [[ "$USER_MSG" == "quit" ]] && break
    [[ -z "$USER_MSG" ]] && continue

    SYSTEM_PROMPT="You are Foreman, a get-shit-done agent that runs the crew for a company. You have a $LOADED_TEMPLATE swarm template loaded. Be concise, direct, and helpful. When the user describes a task, suggest how to dispatch it."

    case "$BRAIN_PROVIDER" in
      openai)
        if [[ -n "${OPENAI_API_KEY:-}" ]]; then
          RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
            -H "Authorization: Bearer $OPENAI_API_KEY" \
            -H "Content-Type: application/json" \
            -d "{\"model\":\"$BRAIN_MODEL\",\"messages\":[{\"role\":\"system\",\"content\":\"$SYSTEM_PROMPT\"},{\"role\":\"user\",\"content\":\"$USER_MSG\"}],\"max_tokens\":300}" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin)['choices'][0]['message']['content'])" 2>/dev/null || echo "(no response)")
          echo -e "${CYAN}Foreman:${NC} $RESPONSE"
        fi
        ;;
      xai)
        if [[ -n "${XAI_API_KEY:-}" ]]; then
          RESPONSE=$(curl -s https://api.x.ai/v1/chat/completions \
            -H "Authorization: Bearer $XAI_API_KEY" \
            -H "Content-Type: application/json" \
            -d "{\"model\":\"$BRAIN_MODEL\",\"messages\":[{\"role\":\"system\",\"content\":\"$SYSTEM_PROMPT\"},{\"role\":\"user\",\"content\":\"$USER_MSG\"}],\"max_tokens\":300}" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin)['choices'][0]['message']['content'])" 2>/dev/null || echo "(no response)")
          echo -e "${CYAN}Foreman:${NC} $RESPONSE"
        fi
        ;;
      ollama)
        if command -v ollama >/dev/null 2>&1; then
          RESPONSE=$(echo "$USER_MSG" | ollama run "$BRAIN_MODEL" "$SYSTEM_PROMPT" 2>/dev/null | head -10 || echo "(no response)")
          echo -e "${CYAN}Foreman:${NC} $RESPONSE"
        fi
        ;;
      *)
        echo -e "${DIM}(Brain provider not supported for chat yet)${NC}"
        ;;
    esac
    echo ""
  done
fi