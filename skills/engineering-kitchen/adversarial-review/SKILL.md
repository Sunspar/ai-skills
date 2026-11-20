---
name: adversarial-review
description: >-
  Review a code change (PR, branch, commit, or diff) with parallel reviewers on the other model, each attacking through one lens, and end with one verdict.
  Use when the user asks for a code review, an adversarial review, or a "sol loop", or another skill requires review as an approval gate.
metadata:
  dependencies:
  - software-design skill
  - writing-for-agents skill
  - T3 Code delegate_task, or another route to the other model
---

# Adversarial review

Reviewers on the **other model** attack the change, each through one **lens**. A reviewer on your own model shares your blind spots, so when you are Claude the reviewers are Sol, and when you are Codex they are Claude. You are the **lead**: you verify every finding against the code, judge it, and issue one verdict.

The review runs in one of two modes:

- **Report**: one round and a verdict, leaving the author's files intact. This is the default.
- **Loop**: you also fix the findings you accept and send the fixes back for re-review until the verdict holds. Use it when a calling skill makes review its gate, when the user asks you to fix findings, or when the user says "sol loop", which also pins every reviewer to Sol.

Publishing stays with the user in both modes: PR comments, approvals, pushes, and merges need their own request.

## Lenses

Each lens gets one reviewer, and that reviewer works through its lens alone, so one concern cannot mask another. Each lens's full brief is in `references/lenses/<lens>.md`.

| Lens | Attacks | Runs when |
| --- | --- | --- |
| **Skeptic** | Correctness and proof: inputs, states, and sequences that break it; unhandled errors; claims and tests that prove nothing | Always |
| **Steward** | Written standards: project instructions, `software-design`, and `writing-for-agents` | Application source, tests, or agent instructions changed |
| **Attacker** | Security: a path from attacker-controlled input to privileged operations, data, or secrets | Anything that executes or grants access changed: source, dependencies, configuration, CI, or permissions |
| **Architect** | Structure and scale: boundaries, coupling, ownership, the data model, growth under load | The change is medium or large, or adds a module, public interface, schema, dependency, or data-access path |
| **Minimalist** | Necessity: what to delete, speculative flexibility, scope creep, redundant tests, change size | The change is large, or adds an abstraction, option, or configuration |

Size the change from `git diff --shortstat`, leaving out generated files and lockfiles. **Small** is under 50 lines in at most 2 files, **large** is 200 or more lines or 6 or more files, and **medium** is everything between.

## Steps

### 1. Fix the snapshot

Run `git status --short`. Leave unrelated changes alone: do not stash, discard, or include them. When the change's paths separate cleanly, review only those paths. Otherwise stop and ask.

Resolve the change to one snapshot that every reviewer in a round uses. The base ref is the one the user or calling skill supplied, else the default branch, after `git fetch origin`.

- **Local work:** use `git merge-base HEAD <base-ref>`. The change runs from the base to the working tree, untracked files included. Without a remote, use a supplied local base, or `HEAD` for uncommitted changes only.
- **Named branch:** resolve its head with `git rev-parse --verify <branch>` and use `git merge-base <base-ref> <head-sha>`. The change is `git diff <merge-base> <head-sha>`. Read surrounding code at the head SHA (`git show <head-sha>:<path>`), not from the current checkout.
- **PR:** run `gh pr view <n> --json baseRefName,headRefOid`. Check out the head only if the tree is clean, confirm `HEAD` matches it, and use `git merge-base HEAD origin/<baseRefName>`.
- **Commit:** `git show <sha>`.
- **Staged or unstaged only:** `git diff --cached` or `git diff`. Staged content can differ from the file on disk.
- **Supplied patch:** review it against the surrounding code you can reach, and state what context is missing.

Resolve refs to SHAs with `git rev-parse --verify` and use the SHAs throughout. Stop on an invalid ref, and report an empty diff as empty. Record the base SHA, the head (a SHA or the working tree), the diff command, the commit list, the changed and untracked files, and the shortstat.

Loop mode reviews local work, so each round's diff picks up the previous round's fixes. Keep the base, paths, and diff command fixed across rounds; only the working tree moves. To loop on a named branch or PR, check it out first. Review a commit, a staged-only change, or a patch in report mode.

### 2. Pick the lenses

Size the change and pick lenses from the table. Add a lens below its threshold when the diff gives it work. Record each lens you skip and why, for example "Steward: only lockfiles changed".

### 3. Gather intent, standards, and evidence

Gather these once, for every reviewer:

