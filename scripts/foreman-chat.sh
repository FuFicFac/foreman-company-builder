#!/bin/zsh
# foreman chat — Talk to Foreman's brain. Starts the AI-driven conversational
# onboarding if no swarm template is loaded, otherwise runs an interactive session.
#
# Usage: foreman chat            # interactive chat with Foreman's brain
#        foreman chat --onboard  # force the onboarding conversation

set -euo pipefail

CONFIG_DIR="${FOREMAN_CONFIG_DIR:-$HOME/.foreman}"
PROFILE_FILE="$CONFIG_DIR/profile.json"
MODULES_DIR="$CONFIG_DIR/modules"
REPO_ROOT="$(dirname "$0")/.."
COMPOSE_SCRIPT="$REPO_ROOT/scripts/compose-company-from-departments.py"
BRAIN_SCRIPT="$REPO_ROOT/scripts/foreman-brain.py"
CATALOG_FILE="$REPO_ROOT/modules/departments/catalog.json"

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
  #
  # AI-driven: the brain boots first, conducts a natural conversation, determines
  # the company type from what the person describes, asks the right follow-up
  # questions, and signals completion by emitting a JSON block prefixed with
  # "FCB_ONBOARD_RESULT:".
  #
  # The JSON must contain:
  #   company_type: one of the 6 FCB catalog types
  #   template: a builtin module slug to install (software, creative-writing,
  #             publishing, youtube, marketing) — or empty if no template fits
  #   name: the company/project name
  #   details: an object with any type-specific context the AI gathered
  #
  # If no brain is configured, fall back to a guided 6-type menu that asks
  # the right questions per type — never defaults to software.

  COMPANY_TYPES="software physical_product local_service creator publishing education_community"
  BUILTIN_TEMPLATES="software creative-writing publishing youtube marketing"

  # Build a summary of available company types and templates for the system prompt
  CATALOG_SUMMARY=""
  if [[ -f "$CATALOG_FILE" ]]; then
    CATALOG_SUMMARY=$(python3 -c "
import json
with open('$CATALOG_FILE') as f:
    cat = json.load(f)
print('Company types:')
for ct in cat.get('company_types', []):
    depts = cat.get('default_department_sets', {}).get(ct, [])
    print(f'  - {ct} ({len(depts)} departments)')
print()
print('Builtin swarm templates: software, creative-writing, publishing, youtube, marketing')
print()
print('Department catalog has', len(cat.get('departments', [])), 'departments across', len(cat.get('capabilities', [])), 'capabilities.')
" 2>/dev/null || echo "Company types: software, physical_product, local_service, creator, publishing, education_community")
  else
    CATALOG_SUMMARY="Company types: software, physical_product, local_service, creator, publishing, education_community
Builtin swarm templates: software, creative-writing, publishing, youtube, marketing"
  fi

  if [[ "$BRAIN_PROVIDER" != "none" ]]; then
    # ── AI-driven onboarding ──
    CONV_HISTORY=$(mktemp)
    trap 'rm -f "$CONV_HISTORY"' EXIT

    ONBOARD_SYSTEM_PROMPT="You are Foreman, the onboarding agent for the Foreman Company Builder. You're talking to someone who wants to build a company with AI agents.

Your job: have a natural conversation to understand what kind of company they're building, gather the key details, and then signal completion.

Available company types (you MUST pick exactly one):
- software — SaaS, apps, dev tools, platforms
- physical_product — e-commerce, physical goods, product businesses
- local_service — service businesses, agencies, local operations
- creator — YouTube, content, media, personal brand
- publishing — books, direct sales, imprint
- education_community — courses, communities, education

Builtin swarm templates you can assign: software, creative-writing, publishing, youtube, marketing
If none of these templates fit the company type, leave template empty — the department composition will still run.

${CATALOG_SUMMARY}

Instructions:
1. Ask what they're building. Let them describe it naturally.
2. Based on their description, determine the company type. Don't ask them to pick from a list — you figure it out.
3. Ask 2-4 follow-up questions that matter for THAT company type. For example:
   - software: project name, primary language, repo URL
   - physical_product: product name, what they sell, sales channel
   - local_service: business name, service type, service area
   - creator: channel name, niche, content frequency
   - publishing: imprint name, formats, storefront tools
   - education_community: community name, platform, topic
4. Once you have enough, ask if they're ready for you to set up the company.
5. When ready (or when they say yes), emit EXACTLY this on its own line:
FCB_ONBOARD_RESULT: {\"company_type\":\"<type>\",\"template\":\"<template-or-empty>\",\"name\":\"<name>\",\"details\":{<type-specific fields>}}

Do not put the JSON in a code block. Put it on a single line starting with FCB_ONBOARD_RESULT: 
Before that line, give a brief friendly summary of what you understood and what you're setting up.
Keep the conversation warm, concise, and practical. No more than 5-6 exchanges total."

    echo -e "${B}Foreman here. What are you building?${NC}"
    echo ""

    ONBOARD_DONE=false
    ONBOARD_RESULT=""

    while [[ "$ONBOARD_DONE" == false ]]; do
      echo -e "${BOLD}You:${NC} \c"
      read -r USER_MSG
      [[ -z "$USER_MSG" ]] && continue

      # Call brain
      RESPONSE=$(python3 "$BRAIN_SCRIPT" \
        --provider "$BRAIN_PROVIDER" \
        --model "$BRAIN_MODEL" \
        --system-prompt "$ONBOARD_SYSTEM_PROMPT" \
        --history "$CONV_HISTORY" \
        --user-msg "$USER_MSG" 2>/dev/null || echo "(brain connection failed)")

      # Check for completion marker
      if echo "$RESPONSE" | grep -q "FCB_ONBOARD_RESULT:"; then
        # Extract the JSON line
        ONBOARD_RESULT=$(echo "$RESPONSE" | grep "FCB_ONBOARD_RESULT:" | sed 's/FCB_ONBOARD_RESULT://' | head -1 | tr -d '\r')
        # Print everything before the marker
        echo "$RESPONSE" | sed '/FCB_ONBOARD_RESULT:/,$d' | while IFS= read -r line; do
          echo -e "${CYAN}Foreman:${NC} $line"
        done
        ONBOARD_DONE=true
      else
        echo -e "${CYAN}Foreman:${NC} $RESPONSE"
      fi
      echo ""
    done

    # Parse the result
    if [[ -n "$ONBOARD_RESULT" ]]; then
      COMPANY_TYPE=$(echo "$ONBOARD_RESULT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('company_type',''))" 2>/dev/null || echo "")
      TEMPLATE=$(echo "$ONBOARD_RESULT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('template',''))" 2>/dev/null || echo "")
      PROJECT_NAME=$(echo "$ONBOARD_RESULT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('name','unnamed'))" 2>/dev/null || echo "unnamed")
      DETAILS_JSON=$(echo "$ONBOARD_RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin).get('details',{}); print(json.dumps(d))" 2>/dev/null || echo "{}")
    else
      echo -e "${R}Could not parse onboarding result. Please try again.${NC}"
      exit 1
    fi

  else
    # ── No-brain fallback: guided 6-type menu ──
    # Each type gets its own questions. No defaults to software.
    echo -e "${B}What kind of company are you building?${NC}"
    echo ""
    echo -e "  ${BOLD}1)${NC} Software / app / SaaS"
    echo -e "  ${BOLD}2)${NC} Physical product / e-commerce"
    echo -e "  ${BOLD}3)${NC} Local service / agency"
    echo -e "  ${BOLD}4)${NC} Creator / media / content"
    echo -e "  ${BOLD}5)${NC} Publishing / books / imprint"
    echo -e "  ${BOLD}6)${NC} Education / community"
    echo ""
    echo -e "${BOLD}Choose [1-6]:${NC} \c"
    read -r CHOICE

    TEMPLATE=""
    COMPANY_TYPE=""
    PROJECT_NAME="unnamed"
    DETAILS_JSON="{}"

    case "$CHOICE" in
      1)
        COMPANY_TYPE="software"; TEMPLATE="software"
        echo -e "  ${BOLD}Project name:${NC} \c"; read -r PROJECT_NAME
        echo -e "  ${BOLD}Primary language (js/ts/py/go/rs):${NC} \c"; read -r PRIMARY_LANG
        echo -e "  ${BOLD}Repo URL (if exists):${NC} \c"; read -r REPO_URL
        DETAILS_JSON=$(python3 -c "import json; print(json.dumps({'language':'${PRIMARY_LANG:-js}','repo':'${REPO_URL:-}'}))")
        ;;
      2)
        COMPANY_TYPE="physical_product"; TEMPLATE=""
        echo -e "  ${BOLD}Product/company name:${NC} \c"; read -r PROJECT_NAME
        echo -e "  ${BOLD}What do you sell?${NC} \c"; read -r PRODUCT_DESC
        echo -e "  ${BOLD}Sales channel (shopify/stripe/gumroad/own-site):${NC} \c"; read -r SALES_CHANNEL
        echo -e "  ${BOLD}Inventory type (made-to-order/stocked/dropship):${NC} \c"; read -r INVENTORY_TYPE
        DETAILS_JSON=$(python3 -c "import json; print(json.dumps({'product_description':'${PRODUCT_DESC:-}','sales_channel':'${SALES_CHANNEL:-}','inventory_type':'${INVENTORY_TYPE:-}'}))")
        ;;
      3)
        COMPANY_TYPE="local_service"; TEMPLATE="marketing"
        echo -e "  ${BOLD}Business name:${NC} \c"; read -r PROJECT_NAME
        echo -e "  ${BOLD}Service type:${NC} \c"; read -r SERVICE_TYPE
        echo -e "  ${BOLD}Service area (city/region/online):${NC} \c"; read -r SERVICE_AREA
        echo -e "  ${BOLD}Primary channel (email/social/ads/referrals):${NC} \c"; read -r PRIMARY_CHANNEL
        DETAILS_JSON=$(python3 -c "import json; print(json.dumps({'service_type':'${SERVICE_TYPE:-}','service_area':'${SERVICE_AREA:-}','primary_channel':'${PRIMARY_CHANNEL:-}'}))")
        ;;
      4)
        COMPANY_TYPE="creator"; TEMPLATE="youtube"
        echo -e "  ${BOLD}Channel/brand name:${NC} \c"; read -r PROJECT_NAME
        echo -e "  ${BOLD}Niche/topic:${NC} \c"; read -r NICHE
        echo -e "  ${BOLD}Content format (video/written/podcast/mixed):${NC} \c"; read -r CONTENT_FORMAT
        echo -e "  ${BOLD}Upload frequency (daily/weekly/biweekly):${NC} \c"; read -r FREQUENCY
        DETAILS_JSON=$(python3 -c "import json; print(json.dumps({'niche':'${NICHE:-general}','content_format':'${CONTENT_FORMAT:-video}','frequency':'${FREQUENCY:-weekly}'}))")
        ;;
      5)
        COMPANY_TYPE="publishing"; TEMPLATE="publishing"
        echo -e "  ${BOLD}Imprint/publishing company name:${NC} \c"; read -r PROJECT_NAME
        echo -e "  ${BOLD}Publishing focus (fiction/nonfiction/comics/courses/mixed):${NC} \c"; read -r PUBLISHING_FOCUS
        echo -e "  ${BOLD}Formats (epub/pdf/print/audio/serial):${NC} \c"; read -r FORMATS
        echo -e "  ${BOLD}Sell direct? (yes/no):${NC} \c"; read -r SELL_DIRECT
        echo -e "  ${BOLD}Storefront/payment tools:${NC} \c"; read -r COMMERCE_TOOLS
        echo -e "  ${BOLD}Email marketing tools:${NC} \c"; read -r EMAIL_TOOLS
        echo -e "  ${BOLD}Human approval gates (pricing,publish,ads,refunds,email):${NC} \c"; read -r APPROVAL_GATES
        DETAILS_JSON=$(python3 -c "import json; print(json.dumps({'focus':'${PUBLISHING_FOCUS:-mixed}','formats':'${FORMATS:-epub}','selling_direct':'${SELL_DIRECT:-no}','commerce_tools':'${COMMERCE_TOOLS:-}','email_tools':'${EMAIL_TOOLS:-}','approval_gates':'${APPROVAL_GATES:-pricing,publish,ads,refunds,email}','capabilities':['editorial','metadata','launch-operations','digital-commerce','email-marketing','analytics','customer-support']}))")
        ;;
      6)
        COMPANY_TYPE="education_community"; TEMPLATE=""
        echo -e "  ${BOLD}Community/course name:${NC} \c"; read -r PROJECT_NAME
        echo -e "  ${BOLD}Topic/subject:${NC} \c"; read -r TOPIC
        echo -e "  ${BOLD}Platform (skool/circle/mighty-networks/discord/own):${NC} \c"; read -r PLATFORM
        echo -e "  ${BOLD}Model (free-tier/paid-membership/one-time/cohort):${NC} \c"; read -r MODEL_TYPE
        DETAILS_JSON=$(python3 -c "import json; print(json.dumps({'topic':'${TOPIC:-general}','platform':'${PLATFORM:-}','model':'${MODEL_TYPE:-paid-membership}'}))")
        ;;
      *)
        echo -e "${R}Invalid choice. Please run foreman chat --onboard again.${NC}"
        exit 1
        ;;
    esac
  fi

  # ── Common: install template, save project, compose departments ──

  # Install the template (if one was determined)
  BUILTIN_DIR="$(dirname "$0")/../modules"
  if [[ -n "$TEMPLATE" ]] && [[ -d "$BUILTIN_DIR/$TEMPLATE" ]]; then
    mkdir -p "$MODULES_DIR"
    cp -r "$BUILTIN_DIR/$TEMPLATE" "$MODULES_DIR/$TEMPLATE" 2>/dev/null || true
    echo ""
    echo -e "${G}✓${NC} Loaded swarm template: ${BOLD}$TEMPLATE${NC}"
  elif [[ -n "$TEMPLATE" ]] && [[ -d "$MODULES_DIR/$TEMPLATE" ]]; then
    echo ""
    echo -e "${G}✓${NC} Swarm template ${BOLD}$TEMPLATE${NC} already installed"
  elif [[ -n "$TEMPLATE" ]]; then
    echo ""
    echo -e "${Y}⚠${NC} Template ${BOLD}$TEMPLATE${NC} not found. Install it with: foreman module add $TEMPLATE"
  else
    echo ""
    echo -e "${DIM}No swarm template needed — departments will be composed from the catalog.${NC}"
  fi

  # Save project context (merge type-specific details from AI or menu)
  mkdir -p "$CONFIG_DIR"
  python3 - "$CONFIG_DIR/project.json" "$TEMPLATE" "$COMPANY_TYPE" "$PROJECT_NAME" "$DETAILS_JSON" <<'PY'
