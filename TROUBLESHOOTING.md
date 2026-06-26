# Troubleshooting

Common issues and fixes for Foreman Company Builder.

## `foreman: command not found` after install

**Cause:** The PATH entry that `install.sh` added to your shell config hasn't been sourced yet.

**Fix:**

```bash
source ~/.zshrc    # macOS default
# or
source ~/.bashrc   # if you use bash
```

Or just close and reopen your terminal.

**Verify:**

```bash
which foreman
# Should print: /Users/<you>/.foreman/scripts/foreman
```

If `which foreman` still returns nothing, check that the PATH line is actually in your shell config:

```bash
grep foreman ~/.zshrc ~/.bashrc 2>/dev/null
# Should show: export PATH="$HOME/.foreman/scripts:$PATH"
```

If it's missing, add it manually:

```bash
echo 'export PATH="$HOME/.foreman/scripts:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## `No CLIs found` during `foreman init`

**Cause:** Foreman couldn't find any AI CLI tools in your PATH. It needs at least one to function.

**What Foreman looks for:** `agent` (Cursor Agent), `claude` (Claude Code), `codex` (Codex), `ollama` (Ollama), `hermes` (Hermes).

**Fix:** Install at least one of these:

| CLI | Install |
|-----|---------|
| Cursor Agent | https://cursor.com |
| Claude Code | https://claude.ai/code |
| Codex | https://github.com/openai/codex |
| Ollama | https://ollama.com/download |
| Hermes | https://hermes-agent.nousresearch.com |

After installing, verify the CLI is in your PATH:

```bash
which claude    # or agent, codex, ollama, hermes
```

Then re-run:

```bash
foreman init
```

## `No API keys found and no local models available`

**Cause:** Foreman needs a "brain" for orchestration and chat. It scans for API keys or local Ollama models and found neither.

**Fix (pick one):**

1. **Set an API key** — export one before running init:

```bash
export OPENAI_API_KEY="sk-..."
foreman init
```

   See `.env.example` for the full list of supported keys (OpenAI, xAI, Google, Anthropic).

2. **Install Ollama and pull a model** — no API key needed:

```bash
ollama pull llama3.2
foreman init
```

3. **Run headless** — Foreman will still work for blast/run cycles without a brain, but `foreman chat` won't be available.

## API key detected but brain calls fail

**Cause:** The key is expired, revoked, or has insufficient quota/credits.

**Fix:**

1. Verify the key works at the provider's playground:
   - OpenAI: https://platform.openai.com/playground
   - xAI: https://console.x.ai
   - Google: https://aistudio.google.com
   - Anthropic: https://console.anthropic.com
2. Check billing/quotas at the provider dashboard
3. Rotate the key if compromised and update `~/.foreman/secrets.env`:

```bash
foreman init   # re-run to re-detect and re-save
```

## `foreman blast` fails with `template 'X' not found in modules/`

**Cause:** The auto-detected or specified template doesn't exist in the `modules/` directory.

**Fix:**

```bash
# List available templates
ls modules/ | grep -v departments

# Or force a known template
foreman blast "my task" --template software
```

## `foreman blast` fails with `module.json missing`

**Cause:** The template directory exists but is missing its manifest file.

**Fix:** The module is incomplete. Check the module directory:

```bash
ls modules/<template-name>/
cat modules/<template-name>/module.json
```

If `module.json` is missing, the module needs to be rebuilt or re-synced. Run `foreman module` for module management.

## Pipeline starts but no work happens

**Cause:** No providers were discovered. Foreman found CLIs during init but they may not be in PATH for the current session.

**Fix:**

```bash
# Check what Foreman sees
foreman fleet

# Dry-run to see what would fire
foreman blast "test task" --dry-run
```

If providers show as "none found", re-source your shell config or re-run `foreman init`.

## Profile is stale or wrong after changing CLIs

**Fix:**

```bash
foreman init    # re-scans and overwrites ~/.foreman/profile.json
```

Or start clean:

```bash
rm -rf ~/.foreman
foreman init
```

## `source ~/.zshrc` produces errors

**Cause:** There may be a syntax error in your shell config, possibly from a partial install.

**Fix:** Check the last few lines of your config:

```bash
tail -5 ~/.zshrc
```

Look for the Foreman PATH line. It should read:

```
export PATH="$HOME/.foreman/scripts:$PATH"
```

If it's malformed, edit it manually or remove it and re-run `./scripts/install.sh`.

## Still stuck?

1. Run `foreman fleet` and `foreman blast "test" --dry-run` to see what Foreman detects
2. Check `~/.foreman/profile.json` (redact API key references before sharing)
3. Open a GitHub issue with the full output of the failing command