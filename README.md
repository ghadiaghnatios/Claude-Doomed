# Claude-Doomed

A universal Claude Code workspace setup for any kind of project.

## Install

Open a terminal in your new (or existing) project folder and run the command for your OS.

**Windows** (PowerShell):

```powershell
irm https://raw.githubusercontent.com/ghadiaghnatios/Claude-Doomed/main/install.ps1 | iex
```

**macOS / Linux** (Terminal):

```sh
curl -fsSL https://raw.githubusercontent.com/ghadiaghnatios/Claude-Doomed/main/install.sh | sh
```

Then, on any OS, run `claude` and say **setup yourself**. It asks its questions one at a time (what you're building, the stack, how much autonomy to give it, whether to add Context7), then builds everything below and stops once so you can review the plan. Say **continue** to start phase 1. Existing files are never overwritten.

During setup, Claude Code asks you to approve a few writes to `.claude/` (settings and rules). That's a built-in safety check and can't be skipped, so approve them.

## Update an existing project

This refreshes only the files the template owns (the `setup` and `close-phase` skills, the `reviewer` agent, the secret guard hook, `rules/security.md`). Your `CLAUDE.md`, settings, docs and code are left alone.

**Windows** (PowerShell):

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/ghadiaghnatios/Claude-Doomed/main/install.ps1))) -Update
```

**macOS / Linux** (Terminal):

```sh
curl -fsSL https://raw.githubusercontent.com/ghadiaghnatios/Claude-Doomed/main/install.sh | sh -s -- --update
```

## What you get

```
CLAUDE.md              always loaded: layout, commands, working rules, autonomy
.claude/
  settings.json        enforced: allow/deny lists, secret guard + format-on-edit hooks
  hooks/               guard-secrets.sh: blocks shell access to .env, keys, `printenv`
  agents/reviewer.md   read-only reviewer, runs at the end of every phase
  rules/               security.md always loads; the others load only for the files they cover
  skills/setup/        the installer + templates (re-runnable, config only)
  skills/close-phase/  gate → review → report → progress → issues, plus the final sweep
.github/workflows/ci.yml   the same gate on every push and PR
.mcp.json              only if you opted into Context7
app/                   all runnable code
docs/                  DEFINITION: plan.md, phases.md, architecture.md, decisions/ (ADRs)
status/                STATE: PROGRESS.md, ISSUES.md, reports/phase-N.md
```

**Token cost:** every session loads only `CLAUDE.md`, `status/PROGRESS.md` and the security rules, plus one line per skill and agent. Everything else loads when it's needed. Context7 costs roughly 1–4k tokens per session, so it's off unless you choose it.

**Safety:**
- `settings.json` blocks reading `.env`, key and cert files, plus force-push, `reset --hard`, `clean -fd` and `rm -rf` on `/` or `~`.
- A `PreToolUse` hook also blocks shell commands like `cat .env` and `printenv`.
- Only the project's own gate commands are pre-approved.
- For OS-level enforcement on macOS, Linux or WSL2, also turn on `/sandbox`.

**Workflow:**
- One phase at a time. Each phase is a slice that works end to end and touches only the files it lists.
- Each phase is closed by running the gate and getting an independent review.
- Schema and contract changes need an ADR first.
- Every bug found goes into `status/ISSUES.md`.
- *Review each phase* mode stops after every phase. *Run all phases* mode keeps going and stops only on a blocker.

**Requirements:** Claude Code, plus Git Bash on Windows (Claude Code already needs it, and the hooks run through it).
