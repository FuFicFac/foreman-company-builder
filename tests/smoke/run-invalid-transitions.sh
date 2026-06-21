#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export FOREMAN_CONFIG_DIR="$TMP/.foreman"

if "$ROOT/scripts/foreman-run.sh" status missing_run >/dev/null 2>&1; then
  echo "status missing_run should fail" >&2
  exit 1
fi

out="$("$ROOT/scripts/foreman-run.sh" start software --project app --stage test --task "Fix flaky test")"
run_id="$(printf '%s\n' "$out" | awk '/run_/ {print $NF; exit}')"

"$ROOT/scripts/foreman-run.sh" cancel "$run_id"

if "$ROOT/scripts/foreman-run.sh" pause "$run_id" >/dev/null 2>&1; then
  echo "pause cancelled run should fail" >&2
  exit 1
fi

if "$ROOT/scripts/foreman-run.sh" resume "$run_id" >/dev/null 2>&1; then
  echo "resume cancelled run should fail" >&2
  exit 1
fi

echo "invalid transition smoke passed"
