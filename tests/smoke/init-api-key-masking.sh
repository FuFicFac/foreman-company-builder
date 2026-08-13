#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FOREMAN="$ROOT/scripts/foreman"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
BIN="$WORK/bin"
mkdir -p "$BIN"

cat > "$BIN/agent" <<'STUB'
#!/usr/bin/env bash
if [[ "${1:-}" == "models" ]]; then
  echo "composer-2.5"
  echo "composer-2.5-fast"
else
  cat >/dev/null
  echo "READY"
fi
STUB

cat > "$BIN/codex" <<'STUB'
#!/usr/bin/env bash
case "${1:-}" in
  --help) echo "--model gpt-test" ;;
  *) cat >/dev/null; echo "READY" ;;
esac
STUB

cat > "$BIN/curl" <<'STUB'
#!/usr/bin/env bash
exit 1
STUB

cat > "$BIN/claude" <<'STUB'
#!/usr/bin/env bash
case "${1:-}" in
  --version) echo "Claude test" ;;
  default) echo "claude-test" ;;
  *) cat >/dev/null; echo "READY" ;;
esac
STUB

cat > "$BIN/ollama" <<'STUB'
#!/usr/bin/env bash
case "${1:-}" in
  --version) echo "ollama version is test" ;;
  list) printf 'NAME\tID\tSIZE\ntestmodel:latest\tabc123\t1GB\n' ;;
  *) cat >/dev/null; echo "READY" ;;
esac
STUB

cat > "$BIN/hermes" <<'STUB'
#!/usr/bin/env bash
echo "Hermes test"
STUB

chmod +x "$BIN/agent" "$BIN/codex" "$BIN/curl" "$BIN/claude" "$BIN/ollama" "$BIN/hermes"
export FOREMAN_CONFIG_DIR="$WORK/config"
export FOREMAN_SKIP_PROBE=1
export FOREMAN_OPENAI_MODEL=gpt-test
export PATH="$BIN:$PATH"

SECRET='sk-test-visible-input-must-not-appear'
INPUT=$'y\n'"$SECRET"$'\n\n\n1\n'
OUTPUT="$(printf '%s' "$INPUT" | "$FOREMAN" init 2>&1)"

if grep -qF "$SECRET" <<<"$OUTPUT"; then
  echo "pasted API key appeared in init output" >&2
  exit 1
fi
SECRETS_FILE="$FOREMAN_CONFIG_DIR/secrets.env"
test -f "$SECRETS_FILE"
if grep -qF "$SECRET" "$SECRETS_FILE"; then
  echo "pasted API key was written into secrets.env" >&2
  exit 1
fi
grep -qF 'export OPENAI_API_KEY="$OPENAI_API_KEY"' "$SECRETS_FILE"
echo "api-key masking smoke passed"
