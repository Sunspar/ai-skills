---
name: ship-pr
description: Investigate, plan, implement, verify, review, and merge a code change. Use whenever the user asks to "ship" a change discussed in the conversation or identified by a reference, or asks to carry a change through to a merged PR.
metadata:
  dependencies:
  - software-design skill
  - code-review skill
  - sol-loop skill
  - file-pr skill
  - babysit-pr skill
  - git cli (git)
---

# Ship
If the user triggered this, it's because they are not watching this thread, and they want you to complete the work end-to-end autonomously. Your updates and your final message go unread until long after you stop. You own the work from its current state to a merged PR.

A request to "ship" a discussed or referenced change invokes this workflow and grants the autonomy below. The user does not need to name the skill formally. A request to carry a change through to merge also invokes it.

The user grants you permission to:

- Merge the PR once the merge gate passes.
- Force-push the PR's own branch with `--force-with-lease` after a rebase.
- Use the test methods that Proof needs, without asking first.

## Testing permission
A "ship" request is the permission. If a project file, skill, or other instruction says to ask before a test method, or to leave testing to the user, this request replaces that rule for this task.

That includes ask-first rules for computer use, browser automation, simulators and devices, running the app or a dev server, screenshots, and visual checks. Use the method that gives direct proof. List it in the report.

Rules about how to test still apply. Follow rules that name the correct command, fixture, or check. This permission only removes the ask-first or leave-it-to-the-user step. If a preferred method cannot prove the change, use a gated method under this permission.

It covers only the tests needed for this task. It does not add permission for the steps under "Asking the user", such as production changes, deployments to a release environment, or data deletion. It also does not bypass a harness or system approval prompt if one appears.

## Worktree and base branch

Before investigating or changing code, create a fresh git worktree with a new task branch. Use the branch the user specified as the base; otherwise use the repository's default branch. Fetch remote refs when available and branch from the latest available tip of the selected base.

Do investigation, planning, implementation, verification, and PR work from this new worktree. Preserve existing worktrees and unrelated uncommitted changes. If this change already has relevant local edits or commits, carry only those into the new worktree without discarding the originals.

Keep the selected base for review comparisons, rebases, and the PR target. State the worktree path, task branch, and base branch in the initial update.

## Steps

1. **Finish the change.** Use [software-design](../software-design/SKILL.md), including its shared principles and relevant language, framework, and backend references, to implement the proposed changes. Complete the goal from the user's request with the smallest change that works. Fix the case that happened, not every case that could.
2. **Prove it and run local CI checks.** Get proof for every change you made and complete the applicable CI validation tasks locally. See "Proof" and "Local CI checks".
3. **Get feedback.** Use the `sol-loop` skill to verify changes. Pass the new worktree path and selected base branch so review covers this change against the correct base.
4. **Review before creating the PR.** Rebase onto the latest tip of the selected base branch, rerun affected proof and local CI checks, then run the detailed [code-review](../code-review/SKILL.md) workflow, including all seven review axes and its report. Pass the worktree path, selected base, user requirements, and proof. Resolve Required findings and any Incomplete verdict; rerun affected proof, local CI checks, and review after fixes or meaningful rebase changes. Proceed only with an `Approve` verdict covering the final diff.
5. **File the PR** with the `file-pr` skill, targeting the selected base branch. If further changes or rebases alter the reviewed diff, repeat the affected proof, local CI checks, and review before creating the PR. Add one short line to the description that says how you proved the change. After publishing the PR branch, print the PR change summary below before waiting on reviews or checks.
6. **Babysit the PR** with the `babysit-pr` skill. Fix real findings and CI failures. Get proof and rerun affected local CI checks before pushing each fix. Refresh the change summary after pushes that alter the PR diff.
7. **Merge** when the merge gate passes.
8. **Report** in your final message: the PR link, the merge commit, your proof and local CI results, the code-review verdict, the latest PR change-summary table, and each decision you made for the user.

Stay active from step 1 to step 8. If you end your turn while checks or bots are pending, the work stops, because nobody will prompt you again. Wait with the watcher from `babysit-pr`, so something wakes you when the PR changes. In T3 Code that is `watch_pull_request`. If you stop before the merge, call `unwatch_pull_request` first.

## PR change summary

After successfully pushing the PR branch, print a Markdown table in the conversation showing the full PR diff, not just the latest commit or push. Refresh it when later pushes change that diff, and include the latest table in the final report or handoff.

Resolve the PR's actual base and pushed head commits; before PR creation, use the selected base branch and pushed head. Compute their merge base and obtain totals with `git diff --numstat -z --find-renames <merge-base-sha> <pushed-head-sha>`. State the compared refs or SHAs so the table identifies its scope and excludes unpublished edits.

