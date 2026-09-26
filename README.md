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

Then, on any OS, run `claude` and say **setup yourself**. It asks one round of questions, then builds everything below and stops so you can review the plan. Say **continue** to start phase 1. Existing files are never overwritten.

## What you get

```
CLAUDE.md            always loaded: layout, commands, working rules
.claude/
  settings.json      enforced: allow/deny lists, format-on-edit hook
  rules/             conventions: security.md always, the rest scoped to the files they cover
  skills/setup/      the installer + templates (re-runnable, config only)
  skills/close-phase/  gate → report → progress → issues, plus the final sweep
app/                 all runnable code
docs/                DEFINITION: plan.md, phases.md, architecture.md, decisions/ (ADRs)
status/              STATE: PROGRESS.md, ISSUES.md, reports/phase-N.md
```

**Token cost:** every session loads only `CLAUDE.md`, `status/PROGRESS.md` and `rules/security.md`, plus a one-line description per skill. Everything else loads when it's needed.

**Safety:** `settings.json` blocks reading `.env`, key and cert files, force-push, `reset --hard`, `clean -fd` and `rm -rf` on `/` or `~`. Only the project's own gate commands are pre-approved. No MCP servers, plugins or extra dependencies get installed.

**Workflow:** one phase at a time. Each phase is a slice that works end to end, touches only the files it lists, and has acceptance criteria you can run. Schema and contract changes need an ADR first. Every bug found goes into `status/ISSUES.md`, and `PROGRESS.md` is updated before Claude stops for any reason.