import json, sys
from datetime import datetime, timezone

path, template, company_type, name, details_json = sys.argv[1:6]
details = json.loads(details_json)

project = {
    "template": template or company_type,
    "company_type": company_type,
    "name": name,
    "created": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
}
# Merge in type-specific details as top-level keys
project.update(details)

# If the file already exists, preserve existing fields
try:
    with open(path) as f:
        existing = json.load(f)
    existing.update(project)
    project = existing
except (FileNotFoundError, json.JSONDecodeError):
    pass

with open(path, "w") as f:
    json.dump(project, f, indent=2)
    f.write("\n")
PY

  # Compose departments into project.json (FCB universal company builder)
  if [[ -f "$COMPOSE_SCRIPT" ]] && [[ -n "$COMPANY_TYPE" ]]; then
    COMPOSED="$(python3 "$COMPOSE_SCRIPT" --company-type "$COMPANY_TYPE" --template "$TEMPLATE" --name "$PROJECT_NAME")"
    python3 - "$CONFIG_DIR/project.json" "$COMPOSED" <<'PY'
import json, sys
from datetime import datetime, timezone

path, composed_raw = sys.argv[1], sys.argv[2]
composed = json.loads(composed_raw)
existing = {}
try:
    with open(path) as fh:
        existing = json.load(fh)
