#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export FOREMAN_CONFIG_DIR="$TMP/.foreman"

CLI="$TMP/weather-cli"
cat > "$CLI" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "--help" ]]; then
  echo '{"usage":"weather-cli get --city CITY"}'
  exit 0
fi
if [[ "${1:-}" == "get" && "${2:-}" == "--city" && -n "${3:-}" ]]; then
  printf '{"city":"%s","condition":"sunny"}\n' "$3"
  exit 0
fi
echo 'usage error' >&2
exit 2
SH
chmod +x "$CLI"

MANIFEST="$TMP/weather.manifest.json"
cat > "$MANIFEST" <<JSON
{
  "schema": "foreman.tool.v1",
  "id": "com.printingpress.local-weather",
  "name": "Local Weather",
  "version": "0.1.0",
  "description": "Read-only local weather lookup.",
  "lifecycle": { "status": "proposed" },
  "provenance": { "source": "printing-press", "generator_version": "0.1.0" },
  "invocation": {
    "binary": "$CLI",
    "output_format": "json",
    "timeout_ms": 5000,
    "idempotent": true,
    "max_output_bytes": 524288
  },
  "commands": [
    {
      "name": "get",
      "description": "Fetch weather for a city.",
      "args_schema": { "type": "object", "properties": { "city": { "type": "string" } }, "required": ["city"] },
      "output_schema": { "type": "object", "properties": { "city": { "type": "string" } }, "required": ["city"] },
      "example": "weather-cli get --city Austin"
    }
  ],
  "permissions": { "reads": ["filesystem:local"], "risk_level": "none" },
  "validation": { "smoke_test": { "args": ["get", "--city", "Austin"] }, "expected_output_path": "$.city" },
  "error_contract": { "on_nonzero_exit": "stderr", "error_json_path": "$.error" },
  "tags": ["weather", "read-only"]
}
JSON

VALIDATE_OUT="$($ROOT/scripts/foreman press validate "$MANIFEST")"
echo "$VALIDATE_OUT" | python3 -c 'import json,sys; data=json.load(sys.stdin); assert data["ok"] is True; assert data["id"] == "com.printingpress.local-weather"'

REGISTER_OUT="$($ROOT/scripts/foreman press register "$MANIFEST")"
echo "$REGISTER_OUT" | python3 -c 'import json,sys; data=json.load(sys.stdin); assert data["ok"] is True; assert data["status"] == "registered"; assert data["id"] == "com.printingpress.local-weather"'

LIST_OUT="$($ROOT/scripts/foreman press list)"
echo "$LIST_OUT" | python3 -c 'import json,sys; data=json.load(sys.stdin); assert len(data["tools"]) == 1; assert data["tools"][0]["id"] == "com.printingpress.local-weather"'

INSPECT_OUT="$($ROOT/scripts/foreman press inspect com.printingpress.local-weather)"
echo "$INSPECT_OUT" | python3 -c 'import json,sys; data=json.load(sys.stdin); assert data["id"] == "com.printingpress.local-weather"; assert data["lifecycle"]["status"] == "registered"; assert "registered_at" in data["lifecycle"]'
