---
name: prepare-pr
description: Investigate, plan, implement, verify, and review a code change, leaving the PR open for human review. Use whenever the user asks to "prepare a PR" for a code change, or ends messages with "prepare".
metadata:
  dependencies:
  - ship-pr skill
  - software-design skill
  - code-review skill
---

# Prepare
Do the same work as `ship`, but stop with the PR ready for the user to merge. Never merge it.

Read [ship-pr](../ship-pr/SKILL.md) and follow its workflow, proof rules, review, and babysitting steps. A request to "prepare" a discussed or referenced change invokes this workflow without a formal skill invocation or separate "ship" request. That includes ship's testing permission. A "prepare" request is the permission for the test methods Proof needs, even when a project file says to ask first, for example before computer use. Use those methods directly. Its merge permission does not apply. The overrides below take precedence.

## Worktree and base branch

Before investigating or changing code, create a fresh git worktree with a new task branch. Use the branch the user specified as the base; otherwise use the repository's default branch. Fetch remote refs when available and branch from the latest available tip of the selected base.

Do investigation, planning, implementation, verification, and PR work from this new worktree. Preserve existing worktrees and unrelated uncommitted changes. If this change already has relevant local edits or commits, carry only those into the new worktree without discarding the originals.

Keep the selected base for review comparisons, rebases, and the PR target. State the worktree path, task branch, and base branch in the initial update.

## Development and pre-PR review

Use [software-design](../software-design/SKILL.md) to implement the proposed changes, including its shared principles and relevant language, framework, and backend references.

Before detailed review and PR creation, run the repository's applicable CI validation tasks locally, following [ship's local CI checks](../ship/SKILL.md#local-ci-checks). Fix failures caused by the change and rerun affected checks after later edits or rebases. Record commands, results, and any checks that cannot run locally.

Follow `ship`'s pre-PR review step: run the detailed [code-review](../code-review/SKILL.md) workflow before creating the PR. Its `Approve` verdict must cover the final diff after rebasing and resolving findings.

## PR change summary

After publishing the PR branch, print [ship's PR change-summary table](../ship/SKILL.md#pr-change-summary) in the conversation before waiting on checks or reviews. Split added and deleted lines into application code, tests, generated content, and repository documentation, with any remaining changes accounted for. Refresh it after pushes that alter the PR diff and include the latest table in the handoff.

## No merging
You may commit, push, rebase, fix conflicts, and use `--force-with-lease` on this task's branch. Never merge, enable auto-merge, enter a merge queue, push to the default branch, bypass branch protection, or delegate those actions.

Disable existing auto-merge and remove the PR from any merge queue before work begins; check again before each push. Report these changes. If you cannot prevent automatic merging, report the blocker before proceeding.

## Stop at the gate

Use `ship-pr`'s merge gate as the readiness check. Replace its merge and final report steps with a handoff. Proof and review must cover the final diff. Recheck behavior changes and meaningful conflict fixes before handoff.

Fetch the target branch and check the live PR's head, base, checks, reviews, and mergeability. Confirm it is open, not a draft, and not set to merge without the user. If someone else merged it, report that instead.

- **Ready to merge:** the merge gate passes. Leave the PR open and unmerged.
- **Waiting for required approval:** only human approval remains. Confirm that this is the actual blocker.
- **Blocked:** explain what prevents readiness, what you tried, and what is needed. Follow `ship`'s rules for asking the user.

In T3 Code, call `unwatch_pull_request` before the handoff or a question. Report the PR link, final head, verdict, proof, local CI results, reviewer outcome, latest PR change-summary table, and remaining risks. State whether the PR is still open and unmerged.
