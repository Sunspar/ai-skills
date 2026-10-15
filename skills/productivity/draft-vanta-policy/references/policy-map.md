# Maintaining the project's policy-map.md

Maintain one `policy-map.md` at the root of the user's policy project. Use it to locate critical source material efficiently. It indexes `original-documentation/`; it is not a source of independently established company facts.

## Reconcile the folder and map

On first use, and whenever the user announces new information:

1. Read the existing map and list the contents of `original-documentation/` recursively, including nested files and attachments. Compare in both directions to find unindexed files and entries whose files moved or disappeared. Every source document needs an entry; explain any excluded auxiliary files.
2. Establish what changed since the prior mapping using available content comparisons, recorded fingerprints, versions, or explicit user identification. Modification times alone do not prove that content is unchanged. If there is no reliable baseline, inspect the potentially changed documents and refresh their entries; ask if ambiguity about source identity or version affects interpretation.
3. Read each new or changed document in full, including tables and appendices. Record its purpose, critical topics, exact section or page pointers, and related templates or policies. Distinguish a verified relationship from a candidate based only on a similar title. Mark inaccessible content as unreadable and ask for an accessible copy when it affects the requested policy. An inventory entry is not a claim that its contents have been reviewed.
4. Repair stale entries and pointers. Preserve useful prior context and note renames or removals so policies citing those sources can be rechecked. Record conflicting source passages as unresolved; let the user settle them before policy drafting depends on a choice.
5. Identify requirements, open questions, and existing policies affected by the new material. Update links and review-needed status in the map; revisit affected claims in the active policy and review record. Report other affected policies for follow-up.

The reconciliation is accounted for when each source document has a current entry or an explicit unreadable/unreviewed status, removed entries are identified, and new or changed content has mapped topics and source pointers or a recorded blocker. Required inaccessible material still blocks the corresponding policy work.

## Suggested map structure

Adapt an existing format without discarding its information. For a new map, use:

```markdown
# Policy map

## Source index

| Source path | Purpose and critical topics | Section or page pointers | Related templates or policies | Review state and content baseline |
| --- | --- | --- | --- | --- |

## Source changes and unresolved gaps

| Source or change | What changed or remains unknown | Affected policy or question | Next action |
| --- | --- | --- | --- |
```

Use project-relative paths and enough detail that the next agent can go directly to the relevant passage. Review state distinguishes reviewed, changed pending review, unreadable, and removed. Record a content fingerprint or another reliable baseline where tooling allows; an actual mapping timestamp may accompany it but does not replace it. Add generated-policy links as artifacts are created. Keep per-requirement coverage and detailed user answers in the companion review record rather than duplicating them here.
