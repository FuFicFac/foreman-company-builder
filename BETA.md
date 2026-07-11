# Foreman Beta — What to Expect

Welcome. You're testing the real thing, and the point of Foreman is honesty about agent work — so here's the same honesty about Foreman itself.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/FuFicFac/foreman-company-builder/main/scripts/install.sh | zsh
foreman init     # discovers your agent CLIs, live-probes them, assigns roles
```

Requirements: macOS or Linux, `git`, `zsh`, `python3`, and **at least one working agent CLI** — Cursor Agent (`agent`), Claude Code (`claude`), Codex (`codex`), Hermes (`hermes`), or Ollama (`ollama`). Two or more is better: Foreman assigns the strongest as inspector and the fastest as builder, and verification is more honest when they're different tools.

## The blessed path (start here)

```bash
foreman blast "write a 300-word flash fiction about <anything>"
```

This fires the full pipeline on the creative-writing template: a builder drafts, an inspector reviews and issues a real verdict, failed attempts retry with the inspector's feedback (3 strikes → escalation), a QA editor runs a checklist pass, and a launch phase generates shipping assets (blurb, hook, funnel copy, and more) into your workspace.

The creative-writing and software templates are the two we have run end-to-end many times. Marketing, YouTube, and publishing templates are wired and validated but have had less live mileage — reports welcome.

## Known issues (we know, it's filed)

- **QA failure ends the run** rather than sending the builder back to fix what QA found (issue #15). If QA fails your run, the QA reviewer's reasons are in `qa_*.txt` in the workspace — rerun with a sharper prompt for now.
- **Existing `~/.foreman` directory**: if you have a config-only `~/.foreman` from an earlier setup, the installer's clone will fail (issue #16). Move it aside first: `mv ~/.foreman ~/.foreman.bak`, install, then copy your `profile.json` back.
- **Inspector CLIs must work headless.** Claude Code needs a headless-capable login for `claude -p`. If your configured inspector can't run a job, Foreman now detects that before dispatching and falls back to another live provider automatically — but a two-provider setup makes this seamless.
- **Ollama reasoning models are slow inspectors.** A verdict can take a couple of minutes. Working as intended, just don't assume it hung.

## What we want from you

1. Run `foreman blast` on a real task in your domain. Did the verdict loop behave honestly?
2. If anything reports success that shouldn't have (or vice versa) — that's the bug we care about most. File it with the workspace contents.
3. Tell us the first moment you were confused. That's a docs bug.

File issues: https://github.com/FuFicFac/foreman-company-builder/issues
