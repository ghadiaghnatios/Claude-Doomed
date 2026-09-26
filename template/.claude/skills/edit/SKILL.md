---
name: edit
description: Save a change idea for later in docs/edits.md, or build the saved ones. Use when the user runs /edit, says "note this for later", "add to the edits", "later the app should...", or "run the edits" / "do the edits".
argument-hint: "[what to change later] | run"
---

# Edits: changes saved for later

`docs/edits.md` is the backlog of add-ons and changes the user wants after
the current plan. Noting an edit never builds it.

Arguments: $ARGUMENTS

## Note an edit (any argument except "run")

1. Create `docs/edits.md` from the format below if it doesn't exist.
2. Append the argument under **Pending** as `- [ ] <YYYY-MM-DD>: <the edit, in
   the user's words>`. If it's vague, keep their words and add one line of
   what you think they mean in brackets. Don't ask.
3. Reply in one line: "Saved for later (N pending)." Don't touch code, the
   plan or the phases.

No argument: show the Pending list and ask, in plain text, what to add.

## Run the edits ("run", or the user asks to run/do the edits)

1. Read Pending in `docs/edits.md`, plus `docs/plan.md` and `docs/phases.md`.
2. Group the edits into new phases appended after the last phase in
   `docs/phases.md`, with the same shape as the others: Goal, Touches,
   Acceptance you can run. Related edits share a phase; keep each phase
   reviewable in one sitting. Flag any edit that conflicts with the plan or
   needs an ADR.
3. Show the new phases in chat (one line each, with the edits they cover),
   then one AskUserQuestion: **Approve and build (Recommended)** or **Change
   something**. Without AskUserQuestion, list the same options in plain text
   ending with "Or type your own." Loop until approved. Write nothing before.
4. On approval: write the phases, move each edit from Pending to **Planned**
   as `- phase N: <edit>`, and add any new scope to `docs/plan.md`.
5. Build them like any other phase: one at a time, `close-phase` after each,
   and follow the Autonomy line in `CLAUDE.md`. When a phase closes, move its
   edits from Planned to **Done**.

## Format

```
# Edits

Changes saved for later. `/edit <idea>` adds one; `/edit run` builds them.

## Pending

## Planned

## Done
```
