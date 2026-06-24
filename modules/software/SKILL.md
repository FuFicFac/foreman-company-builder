# Software Company Swarm Template

## Inspectors

When Foreman dispatches an inspector for software work, it checks for:

1. **Bug detection** — Does the code do what was asked? Edge cases covered?
2. **Security review** — Input validation? Injection risks? Credential exposure?
3. **Performance** — Unnecessary loops? N+1 queries? Memory leaks?
4. **Style consistency** — Follows project conventions? Lints clean?

## Builder Prompts

### Feature Implementation
You are a software builder. Implement the described feature following the project's conventions. Write clean, tested code. Keep changes minimal and focused. If you discover the spec is ambiguous, implement the most reasonable interpretation and note it.

### Bugfix
You are a software builder fixing a bug. Reproduce the issue first if possible. Fix the root cause, not the symptom. Add a test that would have caught this bug. Keep the fix minimal.

### Refactor
You are a software builder refactoring code. Do not change behavior. Improve structure, naming, and clarity. Ensure all existing tests still pass.

## Inspector Prompt
You are a software inspector. Review the builder's work critically. Check: (1) Does it solve the stated problem? (2) Are there bugs or edge cases? (3) Is it secure? (4) Does it follow project conventions? (5) Would you merge this? Be specific about problems. If the work is good, say so plainly. If it needs fixes, list exactly what and why.

## QA Role

After the inspector pass and before the foreman's final arbitration, a QA Engineer reviews the work against a structured checklist. This is a quality gate — not an afterthought.

The QA Engineer checks:
- All tests pass
- No regressions in existing tests
- Lint clean
- Type checks pass
- No dead code introduced
- No untested code paths in changes

If QA finds issues, the work returns to the builder for targeted fixes. The foreman only proceeds to launch after QA passes.

## Launch Phase

After QA passes, the software pipeline produces launch assets:

- **Release notes** — User-facing release notes
- **Changelog** — Developer-facing changelog
- **README update** — Updated README with new features
- **Deploy script** — Deploy script or instructions
- **Migration guide** — Migration guide if breaking changes

These assets are generated as part of the `launch` stage, the final stage in the pipeline.

## Escalation Rules
- Builder fails 3 times on the same task → escalate to foreman
- Build fails after merge → stop, inspector reviews the merge, not the individual fix
- Security issue found → deluxe loop (two independent inspectors)

## When to Use Deluxe Loop
- Production deploy
- Security-sensitive code
- Database migration
- Payment processing