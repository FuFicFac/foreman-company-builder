#!/usr/bin/env python3
"""Sync modules/departments/*/module.json from catalog.json research synthesis."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "modules" / "departments" / "catalog.json"
DEPT_ROOT = ROOT / "modules" / "departments"

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
    "role-instructions",
    "relevant-artifacts",
    "constraints",
    "prior-inspection-results",
    "human-decisions",
    "expected-output-schema",
]

LOOP_BY_SLUG = {
    "quality-inspection": "deluxe",
    "legal-compliance": "deluxe",
    "finance": "deluxe",
}


def stages_from_workflows(workflows):
    stages = []
    for workflow in workflows:
        for stage in workflow.get("stages", []):
            if stage not in stages:
                stages.append(stage)
    return stages or ["intake", "execute", "verify", "closeout"]


def standards_from_inspectors(inspectors):
    standards = []
    for inspector in inspectors:
        standard = inspector.replace("_", "-")
        if standard not in standards:
            standards.append(standard)
    if not standards:
        standards = ["artifact-completeness", "policy-compliance", "evidence-captured"]
    standards.extend(["human-approval-respected", "stage-fit"])
    deduped = []
    for item in standards:
        if item not in deduped:
            deduped.append(item)
    return deduped


def build_module(entry):
    slug = entry["slug"]
    workflows = entry.get("workflows", [])
    inspectors = entry.get("inspectors", [])
    return {
        "name": slug,
        "kind": "department",
        "department_slug": slug,
        "version": "1.0.0",
        "description": f"{entry['name']} — {entry['purpose']}",
        "purpose": entry["purpose"],
        "domain": slug,
        "capabilities": entry.get("capabilities", []),
        "required_capabilities": entry.get("required_capabilities", entry.get("capabilities", [])),
        "universal_responsibilities": entry["universal_responsibilities"],
        "workflows": workflows,
        "inspectors": inspectors,
        "builders": entry.get("builders", []),
        "loop_mode": LOOP_BY_SLUG.get(slug, "lean"),
        "high_stakes_loop": "deluxe" if LOOP_BY_SLUG.get(slug) == "deluxe" else None,
        "source": "fcb-department",
        "twelve_factor_profile": TWELVE_FACTOR,
        "stages": stages_from_workflows(workflows),
        "roles": entry.get("roles", []),
        "human_approval_gates": entry.get("human_approval_gates", []),
        "context_packet_requirements": CONTEXT_PACKET,
        "inspection_standards": standards_from_inspectors(inspectors),
        "smoke_tests": entry.get("smoke_tests", []),
        "company_type_mappings": entry["company_type_mappings"],
        "tool_manifest": entry.get("tool_manifest", {}),
        **(
            {"recommended_capabilities": entry["recommended_capabilities"]}
            if entry.get("recommended_capabilities")
            else {}
        ),
        **(
            {"conditional_capabilities": entry["conditional_capabilities"]}
            if entry.get("conditional_capabilities")
            else {}
        ),
        **(
            {"depends_on_departments": entry["depends_on_departments"]}
            if entry.get("depends_on_departments")
            else {}
        ),
    }


def build_skill(entry):
    slug = entry["slug"]
    name = entry["name"]
    lines = [
        f"# {name} Department",
        "",
        entry["purpose"],
        "",
        "## Universal Responsibilities",
        "",
    ]
    for item in entry["universal_responsibilities"]:
        lines.append(f"- {item}")
    lines.extend(["", "## Workflows", ""])
    for workflow in entry.get("workflows", []):
        stages = " → ".join(workflow.get("stages", []))
        lines.append(f"### {workflow.get('name', workflow.get('id', 'workflow'))}")
        lines.append(f"Trigger: `{workflow.get('trigger', 'manual')}`")
        lines.append(f"Stages: {stages}")
        evidence = ", ".join(workflow.get("evidence", []))
        if evidence:
            lines.append(f"Evidence: {evidence}")
        lines.append("")
    if entry.get("inspectors"):
        lines.extend(["## Inspectors", ""])
        for inspector in entry["inspectors"]:
            label = inspector.replace("-", " ").title()
            lines.append(f"### {label}")
            lines.append(
                f"Review department work for {label.lower()} against inspection standards "
                f"and company type expectations."
            )
            lines.append("")
    if entry.get("builders"):
        lines.extend(["## Builder Prompts", ""])
        for builder in entry["builders"]:
            label = builder.replace("-", " ").title()
            lines.append(f"### {label}")
            lines.append(
                f"You are a {name.lower()} builder focused on {label.lower()}. "
                f"Follow company brief, constraints, and prior inspection results. "
                f"Produce evidence-ready artifacts and note assumptions."
            )
            lines.append("")
    lines.extend(
        [
            "## Escalation Rules",
            "- Builder fails inspection 3 times on the same task → escalate to Foreman / department lead",
            "- Approval gate triggered → pause until human decision event is recorded",
            "- Cross-department blocker → hand off via operations handoff workflow",
            "",
            "## Company Type Notes",
            "",
        ]
    )
    for company_type, mapping in entry.get("company_type_mappings", {}).items():
        lines.append(
            f"- **{company_type}** ({mapping['relevance']}): {mapping['notes']}"
        )
    lines.append("")
    return "\n".join(lines)


def main():
    catalog = json.loads(CATALOG.read_text())
    written = []
    for entry in catalog["departments"]:
        slug = entry["slug"]
        dept_dir = DEPT_ROOT / slug
        dept_dir.mkdir(parents=True, exist_ok=True)
        module = build_module(entry)
        if module.get("high_stakes_loop") is None:
            del module["high_stakes_loop"]
        module_path = dept_dir / "module.json"
        module_path.write_text(json.dumps(module, indent=2) + "\n")
        skill_path = dept_dir / "SKILL.md"
        skill_path.write_text(build_skill(entry))
        written.append(slug)
    print(f"synced {len(written)} department modules: {', '.join(written)}")


if __name__ == "__main__":
    main()
