# Shape

Turn an idea or an underspecified ticket into a spec. A one-ticket spec must be ready; a larger one must be clear enough for slice to cut into ready tickets. A ready ticket needs no shaping: say so in one line and post nothing.

## Decide

Settle each open question from the code, the project's glossary and ADRs, and the spec of record before treating it as open.

- **Unattended**: decide the rest yourself. Choose the smallest reading that meets the intent, and record it as an assumption.
- **Attended**: interview the user with the `grilling` skill, and record terms and hard-to-reverse decisions with `domain-modeling`, until no decision that changes the result is open.

Reach for `research` when a fact lives outside the repo, and `prototype` when a state model or UI is easier to judge running than on paper.

While deciding:

- For an architectural decision (a new module, interface, schema, or dependency), design it twice with the `software-design` skill's design-it-twice reference, then record the design you chose and why under Decisions.
- For a change to existing code, ask what you would build from scratch with this requirement in hand, and prefer that design when it is not much larger.
- Choose testing seams: existing seams before new ones, at the highest level the behavior crosses, as few as possible.
- Mark each one-way-door decision, and each part of the work that falls in a gate class.

## Spec format

Use the project glossary's terms and respect its ADRs. Leave out file paths and code: they go stale. The exception is a prototype snippet (a state machine, reducer, schema, or type shape) that states a decision more precisely than prose; inline only its decision-rich part and say it came from a prototype.

```markdown
## Assumptions and one-way doors
<first, so a reviewer sees them first: each assumption and the reading you chose; each one-way-door decision, why it is hard to reverse, and what reversing it would cost. "None" when empty.>

## Problem
<the problem from the user's side>

## Solution
<the solution from the user's side>

## Acceptance criteria
1. As <actor>, when <situation>, <observable result>.
<numbered and exhaustive: every actor and case the solution covers>

## Decisions
<modules built or changed and their interfaces, schema and API contracts, specific interactions; alternatives considered for architectural decisions>

## Testing
<the seams, what a good test checks here (external behavior only), and prior art in this codebase>

## Gate classes
<each predicted class and why, or "None">

## Out of scope
<work ruled out of this change>
```

## Review the spec

When the spec will be sliced into several tickets, or contains a one-way door or a security class, run `adversarial-review` on it in its spec mode, and fix the accepted findings in the spec before publishing. A one-ticket spec with neither goes straight to publish; its code gets reviewed later.

## Publish

- **Ticket**: post the spec as one comment on it. When an earlier delivery spec comment exists, post a new one that says it supersedes the earlier one.
- **Idea**: create a tracker item with the spec as its body, in the project `SKILL.md`'s Tracker section picks.
- Mark the item `ready-for-agent` when it is ready and needs no slicing, using the project's label mapping when one exists.
- Post an update with the link, listing assumptions and one-way-door decisions first, so the user can redirect you while you continue.

## Done when

The spec is published, and it is ready or states exactly what blocks it.
