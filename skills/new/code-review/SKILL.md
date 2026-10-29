---
name: code-review
description: >-
  Review a set of code changes (PR, branch, diff).
  Use when the user asks for a "code review" or another skill requires this as part of an approval gate. 
metadata:
  dependencies: []
---

# Code review

Review code change across the following areas. A passing result in one area does not clear another. 
- Correctness
- Readability and simplicity
- Architecture and design
- Security
- Performance

Recommend approval when the change delivers its intended behavior, maintains or improves code health, follows project standards, and has no unresolved blockers. Optional improvements and nits can wait.

A review authorizes inspection and a report. Keep the author's files intact. Code changes, deletions, published comments, submitted approvals, and merging need separate authorization.

## Workflow

### 1. Establish the scope

Capture a stable snapshot of the requested change:

- **Branch:** resolve refs with `git rev-parse --verify`, find the base with `git merge-base`, and capture `git diff <merge-base-sha> <head-sha>` and `git log <merge-base-sha>..<head-sha> --oneline`. Use the resolved SHAs throughout.
- **Pull Requests / PRs**: Identify the branches relevant to the pull request, and then resolve the artifacts from there.
- **Single commit**: Identify the changes with `git show <commit-hash>`.
- **Working Tree**: `git diff HEAD` shows the combined tracked result; `git diff --cached` selects staged changes and `git diff` selects unstaged changes. Find untracked files with `git ls-files --others --exclude-standard` and capture relevant contents. Preserve the selected snapshot: staged content can differ from the file on disk.
- **Supplied patch or inline diff**: Review the diff and available surrounding code. State any missing context.

Read surrounding code from the reviewed head or captured snapshot so unrelated local edits do not affect the assessment.

Infer the base commit when repository context is unambiguous, and state the assumption. Otherwise ask while gathering independent context. Stop a comparison with invalid refs. Report an empty diff as empty.

Record the scope, endpoints or patch, commit list, and changed files. Every reviewer must use the same snapshot. If it changes, identify the new scope and revisit affected findings.

### 2. Gather intent, standards, and evidence

Read applicable repository instructions and gather these sources once for all reviewers:

- **Standards**: `AGENTS.md`, `CODING_STANDARDS.md`, `CONTRIBUTING.md`, and relevant design, naming, testing, and language guidance. Apply nested instructions within their scope.
- **Intent**: start with the user's requirements or supplied path, then the PR description, linked issues, commit issue references, relevant ADRs (`docs/adr/`), architecture docs (`docs/architecture/`), `GLOSSARY.md`/`GLOSSARY-MAP.md`, and relevant files under `specs/` or `.scratch/`. Use available tracker tools or repository workflows; tracker setup should not block review.
- **Security**: `SECURITY.md`, threat models, security ADRs, and guidance on authentication, authorization, tenant isolation, privacy, and secrets. Read tests around changed boundaries.
- **Verification**: test/build commands, CI results, and the author's reported tests, manual checks, screenshots, or benchmarks.

Record sources, conflicting expectations, and evidence gaps. Ask about missing intent when the answer could change the assessment; continue independent work.

Without a spec, assess correctness against the stated goal, public contracts, existing behavior, and tests. Mark **spec coverage unverified**. Keep implementation-derived assumptions separate from requirements.

Project standards override the design heuristics below. Cite the source and rule for standards violations; label design judgments as judgments. Local conventions cannot excuse an evidenced vulnerability. Leave routine formatting and lint enforcement to configured tools, and report relevant failures once.

### 3. Read tests and review all five axes

Read changed tests and nearby contract tests first. Identify the behaviors they establish, failures they catch, and significant paths they omit.

Run one independent sub-agent per axis in parallel. Give each reviewer:

- The same snapshot, endpoints, commits, and changed-file list.
- Its axis guidance in full, or an accessible path with instructions to read it.
- Applicable source paths or fetched contents, known intent, and evidence gaps.
- The finding format and coverage requirements in this skill.

Reviewers may inspect surrounding code and tests. They must preserve the author's files and report proposed fixes. Ask for actionable findings, uncertainties, and coverage without a findings quota or a word limit that cuts off evidence.

Keep initial passes independent. Each reviewer must consider every changed file, following relevant callers, callees, configuration, and data flows beyond the diff. Account for every applicable requirement and any unavailable evidence. Generated files, lockfiles, and deletions may need different depth, but still need coverage.

The coordinator validates and reconciles the results.

### 4. Validate findings and verification

Confirm that each reported problem is introduced, exposed, or materially worsened by the change. Check surrounding guards, callers, contracts, and tests. Keep unchanged problems outside the findings unless the diff activates or aggravates them.

