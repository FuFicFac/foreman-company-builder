# Wave 6 dogfood gate

The 2026-07-16 finishing dispatch ran this branch's `foreman blast` live against a bounded creative-writing project in the dispatch workspace's `dogfood/` directory.

Result: **blocked; the product is not finished by its own gate**.

- Builder: live, discovered Cursor provider.
- Inspector: live, independent Codex provider.
- Attempt 1: inspector failed.
- Attempt 2: inspector failed.
- Attempt 3: inspector passed.
- QA Editor: live; failed on a remaining timeline/plot hole.
- Launch: correctly skipped after QA failure; no launch assets were produced.
- Dry-run substitutions: none.

The workspace evidence includes the full Blast log, final story, builder and inspector transcripts, QA transcript, and run ledger. The dispatch stopped after the third revision instead of bypassing the QA gate.

## Run 2 — 2026-07-17

Result: **blocked at the three-strike inspector gate**.

- Builder: live, discovered Cursor `composer-2.5` provider.
- Inspector: live, independent Codex `gpt-5.6-sol` provider.
- Attempt 1: inspector failed on an out-of-window February flashback and a contradictory evidence timestamp.
- Attempt 2: inspector failed because the replacement March 1 flashback was still outside the March 3–April 7 window and Park's pre-rupture timestamp was incorrectly described as a final safety clearance. The inspector also flagged the ending as slightly ambiguous.
- Attempt 3: inspector failed on conflicting deadline details, a duplicate pen-capping action, an inaccurate claim of a clearance-signature discrepancy, and a closing action assigned to Park rather than Elena.
- QA Editor: not run because no builder attempt passed inspection; there is no QA verdict.
- Launch: correctly skipped after the inspector gate blocked; no launch assets were produced.
- Dry-run substitutions: none.

The committed run-2 evidence is in [`docs/dogfood-evidence-run-2/`](dogfood-evidence-run-2/). It contains the full Blast, fleet-check, and init logs; the run ledger; the fixed project brief; the final story; Foreman's final builder and inspector prompt/output files; and a per-attempt transcript preserving every inspector finding and verdict.
