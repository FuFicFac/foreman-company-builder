# Foreman + 12-Factor Agents

> Architecture note: this document adapts the public [12-Factor Agents](https://github.com/humanlayer/12-factor-agents) principles by HumanLayer/Dex Horthy into Foreman language. Source content is public under CC BY-SA 4.0; this doc is an applied translation for Foreman's product architecture, not a copy of the upstream guide.

## Thesis

Foreman should not become a giant agent with a bag of tools and a loop that keeps going until the model feels done.

Foreman should be a **company-shaped operating discipline layer**:

```text
Company state + incoming event + role/workflow context
→ controlled agent step
→ deterministic action/execution
→ inspection
→ updated company state + evidence
```

The LLMs are workers inside the system. They are not the system.

This matches Foreman's product direction:

- Paperclip is the holding-company control plane and visible work surface.
- Hermes is the default runtime for agents, tools, skills, schedules, and delivery.
- Foreman owns company workflow, context shaping, verification, escalation, and evidence.
- Printing Press supplies agent-native tools matched to company capabilities.

## Foreman Operating Principles

These are the Foreman-native translation of the twelve upstream factors. Foreman also has one product axiom that sits above them:

> **Company-shaped, not chatbot-shaped.** A Foreman Company is a durable business context with roles, workflow stages, tool manifests, state, inspections, human approvals, and audit history. Do not model it as "chat with an agent." Model it as a small operating company that can receive events and move work forward.

### 1. Natural language becomes structured company action

Users can speak naturally:

```text
Help me launch this book.
```

Foreman converts that into explicit operations:

```text
classify project state
select company template
verify capability/tool manifest
create/triage tasks
assign role agents
run builder/inspector loop
request human decisions when needed
update company/project state
```

The user interface may be conversational. The internal system should be structured.

### 2. Own the prompts

Role prompts, inspection prompts, escalation prompts, handoff prompts, and reporting prompts are product assets.

They should be:

- versioned,
- visible in the repo,
- tied to company templates and roles,
- tested through real runs,
- revised when inspectors expose recurring failures.

A Foreman Company should never depend on hidden prompt vibes scattered across tools.

### 3. Own the context

Foreman should construct context deliberately for each role and task.

Do not dump an entire workspace into the model. Build a focused packet:

```text
company brief
project/stage state
active task
role instructions
relevant artifacts
constraints
previous inspection results
human decisions
tool/capability availability
expected output schema
```

This is especially important for Personal Publishing House: a metadata specialist needs positioning, genre, audience, comparable titles, manuscript summary, and launch constraints — not necessarily the entire manuscript.

### 4. Tools are capabilities with structured outputs

Foreman tools are not magic model powers. They are business capabilities exposed through structured actions.

Example:

```json
{
  "action": "create_launch_checklist",
  "company": "personal-publishing-house",
  "project": "book-x",
  "stage": "launch",
  "inputs": {
    "launch_date": "2026-09-01",
    "channels": ["amazon", "direct", "newsletter"]
  }
}
```

The company tool manifest defines what capabilities exist, what CLI/API tools satisfy them, how to verify them, and what to do if they are missing.

### 5. State is the source of truth

Chat transcripts are not company state.

Foreman should persist the business state and the execution state together:

```text
Company
Project
Stage
Task
Role
Run
Attempt
Artifact
Inspection
Escalation
Human decision
Tool manifest status
```

If the system cannot pause today and resume tomorrow from stored state, it is not yet a Foreman Company.

### 6. Runs need launch, pause, resume, cancel, inspect

Foreman runs should have stable IDs and simple control operations:

```bash
foreman run start personal-publishing-house --project memoir --stage metadata
foreman run status run_123
foreman run pause run_123
foreman run resume run_123
foreman run cancel run_123
foreman run inspect run_123
```

The CLI names can change later, but the primitives should exist in the architecture.

### 7. Humans are part of the system

Human contact is not failure. It is a first-class tool call / event.

Foreman should stop and ask when judgment, approval, credentials, budget, positioning, or risk requires the owner:

```text
Human decision required: choose one primary audience before metadata generation.
```

This ties directly to Foreman's 3-strike escalation rule. After repeated failure, ambiguity, missing credentials, or high-risk action, escalate cleanly instead of spiraling.

### 8. Foreman owns the control flow

The model can help inside steps. It should not invent the whole workflow every time.

Each company template should define canonical stages, entry conditions, exit criteria, required artifacts, likely tasks, inspection standards, and human approval points.

For Personal Publishing House:

```text
Idea → Outline → Partial draft → Finished draft → Developmental edit → Revision → Copyedit → Proofread → Metadata → Cover direction → Storefront/distribution → Launch → Reader follow-up → Analytics/relaunch
```

The user can enter anywhere, but Foreman owns the map.

### 9. Errors get compacted into useful context

Do not shovel raw logs or whole failed transcripts into the next agent call when a compact failure packet will do.

A useful failure packet records:

```text
what failed
where it failed
what was expected
what was observed
what was tried
root-cause hypothesis
what remains unresolved
recommended next action
```

Inspection results should become state and targeted context, not transcript sludge.

### 10. Small, focused role agents

Foreman should prefer small jobs performed by specific roles over giant generalist agents.

For Personal Publishing House, durable roles may include:

- Publisher / CEO
- Developmental Editor
- Line Editor
- Copyeditor
- Proofreader
- Metadata Specialist
- Launch Coordinator
- Reader Follow-up Analyst
- Inspector

Each role should have a clear input, output, quality standard, and escalation path.

### 11. Trigger from anywhere

Foreman should be triggerable from the surfaces where work appears:

- CLI
- Telegram / chat
- Paperclip
- GitHub issue
- file drop
- webhook
- scheduled check-in
- browser UI
- voice interface later

The source changes, but the reducer is the same: event + state → actions + state update.

### 12. Treat each agent call as a stateless reducer

The durable company state is the memory. The agent call is a controlled transformation.

```text
current company state
+ incoming event
+ selected role prompt
+ focused context packet
→ proposed structured actions
→ deterministic execution
→ inspection
→ updated company state
```

This is the core reliability pattern for Foreman.

## Product Architecture Implications

### Build state primitives before fancy UI

Foreman needs durable primitives before dashboard polish:

```text
Company
Project
Capability
ToolManifest
Role
Stage
Task
Run
Attempt
Artifact
Inspection
Escalation
HumanDecision
EventLog
```

Paperclip can visualize these; Foreman must own their operational meaning.

### Company templates need workflow maps

Every Foreman Company template should include:

1. canonical stages,
2. evidence that identifies each stage,
3. required and optional artifacts,
4. likely tasks at each stage,
5. role assignment defaults,
6. inspection criteria,
7. human approval points,
8. capability/tool requirements,
9. resume/recovery behavior.

### Tool manifests become a gate, not a footnote

Before a run, Foreman should verify the manifest:

```text
Which capabilities does this company need?
Which installed tools satisfy them?
Which credentials are present?
Which tools can Printing Press install?
Which missing capability blocks this run?
Which missing capability only degrades the run?
```

### Human-in-the-loop becomes a product feature

Foreman's trust comes from knowing when it needs the owner.

For creators and small businesses, the promise should be:

> A structured AI company that moves work forward, asks when judgment is needed, and keeps evidence of what changed.

Not:

> Fully autonomous magic employees, no humans required.

### The first proof is Personal Publishing House

Personal Publishing House should demonstrate the whole model:

```text
A real writer has a real book at an arbitrary stage.
Foreman discovers where the project is.
It starts from there without destroying prior work.
It assigns publishing roles.
It checks tools and capabilities.
It asks the human for judgment at the right moments.
It produces inspectable artifacts.
It preserves state.
It resumes tomorrow.
```

The product is not "AI writes your book."

The product is:

> Your book has a little company now.

## Implementation Checklist

Near-term architecture work should prioritize:

- [ ] Define JSON schemas for Company, Project, Run, Task, Role, Inspection, Escalation, HumanDecision, and ToolManifest.
- [ ] Add a run ledger/event log format.
- [ ] Make module manifests declare stages, roles, capabilities, tool manifest, inspection standards, and human gates.
- [ ] Add context-packet builders per role/task instead of whole-workspace dumping.
- [ ] Add prompt asset files per company role and inspection mode.
- [ ] Add CLI primitives for run start/status/pause/resume/cancel/inspect.
- [ ] Add human-decision events as explicit state records.
- [ ] Add compact failure packets to inspection and retry flows.
- [ ] Keep the existing builder → inspector → arbitration → escalation loop as the quality spine.

## Design Constraint

Do not overbuild the cathedral.

Layer the implementation:

### V0

- CLI
- JSON files
- module manifests
- run logs
- prompt files
- inspection loops
- tool-manifest checks

### V1

- Paperclip adapter
- persistent company/project state
- role agents
- human-decision events
- scheduled check-ins

### V2

- richer UI
- multi-company dashboard
- webhook/file/chat triggers
- company template marketplace
- advanced automation

The goal is disciplined momentum, not enterprise orchestration cosplay.
