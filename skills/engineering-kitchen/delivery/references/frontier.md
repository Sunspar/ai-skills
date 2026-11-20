# Working the frontier

When slice produced several tickets, carry them to the target together on one **integration branch**, so a ticket builds on its blockers before anything reaches the base. The tickets form a graph, not a list: the frontier is whatever is unblocked now, and it grows as tickets merge.

You are the **lead**. Children build and review tickets; you merge them, keep the integration branch green, and publish.

1. **Create the integration branch** from the base, in the task worktree. For every ticket it stands in for the base.
2. **Share exploration.** When several tickets need the same codebase or documentation research, run it once and save the notes outside the repo at `$HOME/agent-notes/<repo-slug>/`, then hand children the path.
3. **Start a child per frontier ticket.** Delegate each to its own agent (T3 `delegate_task`, or the harness's subagents), in its own worktree branched from the integration tip. Run independent tickets in parallel. Brief by pointers rather than copied content: the ticket link, the spec link, the notes path, and this skill. Each child:
   - confirms its worktree starts at the integration tip, and resets onto it if not;
   - runs execute (`execute.md`);
   - merges the integration tip into its branch;
   - runs review (`review.md`) with the integration tip as its base;
   - reports its verdict, proof, local check results, gate classes, and assumptions.
4. **Merge each passing child** into the integration branch, one at a time. Rerun the affected local checks there. Any ticket this unblocks joins the frontier: go back to step 3.
5. **Verify the whole branch** once every ticket has merged. Rerun the local CI checks on the full diff against the base. Run `adversarial-review` on that full diff, with the spec's acceptance criteria as intent and the tickets' verdicts and proof as evidence, so reviewers can spend their attention on how the tickets interact. Its PASS must cover the final diff.
6. **Publish** the integration branch as one PR that links every ticket (`publish.md`). Its gate classes are the union of the tickets', so one gated ticket holds the whole PR at ready; slice keeps gated work in small tickets so the hunks to read stay few.
7. **Clean up** every child worktree.

A child that hits the review timebox stops its ticket, not the run: keep working the rest of the frontier. When no runnable ticket remains, deliver the subset that merged, at target ready. If nothing merged, publish nothing. Otherwise run step 5 with the merged tickets' acceptance criteria as intent, and step 6 linking only the merged tickets as resolved by the PR. Name each stopped ticket, and each ticket it blocks, as unresolved in the PR description and the report, and ask the user how to proceed.
