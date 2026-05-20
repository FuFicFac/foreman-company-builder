#!/usr/bin/env zsh
# Foreman installer — run with: curl -fsSL https://get.foreman.dev | zsh
# Or: curl -fsSL https://raw.githubusercontent.com/FuFicFac/foreman-company-runner/main/scripts/install.sh | zsh

set -euo pipefail

REPO="FuFicFac/foreman-company-runner"
BRANCH="main"
INSTALL_DIR="${FOREMAN_INSTALL_DIR:-$HOME/.foreman}"

G='\033[0;32m' B='\033[0;34m' BOLD='\033[1m' DIM='\033[2m' NC='\033[0m'

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║         Foreman — Installer                  ║${NC}"
echo -e "${BOLD}║   Paperclip is the company.                  ║${NC}"
echo -e "${BOLD}║   Foreman runs the crew.                      ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""

# Check for git
if ! command -v git >/dev/null 2>&1; then
  echo -e "${R}✗ git is required. Install it first.${NC}"
  exit 1
fi

# Clone or update
if [[ -d "$INSTALL_DIR/.git" ]]; then
  echo -e "${B}Updating Foreman...${NC}"
  cd "$INSTALL_DIR" && git pull origin "$BRANCH" 2>&1
else
  echo -e "${B}Installing Foreman...${NC}"
  git clone --depth 1 -b "$BRANCH" "https://github.com/${REPO}.git" "$INSTALL_DIR" 2>&1
fi

# Make scripts executable
chmod +x "$INSTALL_DIR/scripts/"*.sh 2>/dev/null || true

# Add to PATH if not already there
SHELL_RC=""
if [[ -f "$HOME/.zshrc" ]]; then SHELL_RC="$HOME/.zshrc"
elif [[ -f "$HOME/.bashrc" ]]; then SHELL_RC="$HOME/.bashrc"
fi

PATH_LINE='export PATH="$HOME/.foreman/scripts:$PATH"'
if [[ -n "$SHELL_RC" ]] && ! grep -q "foreman/scripts" "$SHELL_RC" 2>/dev/null; then
  echo "" >> "$SHELL_RC"
  echo "# Foreman CLI" >> "$SHELL_RC"
  echo "$PATH_LINE" >> "$SHELL_RC"
  echo -e "${G}✓${NC} Added Foreman to PATH in ${SHELL_RC}"
else
  echo -e "${DIM}Foreman scripts already in PATH${NC}"
fi

echo ""
echo -e "${G}✓${NC} Foreman installed to ${DIM}$INSTALL_DIR${NC}"
echo ""
echo -e "  ${BOLD}Next:${NC} Run ${B}foreman init${NC} to set up your fleet"
echo -e "  ${DIM}source $SHELL_RC  # or restart your terminal${NC}"
echo ""