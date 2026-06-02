#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

PROJECT="$TMPDIR/patreon-pilot"

"$ROOT/scripts/foreman" lph new "$PROJECT" \
  --title "Patreon Pilot" \
  --stage "partial draft" \
  --mode hermes \
  --goal "book project map" > "$TMPDIR/new.out"

grep -q "Created Little Publishing House workspace" "$TMPDIR/new.out"
test -f "$PROJECT/README.md"
test -f "$PROJECT/foreman-lph.json"
test -d "$PROJECT/drafts"
test -d "$PROJECT/assets"
test -d "$PROJECT/heartbeats"
test -d "$PROJECT/outputs"

grep -q "Patreon Pilot" "$PROJECT/README.md"
grep -q '"mode": "hermes"' "$PROJECT/foreman-lph.json"

"$ROOT/scripts/foreman" lph doctor "$PROJECT" > "$TMPDIR/doctor.out"
grep -q "Little Publishing House doctor: OK" "$TMPDIR/doctor.out"
grep -q "Patreon Pilot" "$TMPDIR/doctor.out"

"$ROOT/scripts/foreman" company little-publishing-house heartbeat "$PROJECT" > "$TMPDIR/heartbeat.out"
grep -q "Little Publishing House Heartbeat" "$TMPDIR/heartbeat.out"
grep -q "book project map" "$TMPDIR/heartbeat.out"

printf 'lph cli smoke: ok\n'
