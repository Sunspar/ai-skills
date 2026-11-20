# AI Skills

An opinionated collection of reusable agent workflows for software engineering and knowledge work. Each skill lives in its own directory, with `SKILL.md` as its entry point and optional templates or reference material beside it.

The collection favors explicit feedback loops, durable project context, vertical delivery, and clear handoffs between human and agent work.

## Installing and refreshing

Run [`scripts/sync-skill-links.sh`](scripts/sync-skill-links.sh) from the main checkout. It links every top-level skills folder into `~/.agents/skills` for Codex, and every skill into each `~/.claude*/skills/` home for Claude, which reads only one level deep. It also removes links to skills that no longer exist. To refresh after skill changes land, pull first and then run it:

```sh
git -C ~/workspace/personal/ai-skills pull --ff-only && ~/workspace/personal/ai-skills/scripts/sync-skill-links.sh
```

## Choosing and invoking a skill

Skills marked **automatic** describe when an agent may select them from the user's request. Skills marked **explicit** are deliberate commands or orchestrators and are intended to be invoked by name.

Before using tracker-dependent workflows such as `delivery`, `triage`, or `wayfinder` in a new project, run `setup-engineering-skills` once.

## Engineering skills

| Skill | Primary function | Use it when | Benefits and tradeoffs |
| --- | --- | --- | --- |
| [`setup-engineering-skills`](skills/engineering/setup-engineering-skills/SKILL.md) · explicit | Configures issue-tracker instructions, triage labels, and domain-document layout for a repository. | Preparing a project for the other engineering workflows, or changing its tracker or domain layout. | Establishes one shared convention for several skills. Unlike configuring each workflow ad hoc, it has an up-front interactive setup cost and is normally run only once. |
| [`domain-modeling`](skills/engineering/domain-modeling/SKILL.md) · automatic | Sharpens domain language and records resolved terms in `CONTEXT.md` and durable tradeoffs in ADRs. | Terminology is fuzzy, code and business language disagree, or a hard-to-reverse design decision needs recording. | Records durable domain vocabulary and decisions beyond `software-design`'s implementation guidance. It can slow a design conversation with terminology work and deliberately avoids implementation detail. |
| [`grill-with-docs`](skills/engineering/grill-with-docs/SKILL.md) · explicit | Combines a relentless design interview with live domain-model and ADR updates. | A plan needs stress-testing and the resulting terminology or decisions should be captured as they settle. | More durable than plain `grilling`; the tradeoff is that it writes project documentation and is too heavy for exploratory conversations whose conclusions are still disposable. |
| [`improve-codebase-architecture`](skills/engineering/improve-codebase-architecture/SKILL.md) · explicit | Scans architectural hot spots for module-deepening opportunities, presents a visual report, then grills the selected option. | A codebase is hard to navigate or test and you want evidence-backed structural refactoring candidates. | Adds repository-wide exploration, visual reports, and prioritization to `software-design`'s shared principles. It is correspondingly heavier and initially recommends rather than implements changes. |
| [`prototype`](skills/engineering/prototype/SKILL.md) · automatic | Builds disposable logic or UI experiments to answer one design question. | A state model is difficult to reason about on paper or several UI directions need to be compared. | Faster learning than a `delivery` run, with visible state and little ceremony. It intentionally skips production quality, persistence, tests, and long-term maintainability; validated decisions must later move into real code. |
| [`research`](skills/engineering/research/SKILL.md) · automatic | Delegates primary-source research and records cited findings in a Markdown artifact. | A decision depends on official documentation, specifications, APIs, or source-code reading. | Keeps research parallel and creates a reusable evidence trail. Unlike `wayfinder`, it answers a bounded factual question rather than managing a decision program; unlike a quick lookup, it adds an artifact and citation overhead. |
| [`wayfinder`](skills/engineering/wayfinder/SKILL.md) · explicit | Maps a large, uncertain effort into issue-tracker decision tickets and resolves the visible frontier over multiple sessions. | The destination matters, but too many decisions remain for one agent session or a normal plan. | Handles uncertainty and parallel decision work better than `delivery`'s slice stage, which assumes work is ready to build. It has the highest tracker and coordination overhead and deliberately plans rather than implements the destination. |
| [`triage`](skills/engineering/triage/SKILL.md) · explicit | Moves issues and eligible external PRs through verification and readiness states, producing agent-ready briefs when appropriate. | Evaluating incoming requests, reproducing claims, requesting information, or deciding whether work is ready for an agent or human. | Verifies demand before planning, unlike `delivery`'s slice stage, which decomposes already-approved work. It mutates tracker state and depends on configured label and tracker conventions. |
| [`tdd`](skills/engineering/tdd/SKILL.md) · automatic | Runs behavior-first red-to-green development at pre-agreed public seams. | Building a feature or fix test-first, especially when integration behavior matters. | Produces durable, refactor-resistant tests and limits speculative implementation. It requires agreement on seams and has more up-front cost than direct coding; for an unexplained failure, use `diagnosing-bugs` first. |
| [`diagnosing-bugs`](skills/engineering/diagnosing-bugs/SKILL.md) · automatic | Drives hard bug and performance diagnosis through a tight repro loop, minimization, ranked hypotheses, instrumentation, and regression verification. | Something is broken, flaky, throwing, or slow and the cause is unknown. | More rigorous about root cause than jumping directly into `tdd`; it refuses to theorize before a red-capable feedback loop exists. That discipline costs time and may stop pending better reproduction access. |
| [`resolving-merge-conflicts`](skills/engineering/resolving-merge-conflicts/SKILL.md) · automatic | Resolves an in-progress merge or rebase by reconstructing both changes' intent, verifying the result, and completing Git state. | Git already has conflicts that must be reconciled without losing either side's purpose. | Better suited than `diagnosing-bugs` to history and intent conflicts, and it carries the operation through to completion. It is intentionally narrow, never invents feature behavior, and its policy is to resolve rather than abort. |
| [`wizard`](skills/engineering/wizard/SKILL.md) · automatic | Generates a guided Bash wizard for human-only setup, credentials, dashboard work, migrations, or cutovers. | A procedure contains browser or secret-handling steps the agent cannot safely perform itself. | More repeatable and safer than a prose checklist, with confirmation gates and consistent secret handling. It takes scripting effort, still requires a human to run it, and should not replace automation for steps the agent can perform directly. |

