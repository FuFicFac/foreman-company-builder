# Contributing to Foreman Company Builder

Thanks for your interest in contributing. Foreman is a shell-first project — most of the logic lives in Bash/Zsh scripts and Python files under `scripts/`. No build step, no compiler.

## Getting Started

```bash
git clone https://github.com/FuFicFac/foreman-company-builder.git
cd foreman-company-builder
./scripts/install.sh
source ~/.zshrc   # or restart your terminal
foreman init
```

You need at least one AI CLI installed for Foreman to do real work: Cursor Agent, Claude Code, Codex, Ollama, or Hermes.

## Project Layout

```
scripts/          Shell scripts and Python — the actual Foreman logic
  foreman         Main CLI wrapper (routes subcommands)
  foreman-blast.sh   Entry-point pipeline launcher
  foreman-init.sh    First-run fleet/role discovery
  foreman-run.sh     Run lifecycle (start, status, advance)
  foreman-press.py   Printing Press manifest tool
  foreman-tools.sh   Tool supply (doctor, search, install)
  foreman-lph.py     Little Publishing House company package
  install.sh         Installer (clones to ~/.foreman, adds to PATH)
modules/          Capability templates (software, publishing, etc.)
docs/             Architecture and design docs
site/             Landing page (static HTML)
tests/            Smoke tests and JSON validators
```

## Making Changes

1. Create a branch: `git checkout -b my-feature`
2. Make your changes. Keep them focused — no drive-by refactors.
3. Match the existing style: shell scripts use `set -euo pipefail`, Python files use stdlib only (no external deps unless already in the project).
4. Test your changes:

```bash
# Run the smoke tests
npm test

# Or individually
bash tests/smoke/foreman-wrapper-dispatch.sh
bash tests/smoke/press-lifecycle.sh
python3 tests/json/validate-module-manifests.py
```

5. If you add or change a CLI subcommand, update the help text in `scripts/foreman` and the command table in `README.md`.
6. If you add a new env var, add it to `.env.example`.

## Commit Style

Use conventional commit prefixes:

```
feat: add new template
fix: correct role assignment for single-provider fleet
docs: update install instructions
```

Keep commits small and self-contained.

## Pull Requests

- One feature or fix per PR.
- Include the relevant smoke test output in your PR description.
- If you change user-facing commands, call it out explicitly in the PR.
- Don't edit `package.json` unless the change is specifically about the npm package metadata — the `foreman` wrapper handles CLI routing.

## Reporting Issues

Open a GitHub issue with:

1. What you did (exact command)
2. What you expected
3. What actually happened (full output)
4. Your setup: OS, which CLIs are installed (`foreman fleet`), and `~/.foreman/profile.json` with API keys redacted

## Code of Conduct

Be direct, be useful, don't be a jerk. This is a builder project for builders.