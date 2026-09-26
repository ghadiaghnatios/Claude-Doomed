---
name: close-phase
description: End-of-phase procedure (gate, report, progress, issues) and the final pre-release sweep. Use when a phase's work is built, when the user says "close the phase", "wrap up", "we're done", or before stopping mid-phase for any reason.
---

# Close a phase

Do these in order. The phase isn't done until all of them are.

1. **Gate.** Run lint, types and tests, and boot the app if there's a
   service. Paste the real output. If anything fails, fix it or record it
   as CRITICAL/HIGH in `status/ISSUES.md`, which means the phase stays open.
2. **Acceptance.** Tick each box in `docs/phases.md` for this phase by
   running something, not by reading code.
2b. **Review.** Spawn the `reviewer` agent with the list of files touched,
   the phase's section of `docs/phases.md`, and the gate summary. Fix every
   CRITICAL/HIGH finding and re-run the gate. Log the rest in
   `status/ISSUES.md`. If you disagree with a finding, say why in the report.
3. **Report.** Write `status/reports/phase-N.md` in ≤30 lines:
   - What was built, and the files touched
   - Decisions made, and why
   - Dependencies added, and why
   - Gate output (a summary line each)
   - Anything that deviates from `docs/phases.md`
4. **`status/PROGRESS.md`.** Set the phase and date, update the open-issue
   count, move items between Now and Next, and append the decisions. Keep it
   under ~40 lines: trim old decisions, since they live in the reports.
   If `docs/edits.md` lists this phase under Planned, move those lines to Done.
5. **`status/ISSUES.md`.** Add everything found and not fixed. Each row
   says what it does to the user, not only where it is. Move fixed items to
   Resolved with evidence, and drop Resolved rows from before the last phase.
6. **Stop or continue.** Show a ≤5-line summary. Then follow the Autonomy
   line in `CLAUDE.md`: either wait for "continue", or start the next phase.

Stopping mid-phase (context limit, blocker, user asks): do steps 4 and 5
only, and write under Now exactly where you stopped.

## Final sweep (after the last phase, before calling the project done)

Check each item by running something, and show the output.

- [ ] No CRITICAL/HIGH in Open. Needs checking is empty.
- [ ] Every shortcut is either accepted in writing or upgraded.
- [ ] Gate is green from a fresh clone, following only the README's setup steps.
- [ ] No secret in the repo or its history (`git log -p | grep -iE "api[_-]?key|secret|password|token"`, review the hits).
- [ ] Every error path returns a real message, not a stack trace.
- [ ] Every input that crosses a trust boundary is validated.
- [ ] No debug output, no commented-out code, and every TODO has an issue ID.
- [ ] `docs/` and every ADR match what the code actually does.
