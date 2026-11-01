---
name: prepare
description: Investigate, plan, implement, verify, and review a code change, leaving its PR ready for the user to merge. Use whenever the user asks to "prepare" a change discussed in the conversation or identified by a reference, including a closing "Prepare." attached to a change request.
metadata:
  dependencies:
  - ship skill
---

# Prepare
Do the same work as `ship`, but stop with the PR ready for the user to merge. Never merge it.

Read [ship](../ship/SKILL.md) and follow its workflow, proof rules, review, and babysitting steps. A request to "prepare" a discussed or referenced change invokes this workflow without a formal skill invocation or separate "ship" request. That includes ship's testing permission. A "prepare" request is the permission for the test methods Proof needs, even when a project file says to ask first, for example before computer use. Use those methods directly. Its merge permission does not apply. The overrides below take precedence.

## Worktree and base branch

Before investigating or changing code, create a fresh git worktree with a new task branch. Use the branch the user specified as the base; otherwise use the repository's default branch. Fetch remote refs when available and branch from the latest available tip of the selected base.

Do investigation, planning, implementation, verification, and PR work from this new worktree. Preserve existing worktrees and unrelated uncommitted changes. If this change already has relevant local edits or commits, carry only those into the new worktree without discarding the originals.

Keep the selected base for review comparisons, rebases, and the PR target. State the worktree path, task branch, and base branch in the initial update.

## No merging
You may commit, push, rebase, fix conflicts, and use `--force-with-lease` on this task's branch. Never merge, enable auto-merge, enter a merge queue, push to the default branch, bypass branch protection, or delegate those actions.

Disable existing auto-merge and remove the PR from any merge queue before work begins; check again before each push. Report these changes. If you cannot prevent automatic merging, report the blocker before proceeding.

## Stop at the gate

Use `ship`'s merge gate as the readiness check. Replace its merge and final report steps with a handoff. Proof and review must cover the final diff. Recheck behavior changes and meaningful conflict fixes before handoff.

Fetch the target branch and check the live PR's head, base, checks, reviews, and mergeability. Confirm it is open, not a draft, and not set to merge without the user. If someone else merged it, report that instead.

- **Ready to merge:** the merge gate passes. Leave the PR open and unmerged.
- **Waiting for required approval:** only human approval remains. Confirm that this is the actual blocker.
- **Blocked:** explain what prevents readiness, what you tried, and what is needed. Follow `ship`'s rules for asking the user.

In T3 Code, call `unwatch_pull_request` before the handoff or a question. Report the PR link, final head, verdict, proof, reviewer outcome, and remaining risks. State whether the PR is still open and unmerged.
