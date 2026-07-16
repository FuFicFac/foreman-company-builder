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