- **Intent:** what the author is trying to achieve, in 1–3 sentences, and what is out of scope. Draw on the user's requirements, the PR description, linked issues, commit messages, ADRs (`docs/adr/`), architecture docs, the glossary, and specs under `specs/` or `.scratch/`. Reviewers challenge whether the work achieves the intent well. Whether the intent is right is not part of the review. Without a spec, judge against the stated goal, public contracts, existing behavior, and tests, and mark spec coverage unverified.
- **Standards**, when the Steward runs: applicable `AGENTS.md` and `CLAUDE.md` files (nested ones apply within their directory), `CODING_STANDARDS.md`, `CONTRIBUTING.md`, and other design, naming, and testing guidance. For code, load the `software-design` skill and note the absolute paths of its file and of the references relevant to the changed languages and frameworks. For agent instructions, note the `writing-for-agents` skill's path.
- **Security context**, when the Attacker runs: `SECURITY.md`, threat models, security ADRs, and guidance on authentication, authorization, tenant isolation, privacy, and secrets.
- **Evidence:** run the smallest covering tests and the repository's required checks, and record the commands and results. Collect CI results and the author's reported tests, screenshots, or benchmarks. Keep your own runs separate from the author's claims, and pre-existing failures separate from regressions. In loop mode, fix any failures the change caused before round 1.

Ask about missing intent only when the answer could change the verdict, and keep working meanwhile.

### 4. Spawn the reviewers

**Choose the model.** In T3, call `orchestrator_capabilities` once per thread. Take an enabled provider of the other kind that can run cross-provider child tasks: driver `codex` when you are Claude, or `claudeAgent` when you are Codex. Use its latest Sol or latest Opus model unless the user named one. Never hardcode a model ID. Record the provider, model, and effort as far as the tools expose them.

If the T3 tools are not listed, try one direct `orchestrator_capabilities` call, since they can load late. Outside T3, use a native subagent only if it runs the other model. When no route reaches the other model, report the blocker and stop. Whether a same-model reviewer is acceptable is the user's decision.

**Spawn in parallel.** In one turn, send one `delegate_task` per lens with `role: "review"`, `mode: "async"`, the title `review: <lens> r<round>`, a fresh `clientRequestId`, and that lens's brief as `task`. Save each `taskId`. The `childThreadId` is for storage only; don't send messages to it. Every round and every rebuttal is a new `delegate_task`. Never use `t3_thread_send`, `create_threads`, or `t3_thread_launch` for review.

**Wait.** Leave the scoped files untouched while reviewers run. Follow each task's `next` and wait for every completion notice instead of polling. A timeout, an error, or an empty reply is not approval. Cancel that task, confirm it stopped, and respawn the lens once with the same brief. A lens that fails twice makes the verdict INCOMPLETE.

#### Reviewer brief

T3 children start with no history, so the brief has to carry everything, with absolute paths:

```text
You are the <Lens> in an adversarial code review. Your job is to find real problems, not to validate the work. Review only: do not edit, commit, push, comment on PRs, or start subagents. Read any file and run read-only commands as needed.

1. Intent: <intent>. Out of scope: <out of scope>.
2. Lens: read <skill dir>/references/lenses/<lens>.md and review through that lens alone.
3. Principles: read each principle file your lens lists. <Steward only: also read <standard and skill paths>.> If a file is missing, say so and continue from the lens.
4. Change: repo <abs path>; base <sha>; diff `<diff command>`; changed files <list>; untracked files <list>. Checks: <commands and results>. Evidence gaps: <gaps>.
5. Findings: read the surrounding code, callers, and tests beyond the diff, and account for every changed file. Report only problems this change introduces, exposes, or worsens, each with file:line and a concrete failure scenario. Rate each one, letting your lens file's severity notes refine these:
   high = blocks ship: the intended case is wrong, callers will hit the bug, the intended behavior is unproven, a concrete vulnerability, or a broken written standard.
   medium = should fix: a concrete improvement worth making now.
   low = worth noting: other paths, rare cases, small costs, nits.

Reply with a numbered list using your lens's ID prefix, then coverage:
<ID> [high|medium|low] <file>:<line> <claim>. Scenario: <input or state -> wrong result>. Principle: <slug, or standard file#section>. Fix: <smallest fix>.
Coverage: <what you reviewed, what you could not, and why>.
```

For a later round or a rebuttal, send the same brief plus that lens's ledger entries (`fixed:`, `disagree:`, or `declined:`, each with evidence) and the change since the last round. Tell the reviewer to check only its open IDs and the changed code, and to mark each old ID `resolved`, `withdrawn`, or `still open: <reason>`.

### 5. Judge the findings

Once every reviewer has returned, read the lens files of the lenses that ran. Their severity notes bind you too. Then, for each finding:

