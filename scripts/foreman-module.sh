#!/usr/bin/env zsh
# foreman module — Manage swarm templates and community modules.
#
# Usage:
#   foreman module list              # show installed modules
#   foreman module add <name>        # add a module from registry
#   foreman module remove <name>    # remove a module
#   foreman module search <query>   # search community modules on GitHub
#   foreman module update           # check for updates to all modules
#   foreman module update <name>    # update one module

set -euo pipefail

CONFIG_DIR="${FOREMAN_CONFIG_DIR:-$HOME/.foreman}"
MODULES_DIR="$CONFIG_DIR/modules"
REGISTRY_URL="https://raw.githubusercontent.com/FuFicFac/foreman-modules/main/registry.json"
PROFILE_FILE="$CONFIG_DIR/profile.json"

# Colors
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' B='\033[0;34m' BOLD='\033[1m' DIM='\033[2m' NC='\033[0m'

ACTION="${1:-list}"
TARGET="${2:-}"

mkdir -p "$MODULES_DIR"

case "$ACTION" in
  list)
    echo -e "${B}Installed Foreman Modules${NC}"
    echo ""
    if [[ -z "$(ls -A "$MODULES_DIR" 2>/dev/null)" ]]; then
      echo -e "  ${DIM}No modules installed yet.${NC}"
      echo -e "  ${DIM}foreman module add software${NC}"
      echo -e "  ${DIM}foreman module search \"creative writing\"${NC}"
    else
      for mod in "$MODULES_DIR"/*/; do
        MOD_NAME=$(basename "$mod")
        MOD_VER=$(cat "$mod/module.json" 2>/dev/null | grep -o '"version": *"[^"]*"' | head -1 | cut -d'"' -f4 || echo "unknown")
        MOD_DESC=$(cat "$mod/module.json" 2>/dev/null | grep -o '"description": *"[^"]*"' | head -1 | cut -d'"' -f4 || echo "")
        echo -e "  ${G}●${NC} ${BOLD}${MOD_NAME}${NC} ${DIM}v${MOD_VER}${NC}"
        [[ -n "$MOD_DESC" ]] && echo -e "    ${DIM}$MOD_DESC${NC}"
      done
    fi
    echo ""
    ;;

  add)
    if [[ -z "$TARGET" ]]; then
      echo -e "${R}Usage: foreman module add <name>${NC}"
      echo -e "${DIM}  Built-in: software, creative-writing, youtube, marketing${NC}"
      echo -e "${DIM}  GitHub:   foreman module add github:user/repo${NC}"
      exit 1
    fi

    # Built-in modules shipped with Foreman
    BUILTIN_DIR="$(dirname "$0")/../modules"

    if [[ -d "$BUILTIN_DIR/$TARGET" ]]; then
      # Copy from built-in
      cp -r "$BUILTIN_DIR/$TARGET" "$MODULES_DIR/$TARGET"
      MOD_DESC=$(cat "$MODULES_DIR/$TARGET/module.json" 2>/dev/null | grep -o '"description": *"[^"]*"' | head -1 | cut -d'"' -f4 || echo "")
      echo -e "${G}✓${NC} Added built-in module: ${BOLD}$TARGET${NC}"
      [[ -n "$MOD_DESC" ]] && echo -e "  ${DIM}$MOD_DESC${NC}"
    
    elif [[ "$TARGET" == github:* ]]; then
      # GitHub repo module
      REPO="${TARGET#github:}"
      echo -e "${B}Installing from GitHub: ${REPO}${NC}"
      if command -v git >/dev/null 2>&1; then
        MOD_NAME=$(basename "$REPO" | sed 's/\.git$//')
        git clone --depth 1 "https://github.com/${REPO}.git" "$MODULES_DIR/$MOD_NAME" 2>&1
        if [[ $? -eq 0 ]]; then
          rm -rf "$MODULES_DIR/$MOD_NAME/.git"
          echo -e "${G}✓${NC} Added GitHub module: ${BOLD}$MOD_NAME${NC}"
        else
          echo -e "${R}✗${NC} Could not clone ${REPO}"
          rm -rf "$MODULES_DIR/$MOD_NAME" 2>/dev/null
          exit 1
        fi
      else
        echo -e "${R}✗${NC} git is required for GitHub modules"
        exit 1
      fi

    else
      # Try the registry
      echo -e "${B}Looking up '${TARGET}' in module registry...${NC}"
      REGISTRY=$(curl -s "$REGISTRY_URL" 2>/dev/null || true)
      if [[ -n "$REGISTRY" ]]; then
        MATCH=$(echo "$REGISTRY" | grep "\"$TARGET\"" || true)
        if [[ -n "$MATCH" ]]; then
          SOURCE=$(echo "$MATCH" | grep -o '"source": *"[^"]*"' | head -1 | cut -d'"' -f4 || true)
          if [[ -n "$SOURCE" ]]; then
            echo -e "${G}✓${NC} Found in registry. Installing..."
            exec "$0" add "$SOURCE"
          fi
        else
          echo -e "${R}✗${NC} Module '${TARGET}' not found in registry"
          exit 1
        fi
      else
        echo -e "${Y}⚠${NC} Could not reach module registry"
        exit 1
      fi
    fi
    ;;

  remove)
    if [[ -z "$TARGET" ]]; then
      echo -e "${R}Usage: foreman module remove <name>${NC}"; exit 1
    fi
    if [[ -d "$MODULES_DIR/$TARGET" ]]; then
      rm -rf "$MODULES_DIR/$TARGET"
      echo -e "${G}✓${NC} Removed module: ${BOLD}$TARGET${NC}"
    else
      echo -e "${R}✗${NC} Module '${TARGET}' not found"
      exit 1
    fi
    ;;

  search)
    QUERY="${TARGET:-}"
    if [[ -z "$QUERY" ]]; then
      echo -e "${R}Usage: foreman module search <query>${NC}"; exit 1
    fi
    echo -e "${B}Searching for '${QUERY}'...${NC}"
    echo ""

    # Search built-in modules
    BUILTIN_DIR="$(dirname "$0")/../modules"
    if [[ -d "$BUILTIN_DIR" ]]; then
      for mod in "$BUILTIN_DIR"/*/; do
        MOD_NAME=$(basename "$mod")
        MOD_DESC=$(cat "$mod/module.json" 2>/dev/null | grep -o '"description": *"[^"]*"' | head -1 | cut -d'"' -f4 || echo "")
        if echo "$MOD_NAME $MOD_DESC" | grep -qi "$QUERY"; then
          echo -e "  ${G}●${NC} ${BOLD}${MOD_NAME}${NC} ${DIM}(built-in)${NC}"
          [[ -n "$MOD_DESC" ]] && echo -e "    ${DIM}$MOD_DESC${NC}"
        fi
      done
    fi

    # Search installed modules
    for mod in "$MODULES_DIR"/*/; do
      MOD_NAME=$(basename "$mod")
      MOD_DESC=$(cat "$mod/module.json" 2>/dev/null | grep -o '"description": *"[^"]*"' | head -1 | cut -d'"' -f4 || echo "")
      if echo "$MOD_NAME $MOD_DESC" | grep -qi "$QUERY"; then
        MOD_VER=$(cat "$mod/module.json" 2>/dev/null | grep -o '"version": *"[^"]*"' | head -1 | cut -d'"' -f4 || echo "unknown")
        echo -e "  ${G}●${NC} ${BOLD}${MOD_NAME}${NC} ${DIM}v${MOD_VER} (installed)${NC}"
        [[ -n "$MOD_DESC" ]] && echo -e "    ${DIM}$MOD_DESC${NC}"
      fi
    done

    # Search GitHub
    echo ""
    echo -e "${B}GitHub results${NC} ${DIM}(foreman module add github:user/repo to install)${NC}"
    if command -v gh >/dev/null 2>&1; then
      GH_RESULTS=$(gh search repos "foreman-module $QUERY" --limit 5 --json fullName,description,stargazersCount 2>/dev/null || true)
      if [[ -n "$GH_RESULTS" ]]; then
        echo "$GH_RESULTS" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for r in data:
    print(f'  ● {r[\"fullName\"]}  ⭐{r[\"stargazersCount\"]}  — {r.get(\"description\",\"\")}')
" 2>/dev/null || true
      fi
    else
      echo -e "  ${DIM}Install gh CLI for GitHub search: brew install gh${NC}"
    fi
    echo ""
    ;;

  update)
    TARGET="${2:-all}"
    echo -e "${B}Checking for module updates...${NC}"
    echo ""

    for mod in "$MODULES_DIR"/*/; do
      MOD_NAME=$(basename "$mod")
      SOURCE=$(cat "$mod/module.json" 2>/dev/null | grep -o '"source": *"[^"]*"' | head -1 | cut -d'"' -f4 || echo "")

      if [[ "$SOURCE" == github:* ]]; then
        REPO="${SOURCE#github:}"
        echo -e "  ${BOLD}$MOD_NAME${NC} ${DIM}($REPO)${NC}"
        # Compare local version with remote
        REMOTE_VER=$(curl -s "https://raw.githubusercontent.com/${REPO}/main/module.json" 2>/dev/null | grep -o '"version": *"[^"]*"' | head -1 | cut -d'"' -f4 || echo "unknown")
        LOCAL_VER=$(cat "$mod/module.json" 2>/dev/null | grep -o '"version": *"[^"]*"' | head -1 | cut -d'"' -f4 || echo "unknown")
        if [[ "$REMOTE_VER" != "$LOCAL_VER" ]] && [[ "$REMOTE_VER" != "unknown" ]]; then
          echo -e "    ${Y}↑${NC} Update available: ${DIM}${LOCAL_VER} → ${REMOTE_VER}${NC}"
          if [[ "$1" == "--apply" ]] || [[ "${3:-}" == "--apply" ]]; then
            echo -e "    ${B}Updating...${NC}"
            rm -rf "$MODULES_DIR/$MOD_NAME"
            git clone --depth 1 "https://github.com/${REPO}.git" "$MODULES_DIR/$MOD_NAME" 2>&1
            rm -rf "$MODULES_DIR/$MOD_NAME/.git"
            echo -e "    ${G}✓${NC} Updated to ${REMOTE_VER}"
          else
            echo -e "    ${DIM}Run: foreman module update $MOD_NAME --apply${NC}"
          fi
        else
          echo -e "    ${G}✓${NC} Up to date (${LOCAL_VER})"
        fi
      else
        echo -e "  ${BOLD}$MOD_NAME${NC} ${DIM}(built-in or local — check manually)${NC}"
      fi
    done
    echo ""
    ;;

  *)
    echo -e "${R}Unknown action: $ACTION${NC}"
    echo -e "${DIM}Usage: foreman module [list|add|remove|search|update]${NC}"
    exit 1
    ;;
esac