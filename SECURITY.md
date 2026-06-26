# Security Policy

## Supported Versions

Foreman Company Builder is early-stage software. Security fixes will be applied to the latest `main` branch.

| Version | Supported |
|---------|-----------|
| latest main | yes |
| older commits | no — rebase or update |

## Reporting a Vulnerability

Do not open a public GitHub issue for security vulnerabilities.

Instead, email **security@fffactory.media** with:

1. A description of the vulnerability
2. Steps to reproduce
3. The impact (what an attacker could do)
4. Any suggested fix

You will receive a response within 72 hours. If the vulnerability is confirmed, a fix will be prioritized and a security advisory published after the fix is merged.

## API Key Handling

Foreman scans for API keys in your environment variables during `foreman init`. Here is what you should know:

- **Scanned env vars:** `OPENAI_API_KEY`, `XAI_API_KEY`, `GOOGLE_API_KEY`, `ANTHROPIC_API_KEY`
- Keys are stored in `~/.foreman/secrets.env` with `chmod 600` (owner read/write only)
- `~/.foreman/secrets.env` is not committed to git (`.env` and secrets are gitignored)
- The profile file (`~/.foreman/profile.json`) stores the *env var name*, not the key value itself
- Key values are masked when displayed (first 8 / last 4 characters only)
- Never paste a real API key into a GitHub issue, PR, or commit message

If you believe a key has been exposed, rotate it immediately at the provider's dashboard:

- OpenAI: https://platform.openai.com/api-keys
- xAI: https://console.x.ai
- Google: https://aistudio.google.com/apikey
- Anthropic: https://console.anthropic.com/settings/keys

## What Foreman Does Not Do

- Foreman does not send your code or prompts to any third party beyond the AI CLI providers you already have installed
- Foreman does not modify files outside `~/.foreman/` during init
- Foreman does not auto-execute arbitrary network calls during blast (provider CLIs handle their own network traffic)
- Foreman does not store credentials in plaintext in any committed file