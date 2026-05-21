#!/usr/bin/env zsh
# foreman tools — Printing Press tool supply-chain helpers.
#
# Usage:
#   foreman tools doctor
#   foreman tools list
#   foreman tools search <query>
#   foreman tools install <name> [name...]
#   foreman tools manifest <module-name>

set -euo pipefail

CONFIG_DIR="${FOREMAN_CONFIG_DIR:-$HOME/.foreman}"
MODULES_DIR="$CONFIG_DIR/modules"
REPO_MODULES_DIR="$(dirname "$0")/../modules"

G='\033[0;32m' R='\033[0;31m' Y='\033[1;33m' B='\033[0;34m' BOLD='\033[1m' DIM='\033[2m' NC='\033[0m'

ACTION="${1:-doctor}"
shift || true

pp() {
  npx -y @mvanhorn/printing-press "$@"
}

ensure_go_bin_path() {
  local go_bin="${GOBIN:-$HOME/go/bin}"
  case ":$PATH:" in
    *":$go_bin:"*) ;;
    *) export PATH="$go_bin:$PATH" ;;
  esac
}

require_printing_press() {
  if ! command -v npx >/dev/null 2>&1; then
    echo -e "${R}✗ npx is required for Printing Press.${NC}"
    exit 1
  fi
}

module_file() {
  local name="$1"
  if [[ -f "$MODULES_DIR/$name/module.json" ]]; then
    echo "$MODULES_DIR/$name/module.json"
  elif [[ -f "$REPO_MODULES_DIR/$name/module.json" ]]; then
    echo "$REPO_MODULES_DIR/$name/module.json"
  else
    return 1
  fi
}

case "$ACTION" in
  doctor)
    require_printing_press
    echo -e "${B}Foreman Tool Supply Chain Doctor${NC}"
    echo ""

    if command -v go >/dev/null 2>&1; then
      echo -e "  ${G}✓${NC} Go: ${DIM}$(go version)${NC}"
    else
      echo -e "  ${Y}⚠${NC} Go not found. Printing Press binary installs require Go."
      echo -e "    ${DIM}macOS: brew install go${NC}"
    fi

    if command -v npx >/dev/null 2>&1; then
      echo -e "  ${G}✓${NC} npx: ${DIM}$(npm --version 2>/dev/null || echo available)${NC}"
    else
      echo -e "  ${R}✗${NC} npx not found. Install Node/npm first."
    fi

    ensure_go_bin_path
    echo -e "  ${G}✓${NC} Go bin path checked: ${DIM}${GOBIN:-$HOME/go/bin}${NC}"
    echo ""
    pp list 2>/dev/null || true
    ;;

  list)
    require_printing_press
    ensure_go_bin_path
    pp list
    ;;

  search)
    require_printing_press
    QUERY="${1:-}"
    if [[ -z "$QUERY" ]]; then
      echo -e "${R}Usage: foreman tools search <query>${NC}"
      exit 1
    fi
    pp search "$QUERY"
    ;;

  install)
    require_printing_press
    if [[ $# -eq 0 ]]; then
      echo -e "${R}Usage: foreman tools install <name> [name...]${NC}"
      exit 1
    fi
    ensure_go_bin_path
    if ! command -v go >/dev/null 2>&1; then
      echo -e "${R}✗ Go is required to install Printing Press CLI binaries.${NC}"
      echo -e "${DIM}Install it with: brew install go${NC}"
      exit 1
    fi
    pp install "$@" --cli-only
    echo ""
    echo -e "${G}✓${NC} Install attempted. Verifying installed tools:"
    pp list
    ;;

  manifest)
    NAME="${1:-}"
    if [[ -z "$NAME" ]]; then
      echo -e "${R}Usage: foreman tools manifest <module-name>${NC}"
      exit 1
    fi
    FILE="$(module_file "$NAME" || true)"
    if [[ -z "${FILE:-}" ]]; then
      echo -e "${R}✗ Module not found: $NAME${NC}"
      exit 1
    fi
    python3 - "$FILE" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path))
print(f"Module: {data.get('name')} v{data.get('version')}")
print(f"Description: {data.get('description','')}")
print("\nCapabilities:")
for cap in data.get('capabilities', []):
    print(f"  - {cap}")
print("\nTool manifest:")
manifest = data.get('tool_manifest', {})
if not manifest:
    print("  (none declared)")
for cap, tools in manifest.items():
    print(f"  {cap}:")
    for tool in tools:
        print(f"    - {tool}")
PY
    ;;

  *)
    echo -e "${R}Unknown action: $ACTION${NC}"
    echo -e "${DIM}Usage: foreman tools [doctor|list|search|install|manifest]${NC}"
    exit 1
    ;;
esac
