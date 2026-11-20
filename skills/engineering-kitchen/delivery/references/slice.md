# Slice

Cut a spec into **tickets**: tracer-bullet vertical slices, each declaring the tickets that **block** it, published to the tracker.

## Draft the slices

- Each ticket cuts a narrow but complete path through every layer the behavior crosses (schema, API, UI, tests). A finished ticket is demoable or verifiable on its own.
- Each ticket is ready by the definition in `intake.md`, including one session and one PR.
- Prefactoring comes first, as its own ticket: make the change easy, then make the easy change.
- Put each one-way-door change in its own small ticket where possible, so the part a human must read stays small.
- Give each ticket its blocking edges: the tickets that must merge before it can start. Keep only edges that truly gate the work; a ticket with no blockers can start at once.

**Wide refactors** are the exception to vertical slicing. A wide refactor is one mechanical change (renaming a column, retyping a shared symbol) whose blast radius fans across the codebase, so no vertical slice can land green. Sequence it as **expand–contract**:

1. Expand: add the new form beside the old, so nothing breaks.
2. Migrate: move call sites over in batches sized by blast radius (per package or directory), one ticket per batch, each blocked by the expand. CI stays green between batches because the old form still exists.
3. Contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch.

When batches cannot stay green alone, merge the inseparable ones into a single ticket: a mechanical change can be larger than one sitting's read, provided it lands green.

## Ticket format

```markdown
## Parent
<link to the spec's tracker item>

## What to build
<the end-to-end behavior this ticket makes work, from the user's side, not a layer-by-layer list>

## Acceptance criteria
- [ ] <observable criterion>

## Proof
<how an agent observes each criterion met: the command, test, or check>

## Gate classes
<each class and why, or "None">

## Blocked by
<each blocking ticket, or "None (can start immediately)">
```

As in the spec, leave out file paths and code, except a decision-rich prototype snippet.

## Confirm the breakdown

- **Attended**: show the numbered breakdown with each ticket's title, blockers, and what it delivers. Ask whether the granularity is right, whether each blocking edge truly gates, and whether any ticket should merge or split. Iterate until the user approves.
- **Unattended**: publish without waiting, and list the breakdown in the next update so the user can review it while you work.

## Publish

Publish tickets in dependency order (blockers first), so each "Blocked by" can reference real identifiers.

- **A real tracker** (Jira, GitHub): one child item per ticket under the spec's item. Use the tracker's native blocking and parent links where it has them. Label each `ready-for-agent`, or `ready-for-human` when its proof needs a person.
- **Local tracker**: one file per ticket at `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01` in dependency order, with a `Status:` line.

Leave the parent item's body and state alone.

## Done when

Every ticket is published with its blocking edges and gate classes, and the update names the frontier. Unless the target is sliced, work the frontier next (`frontier.md`).