except FileNotFoundError:
    pass
existing.update(composed)
existing.setdefault("created", datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))
with open(path, "w") as fh:
    json.dump(existing, fh, indent=2)
    fh.write("\n")
PY
    DEPT_COUNT="$(python3 -c "import json; print(len(json.load(open('$CONFIG_DIR/project.json')).get('departments',[])))")"
    echo ""
    echo -e "${G}✓${NC} Composed ${BOLD}${DEPT_COUNT}${NC} departments for company type ${BOLD}${COMPANY_TYPE}${NC}."
  fi

  echo ""
  echo -e "${G}✓${NC} Project saved. Foreman knows you're a ${BOLD}${COMPANY_TYPE}${NC} company${TEMPLATE:+ (template: ${BOLD}${TEMPLATE}${NC})}."
  echo ""

  # Send project context to the brain for a welcome message
  if [[ "$BRAIN_PROVIDER" != "none" ]]; then
    echo -e "${DIM}Booting Foreman's brain...${NC}"
    echo ""

    SYSTEM_PROMPT="You are Foreman, a get-shit-done agent that runs the crew for a ${COMPANY_TYPE} company. You just finished onboarding. The company is: $(cat "$CONFIG_DIR/project.json" 2>/dev/null). Welcome the user briefly. Tell them what you can do for them. Be direct and warm. 2-3 sentences max."

    case "$BRAIN_PROVIDER" in
      openai)
        if command -v curl >/dev/null 2>&1 && [[ -n "${OPENAI_API_KEY:-}" ]]; then
          RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
            -H "Authorization: Bearer ${OPENAI_API_KEY}" \
            -H "Content-Type: application/json" \
            -d "{\"model\":\"$BRAIN_MODEL\",\"messages\":[{\"role\":\"system\",\"content\":\"$SYSTEM_PROMPT\"},{\"role\":\"user\",\"content\":\"Hi Foreman.\"}],\"max_tokens\":200}" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin)['choices'][0]['message']['content'])" 2>/dev/null || echo "Brain connected. Let's get to work.")
          echo -e "${CYAN}${RESPONSE}${NC}"
        fi
        ;;
      xai)
        if command -v curl >/dev/null 2>&1 && [[ -n "${XAI_API_KEY:-}" ]]; then
          RESPONSE=$(curl -s https://api.x.ai/v1/chat/completions \
            -H "Authorization: Bearer ${XAI_API_KEY}" \
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
  else
    echo -e "${CYAN}Foreman is ready. Run ${BOLD}foreman init${NC} to configure a brain for interactive chat.${NC}"
  fi

  echo ""
  echo -e "${DIM}foreman dispatch --task \"Your task here\"${NC}"
  echo -e "${DIM}foreman blast \"Your task here\"${NC}  # zero-friction entry${NC}"
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
            -H "Authorization: Bearer ${OPENAI_API_KEY}" \
            -H "Content-Type: application/json" \
            -d "{\"model\":\"$BRAIN_MODEL\",\"messages\":[{\"role\":\"system\",\"content\":\"$SYSTEM_PROMPT\"},{\"role\":\"user\",\"content\":\"$USER_MSG\"}],\"max_tokens\":300}" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin)['choices'][0]['message']['content'])" 2>/dev/null || echo "(no response)")
          echo -e "${CYAN}Foreman:${NC} $RESPONSE"
        fi
        ;;
      xai)
        if [[ -n "${XAI_API_KEY:-}" ]]; then
          RESPONSE=$(curl -s https://api.x.ai/v1/chat/completions \
            -H "Authorization: Bearer ${XAI_API_KEY}" \
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