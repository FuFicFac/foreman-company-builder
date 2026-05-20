#!/usr/bin/env zsh
# foreman update — Check for updates to Foreman itself and installed modules.
#
# Usage: foreman update              # check all
#        foreman update --apply      # apply available updates
#        foreman update foreman      # check Foreman itself
#        foreman update modules      # check modules only

set -euo pipefail

CONFIG_DIR="${FOREMAN_CONFIG_DIR:-$HOME/.foreman}"
PROFILE_FILE="$CONFIG_DIR/profile.json"
MODULES_DIR="$CONFIG_DIR/modules"
REPO="FuFicFac/foreman-company-runner"
BRANCH="main"

G='\033[0;32m' R='\033[0;31m' Y='\033[1;33m' B='\033[0;34m' BOLD='\033[1m' DIM='\033[2m' NC='\033[0m'

SCOPE="${1:-all}"
APPLY="${2:-}"

echo ""
echo -e "${B}Foreman — Update Check${NC}"
echo ""

# ──────────────────────────────────────────────
# Check Foreman itself
# ──────────────────────────────────────────────
if [[ "$SCOPE" == "all" ]] || [[ "$SCOPE" == "foreman" ]]; then
  echo -e "${B}Foreman core${NC}"

  # Get local version
  LOCAL_VER=$(python3 -c "import json; print(json.load(open('$PROFILE_FILE'))['version'])" 2>/dev/null || echo "unknown")

  # Get remote version
  REMOTE_VER=$(curl -s "https://raw.githubusercontent.com/${REPO}/${BRANCH}/package.json" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('version','unknown'))" 2>/dev/null || echo "unknown")

  # Also check latest commit
  REMOTE_COMMIT=$(curl -s "https://api.github.com/repos/${REPO}/commits/${BRANCH}" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('sha','unknown')[:8])" 2>/dev/null || echo "unknown")

  LOCAL_COMMIT=$(cd "$(dirname "$0")/.." && git rev-parse --short HEAD 2>/dev/null || echo "unknown")

  if [[ "$REMOTE_COMMIT" != "unknown" ]] && [[ "$LOCAL_COMMIT" != "unknown" ]] && [[ "$REMOTE_COMMIT" != "$LOCAL_COMMIT" ]]; then
    echo -e "  ${Y}↑${NC} Update available: ${DIM}local ${LOCAL_COMMIT} → remote ${REMOTE_COMMIT}${NC}"
    if [[ "$APPLY" == "--apply" ]]; then
      echo -e "  ${B}Updating Foreman...${NC}"
      cd "$(dirname "$0")/.." && git pull origin "$BRANCH" 2>&1
      echo -e "  ${G}✓${NC} Foreman updated to ${REMOTE_COMMIT}"
    else
      echo -e "  ${DIM}Run: foreman update foreman --apply${NC}"
    fi
  else
    echo -e "  ${G}✓${NC} Up to date (${LOCAL_COMMIT})"
  fi
  echo ""
fi

