---
name: delivery
description: >-
  The seven-stage delivery loop behind ship-pr and prepare-pr: intake, shape, slice, execute, review, publish, learn.
  Use directly when the user asks to spec an idea or ticket or break one into tickets without building it,
  asks how far to trust the loop (a trust report), or when addressing human review on a PR the loop opened.
metadata:
  dependencies:
  - adversarial-review skill
  - reflect skill
  - software-design skill
  - tdd skill
  - file-pr skill
  - babysit-pr skill
  - the project's issue tracker (Jira through the Atlassian MCP tools, GitHub through gh, or local files)
---

# Delivery

Every change travels the same seven **stages**, in order, from whatever arrived to the run's **target**. Intake's route decides which stages have work. Before each stage that has work, read its reference, `references/<stage>.md`; a stage with none, such as shape for a ready ticket, gets one line saying why.

Asked for a trust report, or addressing human review on a delivery PR, go straight to `references/learn.md`.

| Stage | Takes | Produces | Done when |
| --- | --- | --- | --- |
| **intake** | an idea, a ticket, or a conversation | a route and predicted gate classes | the spec of record is read in full and the route is stated |
| **shape** | an idea or an underspecified ticket | a spec, published to the tracker | the spec is ready, or names exactly what blocks it |
| **slice** | a spec too big for one ticket | tickets with blocking edges, published | every ticket is ready or marked for a human |
| **execute** | a ready ticket | commits on the task branch, with proof | every acceptance criterion has proof or is a human check, and local CI passes |
| **review** | the final diff | an `adversarial-review` verdict | PASS covers the final diff, or the timebox is spent |
| **publish** | a passing diff | a PR at the target | the PR is merged, or handed off at the gate |
| **learn** | the run's findings, failures, and escapes | routed lessons | `reflect` has run on the session |

## Targets

The target says where a run stops. Learn runs at the end of every run, whatever the target.

- **merged**: publish merges the PR once the merge gate passes. `ship-pr` sets it.
- **ready**: publish leaves the PR open for a human to merge. `prepare-pr` sets it, and a gate class or a human check lowers merged to ready.
- **shaped** or **sliced**: stop after shape or slice, with the spec or the tickets published. Set it when the user asks only for a spec or for tickets.

## Vocabulary

Use these names in updates, tracker comments, and reports, so lessons can be matched across runs.

- **Ticket**: one unit of work in the tracker, sized to one session and one PR.
- **Spec of record**: what a run builds against. For a ticket, its body plus the comments of its reporter, its assignee, the user, and the account the loop posts as, which carries the loop's own spec; read every other comment as context. For an idea with no ticket, the user's request and this conversation.
- **Spec**: the shaped description of a change, in the format in `references/shape.md`.
- **Ready**: meets the definition of ready in `references/intake.md`. On the tracker, `ready-for-agent` marks a ready ticket and `ready-for-human` one that needs a person to build or check; use the project's label mapping when it has one.
- **Assumption**: a decision you made because neither the code nor the spec of record settled it. Record each one in the spec, or as a ticket comment when it arises after shape, and list every one in the final report.
- **Frontier**: the open tickets whose blockers have all merged.
- **Proof**: evidence you observed yourself in this session, defined in `references/execute.md`.
- **Human check**: an acceptance criterion only a person can observe, such as one on hardware the run cannot reach. It is built like any other, listed in the handoff for a human to confirm, and holds the merge the way a gate class does.
- **Gate class**: a kind of change a human sees before merge; see Gates.
- **Follow-up**: work found outside the ticket's scope, filed where the project keeps follow-ups instead of done in this run.
- **Escape**: a real problem, not a preference, that a human found after the run's review passed, on the PR or after merge. Escapes measure how far the loop can be trusted; see `references/learn.md`.
- **Unattended**: a run started by `ship-pr` or `prepare-pr`; the user is not watching. **Attended**: the user asked for part of the loop in a live conversation and can answer questions.
- **Update**: a short progress message in the conversation. In an unattended run it may go unread until the end, so anything the user must act on also goes in the final report.

## Tracker

