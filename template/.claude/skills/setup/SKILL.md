---
name: setup
description: Set up or reconfigure this workspace for Claude (interview, plan, folder layout, CLAUDE.md, rules, permissions, hooks). Use when the user says "setup yourself", "run the setup", "set yourself up", "configure claude", or when CLAUDE.md says setup is pending.
---

# Workspace setup

This turns the folder into a configured workspace. Templates live next to
this file in `templates/`. Rules while it runs:

- Ask everything you need in **one** round, then run to the end without
  asking more. Stop only on a failure, and report the exact error.
- Write nothing outside this folder. Never touch `~/.claude/`.
- Add no MCP servers, plugins or skills. Add no dependency beyond what the
  stack's official generator installs.
- Never handle a secret. If one is needed, name the env var and have the
  user set it.

## Layout this produces

```
CLAUDE.md            always loaded: layout, commands, working rules (≤50 lines)
.claude/
  settings.json      enforced: allow/deny lists, format hook
  rules/             conventions; security.md always, the rest path-scoped
  skills/            setup (this), close-phase
app/                 all runnable code, tests and app config
docs/                what we're building (changes only with approval)
  plan.md  phases.md  architecture.md  decisions/NNNN-*.md
status/              what happened (written every phase)
  PROGRESS.md  ISSUES.md  reports/phase-N.md
.env.example  .gitignore  .gitattributes  README.md
```

Where each thing loads, so the token cost stays low: `CLAUDE.md`,
`status/PROGRESS.md` (imported) and `rules/security.md` load every session.
Path-scoped rules load when matching files are read. Skills load when they
fire. `docs/` and the rest of `status/` are read only when needed.

## 0. Re-run check

If `status/PROGRESS.md` exists, this is a re-run. Only refresh the config:
`.claude/settings.json`, `.claude/rules/`, and the Layout and Commands
sections of `CLAUDE.md`. Never rewrite `docs/` or `status/`. Then jump to step 6.

## 1. Discover

- Run `ls -a` and `git log --oneline -5`. Check which runtimes are installed:
  node, python/uv, go, cargo, docker, whichever might matter.
- **Existing code** (manifests or source outside `.claude/`): don't move it
  into `app/`. Map it where it is, and in every step below read "`app/`" as
  its real location. Take the commands from the manifests, the CI config and
  the README.
- **Empty folder:** everything goes in `app/`.

## 2. Interview (one round)

If the user hasn't already described the project, ask in plain text: what
it is, who uses it, what it stores, the core flow, and what's out of scope for v1.

Then ask one AskUserQuestion call for the choices. Offer a recommended
option first, based on the description:
- Stack: language/framework, front end or none, database or none.
- Is there a runnable service? (decides whether "app boots" is part of the gate)
- Project name. Skip if it's obvious from the description or the folder name.

Don't ask anything you can infer. Write down what you inferred instead.

## 3. Scaffold `app/`

New project only. Use the stack's official generator (`npm create vite@latest`,
`uv init`, `cargo new`, `go mod init`, etc.) with the lint, format, typecheck
and test tooling the ecosystem treats as default. Hand-write no application
code. Phase 1 builds the first real path. Several deployables go in
`app/<name>/`, shared code in `app/packages/<name>/`.

## 4. Write the documents

Fill in from `templates/`, replacing every `<PLACEHOLDER>`. Delete any line
that isn't true for this project.

| Write | From |
|---|---|
| `CLAUDE.md` (replaces the bootstrap) | `templates/CLAUDE.template.md` |
| `docs/plan.md` | `templates/plan.md` |
| `docs/phases.md` | `templates/phases.md`. Phase 1 is always the thinnest walking skeleton. Every phase is demonstrable, reviewable in one sitting, lists its files, and has acceptance criteria you can run. |
| `docs/architecture.md` | no template. Components, data flow, trust boundaries, external services. ≤60 lines. |
| `docs/decisions/0001-stack.md` | `templates/adr.md`, status accepted |
| `status/PROGRESS.md` | `templates/PROGRESS.md` |
| `status/ISSUES.md` | `templates/ISSUES.md`. Tables stay empty. |
| `README.md` | what it is, how to run it, where the docs are. For people, short. |
| `.env.example` | every env var the app reads, no values. Only if there are any. |

The `@status/PROGRESS.md` import in `CLAUDE.md` must point at a file that
exists. A missing import fails silently.

## 5. Conventions: `.claude/rules/`

- Keep `security.md` (always loaded). Add stack-specific lines to it if needed.
- `code.md` with `paths: ["app/**"]`: language conventions the linter
  doesn't enforce, like error handling, logging, what not to reach for. ≤20 lines.
- One more file per real area (`api.md`, `ui.md`, `db.md`, `tests.md`...),
  each scoped with `paths:` to that area's files. Only write one when there's
  something specific to say. No generic advice.

## 6. Config: `.claude/settings.json`

Merge into the existing file, and never drop entries from `deny`.
- `permissions.allow`: the exact install/lint/types/test/run/format commands
  (e.g. `Bash(npm run lint:*)`, `Bash(uv run pytest:*)`). Nothing that
  deploys, publishes or deletes.
- `permissions.deny`: add any other secret-bearing paths this stack uses.
- If there's a formatter, add a `PostToolUse` hook (matcher `Edit|Write`)
  that formats only the edited file. The hook reads JSON on stdin and gets
  the path from `tool_input.file_path`. Parse it with the project's own
  runtime (`node -e` or `python -c`), not `jq`. Exit 0 for files the formatter
  doesn't handle. Hooks run through Git Bash on Windows.
- Add stack entries to `.gitignore` (dependency dirs, build output, caches).

## 7. Verify

Run every command written into `CLAUDE.md`, and trigger the hook once by
editing a file. Anything that fails gets fixed, or goes in
`status/ISSUES.md` under Needs checking. Never leave an unverified command
unmarked.

## 8. Report, then stop

```
Project:  <name>: <one line>
Stack:    <...>
Gate:     <lint> · <types> · <test> [· <run>]  → all green | <what failed>
Plan:     <n> phases; phase 1 is <one line>
Files:    <created / changed>
```

Then say: "Review `docs/plan.md` and `docs/phases.md`. Tell me what to
change, or say **continue** to start phase 1." Don't commit, and don't start
phase 1 until the user says so.
