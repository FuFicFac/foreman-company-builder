#!/usr/bin/env bash
# Foreman Fleet Check — discovers available CLI agents and models
set -euo pipefail

echo "╔══════════════════════════════════════════╗"
echo "║         Foreman Fleet Check             ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Check CLI availability
echo "=== CLI Providers ==="
found=0
for c in agent cursor-agent cursor claude codex hermes ollama; do
  if command -v "$c" >/dev/null 2>&1; then
    version=$("$c" --version 2>/dev/null | head -1 || echo "unknown")
    echo "  ✓ $c  ($version)"
    found=$((found + 1))
  else
    echo "  ✗ $c  (not found)"
  fi
done

echo ""
echo "Found $found provider(s)"

# Check model details
echo ""
echo "=== Cursor Composer Models ==="
if command -v agent >/dev/null 2>&1; then
  agent models 2>/dev/null | head -10 || echo "  (could not list models)"
else
  echo "  (Cursor Agent not installed)"
fi

echo ""
echo "=== Ollama Models ==="
if command -v ollama >/dev/null 2>&1; then
  ollama list 2>/dev/null | head -15 || echo "  (could not list models)"
else
  echo "  (Ollama not installed)"
fi

echo ""
echo "=== Paperclip ==="
if command -v npx >/dev/null 2>&1; then
  npx paperclipai doctor 2>/dev/null | head -10 || echo "  (Paperclip not configured)"
else
  echo "  (npx not available)"
fi

echo ""
echo "=== Role Assignment ==="
if [ "$found" -eq 0 ]; then
  echo "  ⚠ No agent CLIs found. Install at least one provider."
elif [ "$found" -eq 1 ]; then
  echo "  Single-provider mode — Foreman will use model tiers within your provider"
else
  echo "  Multi-provider mode — Foreman will route roles to best available provider"
fi