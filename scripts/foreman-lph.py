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
    project_dir = Path(args.project_dir).expanduser().resolve()
    data = read_manifest(project_dir)
    today = dt.date.today().isoformat()
    print(f"# Little Publishing House Heartbeat — {today}")
    print()
    print("Status: YELLOW — first-pass workspace created; human confirmation still needed.")
    print(f"Project: {data.get('title', project_dir.name)}")
    print(f"Stage: {data.get('stage', 'unknown')}")
    print(f"Mode: {data.get('mode', 'unknown')}")
    print(f"Goal: {data.get('goal', 'unknown')}")
    print()
    print("## Moved")
    print("- Workspace exists and has a strong README.")
    print()
    print("## Blocked / Needs human")
    print("- Confirm the stage and choose one focused deliverable.")
    print()
    print("## Next")
    print("- Add manuscript/notes/assets, then run one focused Little Publishing House pass.")
    print()
    print("## Evidence")
    print(f"- {project_dir / 'README.md'}")
    print(f"- {project_dir / 'foreman-lph.json'}")
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

    heartbeat = sub.add_parser("heartbeat", help="print a first-pass heartbeat report")
    heartbeat.add_argument("project_dir")
    heartbeat.set_defaults(func=cmd_heartbeat)
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    ns = parser.parse_args(sys.argv[1:] if argv is None else argv)
    return ns.func(ns)


if __name__ == "__main__":
    raise SystemExit(main())