## Engineering kitchen skills

The engineering kitchen is the consolidated skill set that replaces the older folders one piece at a time. Each skill has one focus, and no two skills carry the same guidance.

| Skill | Primary function | Use it when | Benefits and tradeoffs |
| --- | --- | --- | --- |
| [`adversarial-review`](skills/engineering-kitchen/adversarial-review/SKILL.md) · automatic | Reviews a change or a spec with parallel reviewers on the other model (Sol when Claude leads, Claude when Codex leads), one per lens: Skeptic, Steward, Attacker, Architect, and Minimalist. Ends with a PASS, CONTESTED, REJECT, or INCOMPLETE verdict. | A code or spec review, the approval gate in `delivery`'s review stage, or a "sol loop". | Replaces `code-review` and `sol-loop`. Cross-model reviewers avoid the author's blind spots, and the lens roster scales with the change. Loop mode fixes accepted findings and sends them back for recheck. It needs T3 or another route to the other model, and stops instead of reviewing with its own model. |
| [`delivery`](skills/engineering-kitchen/delivery/SKILL.md) · automatic | Runs every change through seven stages: intake, shape, slice, execute, review, publish, learn. Owns the definition of ready, the spec and ticket formats, proof, the merge gate, the security and one-way-door gate classes, and the trust report. | Behind `ship-pr` and `prepare-pr`, or directly to spec an idea or ticket, or break one into tickets, without building it. | Replaces `to-spec`, `to-tickets`, `implement`, and `implement-spec`, and holds what `ship-pr` and `prepare-pr` used to carry. Unattended runs decide with recorded assumptions instead of waiting for sign-off, and gate classes keep risky changes in front of a human. |
| [`ship-pr`](skills/engineering-kitchen/ship-pr/SKILL.md) · explicit | Runs `delivery` with target merged. | Asking the agent to "ship" a discussed or referenced change, or carry it through to a merged PR. | Merges only through the merge gate; a tripped gate class lowers it to a `prepare-pr` handoff. |
| [`prepare-pr`](skills/engineering-kitchen/prepare-pr/SKILL.md) · explicit | Runs `delivery` with target ready. | Asking the agent to "prepare" a discussed or referenced change. | Same loop as `ship-pr`, leaving the PR open for the user to merge. The default while trust in the loop is still being measured. |
| [`software-design`](skills/engineering-kitchen/software-design/SKILL.md) · automatic | Holds the coding standards and design vocabulary: minimal implementation, deep modules and seams, and language and framework rules. | Designing, writing, refactoring, or reviewing code; `delivery`'s execute stage and the `adversarial-review` Steward load it by name. | Project conventions override it, and nearby cleanup becomes a follow-up instead of growing the change. Learn names its rules by heading, so `meditate` can turn a repeated miss into a rule change. |
| [`brain`](skills/engineering-kitchen/brain/SKILL.md) · automatic | Owns the persistent memory: a repo's `brain/`, the shared private `~/agent-brain`, the keep test, the routing table, and the note and todo formats. | The user asks you to remember something or corrects a recurring approach, a todo is added, or any brain file is edited. | One place decides what is worth keeping and where it goes, so `reflect`, `ruminate`, and `meditate` stay consistent. Every session loads both indexes, so each note has an ongoing cost. |
| [`reflect`](skills/engineering-kitchen/reflect/SKILL.md) · automatic | Sweeps the current session for lessons and routes each to a check, a note, the skill-feedback queue, or a todo. | Wrapping up a session, especially one with corrections or friction, and the learn stage of every `delivery` run. | Replaces `retro` and applies changes instead of only proposing them. It only sees the current session. |
| [`ruminate`](skills/engineering-kitchen/ruminate/SKILL.md) · explicit | Mines T3 thread history across Claude and Codex for lessons no session captured. | Periodically, or to bootstrap a brain from existing history. | Finds repeated corrections that single-session `reflect` misses. It needs the T3 tools, costs a subagent per batch, and applies only the findings you approve. |
| [`meditate`](skills/engineering-kitchen/meditate/SKILL.md) · explicit | Audits and prunes the brain and instruction files, distills principles, and turns queued skill feedback into a skills PR. | Several `reflect` or `ruminate` passes have piled up, or skill feedback is queued. | Keeps the brain lean as it grows. It is the most expensive of the four, and it edits skills only inside `skills/engineering-kitchen/`. |