1. **Verify** it against the code. Keep it only when the change introduces, exposes, or materially worsens the problem. Check the surrounding guards, callers, contracts, and tests, and reproduce the problem when that is cheap. To confirm a finding by changing code, use an isolated copy of the snapshot, and in report mode get approval first.
2. **Recalibrate** its severity yourself. Another path, a rare case, or a small cost is low whatever its label.
3. **Deduplicate.** Findings that share an underlying reason merge into one under a primary lens and cross-reference the others. Distinct reasons at the same location stay separate.
4. **Judge** it: accept or reject it with a one-line rationale framed by the intent and the principle it cites. Read that principle first. Reviewers are adversarial by design, so call out false positives, overreach, and style mistaken for substance. Back a rejection with evidence (file:line, a test, or command output), and never accept a finding just to end the loop.

A high finding you reject is **disputed** until its reviewer withdraws it. In loop mode the rebuttal goes in the next round. In report mode, send one rebuttal round to that lens when the dispute decides the verdict.

Keep a **ledger** across rounds with each finding's ID, lens, severity, judgment, and outcome (open, fixed, declined, disputed, resolved, or withdrawn), plus usage when a reviewer reports it. Never guess usage.

### 6. Fix and recheck (loop mode)

In report mode, skip to step 7.

The budget is 3 rounds. Extend it to 5 only when the user asks, or while a high finding about security, permissions, authentication, data loss, or state and concurrency stays open with evidence.

Answer each accepted finding:

- **High:** fix it.
- **Medium:** fix it when the fix is small and in scope. Otherwise decline it and list it as a follow-up.
- **Low:** decline it in one line and list it as a follow-up.

Make the smallest fix. Prefer deleting or narrowing code over adding a lock, cache, helper, or option, and fix the case that actually happened. Add one focused test that fails without the fix when the intent needs it. Push back on scope creep: the Minimalist lens applies to your fixes too. Then rerun the affected checks and `git diff --shortstat <base>`. If review has grown the diff, cut it back first.

Start another round when budget remains and either a high finding is open or disputed, or a fix changed behavior. Skills, prompts, and other agent instructions are behavior, just as code is. Rerun each lens with an open or disputed finding, plus each lens whose territory the fixes touched.

The loop ends when one of these holds:

- **Agreed:** no high finding is open or disputed, each lens's latest round covers the current behavior diff, and you have no concern of your own. A round that returns only low findings ends the loop. Declining lows, and fixes that cannot change behavior (code comments, formatting, or prose outside agent instructions), need no new round.
- **Stuck:** a finding is still disputed after two replies, or the budget runs out. A spent budget is not approval.

### 7. Report the verdict

Use this format:

```markdown
## Intent
<what the author is trying to achieve; what is out of scope>

## Verdict: PASS | CONTESTED | REJECT | INCOMPLETE
<one-line summary>

## Scope
- Change: <base..head or patch>, `<diff command>`, <files>, <shortstat; before -> after in loop mode>
- Reviewers: <provider and model>, <lenses run>; skipped: <lens: reason>
- Rounds: <N>, <mode>; usage: <per reviewer, or "not exposed">

## Findings
<numbered, high -> medium -> low>
1. **[high]** `SK1` `path:line`: <description>
   - Lens: <primary lens; cross-referenced lenses>
   - Principle: <principle slug, or standard file#section>
   - Recommendation: <concrete action>
   - Outcome: <open | fixed in round N | declined: reason | disputed>

<Attacker findings also give impact, confidence, and the attack path. List unresolved security risks after the findings, each with the unknown and the check that would resolve it.>

## Verification
<checks you ran and their results; author and CI evidence; checks not run, and why>

## What went well
<1–3 things the reviewers found no issue with>

## Lead judgment
<for each finding: accept or reject, with a one-line rationale; for each disputed finding: both sides in 2–3 lines>
```

Pick the verdict by the first rule that applies:

- **REJECT:** an accepted high finding is still open.
- **INCOMPLETE:** a selected lens failed, a required standard could not be read, or missing intent, context, or verification prevents a justified decision. Say what would resolve it. A blocking security uncertainty belongs here; it does not count as a proven vulnerability.
- **CONTESTED:** a high finding is disputed, because its reviewer still holds it after your rebuttal or because reviewers contradict each other on it. The user decides.
- **PASS:** no high finding is open or disputed, every selected lens covered the final diff, and the evidence supports the intent.

A fix or a documented, authorized exception resolves a high finding. A promise of later cleanup does not. The verdict covers only the reviewed snapshot, so a later change needs a fresh round from the lenses it touches.

When the reviewed change goes to a PR, add one line above the model blurb in the PR description: `Reviewed with adversarial-review: <N> rounds, <lenses> on <model>. Verdict: <verdict>.` Add `on <effort>` only if you verified the effort.
