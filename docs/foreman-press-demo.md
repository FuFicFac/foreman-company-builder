# Foreman Press V0 demo

Foreman Press V0 is intentionally boring: local-only, JSON-only, read-only, no credentials, no publishing, no payment/money flows, and no destructive actions.

`foreman press propose` drafts a `foreman.tool.v1` manifest. It does **not** register or install anything. `foreman press register` is the local lifecycle transition from `proposed` to `registered`.

## Morning demo: propose → validate → register → list → inspect

Run from the repo root:

```bash
TMP="$(mktemp -d)"
export FOREMAN_CONFIG_DIR="$TMP/.foreman"

./scripts/foreman press propose \
  --id com.printingpress.demo-json-tool \
  --name "Demo JSON Tool" \
  --description "Safe read-only demo CLI that emits JSON." \
  --binary "$PWD/examples/press/demo-json-tool" \
  --command-name lookup \
  --smoke-args "lookup --city Austin" \
  --expected-output-path '$.city' \
  --tag demo \
  --tag read-only \
  > "$TMP/demo.manifest.json"

./scripts/foreman press validate "$TMP/demo.manifest.json"
./scripts/foreman press register "$TMP/demo.manifest.json"
./scripts/foreman press list
./scripts/foreman press inspect com.printingpress.demo-json-tool
```

Expected shape:

- `propose` prints the manifest JSON by default.
- `validate` returns `{ "ok": true, ... }` and proves the smoke command emits JSON.
- `register` writes only under `FOREMAN_CONFIG_DIR/tools/...`.
- `list` shows `com.printingpress.demo-json-tool` as `registered`.
- `inspect` prints the registered manifest with Foreman-owned lifecycle fields.

## Optional `--out` form

```bash
./scripts/foreman press propose \
  --id com.printingpress.demo-json-tool \
  --name "Demo JSON Tool" \
  --description "Safe read-only demo CLI that emits JSON." \
  --binary "$PWD/examples/press/demo-json-tool" \
  --command-name lookup \
  --smoke-args "lookup --city Austin" \
  --expected-output-path '$.city' \
  --tag demo \
  --out "$TMP/demo.manifest.json"
```

With `--out`, Foreman writes the manifest file and prints a small JSON status object containing the output path.

## Safe demo fixture

`examples/press/demo-json-tool` is a local fixture CLI. It accepts:

```bash
examples/press/demo-json-tool lookup --city Austin
```

and emits JSON like:

```json
{"city":"Austin","condition":"sunny","source":"local-demo"}
```

It performs no network calls and has no external side effects.
