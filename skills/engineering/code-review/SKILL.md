---
name: code-review
description: >-
  Review a set of changes (PR, branch, diff, etc) across five axes: correctness,
  readability and simplicity, architecture, security, and performance. Use when
  asked to assess changes or review completed implementation before an approval.
metadata:
  references:
  - repo: https://github.com/mattpocock/skills/tree/main/skills/engineering/code-review
    ref: 8295b8e10d4cdb6cce772a56dda7b7c37075074d
---

# Code Review

Produce an evidence-backed review across **Correctness**, **Readability & Simplicity**, **Architecture**, **Security**, and **Performance**. Keep the five perspectives independent so success in one cannot conceal failure in another.

Recommend approval when the change delivers its intended behavior, maintains or improves code health, follows applicable standards, and has no unresolved blockers. Perfection is not the goal, and a review should not fail simply because there are nits to pick. So long as there are no critical failings, we sahould approve it with some notes for things to fix up later if the change can't wait.

Reviewing authorizes inspection and a report, not changes to the code. Keep the author's files intact; implement fixes, delete code, publish comments, or submit approvals only when separately authorized (typically post-review). A review verdict is a recommendation, not a merge action.

## Workflow

### 1. Pin the change

Record the requested scope and capture one stable review artifact before reviewing:

| Request | Comparison |
| --- | --- |
| Branch or PR against a base | Resolve base and head to SHAs; compare their merge-base to the head. Record the selected commits. |
| Explicit before/after commits, tags, or range | Resolve both endpoints; compare those snapshots directly. Use merge-base semantics only when requested. |
| Single commit | Compare it to its parent; for a root commit, use its full introduction diff. Clarify the parent for an ambiguous merge commit. |
| Working-tree changes | Capture staged and unstaged changes plus relevant untracked files. State whether the scope is staged, unstaged, or both. |
| Supplied patch or inline diff | Use that artifact. Inspect surrounding code when available; disclose unavailable context. |

For a branch review, resolve refs with `git rev-parse --verify`, obtain the base with `git merge-base`, and capture `git diff <merge-base-sha> <head-sha>` and `git log <merge-base-sha>..<head-sha> --oneline`. Use resolved SHAs throughout; a moving branch name is not a stable artifact.

For working-tree review, `git diff HEAD` captures the combined tracked result; `git diff --cached` selects staged changes and `git diff` selects unstaged changes. Discover untracked files with `git ls-files --others --exclude-standard` and include relevant contents explicitly. Preserve the selected snapshot for review; staged content can differ from the file on disk. Read surrounding code from the reviewed head or captured snapshot so unrelated local edits cannot distort the assessment.

Use the user-specified base first, then an existing PR's base. Infer a base only when repository context makes it unambiguous, and state the assumption. Otherwise ask while gathering independent context. An invalid ref stops that comparison; an empty diff should be reported without inventing findings.

**Complete when:** the endpoints or patch, changed-file inventory, and included work are explicit. Every reviewer must inspect this same artifact. If it changes during review, identify the new scope and revisit affected findings.

### 2. Gather the review contract

Read applicable repository instructions and discover sources once for all axes:

- **Standards:** `AGENTS.md`, `CODING_STANDARDS.md`, `CONTRIBUTING.md`, and relevant design, naming, testing, and language guidance. Include coding standards and contribution guides when present; apply nested instructions to their actual scope.
- **Intent/spec:** the user's supplied requirements or path first, then the PR description and linked issues, issue references in commit messages, relevant ADRs (`docs/adr/`), architecture documentation (`docs/architecture/`), `GLOSSARY.md`/`GLOSSARY-MAP.md` entries, and potentially relevant files under `specs/`, or `.scratch/`. Use an available tracker integration or repository workflow; tracker setup is not a prerequisite for reviewing code.
- **Security:** `SECURITY.md`, threat models, security ADRs, and authentication, authorization, tenant isolation, privacy, and secrets-handling guidance. Inspect tests around the boundaries changed.
- **Verification:** the project's test/build commands, CI results, and the author's account of tests, manual checks, screenshots, or benchmarks.

Ask for missing intent when it would change the assessment; continue review that does not depend on the answer. Without a spec, assess correctness against the stated goal, public contracts, existing behavior, and tests. Mark **spec coverage unverified** rather than skipping Correctness or treating implementation-derived assumptions as requirements.

Documented project standards override the design heuristics below. Cite the source and rule for a standards violation; identify heuristic concerns as judgments. Local conventions cannot excuse an evidenced vulnerability. Let configured tools handle formatting and routine lint rules; report relevant tool failures once.

