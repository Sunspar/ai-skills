---
name: meditate
description: Audit and prune the brain, distill principles, and turn queued skill feedback into a skills PR.
disable-model-invocation: true
metadata:
  dependencies:
  - brain skill
  - writing-for-agents skill
  - file-pr skill
---

# Meditate

Audit the brain and the instruction files for bloat and drift, distill principles from recurring notes, and, in the skills repo, turn queued skill feedback into a pull request. It is expensive: run it after several `reflect` or `ruminate` passes have piled up. Use the `brain` skill first: its keep test is the audit's bar, and its layout is what you maintain.

## Scope

Where you run decides what is in scope:

- **Always**: the shared brain and `~/agent-brain/AGENTS.md`.
- **In a repo with `brain/`**: that vault, plus the repo's `CLAUDE.md` and `AGENTS.md`.
- **In the ai-skills repo**: the skill-feedback queue and the skills under `skills/engineering-kitchen/`. Feedback for any other skill stays queued until that skill moves into the kitchen. Every linked skill on the machine points at the main checkout, so keep it on the default branch: make every ai-skills change, `brain/` included, in a new git worktree on a new branch from the default branch.

## Steps

1. **Snapshot** each vault in scope, and the kitchen skills when in scope, with [`../brain/scripts/snapshot.sh`](../brain/scripts/snapshot.sh) into a private temp directory (`mktemp -d`).
2. **Audit.** Spawn one read-only subagent with the Auditor spec in [`references/agents.md`](references/agents.md). Wait for its report. With fewer than 3 actionable items, skip step 3.
3. **Review.** Spawn one read-only subagent with the Reviewer spec, giving it the snapshots, the auditor report, and `~/agent-brain/principles.md`.
4. **Report** to the user in the template from `references/agents.md`.
5. **Apply** every finding:
   - outdated notes: update or delete;
   - redundant notes: merge into the stronger note and delete the weaker one;
   - low-value notes and task state: delete;
   - verbose notes: condense in place;
   - missing connections: add `[[links]]`;
   - tensions: reword the notes so the boundary is clear;
   - new principles from the distillation: write `~/agent-brain/principles/<slug>.md` and list it in `principles.md`;
   - principles that are special cases of another: merge the narrower into the broader, and name the result for the combined insight;
   - instruction-file findings: rewrite or delete the lines.

   Run the reindex script for every vault you changed, and leave repo-brain changes uncommitted.
6. **Apply skill feedback** (ai-skills only). In the worktree, apply each queued item for a kitchen skill, together with the reviewer's skill findings, following `writing-for-agents`. Commit everything there, `brain/` changes included, open a PR with `file-pr`, and delete the applied items from the queue.
7. **Commit the shared brain.** Commit everything in `~/agent-brain`, including edits other sessions left there, and push it.
8. **Clean up** the temp directory and report:

```markdown
## Meditate summary
- Pruned: <N deleted, M condensed, K merged>
- Principles: <new or merged, one line and evidence count each>
- Instruction files: <file: change, one line each>
- Skills: <N findings, M applied, PR link>
- Queue: <items left for skills outside the kitchen>
```
