# Subagent specs

Both subagents are read-only and return a structured Markdown report. Give each the snapshot paths. They read brain and skill content from the snapshots, where each file starts with a `=== path ===` header, and use search tools only to verify notes against the codebase or the machine.

## Auditor

**Inputs:** the vault snapshots, the instruction-file paths in scope, and the repo root when there is one.

- Judge every note against the `brain` skill's keep test and routing table, and flag it as:
  - **Outdated**: it names code, files, tools, commands, or decisions that no longer exist or have changed. Verify each claim against the repo or the machine.
  - **Redundant**: another note, a skill, or an instruction file already says it.
  - **Low-value**: it fails the keep test.
  - **Verbose**: it could say the same in fewer words.
  - **Task state**: progress, next steps, or finished work.
  - **Misplaced**: the routing table sends it elsewhere. A shared-brain note naming a company, repo, person, customer, or business fact belongs in a repo brain, or needs rewriting in general terms.
- Audit each instruction file: flag lines that are outdated, duplicate a brain note or skill, could be condensed, or don't match the repo's actual structure.
- Report brain findings and instruction-file findings separately. Give each item what is flagged, why, and the action: update, merge, condense, move, or delete.

## Reviewer

**Inputs:** the vault snapshots, the kitchen-skills snapshot when in scope, the auditor report, and `~/agent-brain/principles.md`. Skip notes the auditor flagged for deletion.

**Section 1, synthesis:**

- Propose `[[links]]` between notes about the same concept.
- Flag principles or notes that pull against each other, and propose wording that makes the boundary clear.
- Propose rewording where a note's relationship to a principle is unclear.

**Section 2, distillation:**

- Look across codebase notes, preferences, and environment notes for recurring patterns that reveal an unstated principle. A new principle must be independent of the existing ones, evidenced by at least two separate notes, and actionable: it changes how future work is approached. A restatement of an existing principle in a new domain doesn't qualify.
- Give each proposal its insight, its evidence (which notes), why it is independent, and a path under `~/agent-brain/principles/`.
- Propose merging two principles when one is a special case of the other.

**Section 3, skill review** (only with a skills snapshot):

- For each skill, check whether it:
  - contradicts a principle;
  - states as text a rule a lint rule, script, metadata flag, or runtime check could enforce;
  - repeats instructions a mechanism already handles;
  - carries guidance another skill also carries, which breaks the one-focus rule. Name the skill that should own it.
- Audit each `description` for context bloat: cut synonym trigger lists, restated purpose, and anything the agent can infer, keeping the core purpose and the distinctive triggers.
- Rank structural fixes above wording fixes.

## Report template

```markdown
## Audit: brain
- <N flagged: outdated, redundant, low-value, verbose, task state, misplaced>
- <each item: note, one-line reason, action>

## Audit: instruction files
- <N flagged>
- <each item: file, one-line reason, action>

## Synthesis
- <N links, M tensions; each in one line>

## Distillation
- <N principles proposed, M merges; each with one line and evidence count>

## Skill review
- <N skills reviewed, M findings; each: skill, gap, proposed fix>
```
