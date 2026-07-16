#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FOREMAN="$ROOT/scripts/foreman"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "qa role smoke"

python3 - "$ROOT" <<'PY'
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
expected = {
    "creative-writing": ["Voice consistency", "Name swaps", "Timeline continuity", "Tone drift", "Plot holes"],
    "software": ["Tests pass", "Lint clean", "Types check"],
    "marketing": ["Claim accuracy", "CTA presence", "Audience fit", "Brand voice"],
    "youtube": ["Hook strength", "Retention structure", "Metadata completeness", "Thumbnail/title match"],
}

for template, checklist in expected.items():
    manifest = json.loads((root / "modules" / template / "module.json").read_text())
    roles = manifest.get("qa_roles", [])
    assert roles, f"{template}: qa role missing"
    assert all(role.get("type") == "qa" for role in roles), f"{template}: qa role type missing"
    actual = [item for role in roles for item in role.get("checklist", [])]
    assert actual == checklist, f"{template}: checklist mismatch: {actual!r}"
    print(f"  ✓ {template}: qa role loads with {len(actual)} checks")
PY

DRY_OUT="$($FOREMAN blast "Create launch campaign copy" \
  --template marketing --dir "$TMP/project" --dry-run 2>&1)"

grep -qF "Loop mode: lean" <<<"$DRY_OUT"
grep -qF "QA gate:   QA Reviewer" <<<"$DRY_OUT"
for check in "Claim accuracy" "CTA presence" "Audience fit" "Brand voice"; do
  grep -qF -- "- $check" <<<"$DRY_OUT"
done
grep -qF "[DRY RUN] No pipeline started" <<<"$DRY_OUT"

echo "  ✓ Lean Blast dry run fires the QA Reviewer checklist"
echo "qa role smoke passed"
