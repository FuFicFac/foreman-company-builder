#!/usr/bin/env python3
"""Minimal Little Publishing House CLI for Foreman.

This is intentionally local-file based for the Patreon/livestream MVP.
It does not require Paperclip. It creates a strong README/workspace that can
run in Hermes-only mode now, and can later be mirrored into Paperclip.
"""
from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LPH_ROOT = ROOT / "companies" / "little-publishing-house"
TEMPLATE_README = LPH_ROOT / "workspace-template" / "README.md"
REQUIRED_FILES = ("README.md", "foreman-lph.json")
REQUIRED_DIRS = ("drafts", "assets", "heartbeats", "outputs")


def fail(message: str, code: int = 1) -> int:
    print(f"foreman lph: {message}", file=sys.stderr)
    return code


def slugify(value: str) -> str:
    slug = "".join(ch.lower() if ch.isalnum() else "-" for ch in value).strip("-")
    while "--" in slug:
        slug = slug.replace("--", "-")
    return slug or "untitled"


def render_template(title: str, stage: str, mode: str, goal: str) -> str:
    if not TEMPLATE_README.exists():
        raise FileNotFoundError(f"missing workspace template: {TEMPLATE_README}")
    text = TEMPLATE_README.read_text(encoding="utf-8")
    replacements = {
        "[working title]": title,
        "[idea / notes / outline / partial draft / full draft / proof / launch / post-launch]": stage,
        "[one concrete goal]": goal,
        "[one focused deliverable]": goal,
        "{{TITLE}}": title,
        "{{SLUG}}": slugify(title),
        "{{STAGE}}": stage,
        "{{MODE}}": mode,
        "{{GOAL}}": goal,
        "{{CREATED_AT}}": dt.date.today().isoformat(),
    }
    for old, new in replacements.items():
        text = text.replace(old, new)
    if "- Mode:" not in text:
        text = text.replace("- Stage:", f"- Mode: {mode}\n- Stage:", 1)
    return text


def read_manifest(project_dir: Path) -> dict[str, str]:
    manifest = project_dir / "foreman-lph.json"
    if manifest.exists():
        try:
            data = json.loads(manifest.read_text(encoding="utf-8"))
            return {str(k): str(v) for k, v in data.items()}
        except Exception:
            pass
    values = {"title": project_dir.name, "stage": "unknown", "mode": "unknown", "goal": "unknown"}
    readme = project_dir / "README.md"
    if readme.exists():
        for raw_line in readme.read_text(encoding="utf-8").splitlines():
            line = raw_line.strip()
            if line.startswith("# "):
                values["title"] = line[2:].strip() or values["title"]
            elif line.startswith("- Stage:"):
                values["stage"] = line.split(":", 1)[1].strip() or values["stage"]
            elif line.startswith("- Mode:"):
                values["mode"] = line.split(":", 1)[1].strip() or values["mode"]
            elif line.startswith("- Goal for this engagement:"):
                values["goal"] = line.split(":", 1)[1].strip() or values["goal"]
    return values