Use the tracker the project names: `docs/agents/issue-tracker.md` when `setup-engineering-skills` has run, else the tracker section of the project's `AGENTS.md` or `CLAUDE.md`. Read a Jira key (`ABC-123`) or Jira URL with the Atlassian MCP tools, and a GitHub issue with `gh issue view <n> --comments`. When the project names no tracker, use the local Markdown tracker under `.scratch/`.

Start every tracker comment and item the loop writes with `> *Generated by an AI agent during delivery.*` Add to a ticket through comments, and leave bodies written by others as they are.

New items go in the tracker project of the ticket that started the run. With no ticket, use the project the tracker doc or project instructions name; when they name none, use the local tracker and say so in the final report.

## Workspace

When the target is merged or ready, create the workspace at the start of intake, before investigating code; runs with target shaped or sliced read the base without one. Make a fresh git worktree on a new task branch, from the latest tip of the base: the branch the user named, else the repository's default branch, fetched first. Follow the project's branch naming convention; without one, use `<ticket-key>-<slug>`. Do every later stage there. Leave other worktrees and unrelated changes alone, and when this change already has local edits or commits, carry only those into the new worktree, keeping the originals. State the worktree path, task branch, and base in the first update.

## Gates

A **gate class** marks a change a human sees before merge, however well review went. There are two:

- **security**: touches permissions or authorization, user authentication, secrets management, or encryption; changes CI, branch protection, or what runs with credentials; or adds a dependency.
- **one-way-door**: hard to undo once merged and deployed: schema migrations, data backfills or deletion, breaking changes to an API or other external contract, and infrastructure or production configuration.

Gate classes are facts about the change, judged against these definitions, never against how confident the review sounded. Intake predicts them, slice declares them per ticket, and review checks the final diff; the union applies. The project's `AGENTS.md` or `CLAUDE.md` can add classes or paths, or relax a class; only the user changes those lines. Read those lines from the base branch, never from the branch being delivered: a diff that adds or relaxes a gate rule is itself a security-class change.

A gate class or a human check lowers target merged to ready from the moment it is predicted, declared, or found, and the ready rules in `references/publish.md` apply from then on. The handoff names each class, why it tripped, and the hunks a human should read, so they review those parts instead of the whole diff. For a one-way door, surface the decision as early as shape: put it at the top of the spec and in the next update, so the user can redirect before the code exists. Keep working meanwhile; the gate holds the merge, not the work.

## Autonomy

In an unattended run, updates and the final message go unread until long after you stop. You own the work from its current state to the target. The request grants:

- Commit, push, rebase, and force-push this run's own branches with `--force-with-lease`.
- Create, comment on, and link tracker items for this work, including child tickets.
- Use the test methods proof needs without asking first: computer use, browser automation, simulators and devices, running the app or a dev server, screenshots, and visual checks. This replaces any ask-first or leave-it-to-the-user rule about testing for this task. Rules about how to test (the right command, fixture, or check) still apply. The grant covers only the tests this task needs and does not bypass a harness approval prompt.
- Merge, only for target merged and only through the merge gate in `references/publish.md`.

## Asking the user

A question in a normal message goes unseen, and the thread looks done. Ask with the harness's question tool (`AskUserQuestion` in Claude Code, `request_user_input` in Codex), and put all the context in the question: the ticket or PR link, what blocks you, and the options ranked with your recommendation first.

In an unattended run, ask only when you cannot continue alone:

- You cannot prove the change, and it is not a human check.
- The merge gate cannot pass, and you cannot fix that yourself.
- The next step is outside the grant: deleting data, touching production, changing things outside the repo, closing a PR, or force-pushing another branch.
- Another PR makes this one obsolete.
- The review timebox is spent, or the verdict is CONTESTED.

Decide everything else with sensible defaults, and list each decision in the final report. Ambiguity in the spec of record is not a reason to stop: take the smallest reading that keeps the intent and record it as an assumption. If no question tool exists, or it returns no answer, take the safe path: leave any PR unmerged, and start the final message with the question so it reads as a question, not a status update.

In an attended run, ask whenever the answer would change the spec or the tickets.