**Complete when:** each source is identified, conflicting expectations are surfaced, and missing sources have a stated limitation or question.

### 3. Read tests, then review all five axes

Read changed tests and nearby contract tests first. Identify which behaviors they demonstrate, which failures they would catch, and the significant paths they omit. Then inspect every changed file through all five axes, following relevant callers, callees, configuration, and data flows beyond the diff to establish consequences.

Use independent sub-agents per axis, and run them in parallel. Give each reviewer:

- The pinned artifact, endpoints, commit list, and changed-file inventory.
- Its assigned axis and the corresponding guidance below, supplied in full or through an accessible path with an explicit instruction to read it.
- Applicable source paths or fetched contents, the known intent, and explicit evidence gaps.
- Permission to inspect relevant surrounding code and tests, while preserving the author's files. Review agents should NEVER attempt to make changes to the code in the review pass, if changes are necessary they should be included in the agents summary for that axis.
- The finding format and completion criteria in this skill. Ask for actionable findings, named uncertainties, and coverage; avoid a findings quota or a word limit that truncates evidence.

Keep initial passes independent. The coordinator validates and reconciles their results afterward.

**Complete when:** the entire pinned change artifact has been considered across all five axes, each applicable requirement has been checked, and unavailable evidence is recorded. Generated files, lockfiles, and deletions may warrant different depth, but must be accounted for.

### 4. Validate candidates and verification

For each candidate, confirm that the change introduces, exposes, or materially worsens the problem. Check surrounding guards, actual callers, contracts, and tests before reporting it. Unchanged problems belong outside the findings unless the diff activates or aggravates them.

Run the smallest relevant tests and required repository checks when feasible. Distinguish reviewer-run results from author-reported or CI evidence, and distinguish pre-existing failures from regressions. Record commands, results, and checks that could not run. A green suite supports the reviewed behavior; it does not establish all five axes.

For bug fixes, seek a regression test that fails on the old behavior and passes on the new behavior. If test sensitivity remains doubtful, or if a change is necessary in order to confirm a finding, you may outline such a change is needed and offer to confirm this finding in a `git` worktree, but do not perform this additional effort unless it is approved by the user. If approved, compare base and head or make a targeted mutation in an **isolated copy containing the reviewed artifact**, then restore that copy. Choose a mutation representing a plausible failure. A surviving mutation is a coverage finding only when it demonstrates a meaningful missing behavioral assertion. Normal review does not require mutation testing.

**Complete when:** reported findings have a specific location, trigger or violated rule, consequence, and useful remedy; uncertainty is separated from established findings; verification claims match available evidence.

### 5. Report and recommend

Use the report contract below. Recheck affected paths and verification after fixes if a further review is requested; tie the result to the new artifact.

## The five axes

### 1. Correctness

Does the change implement the intended behavior and preserve relevant contracts?

- Each requirement in the spec should be able to map to implementation and observable tests. Report missing, partial, or incorrect behavior with a spec citation where available.
- Are all use cases established? Trace happy, error, and edge paths: validation, empty and boundary values, state transitions, retries, concurrency, cleanup, and failure propagation where touched.
- Check compatibility of changed APIs, persisted data, migrations, configuration, and consumers. Distinguish an intended behavior change from an unintended regression and raise when unexpected conflicts arise.
- Favor integration tests for contracts crossing those seams and use `tdd` to test at the boundary first, and internally when necessary (for example, to prove an algorithmic process in a module that is very unlikely to ever change). Flag mocks or implementation assertions that leave significant behavior untested. Ensure scenarios being tested are appropriate given the scope.
- Identify unrelated behavior or unrequested features. Protect against scope creep, and explain why they exceed the agreed scope and propose separation.

### 2. Readability & Simplicity

Can another engineer or agent understand the change without the author explaining it?

- Check for and expect meaningful names, consistent terminology, straightforward control flow, and comments explaining non-obvious intent or invariants. Look for and flag obvious in-lined documentation that can be better conveyed through better naming or function or module level documentation instead.
- Prefer the smaller, clearer implementation when it preserves the required behavior. Flag unnecessary branches, speculative hooks, redundant wrappers, and abstraction whose cost exceeds its benefit.
- Identify dead code introduced or orphaned by the change. Establish reachability and external usage before recommending removal; compatibility layers earn their place when a supported or plausible future consumer needs them.
- Propose the actual simplification, not merely “this is complex.” Use the readability heuristics below when they clarify a concrete cost.

### 3. Architecture

Does the change preserve coherent ownership and simplify using the system?