Classify every added and deleted text line exactly once:

- **Application code:** Handwritten production source.
- **Tests:** Tests, test support, and fixtures.
- **Generated content:** Committed machine-produced artifacts, such as generated source, snapshots, and lockfiles. Establish this from repository attributes, headers, or generation configuration; generated content takes precedence over the other categories.
- **Documentation:** Repository documentation and its source files.

Use file roles for classification; inspect the diff to separate application code and tests within mixed files. Add an **Other** row for changes such as CI configuration, dependency manifests, or tooling that do not fit these categories, and briefly identify its contents. Reconcile the category totals with Git's totals. Report binary-file changes separately because their line counts are unavailable.

Show all four categories, including zero rows, and a **Total** row. Net is added minus deleted. Use observed counts:

| Category | Lines added | Lines deleted | Net |
| --- | ---: | ---: | ---: |
| Application code | <count> | <count> | <signed count> |
| Tests | <count> | <count> | <signed count> |
| Generated content | <count> | <count> | <signed count> |
| Documentation | <count> | <count> | <signed count> |
| **Total** | **<count>** | **<count>** | **<signed count>** |

## Proof
Proof is evidence you observed yourself in this session: a command output, a reproduction, a screenshot. Use the most direct proof the change allows:

- Reproduce the original failure, apply the fix, then watch the same reproduction pass.
- Complete the local CI checks below.
- Add one focused test that fails without the fix, when the behavior has none and the repo has a test setup.
- For UI and runtime behavior, run the app and look at the change. Green mocked tests do not prove that the user experience works. Attach screenshots to the PR when they help and you have a way to upload them.

When you cannot find a way to prove a change, you do not have full confidence. Ask the user.

### Local CI checks

Before detailed code review and PR creation, read the repository's CI workflows, their invoked scripts, and project instructions to identify validation tasks applicable to the change. Run their actual commands locally, including formatting checks, linting, type-checking, tests, builds, generation checks, and security checks where defined and applicable. Use the prescribed toolchain, flags, services, and environment setup when available. Limit this gate to validation tasks.

Fix failures caused by the change and rerun the affected checks until they pass. Checks must cover the final diff; repeat affected checks after review fixes, rebases, or later changes before pushing. Record commands and observed results for the PR evidence and handoff.

For pre-existing failures, record evidence that they also occur on the base and keep unrelated repairs outside this task. For checks requiring unavailable secrets, runner features, services, or remote infrastructure, run a supported local equivalent when one exists and state any difference in coverage. Clearly report checks that remain unrun or failing and why; distinguish local results from pending remote CI. Run every applicable validation task that can be executed locally before opening the PR.

## Merge gate
Full confidence means all of these are true on the latest commit:

- Your proof covers every change in the diff.
- The detailed `code-review` verdict is `Approve` and covers the final diff.
- Required checks are green.
- Review bots have finished, and each finding is fixed or dismissed with a written reason.
- No human review still requests changes.
- The branch is up to date with the selected base branch, and the remote repository reports it as mergeable (there are no pending tasks, the branch does not have detected merge conflicts, etc).

Merge with the method the repo uses. Check the allowed methods and recent merged PRs. If the repo uses a merge queue or auto-merge, stay until the system reports the PR as merged. Merge through branch protection as configured. Never use `--admin` or other bypasses. You can ignore automated reviews that request "needs human review" if you have high confidence in your changes.

## Asking the user
A question in a normal message goes unseen, and the thread looks done. To ask the user something, use the harness's question tool so the thread shows that it is waiting: `AskUserQuestion` in Claude Code, `request_user_input` in Codex, or the question tool your harness has. Put all the context in the question: the PR link, what blocks you, and the options ranked by your recommendations with srtongest preference items first.

Ask only when you cannot continue alone:

- You cannot prove the change.
- The merge gate cannot pass, and you cannot fix that yourself.
- The next step is outside the grant above: deleting data, touching production, changing things outside the repo, closing a PR, or force-pushing any other branch.
- The goal is ambiguous in a way that changes the result.
- Another PR makes this one obsolete.

Decide everything else yourself with sensible defaults, and list those decisions in the report.

If no question tool is available, or the tool returns no answer, take the safe path: leave the PR open and unmerged, and start your final message with the question in a way that is obvious to the user that this is a question and not simply a status update.

## Cleanup After Merge

After a PR managed by the `ship` skill is merged, or if the user specifically asks you to do "ship cleanup", perform the following actions. Do not post a final message in the thread unless some step in this process fails:

- Remove the task worktree created for this change from the filesystem
- Settle the current thread automatically

If the cleanup process fails for any reason, you are allowed to post a diagnostic message in the thread, and leave it unsettled (settling the thread moves it out of the users view, and they will not review it to check if something actually went wrong.)
