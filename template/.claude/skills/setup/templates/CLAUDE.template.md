# <PROJECT_NAME>

<One paragraph: what this is, who uses it, the core flow.>

@status/PROGRESS.md

## Layout

- `app/`: all runnable code, its tests and config. Commands run from here.
- `docs/`: what we're building. Changes only with the user's approval.
  `plan.md` (scope, stack, non-goals) · `phases.md` (phase plan, acceptance)
  · `architecture.md` · `decisions/NNNN-*.md` (ADRs) · `edits.md` (changes
  saved for later with `/edit`; `/edit run` turns them into phases).
- `status/`: what happened. `PROGRESS.md` (imported above) · `ISSUES.md`
  (defect register) · `reports/phase-N.md`.
- `.claude/rules/`: conventions. They load by themselves when matching files are read.

## Commands (from `app/`)

- Install: `<INSTALL_CMD>`
- Dev: `<RUN_CMD>`
- Lint: `<LINT_CMD>` · Types: `<TYPES_CMD>` · Test: `<TEST_CMD>`
- One test: `<TEST_ONE_CMD>`

## How we work

- One phase at a time from `docs/phases.md`. State the plan, build it, then
  run the `close-phase` skill (it runs the gate and the `reviewer` agent).
- <AUTONOMY_LINE>
- Touch only the files the phase lists. If the phase needs more, stop and say so.
- New table, module boundary or API contract: write an ADR in
  `docs/decisions/` and get approval before writing code.
- Gate: lint, types, tests<, app boots>. Show the output; never claim a pass.
- Never weaken or skip a test to make it pass. Fix the code.
- Anything found and not fixed goes in `status/ISSUES.md` right away.
- Ask only about product decisions. Decide the rest and log it under
  Decisions in `status/PROGRESS.md`.
- Ask before adding a dependency, skill, MCP server or plugin. Each one costs
  tokens every session.
- Unsure of a library's current API (new major version, fast-moving
  framework)? Read its official docs or changelog before writing. Don't guess.
- Before stopping for any reason, update `status/PROGRESS.md`.
