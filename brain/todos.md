# Todos

<!-- next-id: 10 -->

## Consolidation cleanup (required before the kitchen is done)

1. [ ] Merge the remaining engineering skills from `engineering/` and `new/` into `engineering-kitchen/`, removing duplicates. `reflect` already supersedes `retro`, and the skill feedback queued in `~/agent-brain/skill-feedback/` waits on those moves.
2. [ ] Reconcile the 16 principles seeded in `~/agent-brain/principles/` with `software-design` and `adversarial-review`'s lenses, including the agent-operating ones (prove-it-works, never-block-on-the-human, cost-aware-delegation, guard-the-context-window). `never-block-on-the-human` already conflicts with the plan-only preference.

## Remaining noodle pieces

3. [ ] Jira issue-tracker template for `setup-engineering-skills`: Atlassian MCP operations for `delivery` (read with comments, comment, child tickets, blocking links), the status and label mapping, and whether a ticket resolves at PR or at merge.
5. [ ] Model routing in `delivery`: which provider and model each stage and each frontier child should use. Commit sizing already lives in the execute stage.

## Deferred from the Noodle review

6. [ ] Review Noodle's UI skills (`interaction-design`, `make-interfaces-feel-better`, `frontend-design`) rule by rule for platform-neutral guidance; deferred by the user.
7. [ ] Evaluate Noodle plan 119's skill-refinement loop (binary evals, one mutation per experiment) and `skill-creator`'s eval scripts for improving kitchen skills.
8. [ ] Evaluate `ast-grep` rules as the cheap check for recurring review findings, and Noodle's `oops` for a broken base branch.
9. [ ] Delivery trust report: find candidate PRs by `commenter:<run account>` instead of the `Delivery: opened` text, and check edit history before requiring the marker, so a PR whose opening record another account edited counts as no signal instead of vanishing (adversarial-review AT5 residual, declined after the five-round cap).
