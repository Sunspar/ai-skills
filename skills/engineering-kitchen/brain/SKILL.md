---
name: brain
description: Read and write brain notes, the persistent memory in a repo's `brain/` and the shared `~/agent-brain`. Use when the user asks you to remember something, corrects an approach that will come up again, or adds a todo, and whenever you edit a brain file.
---

# Brain

Persistent memory across sessions, kept in two **vaults**:

- **Repo brain**: `brain/` at the repo root, committed with the code. Knowledge about this codebase.
- **Shared brain**: `~/agent-brain/`, a private git repo that every session on this machine reads, personal and work alike. Knowledge about how the user works and how this machine behaves.

Every session loads both indexes, so a weak note taxes every session after it. Write only what passes the keep test.

## Keep test

A note earns its place only when both hold:

- **Signal**: an agent would reliably get this wrong without the note.
- **Frequency or impact**: it comes up in most sessions or most tasks of its kind, or getting it wrong causes real damage or wasted work.

A correction to a note that has become wrong always passes.

## Routing

Send each lesson to the first destination that fits:

1. **Check**: a lint rule, test, type, script, hook, or CI job could enforce it. Build the check when it is small and belongs to the current repo; otherwise add a todo. The check replaces the note.
2. **Skill behaviour**: how a skill should work (its steps, prompts, or edge cases). Append it to `~/agent-brain/skill-feedback/<skill-name>.md`. `meditate` applies the queue in the skills repo, so the skill files stay as they are.
3. **Domain decision or term**: a hard-to-reverse design decision, or a domain term. Record it through the `domain-modeling` skill as an ADR or glossary entry.
4. **Preference**: how the user works, true in any repo. `~/agent-brain/preferences/`.
5. **Environment**: how this machine, an account, a CLI, or a service behaves. `~/agent-brain/environment/`.
6. **Codebase**: how this repo works, its gotchas and patterns. `brain/codebase/`.
7. **Follow-up**: work that can't happen now. `todos.md` in the vault the work belongs to.
8. **Task state**: progress, next steps, what's done. It belongs in the PR, the ticket, or a handoff, so drop it here.

Drop anything that fits none of these. Principles (`~/agent-brain/principles/`) change only through `meditate`.

Write shared-brain notes in general terms that hold in any repo and either account. Company code, repo names, people, customers, and business facts stay in repo brains.

## Layout

```text
brain/                  repo brain
├── index.md            generated: links every note
├── todos.md            follow-up backlog
└── codebase/           how this repo works

~/agent-brain/          shared brain
├── AGENTS.md           global instructions, linked into every Claude and Codex home
├── hooks/              session-start hook that injects both indexes
├── index.md            generated
├── todos.md
├── principles.md       curated index of principles/
├── principles/
├── preferences/
├── environment/
└── skill-feedback/     queue for meditate; kept out of index.md
```

- One topic per file. The file name is the topic slug: lowercase and hyphenated.
- Read the vault's `index.md` before writing, and update an existing note rather than adding a near-duplicate. Merge notes that overlap.
- Add a new top-level folder when no existing one fits.
- Start with `# Title`, then bullets. Use no frontmatter and no preamble. Keep a note under ~50 lines; split a longer one.
- Link related notes as `[[folder/file-name]]`, relative to the vault root and without `.md`.
- After adding, moving, or deleting files, run [`scripts/reindex.sh`](scripts/reindex.sh) `<vault-dir>`. It rebuilds `index.md` from disk, so it is the only writer of `index.md`.
- Leave changes uncommitted. Repo-brain changes ride along with the branch's PR, and `meditate` commits and pushes the shared brain.

When the repo has no `brain/` yet, create the folder and run the reindex script. When `~/agent-brain` is missing, stop and tell the user: setting it up is a one-time step outside this skill.

## Todos

```markdown
# Todos

<!-- next-id: 4 -->

## Section

1. [ ] One-line description [[codebase/related-note]]
3. [ ] Another item
```

- **Add**: take N from `next-id`, append `N. [ ] description` under the fitting section, and increment the marker.
- **Done**: delete the line; git history keeps it.
- IDs are permanent and never reused.

## Skill feedback

Each `skill-feedback/<skill-name>.md` is a queue: `# <skill-name>`, then one bullet per item giving the date, what the skill did, what it should do, and the evidence in general terms. `meditate` deletes each item once applied.