- Follow established patterns or explain why a new pattern serves the requirement better. Evaluate coupling, dependency direction, domain ownership, and interface size relative to the behavior hidden behind it (deep modules are better than shallow modules).
- Keep feature logic in its owning module and reuse canonical helpers. Separate orchestration from domain logic when doing so clarifies responsibilities.
- Check whether refactoring removes concepts, branches, modes, or layers, or meaningfully hides complexity behind a simpler interface. Moving the same burden between files is not sufficient improvement; useful encapsulation can be.
- Make invariants and type boundaries explicit. Question gratuitous casts, broad types, optionality, and silent fallbacks that conceal an invalid state.
- Review dependencies and change cohesion using the conditional guidance below. File length is an inspection signal, not a design verdict.

### Design heuristics for Readability and Architecture

These are labeled judgments, not automatic violations. Choose remedies that reduce the reader's burden; extraction or polymorphism is useful only when it earns its complexity.

| Possible smell | Evidence to seek → candidate remedy |
| --- | --- |
| Mysterious Name | Intent or domain meaning is obscured → rename or clarify the concept. |
| Duplicated Code | The same rule has multiple implementations → reuse the canonical helper or unify the rule. |
| Feature Envy | Logic depends mainly on another module's internals → move it to the owning module. |
| Data Clumps | The same fields repeatedly travel together → introduce a cohesive value or parameter type. |
| Primitive Obsession | A primitive hides meaningful domain rules → model the concept explicitly. |
| Repeated Switches | Repeated dispatch on the same shape → use a shared dispatcher, typed model, or suitable polymorphism. |
| Shotgun Surgery | One rule requires scattered coordinated edits → gather ownership of that rule. |
| Divergent Change | A module changes for unrelated responsibilities → split along those responsibilities. |
| Speculative Generality | Hooks or abstraction serve no current requirement → remove the unused generality. |
| Message Chains | Callers traverse unstable internal relationships → expose a meaningful operation at the boundary. |
| Middle Man | A wrapper adds only indirection → remove it unless it protects a useful boundary. |
| Refused Bequest | An implementation rejects much of its inherited contract → narrow the contract or use composition. |

Treat a structural concern as Required when it violates an applicable standard or demonstrably worsens maintainability, coupling, or contracts. Otherwise offer an Optional improvement with its tradeoff. Propose the smallest useful move: collapse duplicate flows, replace scattered conditionals with an explicit policy, move logic to its owner, clarify a type boundary, or split a module along coherent seams.

### 4. Security

Does the change create an exploitable path or weaken a security invariant?

- **Trust boundaries:** trace untrusted input from users, external services, files, queues, databases, and configuration into privileged operations or tenant data.
- **Authentication and authorization:** missing or late checks, confused-deputy behavior, privilege escalation, tenant isolation, and insecure defaults.
- **Unsafe interpretation:** SQL/command/template injection, XSS, path traversal, SSRF, unsafe deserialization, and client-controlled queries. Check parameterization, context-appropriate encoding, and validation at the actual boundary.
- **Sensitive data:** secrets or personal data exposed through responses, logs, errors, caches, analytics, or overly broad reads. Describe secret locations without reproducing secret values.
- **Integrity and availability:** replay, races, destructive operations, unbounded work, and attacker-controlled resource consumption.
- **Cryptography and secrets:** incorrect verification, weak randomness, embedded credentials, and unnecessary propagation of secrets.
- **Dependencies and configuration:** vulnerable reachable behavior, compromised provenance, exposed services, relaxed controls, and excessive permissions.

Separate **concrete findings** from **unresolved risks**. A finding needs a broken invariant and a plausible source-to-sink or attacker-to-impact path through the changed behavior. Include exploitation preconditions, impact, confidence, and the smallest useful remediation. When the path cannot be established, name the unknown and the specific check needed; report a risk without claiming a vulnerability.

Calibrate security severity from impact **and** exploitability:

| Severity | Meaning |
| --- | --- |
| Critical | Practical exploitation can cause catastrophic compromise. |
| High | Plausible exploitation crosses a major trust boundary or compromises sensitive data, authorization, or system integrity. |
| Medium | Meaningful impact with narrower reach or substantial preconditions. |
| Low | Limited impact or a defense-in-depth weakness. |

If no plausible attack path is found, report no security findings with the reviewed surface and any limitations. Severity and confidence are separate: uncertainty does not establish a higher-severity vulnerability.

### 5. Performance

Does the change introduce a meaningful regression at expected scale?

