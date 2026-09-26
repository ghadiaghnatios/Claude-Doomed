# Claude-Doomed

A universal Claude Code workspace setup for any kind of project.

## Install

Open a terminal in your new (or existing) project folder and run the command for your OS.

**Windows** (PowerShell):

```powershell
irm https://raw.githubusercontent.com/ghadiaghnatios/Claude-Doomed/v1.1.0/install.ps1 | iex
```

**macOS / Linux** (Terminal):

```sh
curl -fsSL https://raw.githubusercontent.com/ghadiaghnatios/Claude-Doomed/v1.1.0/install.sh | sh
```

Then, on any OS, run `claude` and say **setup yourself**. It asks what you're building, then offers its recommended answers for the rest (the stack, how much autonomy to give it, whether to add Context7). Accept them, or go through them one at a time, each with options and room for your own answer. It then shows the plan and writes nothing until you approve it. Once it's built and the checks pass, say **continue** to start phase 1. Existing files are never overwritten.

During setup, Claude Code asks you to approve a few writes to `.claude/` (settings and rules). That's a built-in safety check and can't be skipped, so approve them.

## Update an existing project

This refreshes only the files the template owns (the `setup`, `close-phase` and `edit` skills, the `reviewer` agent, the secret guard hook, `rules/security.md`). Your `CLAUDE.md`, settings, docs and code are left alone.

**Windows** (PowerShell):

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/ghadiaghnatios/Claude-Doomed/v1.1.0/install.ps1))) -Update
```

**macOS / Linux** (Terminal):

```sh
curl -fsSL https://raw.githubusercontent.com/ghadiaghnatios/Claude-Doomed/v1.1.0/install.sh | sh -s -- --update
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
  skills/edit/         /edit <idea> saves a change for later; /edit run plans and builds them
.github/workflows/ci.yml   the same gate on every push and PR
.mcp.json              only if you opted into Context7
app/                   all runnable code
docs/                  DEFINITION: plan.md, phases.md, architecture.md, decisions/ (ADRs), edits.md
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
- Ideas for later go in with `/edit add a dark-mode toggle`. Nothing is built until you say `/edit run`, which turns them into new phases for you to approve.
- *Review each phase* mode stops after every phase. *Run all phases* mode keeps going and stops only on a blocker.

**Requirements:** Claude Code, plus Git Bash on Windows (Claude Code already needs it, and the hooks run through it).

## Releasing (maintainers)

Installs are pinned to a release tag, so pushing to `main` changes nothing for users until you tag.
1. Run `sh test/setup-smoke.sh` (needs a logged-in `claude`).
2. Replace the old version with the new one in `install.sh`, `install.ps1` and this README.
3. Commit, then `git tag vX.Y.Z && git push origin main vX.Y.Z`.

## All commands

**Inside Claude** (run `claude` in the project folder):

| Type | What it does |
|---|---|
| `setup yourself` or `/setup` | Asks what you're building, offers recommended answers for the rest, shows the plan, and builds the workspace only after you approve. Run it again later to refresh only the config. |
| `continue` | Starts the next phase. Needed after setup, and after every phase in *Review each phase* mode. |
| `close the phase` or `/close-phase` | Runs the gate and the reviewer, writes the phase report, and updates progress and issues. Runs by itself at the end of every phase. |
| `/edit <idea>` | Saves a change for later in `docs/edits.md`. Builds nothing. |
| `/edit` | Shows the saved changes and asks what to add. |
| `/edit run` or `run the edits` | Turns the saved changes into new phases, asks you to approve them, then builds them. |

**In a terminal:**

| Command | What it does |
|---|---|
| `irm https://raw.githubusercontent.com/ghadiaghnatios/Claude-Doomed/v1.1.0/install.ps1 \| iex` | Install on Windows. |
| `curl -fsSL https://raw.githubusercontent.com/ghadiaghnatios/Claude-Doomed/v1.1.0/install.sh \| sh` | Install on macOS / Linux. |
| `& ([scriptblock]::Create((irm https://raw.githubusercontent.com/ghadiaghnatios/Claude-Doomed/v1.1.0/install.ps1))) -Update` | Update the template-owned files on Windows. |
| `curl -fsSL https://raw.githubusercontent.com/ghadiaghnatios/Claude-Doomed/v1.1.0/install.sh \| sh -s -- --update` | Update the template-owned files on macOS / Linux. |
| `sh test/setup-smoke.sh` | Maintainers: check the setup interview before a release. |
