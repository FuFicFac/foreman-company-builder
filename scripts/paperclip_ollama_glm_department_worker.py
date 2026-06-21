#!/usr/bin/env python3
"""Paperclip process-adapter worker for FCB department research using Ollama GLM 5.2.

This script processes one assigned department-research issue per invocation:
- finds the next FOR-* issue assigned to this agent in in_progress/todo/blocked state;
- asks Ollama `glm-5.2:cloud` for a structured department module research brief;
- writes the result under docs/research/departments/;
- comments on the issue and marks it done.
"""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import textwrap
import urllib.request
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
DATA_DIR = os.environ.get('PAPERCLIP_DATA_DIR', str(Path.home() / '.paperclip' / 'data'))
COMPANY_ID = os.environ.get('PAPERCLIP_COMPANY_ID', '')
MODEL = os.environ.get('OLLAMA_MODEL', 'glm-5.2:cloud')
OLLAMA_URL = os.environ.get('OLLAMA_URL', 'http://127.0.0.1:11434/api/chat')
PAPERCLIP = ['npm', 'exec', '--yes', 'paperclipai', '--']


def run_pc(args: list[str], timeout: int = 90) -> subprocess.CompletedProcess[str]:
    return subprocess.run(PAPERCLIP + args, cwd=str(REPO), text=True, capture_output=True, timeout=timeout)


def pc_json(args: list[str], timeout: int = 90):
    proc = run_pc(args + ['--json'], timeout=timeout)
    if proc.returncode != 0:
        raise RuntimeError(f"paperclip command failed: {' '.join(args)}\nSTDOUT:{proc.stdout}\nSTDERR:{proc.stderr}")
    return json.loads(proc.stdout, strict=False)


def slugify(title: str) -> str:
    text = title.lower()
    text = re.sub(r'^research department:\s*', '', text)
    text = re.sub(r'[^a-z0-9]+', '-', text).strip('-')
    return text or 'department'


def find_issue(agent_id: str | None):
    explicit = os.environ.get('PAPERCLIP_TASK_ID') or os.environ.get('PAPERCLIP_ISSUE_ID')
    if explicit:
        try:
            d = pc_json(['issue', 'get', '--data-dir', DATA_DIR, explicit])
            if d.get('identifier', '').startswith('FOR-'):
                return d
        except Exception:
            pass
    if not agent_id:
        raise RuntimeError('No PAPERCLIP_AGENT_ID/PAPERCLIP_TASK_ID available for worker routing.')
    candidates = []
    for status in ['in_progress', 'todo', 'blocked']:
        try:
            items = pc_json(['issue', 'list', '--data-dir', DATA_DIR, '-C', COMPANY_ID, '--assignee-agent-id', agent_id, '--status', status])
        except Exception:
            continue
        for item in items:
            ident = item.get('identifier', '')
            title = item.get('title', '')
            if ident.startswith('FOR-') and title.startswith('Research Department:'):
                candidates.append(item)
    if not candidates:
        return None
    candidates.sort(key=lambda x: x.get('issueNumber', 10**9))
    return candidates[0]


def ask_ollama(issue: dict) -> str:
    title = issue.get('title', '')
    desc = issue.get('description', '')
    prompt = f"""
You are the GLM 5.2 research lane for Foreman Company Builder.

Research and design this universal company department module:

Issue: {issue.get('identifier')} — {title}

Issue brief:
{desc[:6000]}

Produce a practical, implementation-ready Markdown brief with these exact sections:
1. Department purpose
2. Core responsibilities
3. Required capabilities
4. Optional capabilities
5. Standard workflows / SOPs
6. Roles / agents
7. Inputs and outputs
8. Approval gates
9. Inspector checks / quality gates
10. Tooling and data needed
11. Metrics / KPIs
12. Risks and failure modes
13. Module schema recommendations
14. Company-type mappings:
   - software/SaaS
   - physical product/ecommerce
   - local/service business
   - creator/media
   - publishing/media
   - education/community
15. Implementation notes for Foreman Company Builder

Be concrete. Avoid generic business-school filler. Assume this must become reusable code/config/docs in a company-builder system.
""".strip()
    body = json.dumps({
        'model': MODEL,
        'messages': [
            {'role': 'system', 'content': 'You are a precise research and company-operations systems analyst.'},
            {'role': 'user', 'content': prompt},
        ],
        'stream': False,
        'options': {'temperature': 0.2},
    }).encode('utf-8')
    req = urllib.request.Request(OLLAMA_URL, data=body, headers={'Content-Type': 'application/json'})
    with urllib.request.urlopen(req, timeout=600) as resp:
        data = json.load(resp)
    content = data.get('message', {}).get('content', '').strip()
    if len(content) < 500:
        raise RuntimeError(f'Ollama response too short/empty: {content!r}')
    return content


def main() -> int:
    agent_id = os.environ.get('PAPERCLIP_AGENT_ID') or os.environ.get('PAPERCLIP_AGENT')
    issue = find_issue(agent_id)
    if not issue:
        print('No assigned FCB department research issue found for Ollama GLM worker.')
        return 0
    ident = issue['identifier']
    title = issue['title']
    # Claim/in-progress if needed.
    if issue.get('status') != 'in_progress':
        run_pc(['issue', 'update', '--data-dir', DATA_DIR, ident, '--status', 'in_progress', '--comment', f'Ollama GLM 5.2 worker started {ident}.'], timeout=60)
    content = ask_ollama(issue)
    out_dir = REPO / 'docs' / 'research' / 'departments'
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / f"{slugify(title)}.md"
    header = f"# {title}\n\n- Issue: {ident}\n- Model: Ollama `{MODEL}`\n- Worker: Paperclip process adapter / GLM 5.2 lane\n\n"
    out_path.write_text(header + content + '\n', encoding='utf-8')
    rel = out_path.relative_to(REPO)
    comment = textwrap.dedent(f"""
    Ollama GLM 5.2 research complete for {ident}.

    Output file: `{rel}`
    Model: `{MODEL}`

    This card was processed through the Paperclip process adapter using Ollama, per EJ's direction.
    """).strip()
    run_pc(['issue', 'update', '--data-dir', DATA_DIR, ident, '--status', 'done', '--comment', comment], timeout=90)
    print(f'Completed {ident} with Ollama {MODEL}; wrote {rel}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
