# AI Skills

An opinionated collection of reusable agent workflows for software engineering and knowledge work. Each skill lives in its own directory, with `SKILL.md` as its entry point and optional templates or reference material beside it.

The collection favors explicit feedback loops, durable project context, vertical delivery, and clear handoffs between human and agent work.

## Choosing and invoking a skill

Skills marked **automatic** describe when an agent may select them from the user's request. Skills marked **explicit** are deliberate commands or orchestrators and are intended to be invoked by name.

Before using tracker-dependent workflows such as `triage`, `to-spec`, `to-tickets`, or `wayfinder` in a new project, run `setup-engineering-skills` once.

## Engineering skills

| Skill | Primary function | Use it when | Benefits and tradeoffs |
| --- | --- | --- | --- |
| [`setup-engineering-skills`](skills/engineering/setup-engineering-skills/SKILL.md) · explicit | Configures issue-tracker instructions, triage labels, and domain-document layout for a repository. | Preparing a project for the other engineering workflows, or changing its tracker or domain layout. | Establishes one shared convention for several skills. Unlike configuring each workflow ad hoc, it has an up-front interactive setup cost and is normally run only once. |
| [`codebase-design`](skills/engineering/codebase-design/SKILL.md) · automatic | Supplies a shared vocabulary and principles for deep modules, interfaces, seams, adapters, leverage, and locality. | Designing an interface, choosing a test seam, or reasoning about module depth and testability. | Lighter and more focused than `improve-codebase-architecture`; it sharpens a design without scanning the repository or producing an action plan. It is guidance, not a refactor. |
| [`domain-modeling`](skills/engineering/domain-modeling/SKILL.md) · automatic | Sharpens domain language and records resolved terms in `CONTEXT.md` and durable tradeoffs in ADRs. | Terminology is fuzzy, code and business language disagree, or a hard-to-reverse design decision needs recording. | Produces durable shared language that `codebase-design` does not. It can slow a design conversation with terminology work and deliberately avoids implementation detail. |
| [`grill-with-docs`](skills/engineering/grill-with-docs/SKILL.md) · explicit | Combines a relentless design interview with live domain-model and ADR updates. | A plan needs stress-testing and the resulting terminology or decisions should be captured as they settle. | More durable than plain `grilling`; the tradeoff is that it writes project documentation and is too heavy for exploratory conversations whose conclusions are still disposable. |
| [`improve-codebase-architecture`](skills/engineering/improve-codebase-architecture/SKILL.md) · explicit | Scans architectural hot spots for module-deepening opportunities, presents a visual report, then grills the selected option. | A codebase is hard to navigate or test and you want evidence-backed structural refactoring candidates. | More concrete and visual than `codebase-design`, with repository-wide exploration and prioritization. It is correspondingly heavier and initially recommends rather than implements changes. |
| [`prototype`](skills/engineering/prototype/SKILL.md) · automatic | Builds disposable logic or UI experiments to answer one design question. | A state model is difficult to reason about on paper or several UI directions need to be compared. | Faster learning than `implement`, with visible state and little ceremony. It intentionally skips production quality, persistence, tests, and long-term maintainability; validated decisions must later move into real code. |
| [`research`](skills/engineering/research/SKILL.md) · automatic | Delegates primary-source research and records cited findings in a Markdown artifact. | A decision depends on official documentation, specifications, APIs, or source-code reading. | Keeps research parallel and creates a reusable evidence trail. Unlike `wayfinder`, it answers a bounded factual question rather than managing a decision program; unlike a quick lookup, it adds an artifact and citation overhead. |
| [`wayfinder`](skills/engineering/wayfinder/SKILL.md) · explicit | Maps a large, uncertain effort into issue-tracker decision tickets and resolves the visible frontier over multiple sessions. | The destination matters, but too many decisions remain for one agent session or a normal plan. | Handles uncertainty and parallel decision work better than `to-tickets`, which assumes work is ready to build. It has the highest tracker and coordination overhead and deliberately plans rather than implements the destination. |
| [`to-spec`](skills/engineering/to-spec/SKILL.md) · explicit | Synthesizes the current conversation and codebase context into a tracker-published specification. | The important decisions have already been discussed and need a durable, implementation-ready spec. | Faster than `grilling` because it does not interview again. Its quality is limited by what the conversation has already settled, so use `grilling` or `grill-with-docs` first when meaningful ambiguity remains. |
| [`to-tickets`](skills/engineering/to-tickets/SKILL.md) · explicit | Converts a plan or spec into dependency-aware, tracer-bullet implementation tickets. | Work is understood and needs to be split into independently verifiable slices sized for fresh agent sessions. | More executable than `to-spec` and more delivery-oriented than `wayfinder`. It adds tracker overhead and is a poor fit while core product or architecture decisions are unresolved. |
| [`triage`](skills/engineering/triage/SKILL.md) · explicit | Moves issues and eligible external PRs through verification and readiness states, producing agent-ready briefs when appropriate. | Evaluating incoming requests, reproducing claims, requesting information, or deciding whether work is ready for an agent or human. | Verifies demand before planning, unlike `to-tickets`, which decomposes already-approved work. It mutates tracker state and depends on configured label and tracker conventions. |
| [`tdd`](skills/engineering/tdd/SKILL.md) · automatic | Runs behavior-first red-to-green development at pre-agreed public seams. | Building a feature or fix test-first, especially when integration behavior matters. | Produces durable, refactor-resistant tests and limits speculative implementation. It requires agreement on seams and has more up-front cost than direct coding; for an unexplained failure, use `diagnosing-bugs` first. |
| [`implement`](skills/engineering/implement/SKILL.md) · explicit | Implements an approved spec or ticket set, using TDD where possible, then runs review and commits the result. | The work is already specified and the user wants the full delivery workflow. | Convenient end-to-end orchestration compared with invoking `tdd` and `code-review` separately. It is broader and more mutating, offers less control over individual phases, and assumes the specification is ready. |
| [`diagnosing-bugs`](skills/engineering/diagnosing-bugs/SKILL.md) · automatic | Drives hard bug and performance diagnosis through a tight repro loop, minimization, ranked hypotheses, instrumentation, and regression verification. | Something is broken, flaky, throwing, or slow and the cause is unknown. | More rigorous about root cause than jumping directly into `tdd`; it refuses to theorize before a red-capable feedback loop exists. That discipline costs time and may stop pending better reproduction access. |
| [`code-review`](skills/engineering/code-review/SKILL.md) · automatic | Reviews a diff from a fixed point along independent standards, specification, and security axes. | Reviewing a branch, pull request, or work-in-progress change against its intended behavior and repository rules. | Broader and less implementation-coupled than running tests alone, with parallel independent perspectives. It requires a valid comparison point and ideally a source spec; it reports findings rather than fixing them. |
| [`resolving-merge-conflicts`](skills/engineering/resolving-merge-conflicts/SKILL.md) · automatic | Resolves an in-progress merge or rebase by reconstructing both changes' intent, verifying the result, and completing Git state. | Git already has conflicts that must be reconciled without losing either side's purpose. | Better suited than `diagnosing-bugs` to history and intent conflicts, and it carries the operation through to completion. It is intentionally narrow, never invents feature behavior, and its policy is to resolve rather than abort. |
| [`wizard`](skills/engineering/wizard/SKILL.md) · automatic | Generates a guided Bash wizard for human-only setup, credentials, dashboard work, migrations, or cutovers. | A procedure contains browser or secret-handling steps the agent cannot safely perform itself. | More repeatable and safer than a prose checklist, with confirmation gates and consistent secret handling. It takes scripting effort, still requires a human to run it, and should not replace automation for steps the agent can perform directly. |

