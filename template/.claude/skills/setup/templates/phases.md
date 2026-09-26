# <PROJECT_NAME>: phases

`plan.md` says what and why. This file says in what order and how each phase is accepted.

Every phase delivers something observable end to end, never a horizontal layer
like "set up the database". The phase plan is approved before execution. Only
the files under **Touches** may change. The phase is done when every
acceptance box has been checked by running something.

## Spec

<Behaviour per area: inputs, outputs, error cases. If a phase needs something
this section doesn't say, add it here first.>

### <Area>

<...>

## Phase 1: walking skeleton

**Goal:** one trivial path works end to end through every layer.
**Touches:** <explicit file list>
**Acceptance:**
- [ ] `<RUN_CMD>` starts and <the path> works, demonstrated
- [ ] gate green, with a test covering the path

## Phase 2: <name>

**Goal:** <observable outcome>
**Touches:** <file list>
**Acceptance:**
- [ ] <criterion that can be run>
- [ ] gate green

## Deferred

Features postponed on purpose. Defects don't belong here; they go in `status/ISSUES.md`.

| Item | Why deferred | Revisit when |
|---|---|---|
