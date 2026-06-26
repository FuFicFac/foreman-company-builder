#!/bin/zsh
# foreman-heartbeat.sh — cron/launchd-friendly wrapper for `foreman lph heartbeat`
#
# Reads the run ledger at $FOREMAN_CONFIG_DIR/runs.json (default ~/.foreman/runs.json)
# and prints a heartbeat report on stdout. Safe to run unattended.
#
# Usage:
#   ./scripts/foreman-heartbeat.sh           # report from run ledger only
#   ./scripts/foreman-heartbeat.sh <proj>    # also include project manifest context
#
# Env:
#   FOREMAN_CONFIG_DIR  — override config directory (default ~/.foreman)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

exec python3 "$SCRIPT_DIR/foreman-lph.py" heartbeat "$@"