# ──────────────────────────────────────────────
# Check modules
# ──────────────────────────────────────────────
if [[ "$SCOPE" == "all" ]] || [[ "$SCOPE" == "modules" ]]; then
  echo -e "${B}Modules${NC}"

  if [[ ! -d "$MODULES_DIR" ]] || [[ -z "$(ls -A "$MODULES_DIR" 2>/dev/null)" ]]; then
    echo -e "  ${DIM}No modules installed.${NC}"
  else
    for mod in "$MODULES_DIR"/*/; do
      MOD_NAME=$(basename "$mod")
      LOCAL_VER=$(cat "$mod/module.json" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('version','unknown'))" 2>/dev/null || echo "unknown")
      SOURCE=$(cat "$mod/module.json" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('source','built-in'))" 2>/dev/null || echo "unknown")

      if [[ "$SOURCE" == github:* ]]; then
        REPO_PATH="${SOURCE#github:}"
        REMOTE_VER=$(curl -s "https://raw.githubusercontent.com/${REPO_PATH}/main/module.json" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('version','unknown'))" 2>/dev/null || echo "unknown")

        if [[ "$REMOTE_VER" != "$LOCAL_VER" ]] && [[ "$REMOTE_VER" != "unknown" ]]; then
          echo -e "  ${Y}↑${NC} ${BOLD}$MOD_NAME${NC} ${DIM}${LOCAL_VER} → ${REMOTE_VER}${NC}"
          if [[ "$APPLY" == "--apply" ]]; then
            echo -e "    ${B}Updating...${NC}"
            rm -rf "$MODULES_DIR/$MOD_NAME"
            git clone --depth 1 "https://github.com/${REPO_PATH}.git" "$MODULES_DIR/$MOD_NAME" 2>&1
            rm -rf "$MODULES_DIR/$MOD_NAME/.git"
            echo -e "    ${G}✓${NC} Updated to ${REMOTE_VER}"
          else
            echo -e "    ${DIM}Run: foreman update modules --apply${NC}"
          fi
        else
          echo -e "  ${G}✓${NC} ${BOLD}$MOD_NAME${NC} ${DIM}v${LOCAL_VER}${NC}"
        fi
      else
        # Built-in module — check against repo version
        BUILTIN_DIR="$(dirname "$0")/../modules"
        if [[ -d "$BUILTIN_DIR/$MOD_NAME" ]]; then
          BUILTIN_VER=$(cat "$BUILTIN_DIR/$MOD_NAME/module.json" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('version','unknown'))" 2>/dev/null || echo "unknown")
          if [[ "$BUILTIN_VER" != "$LOCAL_VER" ]] && [[ "$BUILTIN_VER" != "unknown" ]]; then
            echo -e "  ${Y}↑${NC} ${BOLD}$MOD_NAME${NC} ${DIM}${LOCAL_VER} → ${BUILTIN_VER} (built-in)${NC}"
            if [[ "$APPLY" == "--apply" ]]; then
              cp -r "$BUILTIN_DIR/$MOD_NAME" "$MODULES_DIR/$MOD_NAME"
              echo -e "    ${G}✓${NC} Updated to ${BUILTIN_VER}"
            fi
          else
            echo -e "  ${G}✓${NC} ${BOLD}$MOD_NAME${NC} ${DIM}v${LOCAL_VER} (built-in)${NC}"
          fi
        else
          echo -e "  ${G}✓${NC} ${BOLD}$MOD_NAME${NC} ${DIM}v${LOCAL_VER} (local)${NC}"
        fi
      fi
    done
  fi
  echo ""
fi

# ──────────────────────────────────────────────
# Check Paperclip
# ──────────────────────────────────────────────
PAPERCLIP_URL=$(python3 -c "import json; print(json.load(open('$PROFILE_FILE'))['paperclip'].get('url',''))" 2>/dev/null || echo "")
if [[ -n "$PAPERCLIP_URL" ]]; then
  if curl -s "${PAPERCLIP_URL}/api/health" 2>/dev/null | grep -q "ok"; then
    PC_VER=$(curl -s "${PAPERCLIP_URL}/api/health" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('version','unknown'))" 2>/dev/null || echo "unknown")
    echo -e "${B}Paperclip${NC}  ${G}✓${NC} ${DIM}v${PC_VER} running${NC}"
  else
    echo -e "${B}Paperclip${NC}  ${Y}⚠${NC} ${DIM}not reachable at $PAPERCLIP_URL${NC}"
  fi
else
  echo -e "${B}Paperclip${NC}  ${DIM}not connected${NC}"
fi
echo ""

if [[ "$APPLY" != "--apply" ]]; then
  echo -e "${DIM}Run ${BOLD}foreman update --apply${NC} ${DIM}to install available updates.${NC}"
  echo ""
fi