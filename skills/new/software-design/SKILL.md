---
name: software-design
description: Use when writing or thinking about an application's code. Use to guide design, generation, refactoring of a software system and to guide design principals and standards. Load relevant language, framework, and backend guidance as needed.
---

# Software Design

## Fit the project

Follow the current task, project instructions, and established code conventions in the repositories you are working in. Use these defaults where the project leaves a choice open, or when the user explicitly requests them in place of an existing convention.

Apply the shared principles to new and modified code during design, implementation, refactoring, and review. Never inflate the PR with unrelated stylistic realignment (even if such changes are valid given your ruleset) if you are working on a targeted feature or bugfix - such cleanup should happen seperately in a dedicated cleanup pass when requested.

## Minimal implementation

Implement the complete requested behavior with the smallest amount of clear, maintainable code that satisfies the requirements and project conventions. Apply this preference throughout implementation and review.

- Reuse existing project code, standard-library features, and established dependencies before introducing another implementation.
- Keep behavior, branches, configuration, and extension points limited to present requirements. Add flexibility when a concrete caller needs it.
- Introduce helpers, types, modules, and layers when they reduce concrete complexity, enforce a useful contract, or centralize nontrivial behavior. Each addition should earn its implementation and caller overhead.
- Prefer fewer lines when behavior and readability are equivalent. Preserve useful names, explicit control flow, and meaningful types.
- Judge the amount of code maintained across the affected implementation, rather than only the size of the diff. Keep simplification within the task's scope.
- Use focused tests for distinct behaviors and failure modes. Reuse fixtures and existing coverage while preserving required checks.

Before final validation, review the change for code that can be removed, inlined, combined, or replaced with existing functionality. Simplify anything that adds no necessary behavior or meaningful clarity.

## Modules and interfaces

Design **deep modules**: substantial behavior behind a small interface. The aim is **leverage** for callers (more capability for less to learn) and **locality** for maintainers (knowledge, changes, bugs, and verification concentrated in one place).

Use these terms consistently when discussing design:

- **Module:** Anything with an interface and an implementation: a function, class, package, or slice spanning several tiers or across multiple files.
- **Interface:** Everything a caller MUST know to use a module correctly, including types, invariants, ordering, error modes, configuration, and performance characteristics.
- **Implementation:** The code and internal organization behind that interface.
- **Depth:** The behavior a caller or test can exercise per unit of interface they must understand. Judge depth by leverage, rather than implementation size or a ratio of line counts.
- **Seam:** A place where behavior can be replaced without editing the code that uses it. Choosing its location is a separate decision from choosing what goes behind it.
- **Adapter:** A concrete implementation satisfying an interface at a seam; the term describes its role.

Preserve project domain vocabulary, including an existing `GLOSSARY.md` or `GLOSSARY-MAP.md`. Use precise technical terms such as HTTP API, service layer, or bounded context for those specific concepts; use module, interface, and seam for the design concepts above.

Your guidelines to follow when designing software, at a high level, are as follows:
- Reduce what callers must know. Prefer fewer entry points, simpler parameters, and constraints enforced inside the module where this makes the interface easier to use correctly.
- Keep internal composition behind the interface. A deep module can contain small parts and internal seams for its own tests without exposing them to callers.
- Apply the **deletion test** before adding an abstraction: if removing it makes complexity vanish, it may be a pass-through; if that complexity reappears across callers, it is earning its keep.
- Introduce substitution seams for actual variation. One adapter suggests a hypothetical seam; two justified adapters establish a real one. Reuse an existing seam before adding another port just for a fake.
- Accept dependencies that need substitution or coordination, and keep their construction at the composition point. An existing ORM connection or transaction handle can be the dependency; this principle does not require a new persistence abstraction.
- Prefer returning calculated values over mutating caller-owned state. Keep necessary side effects in the workflow that owns them. A straightforward workflow can make decisions beside its persistence calls without first producing an in-memory plan.

## Read applicable references

Apply the shared principles in this file, then read only the references relevant to the task.

- **Designing or restructuring a module's interface:** [Module design](references/module-design.md) for evaluating depth, caller knowledge, and seam placement.
- **Deepening a cluster of modules:** [Deepening](references/deepening.md) for dependency categories, adapter choices, and replacing redundant tests while preserving coverage.
- **Exploring alternative interfaces:** [Design it twice](references/design-it-twice.md) for comparing substantially different designs. Use this when alternative design exploration is requested, rather than as a routine code-generation step.
- **Dart code:** [Dart preferences](references/languages/dart.md) for explicit failure values, Result dependencies, and JSON conversion.
- **Rust code:** [Rust preferences](references/languages/rust.md) for ownership, identifier wrappers, deserialization, fallible control flow, repeated implementations, error-reporting tools, and focused test coverage.
- **Flutter code:** [Flutter preferences](references/frameworks/flutter.md) for presentation and form components.
- **Riverpod code:** [Riverpod preferences](references/frameworks/riverpod.md) for subscription granularity and selection costs.
- **Backend or database work:** [Backend structure](references/backend-structure.md) for feature grouping, layer responsibilities, transaction contracts, API/model separation, and persistence tests.
- **Rust backend modules:** Also read [Rust backend conventions](references/languages/rust-backend.md), along with the Rust and backend references, for feature files and struct-associated service and repository functions.
- **SeaORM entity definitions:** Also read [SeaORM conventions](references/frameworks/seaorm.md) for entity module naming and multiple tables.