- Check N+1 queries, unbounded loops or fetching, missing pagination or limits, repeated work, expensive allocations, unnecessary UI renders, and blocking I/O on latency-sensitive paths.
- Follow how work grows with input size, concurrency, and request rate. Check resource cleanup, cache behavior, and memory or connection pressure where affected.
- Connect a concern to a reachable path and realistic workload. Support it with operation counts, measurements, or clearly labeled estimates; speculative micro-optimizations are Optional at most.
- For a claimed optimization or suspected regression, seek comparable before/after measurements. If scale or workload is unknown, state the assumption and the benchmark needed.

## Conditional checks

### Dependency or lockfile changes

Review the actual shipped graph, not just the manifest or version label:

- **Architecture:** whether existing utilities suffice, compatibility with the stack, maintenance status, license constraints, and the cost of a new dependency.
- **Correctness:** changelog and migration notes, behavior changes, direct and transitive version changes, and relevant tests against base and head. Semver and successful installation are insufficient evidence of compatibility.
- **Security:** provenance, advisories, and exploit reachability. Use the ecosystem's available audit tooling and authoritative package sources; distinguish an advisory from a demonstrated application vulnerability.
- **Performance:** bundle size, startup, or hot-path effects when the package reaches those paths.

Check that manifest and lockfile agree and that required lockfile changes are included and reproducible. Prefer isolated upgrades or small related groups when that makes failures and rollback easier to attribute; bulk updates warrant scrutiny, not an automatic rejection.

### Change size and description

Assess whether the change has one coherent purpose with related tests and remains understandable and independently functional. Roughly 100 changed lines is often easy to review; 300 may be cohesive; 1,000 merits a split discussion. Similarly, a file near 1,000 total lines merits inspection of its responsibilities. These are heuristics, with exceptions for generated changes, deletions, and mechanical refactors.

When cohesion suffers, propose a concrete split by dependent commits, file group, layer, or vertical behavior slice. Separate substantial independent refactoring from new behavior; small supporting cleanups may belong together. Review the full requested scope or explicitly disclose incomplete coverage.

Check that the description explains what changes and why, with relevant requirement links and verification. Missing context is actionable when it prevents assessing intent or a consequential design decision. Apply repository title conventions rather than imposing a universal commit-writing style.

## Finding and report contract

Give each actionable finding a stable ID and an explicit action label:

| Label | Meaning |
| --- | --- |
| Required | Must be addressed before recommending approval: an evidenced bug, vulnerability, demonstrated gap in necessary test coverage, standards breach, or material structural regression. |
| Optional | A worthwhile improvement with a concrete benefit; approval does not depend on it. |
| Nit | A minor optional detail. Include sparingly; leave automated style checks to tooling. |
| FYI | Context without a requested change. Exclude from actionable finding counts. |

Each finding states **ID, axis, action label, file and precise line/hunk, evidence, triggering condition or violated rule, consequence, confidence, and smallest useful remedy**. Quote only the relevant requirement or rule. For security, also include the severity and attack-path details defined above. Keep wording direct and focused on code, and label estimates or assumptions.

Validate all candidates before aggregation. Deduplicate reports of the **same reason**, giving the finding one primary axis and cross-referencing it elsewhere without counting it twice. Preserve distinct reasons at the same location as separate findings: an unmet requirement and an authorization failure can need different fixes.

Present one report containing:

1. **Scope and sources:** pinned comparison or patch, intent, standards, and evidence limitations.
2. **Five axis sections**, in order: `Correctness`, `Readability & Simplicity`, `Architecture`, `Security`, `Performance`. Within each, put Required findings first, ordered by impact, then Optional findings. For an empty section, state “No findings” with a brief account of the coverage. Mark partial or inapplicable coverage explicitly. Under Security, separate `Concrete findings` from `Unresolved risks`, including when either is empty.
3. **Verification:** reviewer-run checks and results, available author/CI evidence, and remaining checks.
4. **Summary:** a compact table showing coverage, Required/Optional counts, and the most consequential issue for each axis; count Nits with Optional findings and exclude FYIs, cross-references, and unresolved risks. Also state the highest concrete security severity (or none) and unresolved security-risk count.
5. **Recommendation:** `Approve`, `Request changes`, or `Incomplete`. Recommend approval only with adequate evidence and no unresolved Required findings. Request changes for established blockers. Use Incomplete when missing intent, context, or verification prevents a justified decision, and name what would resolve it. A blocking security uncertainty prevents approval without being counted as a proven vulnerability.

Technical evidence and applicable standards govern disagreements. Explain design tradeoffs rather than enforcing taste. Concrete fixes or documented, authorized exceptions resolve blockers; vague promises of later cleanup do not. Keep approval conditional on the reviewed artifact and describe any accepted exception explicitly.
