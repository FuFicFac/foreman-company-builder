# Foreman / Little Publishing House — guided beta invite

Status: **product loop certified** on 2026-08-13 (Wave 6 run 3). Public domain cutover and marketing announce are separate.

## Who

3–5 guided testers who will run real tasks and report honesty failures first.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/FuFicFac/foreman-company-builder/main/scripts/install.sh | zsh
foreman init
foreman blast "write a 300-word flash fiction about <anything you care about>"
```

Optional LPH:

```bash
foreman lph new ./my-book --title "My Book" --stage "partial draft" --mode hermes --goal "first continuity pass"
foreman lph doctor ./my-book
foreman lph heartbeat ./my-book
```

## What we want

1. Did builder → inspector → QA → launch behave honestly?
2. Any false green or false red?
3. First moment of confusion (docs bug).

File issues: https://github.com/FuFicFac/foreman-company-builder/issues

Evidence reference: `docs/dogfood-wave-6.md` (run 3 green) and `docs/dogfood-evidence-run-3/`.
