---
name: ruminate
description: Mine past T3 threads for corrections, preferences, and knowledge the brain never captured.
disable-model-invocation: true
metadata:
  dependencies:
  - brain skill
  - T3 Code tools (t3_project_list, t3_thread_list, t3_thread_read)
---

# Ruminate

Mine conversation history for lessons `reflect` never captured: corrections the user keeps repeating, preferences, and gotchas. The source is T3 thread history, read through the T3 tools. It spans Claude and Codex, records whether the user or an agent wrote each message, and knows each thread's project. Use the `brain` skill first: its keep test filters the findings and its routing table places them.

## Scope

- **Run in a repo**: threads in that repo's T3 project. Findings go to the repo brain, the shared brain, or the skill-feedback queue.
- **Run in `~/agent-brain`**: threads in every T3 project. Findings go to the shared brain or the skill-feedback queue.

The window starts at the date in the vault's `.ruminated-through` file (`brain/.ruminated-through` or `~/agent-brain/.ruminated-through`). Without that file, the window covers all history.

Threads hold company code. Keep every extracted file in a private temp directory (`mktemp -d`), outside any repo, and delete it at the end.

## Steps

1. **Snapshot** each vault in scope with [`../brain/scripts/snapshot.sh`](../brain/scripts/snapshot.sh) `<vault-dir> <tmp>/<vault>-snapshot.md`.
2. **List threads.** For a repo, find its main checkout (`git rev-parse --path-format=absolute --git-common-dir`, minus the trailing `/.git`) and pick the project from `t3_project_list` whose `workspaceRoot` matches it. Page through `t3_thread_list` with that `projectId` (or `allProjects: true` for the shared scope) and `includeSubagents: false`, until threads predate the window. Leave out the current thread. Write one `<threadId>\t<updatedAt>\t<title>` line per thread to `<tmp>/threads.txt`.
3. **Batch.** Split the list into N batch files, `<tmp>/batches/batch_<n>.txt`: about one batch per 20 threads, at least 2 and at most 10.
4. **Analyse.** Spawn N read-only subagents in parallel, one per batch. Give each its batch file, its output path `<tmp>/findings_<n>.md`, the snapshot paths (so it skips what the brain already holds), and these instructions:
   - Read each thread with `t3_thread_read` in the messages view, paging with `afterPosition` and keeping `maxCharsPerItem` near 4000.
   - Only messages with `createdBy: "user"` count as evidence of the user's view. Messages an agent created, delegated briefs included, are context.
   - Extract user corrections, recurring preferences, technical learnings, workflow patterns, frustrations, and skills the user wished for.
   - Record each finding with its thread id and, for corrections, the user's exact words.

   When a subagent reports it lacks the T3 tools, read that batch yourself.
5. **Synthesize.** Read every findings file, merge duplicates across batches, and compare them with the snapshots. Filter with the keep test: a finding seen in one thread is dropped unless it corrects an existing note. Three strong findings beat nine with noise.
6. **Present** a table with columns finding, evidence (thread count, thread ids, the user's words), destination, and action. Label each finding one-off or recurring.
7. **Apply** only the findings the user approves, through the routing table, updating existing notes before adding new ones. Run the reindex script for every vault where you added or removed files, then write today's date to the vault's `.ruminated-through`. Leave everything uncommitted.
8. **Clean up** the temp directory.
