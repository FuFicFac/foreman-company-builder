#!/usr/bin/env python3
"""Generate modules/departments/<slug>/module.json and SKILL.md from catalog.json."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "modules/departments/catalog.json"
DEPTS = ROOT / "modules/departments"

TWELVE_FACTOR = {
    "natural_language_to_structured_actions": True,
    "owned_prompts": True,
    "owned_context_packets": True,
    "tools_as_structured_outputs": True,
    "unified_execution_and_business_state": True,
    "pause_resume_runs": True,
    "human_decision_events": True,
    "owned_control_flow": True,
    "compact_failure_packets": True,
    "small_focused_role_agents": True,
    "trigger_from_anywhere": True,
    "stateless_reducer_loop": True,
}

CONTEXT_PACKET = [
    "company-brief",
    "active-task",
    "constraints",
    "prior-inspection-results",
    "human-decisions",
    "expected-output-schema",
]


def stages_from_workflows(workflows):
    seen = []
    for wf in workflows:
        for stage in wf.get("stages", []):
            if stage not in seen:
                seen.append(stage)
    return seen or ["intake", "execute", "verify", "closeout"]


def inspection_standards_from_inspectors(inspectors):
    standards = []
    for inspector in inspectors:
        base = inspector.replace("-inspector", "").replace("_", "-")
        standards.append(f"{base}-standard")
    standards.extend(["evidence-complete", "approval-gates-respected", "customer-promise-fit"])
    out = []
    for s in standards:
        if s not in out:
            out.append(s)
    return out


def skill_md(dept):
    slug = dept["slug"]
    name = dept["name"]
    purpose = dept["purpose"]
    inspectors = dept.get("inspectors", [])
    builders = dept.get("builders", [])
    workflows = dept.get("workflows", [])
    gates = dept.get("human_approval_gates", [])

    lines = [
        f"# {name} Department",
        "",
        purpose,
        "",
        "## Universal responsibilities",
        "",
    ]
    for item in dept.get("universal_responsibilities", []):
        lines.append(f"- {item}")
    lines.extend(["", "## Workflows", ""])
    for wf in workflows:
        stages = " → ".join(wf.get("stages", []))
        lines.append(f"### {wf.get('name', wf.get('id', 'workflow'))}")
        lines.append(f"- Trigger: `{wf.get('trigger', 'on-demand')}`")
        lines.append(f"- Stages: {stages}")
        evidence = ", ".join(f"`{e}`" for e in wf.get("evidence", []))
        if evidence:
            lines.append(f"- Evidence: {evidence}")
        lines.append("")

    lines.extend(["## Inspectors", ""])
    if inspectors:
        for i, inspector in enumerate(inspectors, 1):
            lines.append(f"{i}. **{inspector}** — verify deliverables meet department standards.")
    else:
        lines.append("No department-specific inspectors; route through Quality / Foreman Inspection.")

    lines.extend(["", "## Builder prompts", ""])
    if builders:
        for builder in builders:
            title = builder.replace("-", " ").title()
            lines.extend(
                [
                    f"### {title}",
                    f"You are a {name} builder ({builder}). Follow company conventions, "
                    "capture evidence for each workflow stage, and stop at approval gates.",
                    "",
                ]
            )
    else:
        lines.append("Builders are owned by cross-functional delivery roles in Product / Service Delivery.")

    lines.extend(
        [
            "## Inspector prompt",
            f"You are a {name} inspector. Review builder output against inspection standards, "
            "workflow evidence requirements, and human approval gates. Be specific about failures. "
            "If work passes, say so plainly.",
            "",
            "## Human approval gates",
            "",
        ]
    )
    if gates:
        for gate in gates:
            lines.append(f"- `{gate}` — requires explicit human decision event before proceeding.")
    else:
        lines.append("- None beyond company-wide gates.")

    lines.extend(
        [
            "",
            "## Escalation",
            "- Three failed inspection loops on the same artifact → escalate to Foreman / Quality department.",
            "- Missing evidence on a blocker-severity smoke test → block closeout.",
            "- Cross-department conflict → escalate to Executive / Strategy.",
            "",
            f"## Module reference",
            f"- Manifest: `modules/departments/{slug}/module.json`",
            f"- Catalog entry: `modules/departments/catalog.json` (`{slug}`)",
        ]
    )
    return "\n".join(lines) + "\n"


def module_json(dept):
    slug = dept["slug"]
    manifest = {
        "name": slug,
        "version": "1.0.0",
        "description": dept["purpose"],
        "kind": "department",
        "department_slug": slug,
        "purpose": dept["purpose"],
        "universal_responsibilities": dept["universal_responsibilities"],
        "workflows": dept["workflows"],
        "capabilities": dept["capabilities"],
        "stages": stages_from_workflows(dept["workflows"]),
        "roles": dept["roles"],
        "builders": dept.get("builders", []),
        "inspectors": dept.get("inspectors", []),
        "inspection_standards": inspection_standards_from_inspectors(dept.get("inspectors", [])),
        "human_approval_gates": dept.get("human_approval_gates", []),
        "context_packet_requirements": CONTEXT_PACKET,
        "loop_mode": "lean",
        "high_stakes_loop": "deluxe",
        "source": "fcb-department",
        "twelve_factor_profile": TWELVE_FACTOR,
        "company_type_mappings": dept["company_type_mappings"],
    }
    for optional in (
        "required_capabilities",
        "recommended_capabilities",
        "conditional_capabilities",
        "tool_manifest",
        "smoke_tests",
        "depends_on_departments",
    ):
        if optional in dept:
            manifest[optional] = dept[optional]
    if slug == "quality-inspection":
        manifest["depends_on_departments"] = []
    elif slug != "quality-inspection":
        manifest.setdefault("depends_on_departments", ["quality-inspection"])
    return manifest


def main():
    catalog = json.loads(CATALOG.read_text())
    for dept in catalog["departments"]:
        slug = dept["slug"]
        out_dir = DEPTS / slug
        out_dir.mkdir(parents=True, exist_ok=True)
        (out_dir / "module.json").write_text(json.dumps(module_json(dept), indent=2) + "\n")
        (out_dir / "SKILL.md").write_text(skill_md(dept))
        print(f"wrote {slug}")


if __name__ == "__main__":
    main()
