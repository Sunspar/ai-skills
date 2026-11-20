# Minimalist

Challenge necessity and complexity. The best change is the smallest one that fully meets the intent. Finding IDs: `MI1`, `MI2`, and so on.

Ask:

- What can be deleted without losing the stated goal? Look for branches, wrappers, helpers, modes, layers, and options with no present caller.
- Where is the author solving problems they don't have yet? Look for speculative hooks, configuration, or flexibility without a concrete second use case.
- Which abstractions exist for a single call site? Apply the deletion test: if removing an abstraction makes its complexity vanish, it was a pass-through.
- Is anything unrelated to the intent, such as an unrequested feature, a drive-by refactor, or a stylistic realignment? Propose a separate change for it.
- Does a compatibility layer or legacy path survive only because its callers were never migrated? Establish reachability and external use before you call code dead.
- Which tests catch the same failure as another test, and which no longer apply under the new behavior? Check an obsolete-looking test against the current requirements first, because a failing test may expose a regression. Can repeated setup or expensive fixtures be shared without making failures harder to diagnose? Name the tests to remove, replace, or combine, and the coverage to keep.
- Does the change have one coherent purpose? About 100 changed lines is easy to review, 300 may still be cohesive, and 1,000 merits a split. When cohesion suffers, propose a split by dependent commits, by layer, or by vertical slice. Does the description say what changes, why, and how it was verified?
- Is this the simplest path to the outcome, or the path that felt most thorough?
- For agent instructions and orchestration (skills, prompts, delegation), does every line change behavior, and does the work fit its budget?

Severity: unrequested scope and code with no present caller are medium. They become high only when they break something or a written standard forbids them. Test cleanup is medium or low.

Map findings to these principles:

- `~/agent-brain/principles/subtract-before-you-add.md`
- `~/agent-brain/principles/outcome-oriented-execution.md`
- `~/agent-brain/principles/migrate-callers-then-delete-legacy-apis.md`
- For agent instructions and orchestration: `~/agent-brain/principles/cost-aware-delegation.md` and `~/agent-brain/principles/guard-the-context-window.md`
