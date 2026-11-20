# Publish

Open the PR, carry it through checks and review, then merge it or hand it off at the gate.

## Open the PR

1. **File the PR** with the `file-pr` skill, targeting the base. Lead the title with the ticket key when there is one. Add these lines to the description:
   - `Ticket: <link>`, one per ticket;
   - `Proof: <one line on how you proved the change>`;
   - `Gate: none`, or `Gate: <class>: <why>; left for human review`, one per tripped class;
   - `Human check: <criterion>: <what to observe>`, one per human check;
   - the line `adversarial-review` asks for.
2. **Record provenance** as PR comments from the run's own GitHub account, one per event, never editing an earlier one: `Delivery: opened after review PASS at <head-sha>` now, then `Delivery: handed off at <head-sha>` at each handoff, or `Delivery: merged by agent at <head-sha>` just before you merge. The trust report reads these records.
3. **Print the PR change summary** (below) after pushing, before waiting on checks or reviews.
4. **Update each ticket**: comment with the PR link. Move its state only as far as the project's workflow allows for an open PR. Resolve tickets when the PR merges, or however the project closes work.

## Babysit

Use the `babysit-pr` skill. Fix real findings and CI failures; before each push, get proof and rerun the affected local checks. A push that alters the reviewed diff goes back through review (`review.md`, step 5). Refresh the change summary after each push that alters the PR diff.

Stay active until the target. If you end your turn while checks or bots are pending, the work stops, because nobody prompts you again. Wait with the watcher `babysit-pr` names: in T3 Code that is `watch_pull_request`. Call `unwatch_pull_request` before you stop for any reason.

## Merge gate

Full confidence means all of these hold on the latest commit:

- Your proof covers every change in the diff, apart from listed human checks.
- `adversarial-review` PASS verdicts cover the final diff.
- Required checks are green.
- Review bots have finished, and each finding is fixed or dismissed with a written reason.
- No human review still requests changes.
- The branch is up to date with the base, and the remote reports it mergeable: no detected conflicts and no pending tasks.
- No gate class tripped, and no human check is pending.

## Target merged

Merge when the merge gate passes. Use the method the repo uses: check the allowed methods and recent merged PRs. With a merge queue or auto-merge, stay until the system reports the PR merged. Merge through branch protection as configured, never with `--admin` or another bypass. You may ignore automated reviews that request "needs human review" when the merge gate passes and no gate class tripped.

After the merge:

1. **Watch the base branch's CI run for the merge commit.** If it fails because of this change, say so first in the final report, and ask the user whether to revert or fix forward.
2. **Resolve the tickets** however the project closes work.

Then run learn and post the final report. **Clean up** last: remove the task worktree and settle the thread. Cleanup adds no message of its own; if a step fails, post a diagnostic and leave the thread unsettled, so the user sees it. A request for "ship cleanup" runs these clean-up steps for the PR the user names, or this thread's PR, once you confirm it merged.

## Target ready

You may commit, push, rebase, fix conflicts, and use `--force-with-lease` on this run's branch. Leave the merge to a human: no merging, auto-merge, merge queue, pushing to the base, bypassing branch protection, or delegating any of those.

Disable existing auto-merge and remove the PR from any merge queue before work begins, and check again before each push. Report these changes. If you cannot prevent automatic merging, report the blocker before going further.

Use the merge gate as the readiness check. Fetch the base and check the live PR's head, base, checks, reviews, and mergeability. Confirm it is open, not a draft, and not set to merge without the user. If someone else merged it, report that instead. Then hand off in one of three states:

- **Ready to merge**: every merge-gate item holds except tripped gate classes and pending human checks.
- **Waiting for required approval**: only human approval remains. Confirm that this is the actual blocker.
- **Blocked**: say what prevents readiness, what you tried, and what is needed, and ask the user (`SKILL.md`, Asking the user).

## PR change summary

After pushing the PR branch, print a Markdown table of the full PR diff, not just the latest commit or push. Resolve the PR's actual base and pushed head commits; before the PR exists, use the base and the pushed head. Compute their merge base and get totals with `git diff --numstat -z --find-renames <merge-base-sha> <pushed-head-sha>`. State the compared refs or SHAs, so the table names its scope and excludes unpublished edits.

Classify every added and deleted text line exactly once:

- **Application code**: handwritten production source.
- **Tests**: tests, test support, and fixtures.
- **Generated content**: committed machine-produced artifacts, such as generated source, snapshots, and lockfiles. Establish this from repository attributes, headers, or generation configuration. Generated content takes precedence over the other categories.
- **Documentation**: repository documentation and its source files.

Classify by file role, and inspect the diff to separate application code from tests within mixed files. Add an **Other** row for changes that fit none of these, such as CI configuration, dependency manifests, or tooling, and name its contents. Reconcile the category totals with Git's totals. Report binary-file changes separately, since their line counts are unavailable.

Show all four categories, including zero rows, and a **Total** row. Net is added minus deleted. Use observed counts:

| Category | Lines added | Lines deleted | Net |
| --- | ---: | ---: | ---: |
| Application code | <count> | <count> | <signed count> |
| Tests | <count> | <count> | <signed count> |
| Generated content | <count> | <count> | <signed count> |
| Documentation | <count> | <count> | <signed count> |
| **Total** | **<count>** | **<count>** | **<signed count>** |

## Final report

Report, in this order:

1. Any question, failed post-merge check, or blocker.
2. The PR link and its state: the merge commit, or ready, waiting, or blocked.
3. Each tripped gate class (why, and the hunks a human should read) and each human check (what to observe, and how).
4. Assumptions and decisions you made.
5. Proof and local check results, and the `adversarial-review` verdict.
6. The latest PR change summary.
7. Links to the spec and tickets, and the follow-ups filed.
8. The `reflect` summary from learn.