## Productivity skills

| Skill | Primary function | Use it when | Benefits and tradeoffs |
| --- | --- | --- | --- |
| [`grilling`](skills/productivity/grilling/SKILL.md) · automatic | Interviews the user through the full frontier of a branching decision tree until no assumptions remain. | Stress-testing a plan, design, or idea in a live conversation. | More adaptive and exhaustive than `to-questionnaire`. It requires synchronous user attention and can be intense; use `grill-with-docs` when settled decisions also need durable domain documentation. |
| [`handoff`](skills/productivity/handoff/SKILL.md) · explicit | Writes a redacted, temporary continuation brief for a fresh agent session. | Context is about to move to another session or agent and existing artifacts should be linked rather than repeated. | Lighter and more continuity-focused than `to-spec`. The output is intentionally ephemeral and is not an authoritative product or implementation specification. |
| [`teach`](skills/productivity/teach/SKILL.md) · explicit | Runs a stateful, mission-driven learning workspace with sourced lessons, reusable interactive assets, reference pages, and learning records. | The user wants to learn a topic over multiple sessions rather than receive a one-off explanation. | Builds retention and a durable curriculum beyond what `research` provides. It creates substantial workspace structure and is excessive for a quick answer or a single factual investigation. |
| [`to-questionnaire`](skills/productivity/to-questionnaire/SKILL.md) · explicit | Creates a Markdown discovery questionnaire for a knowledgeable third party to answer asynchronously. | A decision depends on facts or judgment held by someone other than the current user. | Sendable and asynchronous compared with `grilling`, and it targets the knowledge gap without asking the user to invent answers. It cannot adapt in real time and may require a follow-up round. |
| [`wait-what`](skills/productivity/wait-what/SKILL.md) · explicit | Stops the current thread and asks for a clearer re-pitch in Simplified Technical English and project vocabulary. | The last explanation did not land or shared context has broken down. | A fast conversational reset compared with launching a full `grilling` session. It clarifies communication only; it does not investigate facts or advance the underlying work. |
| [`writing-for-agents`](skills/productivity/writing-for-agents/SKILL.md) · automatic | Provides principles for writing reliable skills and agent-facing instructions using strong pointers, progressive disclosure, clear completion criteria, and minimal duplication. | Creating or revising a skill, `AGENTS.md`, `CLAUDE.md`, or another document an agent consumes. | Gives deeper instruction-design guidance than `setup-engineering-skills`, which only configures a repository. It is a reference framework rather than a complete authoring or installation workflow. |

## Common workflows

These skills compose, but not every project needs the whole chain.

### From an idea to delivered code

`setup-engineering-skills` → `grilling` or `grill-with-docs` → optional `prototype` → `to-spec` → `to-tickets` → `implement` → `code-review`

### From a bug report to a verified fix

`triage` → `diagnosing-bugs` → regression test and fix → `code-review`

### From architectural friction to an approved refactor

`domain-modeling` + `codebase-design` → `improve-codebase-architecture` → `grill-with-docs` → `to-spec`

### For work too uncertain for a normal plan

Start with `wayfinder`. Its decision tickets may use `research`, `prototype`, or `grilling`; once the route is clear, hand off to `to-spec` or `to-tickets`.

## Repository layout

```text
skills/
├── engineering/   # Software design, planning, delivery, review, and operations
└── productivity/  # Thinking, communication, teaching, and agent-writing workflows
```

When adding or changing a skill, keep its entry point at `<skill-name>/SKILL.md`, place branch-specific templates and references beside it, and use `writing-for-agents` as the authoring guide.
