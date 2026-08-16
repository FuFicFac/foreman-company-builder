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

## Run 3 — 2026-08-13 (certification after PR #22)

Result: **GREEN — inspector pass + QA pass + launch assets; durable ledger evidence on run_13.**

- Repo HEAD: `a26eb9c` (PR #22 durable run-ledger evidence merged).
- Builder: live Claude `opus` (`claude -p --model opus --dangerously-skip-permissions`).
- Inspector: live independent Codex (`codex exec --skip-git-repo-check`).
- Attempt 1: inspector **fail** — ending choice (scan onto vendor flatbed) did not clearly preserve anything beyond the vendor’s normal pre-shred scan.
- Attempt 2: inspector **fail** — still treated digitization as active on April 7; brief confines vendor digitization to April 1–4.
- Attempt 3: inspector **pass** — chronology and choice corrected; story on page before 4:15 with physical cost.
- QA Editor: **pass** (checklist: voice, names, timeline, tone, plot holes).
- Launch: **produced** `blurb`, `hook`, `series-callback`, `funnel-copy` under workspace `launch/`.
- Dry-run substitutions: none.
- Workspace evidence: [`docs/dogfood-evidence-run-3/`](dogfood-evidence-run-3/) and live `dogfood-wave6-run3/`.
- Companion LPH track: `dogfood-wave6-lph/` — `lph new → doctor: OK` on synthetic manuscript *The Quiet Hours Ledger*; heartbeat reports project correctly (global ledger may still show older unrelated YELLOW runs).

This is the certification shape: honest catches on attempts 1–2 beside one honest clean completion on attempt 3 with durable ledger attempts[] evidence.

