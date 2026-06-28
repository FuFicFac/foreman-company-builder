#!/usr/bin/env zsh
# foreman update — Check for updates to Foreman itself, modules, and external dependencies.
#
# Usage: foreman update                    # check all
#        foreman update --apply            # apply available updates
#        foreman update foreman            # check Foreman itself
#        foreman update modules            # check modules only
#        foreman update dependencies       # check external deps only

set -euo pipefail

CONFIG_DIR="${FOREMAN_CONFIG_DIR:-$HOME/.foreman}"
PROFILE_FILE="$CONFIG_DIR/profile.json"
MODULES_DIR="$CONFIG_DIR/modules"
REPO="FuFicFac/foreman-company-builder"
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
# Check external dependencies (GBrain, GStack, etc.)
# ──────────────────────────────────────────────
if [[ "$SCOPE" == "all" ]] || [[ "$SCOPE" == "dependencies" ]]; then
  echo -e "${B}Dependencies${NC}"

  DEPS_FILE="$(dirname "$0")/../config/dependencies.json"
  if [[ ! -f "$DEPS_FILE" ]]; then
    echo -e "  ${DIM}No dependencies config found.${NC}"
  else
    # Count dependencies
    DEP_COUNT=$(python3 -c "import json; print(len(json.load(open('$DEPS_FILE'))['dependencies']))" 2>/dev/null || echo "0")

    if [[ "$DEP_COUNT" == "0" ]]; then
      echo -e "  ${DIM}No dependencies configured.${NC}"
    else
      for i in $(seq 0 $((DEP_COUNT - 1))); do
        DEP_NAME=$(python3 -c "import json; print(json.load(open('$DEPS_FILE'))['dependencies'][$i]['name'])" 2>/dev/null || echo "unknown")
        DEP_REPO=$(python3 -c "import json; print(json.load(open('$DEPS_FILE'))['dependencies'][$i]['repo'])" 2>/dev/null || echo "")
        DEP_CHECK_CMD=$(python3 -c "import json; print(json.load(open('$DEPS_FILE'))['dependencies'][$i]['check_cmd'])" 2>/dev/null || echo "")
        DEP_INSTALL_CMD=$(python3 -c "import json; print(json.load(open('$DEPS_FILE'))['dependencies'][$i].get('install_cmd',''))" 2>/dev/null || echo "")
        DEP_REQUIRED=$(python3 -c "import json; print(json.load(open('$DEPS_FILE'))['dependencies'][$i].get('required', False))" 2>/dev/null || echo "False")

        # Check if installed locally
        LOCAL_VER=$(eval "$DEP_CHECK_CMD" 2>/dev/null || echo "not installed")

        # Get latest GitHub release/tag
        REMOTE_VER=$(curl -s "https://api.github.com/repos/${DEP_REPO}/releases/latest" 2>/dev/null | python3 -c "import json,sys; r=json.load(sys.stdin); print(r.get('tag_name',''))" 2>/dev/null || echo "")
        # Fall back to latest commit if no releases
        if [[ -z "$REMOTE_VER" ]] || [[ "$REMOTE_VER" == "null" ]]; then
          REMOTE_COMMIT=$(curl -s "https://api.github.com/repos/${DEP_REPO}/commits/main" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('sha','')[:8])" 2>/dev/null || echo "")
          REMOTE_VER="${REMOTE_COMMIT:-unknown}"
        fi

        # Format output
        if [[ "$LOCAL_VER" == "not installed" ]]; then
          if [[ "$DEP_REQUIRED" == "True" ]]; then
            echo -e "  ${R}✗${NC} ${BOLD}$DEP_NAME${NC} ${DIM}— required, not installed${NC}"
          else
            echo -e "  ${DIM}○ $DEP_NAME — not installed (optional)${NC}"
          fi
          if [[ -n "$DEP_INSTALL_CMD" ]]; then
            echo -e "    ${DIM}Install: $DEP_INSTALL_CMD${NC}"
          fi
        elif [[ "$REMOTE_VER" != "unknown" ]] && [[ "$LOCAL_VER" != "$REMOTE_VER" ]]; then
          echo -e "  ${Y}↑${NC} ${BOLD}$DEP_NAME${NC} ${DIM}$LOCAL_VER → $REMOTE_VER${NC}"
          if [[ "$APPLY" == "--apply" ]] && [[ -n "$DEP_INSTALL_CMD" ]]; then
            echo -e "    ${B}Updating $DEP_NAME...${NC}"
            eval "$DEP_INSTALL_CMD" 2>&1
            echo -e "    ${G}✓${NC} $DEP_NAME updated"
          else
            echo -e "    ${DIM}Run: foreman update dependencies --apply${NC}"
          fi
        else
          echo -e "  ${G}✓${NC} ${BOLD}$DEP_NAME${NC} ${DIM}$LOCAL_VER${NC}"
        fi
      done
    fi
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