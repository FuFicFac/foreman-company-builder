#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export FOREMAN_CONFIG_DIR="$TMP/.foreman"

FIXTURE="$ROOT/examples/press/demo-json-tool"
MANIFEST="$TMP/demo.manifest.json"

PROPOSE_OUT="$($ROOT/scripts/foreman press propose \
  --id com.printingpress.demo-json-tool \
  --name "Demo JSON Tool" \
  --description "Safe read-only demo CLI that emits JSON." \
  --binary "$FIXTURE" \
  --command-name lookup \
  --smoke-args "lookup --city Austin" \
  --expected-output-path '$.city' \
  --tag demo \
  --tag read-only)"

printf '%s\n' "$PROPOSE_OUT" > "$MANIFEST"

python3 - "$MANIFEST" "$FIXTURE" <<'PY'
import json, os, sys
manifest_path, fixture = sys.argv[1:]
data = json.load(open(manifest_path))
assert data["schema"] == "foreman.tool.v1"
assert data["id"] == "com.printingpress.demo-json-tool"
assert data["name"] == "Demo JSON Tool"
assert data["version"] == "0.1.0"
assert data["description"] == "Safe read-only demo CLI that emits JSON."
assert data["lifecycle"] == {"status": "proposed"}
assert data["provenance"]["source"] == "foreman-press"
assert data["invocation"]["binary"] == fixture
assert os.path.isabs(data["invocation"]["binary"])
assert data["invocation"]["output_format"] == "json"
assert data["invocation"]["idempotent"] is True
assert data["invocation"]["timeout_ms"] == 5000
assert data["invocation"]["max_output_bytes"] == 524288
assert data["commands"][0]["name"] == "lookup"
assert isinstance(data["commands"][0]["args_schema"], dict)
assert isinstance(data["commands"][0]["output_schema"], dict)
assert data["permissions"] == {"reads": ["filesystem:local"], "risk_level": "none"}
assert data["validation"]["smoke_test"]["args"] == ["lookup", "--city", "Austin"]
assert data["validation"]["expected_output_path"] == "$.city"
assert data["error_contract"]["on_nonzero_exit"] == "stderr"
assert data["tags"] == ["demo", "read-only"]
PY

VALIDATE_OUT="$($ROOT/scripts/foreman press validate "$MANIFEST")"
echo "$VALIDATE_OUT" | python3 -c 'import json,sys; data=json.load(sys.stdin); assert data["ok"] is True; assert data["checks"]["smoke_exit_code"] == 0; assert data["checks"]["json_output"] is True; assert data["checks"]["expected_output_path"] == "$.city"'

REGISTER_OUT="$($ROOT/scripts/foreman press register "$MANIFEST")"
echo "$REGISTER_OUT" | python3 -c 'import json,sys; data=json.load(sys.stdin); assert data["ok"] is True; assert data["status"] == "registered"; assert data["id"] == "com.printingpress.demo-json-tool"'

LIST_OUT="$($ROOT/scripts/foreman press list)"
echo "$LIST_OUT" | python3 -c 'import json,sys; data=json.load(sys.stdin); assert data["ok"] is True; assert len(data["tools"]) == 1; tool=data["tools"][0]; assert tool["id"] == "com.printingpress.demo-json-tool"; assert tool["name"] == "Demo JSON Tool"; assert tool["status"] == "registered"'

INSPECT_OUT="$($ROOT/scripts/foreman press inspect com.printingpress.demo-json-tool)"
echo "$INSPECT_OUT" | python3 -c 'import json,sys; data=json.load(sys.stdin); assert data["ok"] is True; assert data["id"] == "com.printingpress.demo-json-tool"; assert data["lifecycle"]["status"] == "registered"; assert data["lifecycle"]["registered_by"] == "foreman"; assert "registered_at" in data["lifecycle"]; assert data["permissions"]["risk_level"] == "none"'

DEFAULT_PATH_MANIFEST="$TMP/default-path.manifest.json"
$ROOT/scripts/foreman press propose \
  --id com.printingpress.default-path \
  --name "Default Path Demo" \
  --description "Safe demo using the default root expected output path." \
  --binary "$FIXTURE" \
  --command-name lookup \
  --smoke-args "lookup --city Austin" \
  > "$DEFAULT_PATH_MANIFEST"
DEFAULT_VALIDATE_OUT="$($ROOT/scripts/foreman press validate "$DEFAULT_PATH_MANIFEST")"
echo "$DEFAULT_VALIDATE_OUT" | python3 -c 'import json,sys; data=json.load(sys.stdin); assert data["ok"] is True; assert data["checks"]["expected_output_path"] == "$"'

OUT_FILE="$TMP/out.manifest.json"
$ROOT/scripts/foreman press propose \
  --id com.printingpress.demo-json-tool \
  --name "Demo JSON Tool" \
  --description "Safe read-only demo CLI that emits JSON." \
  --binary "$FIXTURE" \
  --command-name lookup \
  --smoke-args "lookup --city Austin" \
  --expected-output-path '$.city' \
  --tag demo \
  --out "$OUT_FILE" >/tmp/foreman-propose-out
python3 - "$OUT_FILE" <<'PY'
import json, sys
path = sys.argv[1]
status = json.load(open('/tmp/foreman-propose-out'))
manifest = json.load(open(path))
assert status["ok"] is True
assert status["manifest"] == path
assert manifest["id"] == "com.printingpress.demo-json-tool"
PY