## Productivity skills

| Skill | Primary function | Use it when | Benefits and tradeoffs |
| --- | --- | --- | --- |
| [`grilling`](skills/productivity/grilling/SKILL.md) · automatic | Interviews the user through the full frontier of a branching decision tree until no assumptions remain. | Stress-testing a plan, design, or idea in a live conversation. | More adaptive and exhaustive than `to-questionnaire`. It requires synchronous user attention and can be intense; use `grill-with-docs` when settled decisions also need durable domain documentation. |
| [`handoff`](skills/productivity/handoff/SKILL.md) · explicit | Writes a redacted, temporary continuation brief for a fresh agent session. | Context is about to move to another session or agent and existing artifacts should be linked rather than repeated. | Lighter and more continuity-focused than a `delivery` spec. The output is intentionally ephemeral and is not an authoritative product or implementation specification. |
| [`teach`](skills/productivity/teach/SKILL.md) · explicit | Runs a stateful, mission-driven learning workspace with sourced lessons, reusable interactive assets, reference pages, and learning records. | The user wants to learn a topic over multiple sessions rather than receive a one-off explanation. | Builds retention and a durable curriculum beyond what `research` provides. It creates substantial workspace structure and is excessive for a quick answer or a single factual investigation. |
| [`to-questionnaire`](skills/productivity/to-questionnaire/SKILL.md) · explicit | Creates a Markdown discovery questionnaire for a knowledgeable third party to answer asynchronously. | A decision depends on facts or judgment held by someone other than the current user. | Sendable and asynchronous compared with `grilling`, and it targets the knowledge gap without asking the user to invent answers. It cannot adapt in real time and may require a follow-up round. |
| [`wait-what`](skills/productivity/wait-what/SKILL.md) · explicit | Stops the current thread and asks for a clearer re-pitch in Simplified Technical English and project vocabulary. | The last explanation did not land or shared context has broken down. | A fast conversational reset compared with launching a full `grilling` session. It clarifies communication only; it does not investigate facts or advance the underlying work. |
| [`writing-for-agents`](skills/productivity/writing-for-agents/SKILL.md) · automatic | Provides principles for writing reliable skills and agent-facing instructions using strong pointers, progressive disclosure, clear completion criteria, and minimal duplication. | Creating or revising a skill, `AGENTS.md`, `CLAUDE.md`, or another document an agent consumes. | Gives deeper instruction-design guidance than `setup-engineering-skills`, which only configures a repository. It is a reference framework rather than a complete authoring or installation workflow. |
| [`draft-vanta-policy`](skills/productivity/draft-vanta-policy/SKILL.md) · automatic | Drafts policies from named Vanta templates, verified source documents, and explicit user answers; maintains a project source map. | Adapting Vanta templates to existing company policies or indexing new material in `original-documentation/`. | Preserves every template field and section, tracks sources, marks unanswered gaps with `QQQ:`, and finishes with `humanize-writing`. Requires source material and user answers; document completeness does not establish audit acceptance. |

## Common workflows

These skills compose, but not every project needs the whole chain.

### From an idea or ticket to delivered code

`setup-engineering-skills` once, then `prepare-pr` or `ship-pr` with an idea or a ticket. Both run `delivery`'s stages: intake → shape → slice → execute → review → publish → learn. To stop once the work is specified, ask `delivery` for just the spec or the tickets.

### From a bug report to a verified fix

`triage` → `diagnosing-bugs` → regression test and fix → `adversarial-review`

### From architectural friction to an approved refactor

`domain-modeling` + `software-design` → `improve-codebase-architecture` → `grill-with-docs` → `delivery` (spec only)

### For work too uncertain for a normal plan

Start with `wayfinder`. Its decision tickets may use `research`, `prototype`, or `grilling`; once the route is clear, hand off to `delivery` for the spec and tickets.

## Repository layout

```text
skills/
├── engineering/          # Software design, planning, delivery, review, and operations
├── engineering-kitchen/  # Consolidated, single-focus skills that replace the older folders
├── new/                  # Personal PR workflows awaiting consolidation
└── productivity/         # Thinking, communication, teaching, and agent-writing workflows
```

When adding or changing a skill, keep its entry point at `<skill-name>/SKILL.md`, place branch-specific templates and references beside it, and use `writing-for-agents` as the authoring guide.
