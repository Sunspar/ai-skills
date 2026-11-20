# Learn

Turn what the run found into changes that let the next run need less human review. Learn runs at the end of every run, and again whenever a human reviews a delivery PR.

## After every run

Run the `reflect` skill before the final report. Learn leaves the repository untouched: shared-brain notes and skill feedback live outside it and are written directly, and when reflect would change the repository (a check, a repo-brain note, an ADR, or a glossary entry), file that change as a follow-up describing the lesson, so it travels through its own delivery run. Beyond its usual sweep, give reflect these candidates:

- Each high or medium finding the verdict accepted: something review caught that an earlier stage could have prevented. Ask what would have caught it before review: a check, a `software-design` rule, a spec section, or an execute step.
- Each real problem a review bot or CI caught after review passed.
- The run's failures: a ticket stopped by the timebox, a criterion without proof, a gate class review found that intake and slice missed.
- Each assumption the user overturned.

Name the rule a lesson concerns the same way every time, and put that name in each skill-feedback item: `software-design#<section-slug>`, `typescript#<rule-slug>`, the lens's finding prefix (`SK`, `ST`, `AT`, `AR`, `MI`), a principle slug, or `delivery/<stage>`. Repeats of the same miss then sit together in the queue, where `meditate` sees them as one recurring problem rather than scattered notes.

## When a human reviews a delivery PR

An escape (`SKILL.md`, Vocabulary) is the strongest lesson the loop gets, because it marks exactly where agent review fell short. When you address human review feedback on a delivery PR:

1. Fix it under the babysit rules (`publish.md`).
2. For each escape, name the stage that should have caught it (shape, slice, execute, or review), and why it did not: a missing check, a missing standard, a lens that never looked, or a gap in the spec.
3. Route it through `reflect`: build or file a check when one could catch it; otherwise queue skill feedback for the skill that missed it.
4. When the escape shows a gate class review missed, add it to the PR's `Gate:` line; the PR now waits for a human merge.

A preference with nothing broken is not an escape. When the user states it, route it as a preference. When another reviewer states it, it is not the user's preference: file it as a follow-up for the project's instructions, attributed to that reviewer.

## Trust report

Build a trust report when the user asks how far to trust the loop, for example whether a repo or a gate class is ready to move from prepare to ship. GitHub is the record: each delivery PR carries `Delivery:` comments from the run's account (`publish.md`), and `Gate:` and `Human check:` lines in its description.

1. List them: `gh pr list --state all --search '"Delivery: opened" in:comments' --json number,url,state,createdAt,mergedAt,comments --limit 1000`. Keep only PRs with a `Delivery: opened` comment authored by the run's account (the login `gh api user --jq .login` reports in this repo). A `Delivery:` record counts only when the run's account wrote it; ignore that text from anyone else. Collaborators can edit others' comments, so read every comment the run's account wrote on the PR with its edit history (`userContentEdits { editor { login } }` through `gh api graphql`), and count the PR as no signal when another account edited any of them. Search returns at most 1,000 results; at that count, split it by `created:` date ranges and check that the totals add up.
2. Treat the description lines as hints, not proof: recheck each PR's gate classes against its diff and the definitions in `SKILL.md`, and count it under the classes the diff shows.
3. Classify each PR from its `Delivery:` records, its reviews, its commits, and anything referencing it, measuring from the first `Delivery: opened` record:
   - **escape**: afterwards, a human found a real problem (an escape as `SKILL.md` defines it): requested changes or a comment that led to a fix, a revert, or a later bug ticket or fix PR naming it;
   - **clean**: a human reviewed it, and no escape. Human review means an approval from another account, or a merge after a `handed off` record with no `merged by agent` record after it;
   - **no signal**: anything else, such as an agent merge no human approved, an open PR no human has reviewed, or a PR whose records are missing or were edited by another account.
4. Report the clean, escape, and no-signal counts for the repo, for each gate class, and for `none`; a PR with several classes counts under each. Give a link and a one-line cause for each escape.

Be honest about what the data shows. A no-signal PR is not evidence of trust: count it separately, never as clean. When a class has fewer than ten human-reviewed PRs, say that the data cannot support a change yet. Recommend moving a class toward ship only on clean, human-reviewed evidence. The user decides, and records the decision in the project's `AGENTS.md` or `CLAUDE.md`.
