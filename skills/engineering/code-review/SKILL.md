---
name: code-review
description: Review the changes since a fixed point (commit, branch, tag, or merge-base) along three axes — Standards (does the code follow this repo's documented coding standards?), Spec (does the code match what the originating issue/spec asked for?), and Security (does the code introduce new vulnerabilities or risks to the project). Runs reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to "review since X".
---

Multi-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards** — does the code conform to this repo's documented coding standards?
- **Spec** — does the code faithfully implement the originating issue / spec?
- **Security** - does the code introduce new risks, create vulnerabilities through exploitable paths, or weaken trust boundaries?

All axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings.

The issue tracker should have been provided to you — run `/setup-engineering-skills` if `docs/agents/issue-tracker.md` is missing.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point — a commit SHA, branch name, tag, `main`, `HEAD~5`, etc. If they didn't specify one, ask for it.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base). Also note the list of commits via `git log <fixed-point>..HEAD --oneline`.

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here — not inside multiple parallel sub-agents.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. Issue references in the commit messages (`#123`, `Closes #45`, GitLab `!67`, etc.) — fetch via the workflow in `docs/agents/issue-tracker.md`.
2. A path the user passed as an argument.
3. A spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
4. If nothing is found, ask the user where the spec is. If they say there isn't one, the **Spec** sub-agent will skip and report "no spec available".

### 3. Identify the standards sources

Anything in the repo that documents how code should be written, such as `CODING_STANDARDS.md` or `CONTRIBUTING.md`.

On top of whatever the repo documents, the Standards axis always carries the **smell baseline** below — a fixed set of Fowler code smells (_Refactoring_, ch.3) that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation — and, like any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name** — a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code** — the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy** — a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps** — the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession** — a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches** — the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery** — one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change** — one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality** — abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains** — long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man** — a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest** — a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 4. Identify the security sources

Look for security guidance in this order:

1. `SECURITY.md`, repository threat models, security ADRs, and security-specific documentation.
2. Authentication, authorization, data-classification, privacy, and secrets-handling documentation.
3. Existing tests around the trust boundaries touched by the diff.
4. Any available skills related to "software security", "red-team", "blue-team", offensive security" that might be available to the agent. 
5. The security baseline below.

The repo's documented security model wins where it is stricter than the baseline. It does not suppress a plausible vulnerability merely because the code follows local conventions.

Apply this baseline to the diff and the surrounding code needed to understand it:

- **Trust boundaries** — user input, external services, files, queues, databases, privileged processes, and tenant boundaries.
- **Authentication and authorization** — missing checks, checks performed too late, confused-deputy behaviour, privilege escalation, and insecure defaults.
- **Unsafe interpretation** — injection, command execution, path traversal, SSRF, unsafe deserialization, template execution, and client-controlled queries.
- **Sensitive data** — secrets or personal data exposed through responses, logs, errors, caches, analytics, or overly broad reads.
- **Integrity and availability** — replay, race conditions, unbounded work, attacker-controlled resource consumption, and destructive actions without sufficient validation.
- **Cryptography and secrets** — home-grown cryptography, weak randomness, incorrect verification, embedded credentials, and secrets crossing an unnecessary boundary.
- **Dependencies and configuration** — newly exposed services, relaxed security controls, dangerous permissions, or dependencies introduced into a privileged path.

Three rules bind the Security review:

- **Evidence over vibes.** Do not report a vulnerability without identifying the relevant source, sink, missing control, or broken invariant.
- **Review the change.** Existing problems are in scope only when the diff introduces them, exposes them, or makes them materially worse.
- **Separate findings from risks.** A finding is a plausible vulnerability supported by the code. A risk is a security-sensitive area where the available evidence is insufficient and a specific check is still required.

Calibrate severity from impact plus exploitability:

- **Critical** — practical exploitation can cause catastrophic compromise.
- **High** — plausible exploitation crosses a major trust boundary or compromises sensitive data, authorization, or system integrity.
- **Medium** — meaningful impact with narrower reach or substantial preconditions.
- **Low** — limited impact or a defense-in-depth weakness.

Do not inflate severity to make a finding sound important. If the exploit path is unclear, report a risk — not a vulnerability.

### 5. Spawn all applicable sub-agents in parallel

**Standards sub-agent prompt** — include:

- The full diff command and commit list.
- The list of standards-source files you found in step 3, **plus the smell baseline from step 3** pasted in full — the sub-agent has no other access to it.
- The brief: "Report — per file/hunk where relevant — (a) every place the diff violates a documented standard: cite the standard (file + the rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls — documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 400 words if possible, but do not cut yourself short if it affects intelligibility."

**Spec sub-agent prompt** — include:

- The diff command and commit list.
- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Under 400 words if possible, but do not cut yourself short if it affects intelligibility."

If the spec is missing, skip the Spec sub-agent and note this in the final report.

**Security sub-agent prompt** — include:

- The full diff command and commit list.
- The security-source files found in step 4.
- The security baseline and severity definitions from step 4, pasted in full.
- Permission to inspect relevant call sites, callers, tests, configuration, and data flows outside the diff when needed to validate an exploit path.
- The brief:

> Review this change for security, not general correctness or style.
>
> Report:
>
> 1. Concrete security findings introduced or materially worsened by the diff.
> 2. Security-sensitive risks that require a named follow-up check but are not sufficiently evidenced to call vulnerabilities.
>
> For each finding, provide:
>
> - severity and confidence;
> - file and hunk;
> - the broken security invariant;
> - the source-to-sink or attacker-to-impact path;
> - exploitation preconditions;
> - likely impact;
> - the smallest useful remediation.
>
> For each risk, state exactly what is unknown and how to verify it.
>
> Do not produce checklist noise. Do not report hypothetical attacks without a path through the changed code. Keep the report under 500 words where possible, but do not sacrifice the evidence needed to make a finding actionable.

If no security guidance exists, use the baseline. If the diff does not touch a meaningful attack surface and no plausible path is found, report "no security findings" rather than inventing one.

### 5. Aggregate

Present the under separate sections, and never merge them:

- `## Standards`
- `## Spec`
- `## Security`

Within `## Security`, show `### Concrete Findings` first, ordered by severity, followed by `### Risk highlights` for unresolved security-sensitive questions. Explicitly identify the empty risk section when no issues are found.

Do not merge duplicate-looking findings across axes. The same line can be wrong for three different reasons, and those reasons may have different owners and fixes.

End with a one-line summary containing:

- the finding count for each axis;
- the worst issue within each axis;
- the highest security severity;
- the number of unresolved security risks.

Do not select one overall "winner". The axes answer different questions.

## Why different axes

A change can pass one axis and fail another:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.
