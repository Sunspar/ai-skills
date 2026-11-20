---
name: reflect
description: Sweep the current session for lessons and route each to the brain, the skill-feedback queue, or a new check. Use when the user asks to reflect, or when the delivery loop reaches its learn stage.
metadata:
  dependencies:
  - brain skill
---

# Reflect

Sweep this session for lessons and put each one where it changes how future sessions behave. Use the `brain` skill first: it owns the keep test, the routing table, and the note format this sweep relies on.

## Steps

1. **Load what exists.** Read `~/agent-brain/index.md` and, in a repo, `brain/index.md`, so you know what is already captured.
2. **Sweep the session.** List every candidate lesson:
   - corrections the user gave, in their words;
   - mistakes you made, and what caught each one (a test, a reviewer, the user);
   - preferences and workflow patterns the user showed;
   - codebase knowledge: architecture, gotchas, patterns;
   - tool, library, CLI, and service quirks;
   - friction in a skill's steps, in orchestration, or in delegation;
   - manual steps you repeated;
   - time lost finding a file or fact that a pointer would have saved;
   - a mistake an automated check could have caught, or a repo with no lint, type, or test job at all;
   - a mistake the reviewer missed;
   - an expensive tool call that a cheaper one could have replaced;
   - information you needed and couldn't reach (logs, read-only access to a service).

   The sweep is done when every user correction in the session appears as a candidate.
3. **Filter.** Apply the keep test to each candidate, and drop what an existing note already says.
4. **Route** each survivor through the routing table, first match wins.
5. **Apply.** Build the small checks, write and update notes, append skill feedback, add todos, and run the reindex script for every vault where you added or removed files. Leave everything uncommitted.
6. **Report** with this summary:

```markdown
## Reflect summary
- Repo brain: <file: one line each>
- Shared brain: <file: one line each>
- Skill feedback: <skill: one line each>
- Checks: <check added, or the todo that tracks it>
- Todos: <id: one line each>
- Dropped: <count, plus each borderline drop with its reason>
```