Run the smallest relevant tests and required repository checks when feasible. Record commands, results, and checks that could not run. Separate reviewer-run results from author or CI evidence, and pre-existing failures from regressions. Passing tests support the behavior they exercise; they do not establish all five axes.

For bug fixes, look for a regression test that fails on the old behavior and passes on the new. If test sensitivity remains unclear, or confirming a finding requires code changes, describe the proposed experiment and get approval before doing that additional work.

After approval, use a worktree or isolated copy containing the reviewed snapshot. Compare base and head or make a targeted mutation, then restore the copy. Mutations should represent plausible failures. Report a surviving mutation as a coverage gap only when it demonstrates a meaningful missing behavioral assertion. Routine review does not require mutation testing.

### 5. Report and recommend

Use the report format below. If a follow-up review is requested after fixes, establish the new snapshot and recheck affected paths and verification.

## The five axes

### Correctness

- Map requirements to implementation and observable tests. Cite the spec when reporting missing, partial, or incorrect behavior.
- Trace relevant happy, error, and edge paths: validation, empty and boundary values, state transitions, retries, concurrency, cleanup, and failure propagation.
- Check compatibility across APIs, persisted data, migrations, configuration, and consumers. Distinguish intended changes from regressions.
- Prefer integration tests for contracts crossing these boundaries. Use `tdd` to test at the boundary first, adding internal tests when needed, such as for a stable algorithm. Flag mocks or implementation assertions that leave significant behavior untested, and check that scenarios fit the change's scope.
- Identify unrelated behavior or unrequested features. Explain the scope mismatch and propose a separation.

### Readability & Simplicity

- Expect meaningful names, consistent terminology, and straightforward control flow. Comments should explain non-obvious intent or invariants. Replace obvious inline narration with clearer names or function/module documentation.
- Propose concrete simplifications: remove unnecessary branches, speculative hooks, redundant wrappers, or abstractions whose cost exceeds their benefit.
- Establish reachability and external usage before calling code dead. Compatibility layers can serve supported or plausible future consumers.

### Architecture

- Evaluate coupling, dependency direction, domain ownership, and interface size relative to the behavior hidden behind it. Follow established patterns or explain why a new one better serves the requirement.
- Keep feature logic in its owning module, especially when it depends on that module's internals. Separate orchestration from domain logic when it clarifies responsibilities.
- Give each rule a clear owner. Reuse canonical helpers, unify duplicate rules, and gather logic that otherwise requires scattered coordinated edits. Repeated dispatch may benefit from a shared dispatcher, typed model, or suitable polymorphism.
- Group fields that repeatedly travel together into a cohesive value or parameter type. Model domain rules hidden in primitives. Question casts, broad types, optionality, and silent fallbacks that conceal invalid states.
- Refactoring should remove unnecessary concepts, branches, modes, or layers, or hide complexity behind a simpler interface. Expose meaningful operations instead of making callers traverse internals. Remove pass-through wrappers unless they protect a useful boundary.
- Split modules with unrelated responsibilities. Narrow inherited contracts or use composition when an implementation rejects much of its contract. File length is a reason to inspect responsibilities, not a verdict.

Treat these design suggestions as judgments. Make a structural concern Required when it violates a project standard or demonstrably worsens maintainability, coupling, or contracts. Otherwise offer an Optional improvement with its tradeoff. Propose the smallest useful change; extraction and polymorphism must earn their complexity.

### Security

Trace untrusted input to privileged operations or tenant data. Include input from users, external services, files, queues, databases, and configuration.

Check:

- Authentication and authorization: missing or late checks, confused-deputy behavior, privilege escalation, tenant isolation, and insecure defaults.
- Unsafe interpretation: SQL, command, or template injection; XSS; path traversal; SSRF; unsafe deserialization; and client-controlled queries. Check parameterization, encoding, and validation at the actual boundary.
- Sensitive data: secrets or personal data exposed through responses, logs, errors, caches, analytics, or overly broad reads. Describe secret locations without reproducing values.
- Integrity and availability: replay, races, destructive operations, unbounded work, and attacker-controlled resource consumption.
- Cryptography and secrets: incorrect verification, weak randomness, embedded credentials, and unnecessary secret propagation.
- Dependencies and configuration: reachable vulnerable behavior, compromised provenance, exposed services, relaxed controls, and excessive permissions.

Separate concrete findings from unresolved risks. A finding needs a broken invariant and a plausible source-to-sink or attacker-to-impact path through the changed behavior. Include exploitation preconditions, impact, confidence, and the smallest useful remediation.

When the path is unproven, state the unknown and the check needed to resolve it. Report it as a risk without claiming a vulnerability.

Assign severity from impact and exploitability:

- Critical: practical exploitation can cause catastrophic compromise.
- High: plausible exploitation crosses a major trust boundary or compromises sensitive data, authorization, or system integrity.
- Medium: meaningful impact with narrower reach or substantial preconditions.
- Low: limited impact or a defense-in-depth weakness.

If no plausible attack path is found, report no security findings and state the reviewed surface and limitations. Keep severity separate from confidence; uncertainty does not establish severity.

### Performance

- Check N+1 queries, unbounded loops or fetching, missing pagination or limits, repeated work, expensive allocations, unnecessary UI renders, and blocking I/O on latency-sensitive paths.
- Trace growth with input size, concurrency, and request rate. Inspect affected cleanup, caches, memory, and connection usage.
- Tie concerns to reachable paths and realistic workloads. Use operation counts, measurements, or labeled estimates. Speculative micro-optimizations are Optional at most.
- Seek comparable before/after measurements for claimed optimizations or suspected regressions. If scale or workload is unknown, state the assumption and benchmark needed.

## Conditional checks

### Dependencies and lockfiles

Review the shipped dependency graph, including transitive changes:

- Architecture: whether existing utilities suffice, stack compatibility, maintenance status, license constraints, and the dependency's cost.
- Correctness: changelogs, migration notes, behavior changes, and relevant tests against base and head. Semver and successful installation do not establish compatibility.
- Security: provenance, advisories, and exploit reachability. Use ecosystem audit tools and authoritative package sources. Distinguish an advisory from a demonstrated application vulnerability.
- Performance: bundle size, startup, and hot-path effects where applicable.

Check that manifests and lockfiles agree and required lockfile changes are included and reproducible. Prefer isolated upgrades or small related groups when they make failures and rollback easier to attribute. Bulk updates deserve scrutiny, not automatic rejection.

### Change size and description

Check that the change has one coherent purpose, includes related tests, and remains understandable and independently functional.

Roughly 100 changed lines is often easy to review; 300 may be cohesive; 1,000 merits a split discussion. A file near 1,000 lines merits a look at its responsibilities. Allow for generated changes, deletions, and mechanical refactors.

When cohesion suffers, propose a concrete split by dependent commits, file group, layer, or vertical behavior slice. Separate substantial independent refactoring from new behavior; small supporting cleanups may belong together. Review the full requested scope or disclose incomplete coverage.

The description should explain what changes and why, with relevant requirements and verification. Flag missing context when it prevents assessing intent or a consequential design decision. Follow repository title conventions.

## Findings and report

Give actionable findings stable IDs and an action label:

- Required: an evidenced bug, vulnerability, necessary test-coverage gap, standards violation, or material structural regression that blocks approval.
- Optional: an improvement with a concrete benefit that does not block approval.
- Nit: a minor optional detail. Include sparingly and leave automated style checks to tooling.
- FYI: context without a requested change. Exclude it from actionable counts.

Each finding needs its ID, axis, action label, precise file and line/hunk, evidence, trigger or violated rule, consequence, confidence, and smallest useful remedy. Security findings also need severity and attack-path details. Quote only the relevant requirement or rule. Focus on the code and label assumptions or estimates.

Validate findings before combining them. Deduplicate findings with the same underlying reason: assign one primary axis and cross-reference elsewhere without counting twice. Keep distinct reasons separate even at the same location; an unmet requirement and an authorization failure may need different fixes.

Present one report containing:

1. Scope and sources: the reviewed comparison or patch, intent, standards, and evidence limitations.
2. Five sections in order: `Correctness`, `Readability & Simplicity`, `Architecture`, `Security`, `Performance`. Put Required findings first by impact, then Optional findings. For empty sections, state “No findings” and briefly describe coverage. Mark partial or inapplicable coverage. Under Security, separate `Concrete findings` and `Unresolved risks`, even when empty.
3. Verification: reviewer-run checks and results, author/CI evidence, and remaining checks.
4. Summary: a compact table with coverage, Required/Optional counts, and the most consequential issue per axis. Count Nits as Optional; exclude FYIs, cross-references, and unresolved risks. State the highest concrete security severity, or none, and the unresolved security-risk count.
5. Recommendation: `Approve`, `Request changes`, or `Incomplete`.

Approve only with adequate evidence and no unresolved Required findings. Request changes for established blockers. Use Incomplete when missing intent, context, or verification prevents a justified decision, and say what would resolve it. A blocking security uncertainty prevents approval without counting as a proven vulnerability.

Resolve disagreements through technical evidence and project standards. Explain design tradeoffs. Concrete fixes or documented, authorized exceptions can resolve blockers; vague promises of later cleanup cannot. Tie approval to the reviewed snapshot and state any accepted exception.