def cmd_new(args: argparse.Namespace) -> int:
    project_dir = Path(args.project_dir).expanduser().resolve()
    if project_dir.exists() and any(project_dir.iterdir()):
        return fail(f"project directory is not empty: {project_dir}")
    try:
        readme_text = render_template(args.title, args.stage, args.mode, args.goal)
    except FileNotFoundError as exc:
        return fail(str(exc))

    project_dir.mkdir(parents=True, exist_ok=True)
    for dirname in REQUIRED_DIRS:
        (project_dir / dirname).mkdir(exist_ok=True)
        (project_dir / dirname / ".gitkeep").touch()

    manifest = {
        "title": args.title,
        "slug": slugify(args.title),
        "stage": args.stage,
        "mode": args.mode,
        "goal": args.goal,
        "created_at": dt.date.today().isoformat(),
    }
    (project_dir / "README.md").write_text(readme_text, encoding="utf-8")
    (project_dir / "foreman-lph.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

    print(f"Created Little Publishing House workspace: {project_dir}")
    print(f"Title: {args.title}")
    print(f"Stage: {args.stage}")
    print(f"Mode: {args.mode}")
    print(f"Goal: {args.goal}")
    return 0


def cmd_doctor(args: argparse.Namespace) -> int:
    project_dir = Path(args.project_dir).expanduser().resolve()
    problems: list[str] = []
    if not project_dir.exists():
        problems.append(f"missing project directory: {project_dir}")
    else:
        for name in REQUIRED_FILES:
            if not (project_dir / name).is_file():
                problems.append(f"missing file: {name}")
        for name in REQUIRED_DIRS:
            if not (project_dir / name).is_dir():
                problems.append(f"missing directory: {name}/")
    if problems:
        print("Little Publishing House doctor: FAIL")
        for problem in problems:
            print(f"- {problem}")
        return 1
    data = read_manifest(project_dir)
    print("Little Publishing House doctor: OK")
    print(f"- Project: {data.get('title', project_dir.name)}")
    print(f"- Stage: {data.get('stage', 'unknown')}")
    print(f"- Mode: {data.get('mode', 'unknown')}")
    print(f"- Goal: {data.get('goal', 'unknown')}")
    return 0


def cmd_heartbeat(args: argparse.Namespace) -> int:
    config_dir = Path(os.environ.get("FOREMAN_CONFIG_DIR", str(Path.home() / ".foreman")))
    runs_file = config_dir / "runs.json"
    today = dt.date.today().isoformat()

    print(f"# Foreman Heartbeat — {today}")
    print()

    # Optional project context (kept for backward compatibility with the original CLI path)
    if args.project_dir:
        project_dir = Path(args.project_dir).expanduser().resolve()
        data = read_manifest(project_dir)
        print(f"Project: {data.get('title', project_dir.name)}")
        print(f"Stage: {data.get('stage', 'unknown')}")
        print(f"Mode: {data.get('mode', 'unknown')}")
        print(f"Goal: {data.get('goal', 'unknown')}")
        print()

    # --- Read real state from the run ledger ---
    if not runs_file.exists():
        print(f"Status: UNKNOWN — no run ledger found at {runs_file}")
        print()
        print("## Next")
        print("- Start a run: foreman-run.sh start <module> --project <name> --stage <stage>")
        return 0

    try:
        state = json.loads(runs_file.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError) as exc:
        print(f"Status: UNKNOWN — could not parse run ledger: {exc}")
        return 1

    runs = state.get("runs", [])
    if not runs:
        print("Status: GREEN — no runs recorded yet.")
        print()
        print("## Next")
        print("- Start a run: foreman-run.sh start <module> --project <name> --stage <stage>")
        return 0

    # Tally by status
    passed = [r for r in runs if r.get("status") == "completed"]
    ready = [r for r in runs if r.get("status") in ("running", "paused")]
    blocked = [r for r in runs if r.get("status") == "blocked" and r.get("escalation", {}).get("status") != "escalated"]
    escalated = [r for r in runs if r.get("escalation", {}).get("status") == "escalated"]
    needs_human = [r for r in runs if r.get("status") == "needs_human"]
    failed = [r for r in runs if r.get("status") == "failed"]
    cancelled = [r for r in runs if r.get("status") == "cancelled"]

    # Derive status colour from real state
    if escalated:
        colour = "RED"
        reason = f"{len(escalated)} run(s) escalated"
    elif blocked or needs_human:
        colour = "YELLOW"
        parts = []
        if blocked:
            parts.append(f"{len(blocked)} blocked")
        if needs_human:
            parts.append(f"{len(needs_human)} needs-human")
        reason = ", ".join(parts)
    elif failed:
        colour = "YELLOW"
        reason = f"{len(failed)} run(s) failed (retryable)"
    else:
        colour = "GREEN"
        reason = "all clear"

    print(f"Status: {colour} — {reason}")
    print()

    # Summary counts
    print("## Run Summary")
    print(f"- Passed (completed): {len(passed)}")
    print(f"- Ready (running/paused): {len(ready)}")
    print(f"- Blocked: {len(blocked)}")
    print(f"- Escalated: {len(escalated)}")
    print(f"- Needs human: {len(needs_human)}")
    if failed:
        print(f"- Failed (retryable): {len(failed)}")
    if cancelled:
        print(f"- Cancelled: {len(cancelled)}")
    print()

    # Moved (completed runs)
    print("## Moved")
    if passed:
        for r in passed:
            print(f"- {r['id']}: {r.get('task', 'untitled')} ({r.get('module', '?')}/{r.get('project', '?')}) — completed")
    else:
        print("- No runs completed yet.")
    print()

    # Blocked / Needs human
    print("## Blocked / Needs human")
    issues: list[str] = []
    for r in blocked:
        blockers = r.get("blockers", [])
        last_note = blockers[-1].get("notes", "no detail") if blockers else "no detail"
        issues.append(f"- {r['id']}: BLOCKED — {last_note}")
    for r in escalated:
        esc_reason = r.get("escalation", {}).get("reason") or "no reason recorded"
        issues.append(f"- {r['id']}: ESCALATED — {esc_reason}")
    for r in needs_human:
        decisions = r.get("human_decisions", [])
        last_prompt = decisions[-1].get("prompt", "needs human input") if decisions else "needs human input"
        issues.append(f"- {r['id']}: NEEDS HUMAN — {last_prompt}")
    if issues:
        for line in issues:
            print(line)
    else:
        print("- Nothing blocked or waiting on human.")
    print()

    # Single next action
    print("## Next")
    if escalated:
        r = escalated[0]
        esc_reason = r.get("escalation", {}).get("reason") or "review escalation"
        print(f"- Address escalated {r['id']} ({r.get('task', '?')}): {esc_reason}")
    elif blocked:
        r = blocked[0]
        blockers = r.get("blockers", [])
        last_note = blockers[-1].get("notes", "remove blocker") if blockers else "remove blocker"
        print(f"- Unblock {r['id']} ({r.get('task', '?')}): {last_note}")
    elif needs_human:
        r = needs_human[0]
        decisions = r.get("human_decisions", [])
        last_prompt = decisions[-1].get("prompt", "provide human decision") if decisions else "provide human decision"
        print(f"- Decide on {r['id']} ({r.get('task', '?')}): {last_prompt}")
    elif failed:
        r = failed[0]
        print(f"- Retry {r['id']} ({r.get('task', '?')}) — foreman-run.sh resume {r['id']}")
    elif ready:
        r = ready[0]
        print(f"- Inspect {r['id']} ({r.get('task', '?')}) — foreman-run.sh inspect {r['id']}")
    else:
        print("- All runs complete. Start the next task.")
    print()

    # Evidence
    print("## Evidence")
    print(f"- Run ledger: {runs_file}")
    print(f"- Total runs: {len(runs)}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="foreman lph")
    sub = parser.add_subparsers(dest="command", required=True)

    new = sub.add_parser("new", help="create a Little Publishing House project workspace")
    new.add_argument("project_dir")
    new.add_argument("--title", required=True)
    new.add_argument("--stage", required=True)
    new.add_argument("--mode", choices=("hermes", "paperclip"), default="hermes")
    new.add_argument("--goal", default="one focused publishing deliverable")
    new.set_defaults(func=cmd_new)

    doctor = sub.add_parser("doctor", help="check a Little Publishing House workspace")
    doctor.add_argument("project_dir")
    doctor.set_defaults(func=cmd_doctor)

    heartbeat = sub.add_parser("heartbeat", help="print a heartbeat report from the run ledger")
    heartbeat.add_argument("project_dir", nargs="?", default=None)
    heartbeat.set_defaults(func=cmd_heartbeat)
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    ns = parser.parse_args(sys.argv[1:] if argv is None else argv)
    return ns.func(ns)


if __name__ == "__main__":
    raise SystemExit(main())
