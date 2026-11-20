# Todos

<!-- next-id: 6 -->

## Consolidation cleanup (required before the kitchen is done)

1. [ ] Merge the remaining engineering skills from `engineering/` and `new/` into `engineering-kitchen/`, removing duplicates. `reflect` already supersedes `retro`, and the skill feedback queued in `~/agent-brain/skill-feedback/` waits on those moves.
2. [ ] Reconcile the 16 principles seeded in `~/agent-brain/principles/` with `software-design` and `adversarial-review`'s lenses, including the agent-operating ones (prove-it-works, never-block-on-the-human, cost-aware-delegation, guard-the-context-window). `never-block-on-the-human` already conflicts with the plan-only preference.

## Remaining noodle pieces

3. [ ] Jira adapter: `sync` and `done` scripts plus an issue-tracker template, with the ticket key in branch names and PR titles.
5. [ ] Plan sizing rules: one function or type per phase, at most 3 files, split past 5 test cases, a suggested model per phase.