## Control flow

- Use guard clauses and early returns to keep the main path flat.
- Prefer readable transformation chains where idiomatic, with short steps for iterating, filtering, mapping, and collecting rather than mutable bookkeeping.
- Short bindings in small closures are fine when local context makes their meaning obvious, and doing so helps keep code clean.

### Named conditions

Name boolean variables used in conditionals as predicates, such as `name_changed`, `name_matches`, `is_valid`, or `has_permission`, using the language's casing conventions. The name should make the decision readable without inspecting its calculation.

When a branch condition is hard to scan or spans two or more lines, extract its evaluation into descriptive local booleans. Aim for a single readable line in the conditional. Split independent parts when this helps; give the combined decision a meaningful name when combining those names still makes the condition long. Keep simple, obvious checks inline.

```python
name_matches = left.name == right.name
age_matches = left.age == right.age
address_matches = left.address == right.address

if name_matches and age_matches and address_matches:
    return

update_profile(right)
```

Keep extracted checks close to their use. Preserve evaluation order, short-circuiting, and guard safety; evaluate dependent checks only after their prerequisites hold.

## Helpers and reuse

- A second caller alone does not justify a shared helper. Small, familiar mechanics such as basic file or byte reading can stay local even when duplicated.
- Favor extraction for algorithmic work, nontrivial complexity, or logic that requires a specific understanding of a process. Extract named steps when they simplify repeated use in transformation chains.
- Keep transformations inline while they remain easy to understand. Extract a helper when its name or shared implementation materially reduces reasoning.

## Types and inputs

- Reject unknown fields by default when deserializing into a structured type, including API responses consumed by clients.
- Use domain types to distinguish semantically different identifiers when interchange would be a bug. Use the language's type system to catch accidental mixing where possible.
- When a concept warrants its own type, centralize validation in parsing or construction. Downstream operations consume the validated value without knowing every check.
- Reasonably expected type-specific behavior is another reason for a dedicated type. These preferences do not require wrapping every primitive.
- Group related business values into a named input type for service calls, such as recipient, role, and expiry. Keep execution context, such as the transaction, and the target entity identifier explicit. Use judgment rather than a universal argument-count cutoff.
- For related business actions sharing mechanics, prefer one helper with a descriptive enum parameter over action-named wrappers or a boolean mode flag. This applies even to small private helpers with nearby callers.

## Time

Read the current time inside functions as needed. When a service requires a consistent date or timestamp across multiple models, capture it once at the beginning of the service function and pass it to the relevant helpers and repository operations.

## Errors

When a conversion fails, use a reasonable default when one exists and document the recovery scenario and fallback behavior. If no suitable default exists, return the failure through the function's error contract.

At the application surface, where a failure is displayed to a user, use contextual error reporting while preserving the cause. For reusable libraries whose consumers may react to failure kinds, expose a meaningful higher-level error type describing what went wrong programmatically.

## Comments

Preserve meaningful context beyond the code's mechanics, especially external commitments and change-sensitive policy values. For example, If customer support guarantees recovery for exactly 30 days, the recovery-window constant's comment should preserve that promise and its exact value so a future editor can see the consequence of changing it. State verified commitments rather than inventing a reason.

## Tests

- Treat the module's interface as the test surface. Assert observable outcomes through that interface so internal refactors can preserve the tests. Internal modules can have their own tests at their own interfaces; keep private implementation details out of caller-facing tests.
- Prefer separate, behavior-named tests for distinct scenarios, including closely related boundary cases. Each should have its own failure report and be easy to run, change, or remove independently.
- Keep those scenarios independently runnable rather than bundling assertions into a table-driven loop that stops at its first failure. Shared fixture helpers are compatible with this preference.
- When deepening a module, replace tests coupled to removed internals once tests through the new interface protect their meaningful behavior. Preserve coverage of distinct contracts and regressions.

## Refine from review feedback

When the user asks to incorporate a PR correction or another concrete example, update the narrowest applicable rule while retaining its reason, scope, and exceptions.

Keep shared principles here, substantial design guidance in the design references, language-specific decisions under `references/languages/`, and framework-specific decisions under `references/frameworks/`. Add a reference only when concrete guidance exists, with a conditional read link above. Keep project-only conventions local unless the user adopts them as a personal default.
