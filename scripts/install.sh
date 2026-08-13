#!/usr/bin/env zsh
# Foreman installer — run with: curl -fsSL https://raw.githubusercontent.com/FuFicFac/foreman-company-builder/main/scripts/install.sh | zsh
# Vanity URL (get.foreman.dev) is coming soon — use the raw GitHub URL for now.

set -euo pipefail

REPO="FuFicFac/foreman-company-builder"
BRANCH="main"
INSTALL_DIR="${FOREMAN_INSTALL_DIR:-$HOME/.foreman}"

R='\033[0;31m' G='\033[0;32m' B='\033[0;34m' BOLD='\033[1m' DIM='\033[2m' NC='\033[0m'
REPO_URL="${FOREMAN_REPO_URL:-https://github.com/${REPO}.git}"

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  Foreman Company Builder — Installer         ║${NC}"
echo -e "${BOLD}║   Paperclip is the company.                  ║${NC}"
echo -e "${BOLD}║   Foreman runs the crew.                      ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""

# Check for git
if ! command -v git >/dev/null 2>&1; then
  echo -e "${R}✗ git is required. Install it first.${NC}"
  exit 1
fi

# Clone or update. A config-only ~/.foreman is common from an older install;
# preserve it beside the checkout instead of asking git to clone into it.
clone_target="${INSTALL_DIR}.clone.$$"
while [[ -e "$clone_target" ]]; do
  clone_target="${INSTALL_DIR}.clone.$RANDOM"
done

if [[ -d "$INSTALL_DIR/.git" ]]; then
  echo -e "${B}Updating Foreman...${NC}"
  cd "$INSTALL_DIR" && git pull origin "$BRANCH" 2>&1
elif [[ -e "$INSTALL_DIR" ]]; then
  backup_dir="${INSTALL_DIR}.backup-$(date +%Y%m%d%H%M%S)"
  backup_number=1
  while [[ -e "$backup_dir" ]]; do
    backup_dir="${INSTALL_DIR}.backup-$(date +%Y%m%d%H%M%S)-$backup_number"
    backup_number=$((backup_number + 1))
  done
  echo -e "${B}Preserving existing Foreman data in ${DIM}$backup_dir${NC}"
  mv "$INSTALL_DIR" "$backup_dir"
  if ! git clone --depth 1 -b "$BRANCH" "$REPO_URL" "$clone_target" 2>&1; then
    mv "$backup_dir" "$INSTALL_DIR"
    [[ -e "$clone_target" ]] && rm -rf "$clone_target"
    echo -e "${R}✗ Could not install Foreman; existing data was restored.${NC}" >&2
    exit 1
  fi
  mv "$clone_target" "$INSTALL_DIR"
  # Restore runtime state without overwriting the freshly cloned product.
  for state_file in profile.json fleet.json runs.json issues.json secrets.env openclaw-integration.md; do
    if [[ -f "$backup_dir/$state_file" ]]; then
      cp -p "$backup_dir/$state_file" "$INSTALL_DIR/$state_file"
    fi
  done
  echo -e "${G}✓${NC} Existing runtime state preserved; full backup remains at ${DIM}$backup_dir${NC}"
else
  echo -e "${B}Installing Foreman...${NC}"
  mkdir -p "$(dirname "$INSTALL_DIR")"
  if ! git clone --depth 1 -b "$BRANCH" "$REPO_URL" "$clone_target" 2>&1; then
    [[ -e "$clone_target" ]] && rm -rf "$clone_target"
    echo -e "${R}✗ Could not install Foreman.${NC}" >&2
    exit 1
  fi
  mv "$clone_target" "$INSTALL_DIR"
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
