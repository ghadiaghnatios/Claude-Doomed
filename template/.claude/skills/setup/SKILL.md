---
name: setup
description: Set up or reconfigure this workspace for Claude (interview, plan, folder layout, CLAUDE.md, rules, permissions, hooks). Use when the user says "setup yourself", "run the setup", "set yourself up", "configure claude", or when CLAUDE.md says setup is pending.
---

# Workspace setup

This turns the folder into a configured workspace. Templates live next to
this file in `templates/`. Rules while it runs:

- Interview first, **one question at a time**, then run to the end without
  asking more. Stop only on a failure, and report the exact error.
- Write nothing outside this folder. Never touch `~/.claude/`.
- Add no MCP servers, plugins or skills unless the user opted in during the
  interview. Add no dependency beyond what the stack's official generator installs.
- **Never edit the managed files.** The updater overwrites them:
  `.claude/skills/setup/**`, `.claude/skills/close-phase/**`,
  `.claude/agents/reviewer.md`, `.claude/hooks/guard-secrets.sh`,
  `.claude/rules/security.md`. Project-specific additions go in other files.
- Never handle a secret. If one is needed, name the env var and have the
  user set it.

## Layout this produces

```
CLAUDE.md            always loaded: layout, commands, working rules (≤50 lines)
.claude/
  settings.json      enforced: allow/deny lists, secret guard + format hooks
  hooks/             guard-secrets.sh
  agents/            reviewer (read-only, used by close-phase)
  rules/             conventions; security*.md always, the rest path-scoped
  skills/            setup (this), close-phase
.github/workflows/ci.yml   the same gate on every push and PR
.mcp.json          only if the user opted into Context7
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

## 2. Interview (one question at a time)

Ask each question on its own and wait for the answer before asking the next.
Never list several questions in one message, and never put more than one
question in an AskUserQuestion call. Use earlier answers to shape later
questions and the recommended option. Skip any question already answered or
inferable.

Description, in plain text, one message each:
1. What is it?
2. Who uses it?
3. What does it store?
4. What's the core flow?
5. What's out of scope for v1?

Then the choices, one AskUserQuestion call each, recommended option first:
6. Stack: language/framework, front end or none, database or none.
7. Is there a runnable service? (decides whether "app boots" is part of the gate)
8. Autonomy: **Review each phase** (recommended: stop after every phase) or
   **Run all phases** (keep going, and stop only on a blocker, a failing gate
   you can't fix, an ADR that needs approval, or the end).
9. Context7 library docs (MCP)? **No** (recommended, it costs ~1-4k tokens
   every session) or **Yes** (worth it for fast-moving frameworks; a free API
   key from context7.com/dashboard raises the rate limits).
10. Project name. Skip if it's obvious from the description or the folder name.

Write down what you inferred instead of asking. If AskUserQuestion isn't
available (non-interactive run), or the user already answered in their
message, use those answers or the recommended defaults, and list your
assumptions under Open questions in `docs/plan.md`.

## 3. Scaffold `app/`

New project only. Use the stack's official generator (`npm create vite@latest`,
`uv init`, `cargo new`, `go mod init`, etc.) with the lint, format, typecheck
and test tooling the ecosystem treats as default. Hand-write no application
code. Phase 1 builds the first real path. The only exception is one smoke
test (for example, "the package imports") so that the test runner and the
type checker have something to run. A gate that fails on an empty scaffold
teaches everyone to ignore it. Several deployables go in
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
| `.github/workflows/ci.yml` | no template. On push and pull_request: check out, set up the runtime with dependency caching, install, then run lint, types and test with the exact `CLAUDE.md` commands (`working-directory: app`). Set `permissions: contents: read` and pin actions to a major version. Skip if the folder already has CI; add the gate to it instead. |

In `CLAUDE.md`, write the Autonomy line from the interview answer:
- Review: `Autonomy: after close-phase, stop and wait for "continue".`
- Run all: `Autonomy: after close-phase, start the next phase. Stop only on a
  blocker, an unfixable gate, an ADR that needs approval, or the last phase
  (then run the final sweep).`

The `@status/PROGRESS.md` import in `CLAUDE.md` must point at a file that
exists. A missing import fails silently.

## 5. Conventions: `.claude/rules/`

- `security.md` is managed, so don't edit it. Put stack-specific security
  rules in `security-project.md` (no `paths`, so it's always loaded, ≤10
  lines). Only write it if there's something specific to say.
- `code.md` with `paths: ["app/**"]`: language conventions the linter
  doesn't enforce, like error handling, logging, what not to reach for. ≤20 lines.
- One more file per real area (`api.md`, `ui.md`, `db.md`, `tests.md`...),
  each scoped with `paths:` to that area's files. Only write one when there's
  something specific to say. No generic advice.

## 6. Config: `.claude/settings.json`

Claude Code asks the user to approve writes under `.claude/`. That's on
purpose, so don't try to get around it. Write each `.claude/` file once, in
full, one after another, so the user sees only a few prompts. If a write is
denied or can't be approved (non-interactive run), put the exact intended
content in the final report so the user can apply it.

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
- Keep the `PreToolUse` guard-secrets hook entry as it is.
- Add stack entries to `.gitignore` (dependency dirs, build output, caches).
- Context7 opted in: write `.mcp.json` with
  `{"mcpServers":{"context7":{"type":"http","url":"https://mcp.context7.com/mcp","headers":{"Authorization":"Bearer ${CONTEXT7_API_KEY}"}}}}`.
  Tell the user to set `CONTEXT7_API_KEY` in their own shell (never ask
  for the value), then restart Claude and approve the server. Add one line
  to `CLAUDE.md`: check Context7 before writing against an unfamiliar
  library API.

## 7. Verify

Run every command written into `CLAUDE.md`, and trigger the format hook
once by editing a file. The gate must be green on the fresh scaffold. Anything that fails gets fixed, or goes in
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
phase 1 until the user says so, even in Run-all mode. The plan always gets
one human look.
