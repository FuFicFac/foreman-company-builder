#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export FOREMAN_CONFIG_DIR="$TMP/.foreman"

CLI="$TMP/weather-cli"
cat > "$CLI" <<'SH'
#!/usr/bin/env bash
echo '{"city":"Austin"}'
SH
chmod +x "$CLI"

INVALID_RELATIVE="$TMP/relative-binary.json"
cat > "$INVALID_RELATIVE" <<'JSON'
{
  "schema": "foreman.tool.v1",
  "id": "com.printingpress.bad",
  "name": "Bad",
  "version": "0.1.0",
  "description": "Bad manifest.",
  "lifecycle": { "status": "proposed" },
  "provenance": { "source": "printing-press" },
  "invocation": {
    "binary": "weather-cli",
    "output_format": "json",
    "timeout_ms": 5000,
    "idempotent": true,
    "max_output_bytes": 524288
  },
  "commands": [
    {
      "name": "get",
      "description": "Fetch weather.",
      "args_schema": { "type": "object" },
      "output_schema": { "type": "object" },
      "example": "weather-cli get"
    }
  ],
  "permissions": { "reads": ["filesystem:local"], "risk_level": "none" },
  "validation": { "smoke_test": { "args": [] } },
  "error_contract": { "on_nonzero_exit": "stderr" },
  "tags": []
}
JSON

if "$ROOT/scripts/foreman" press validate "$INVALID_RELATIVE" >/tmp/foreman-invalid-out 2>/tmp/foreman-invalid-err; then
  echo "relative binary manifest should fail validation" >&2
  exit 1
fi
python3 -c 'import json,sys; data=json.load(open("/tmp/foreman-invalid-out")); assert data["ok"] is False; assert any("absolute" in e for e in data["errors"])'

INVALID_SHELL="$TMP/shell-smoke.json"
python3 - "$INVALID_RELATIVE" "$INVALID_SHELL" "$CLI" <<'PY'
import json, sys
src, dst, cli = sys.argv[1:]
data = json.load(open(src))
data["invocation"]["binary"] = cli
data["validation"]["smoke_test"] = f"{cli} get"
json.dump(data, open(dst, "w"), indent=2)
PY

if "$ROOT/scripts/foreman" press validate "$INVALID_SHELL" >/tmp/foreman-invalid-out 2>/tmp/foreman-invalid-err; then
  echo "shell string smoke_test should fail validation" >&2
  exit 1
fi
python3 -c 'import json; data=json.load(open("/tmp/foreman-invalid-out")); assert data["ok"] is False; assert any("smoke_test" in e for e in data["errors"])'

INVALID_CREDENTIALS="$TMP/credentials-permission.json"
python3 - "$INVALID_RELATIVE" "$INVALID_CREDENTIALS" "$CLI" <<'PY'
import json, sys
src, dst, cli = sys.argv[1:]
data = json.load(open(src))
data["invocation"]["binary"] = cli
data["permissions"]["credentials"] = ["api-key"]
json.dump(data, open(dst, "w"), indent=2)
PY

if "$ROOT/scripts/foreman" press validate "$INVALID_CREDENTIALS" >/tmp/foreman-invalid-out 2>/tmp/foreman-invalid-err; then
  echo "credential permissions should fail V0 validation" >&2
  exit 1
fi
python3 -c 'import json; data=json.load(open("/tmp/foreman-invalid-out")); assert data["ok"] is False; assert any("permission" in e and "credentials" in e for e in data["errors"])'

INVALID_TOP_LEVEL="$TMP/top-level-banned.json"
python3 - "$INVALID_RELATIVE" "$INVALID_TOP_LEVEL" "$CLI" <<'PY'
import json, sys
src, dst, cli = sys.argv[1:]
data = json.load(open(src))
data["invocation"]["binary"] = cli
data["credentials"] = {"apiKeyEnv": "SECRET"}
data["publishing"] = {"endpoint": "https://example.invalid"}
data["payment"] = {"price": 1}
json.dump(data, open(dst, "w"), indent=2)
PY

if "$ROOT/scripts/foreman" press validate "$INVALID_TOP_LEVEL" >/tmp/foreman-invalid-out 2>/tmp/foreman-invalid-err; then
  echo "top-level credential/publishing/payment fields should fail V0 validation" >&2
  exit 1
fi
python3 -c 'import json; data=json.load(open("/tmp/foreman-invalid-out")); assert data["ok"] is False; assert any("unsupported V0 top-level" in e and "credentials" in e for e in data["errors"])'

INVALID_WRITES="$TMP/writes-key.json"
python3 - "$INVALID_RELATIVE" "$INVALID_WRITES" "$CLI" <<'PY'
import json, sys
src, dst, cli = sys.argv[1:]
data = json.load(open(src))
data["invocation"]["binary"] = cli
data["permissions"]["writes"] = []
json.dump(data, open(dst, "w"), indent=2)
PY

if "$ROOT/scripts/foreman" press validate "$INVALID_WRITES" >/tmp/foreman-invalid-out 2>/tmp/foreman-invalid-err; then
  echo "permissions.writes presence should fail V0 validation" >&2
  exit 1
fi
python3 -c 'import json; data=json.load(open("/tmp/foreman-invalid-out")); assert data["ok"] is False; assert any("permissions.writes" in e for e in data["errors"])'
