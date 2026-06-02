# Little Publishing House — First-Day Build Checklist

This checklist is for turning the package into a real tester-ready flow.

## Repo / Package

- [ ] Keep Little Publishing House package files under `companies/little-publishing-house/` until/unless extracted to its own repo.
- [ ] Decide public repo name: `little-publishing-house` vs `personal-publishing-house`.
- [ ] Add installer/copy command once Foreman package loading exists.
- [ ] Add a short demo project using fake/sample manuscript data.

## Hermes-only Mode

- [ ] Create a Hermes skill or bundle that loads the Little Publishing House package.
- [ ] Create an intake prompt that reads `workspace-template/README.md`.
- [ ] Create a deterministic heartbeat script or prompt template.
- [ ] Create a closeout prompt/checklist that verifies artifacts and approvals.

## Paperclip-board Mode

- [ ] Define the strong README shape Paperclip should ingest.
- [ ] Map Little Publishing House roles to Paperclip agents.
- [ ] Map workflows to Paperclip issues/Kanban columns.
- [ ] Define evidence/comment format for closeout.
- [ ] Keep Paperclip optional, not required.

## Patreon Test

- [ ] Pick 3-5 testers max.
- [ ] Offer one focused deliverable, not full automation.
- [ ] Collect feedback using `PATREON_TEST_PLAN.md`.
- [ ] Track whether testers prefer board mode or report-only mode.

## Definition of Tester-Ready

Tester-ready means:

- a writer can understand the promise in under two minutes;
- the system can start from the writer's actual current stage;
- one deliverable can be produced safely;
- a closeout report names evidence and next steps;
- no public/paid/irreversible action happens without approval.
