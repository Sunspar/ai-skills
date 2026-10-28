---
name: personal-coding-style
description: Apply the user's coding preferences when implementing or refactoring code. Use these defaults where project conventions leave a choice open or the user explicitly requests this style, loading language and framework guidance only as relevant.
---

# Personal Coding Style

## Fit the project

Follow the current task, project instructions, and established code conventions. Use the defaults below where the project leaves a choice open, or when the user explicitly requests them in place of an existing convention.

For a functional change, follow the surrounding code's style. Keep stylistic realignment in a separate cleanup change or PR; the profile alone does not request that cleanup.

## Read applicable references

Apply the shared preferences below, then read only the references relevant to the work:

- **Dart code:** [Dart preferences](references/languages/dart.md) for explicit failure values, Result dependencies, and JSON conversion.
- **Rust code:** [Rust preferences](references/languages/rust.md) for ownership, identifier wrappers, deserialization, fallible control flow, repeated implementations, and error-reporting tools.
- **Flutter code:** [Flutter preferences](references/frameworks/flutter.md) for presentation and form components.
- **Riverpod code:** [Riverpod preferences](references/frameworks/riverpod.md) for subscription granularity and selection costs.
- **Backend or database work:** [Backend structure](references/backend-structure.md) for feature grouping, layer responsibilities, transaction contracts, API/model separation, and persistence tests.
- **Rust backend modules:** Also read [Rust backend conventions](references/languages/rust-backend.md) for feature files and struct-associated service and repository functions.
- **SeaORM entity definitions:** Also read [SeaORM conventions](references/frameworks/seaorm.md) for entity module naming and multiple tables.

## Control flow

- Use guard clauses and early returns to keep the main path flat. Avoid rightward drift that makes readers track successive levels of conditions.
- Prefer readable transformation chains where idiomatic, with short steps expressing the sequence of iterating, filtering, mapping, and collecting rather than mutable bookkeeping.
- Short bindings in small closures are fine when local context makes their meaning obvious.

## Helpers and reuse

- A second caller alone does not justify extracting a shared helper. Small, familiar mechanics such as basic file or byte reading can stay local even when duplicated.
- Favor extraction for algorithmic work, nontrivial complexity, or logic that requires a specific understanding of a process. Repeated use in transformation chains is another reason to extract when a named step simplifies those chains.
- An inline transformation around five or six lines can stay inline, but it is approaching the user's preferred limit. Extract a helper when it grows further or requires several reasoning steps, and call that helper from the chain. Treat complexity and readability as the criteria, not a hard line count.

## Types and inputs

- Reject unknown fields by default when deserializing into a structured type, including API responses consumed by mobile clients.
- Keep `normalize` limited to data cleanup, such as trimming whitespace. Put data validation and business-rule checks in a separate `validate` function.
- Use domain types to distinguish semantically different identifiers when interchange would be a bug. Use the language's type system to catch accidental mixing where possible.
- When a concept warrants its own type, centralize validation in parsing or construction. Downstream operations consume the validated value without knowing every check. Email addresses and database identifiers are established examples.
- Reasonably expected type-specific behavior is another reason for a dedicated type. These examples do not require wrapping every primitive.
- Group related business values into a named input type for service calls like recipient, role, and expiry. Keep execution context, such as the transaction, and the target entity identifier explicit. No universal argument-count cutoff has been established.
- For related business actions sharing mechanics, prefer one helper with a descriptive enum parameter over action-named wrappers or a boolean mode flag. This applies even to small private helpers with nearby callers.

## Time

Read the current time inside functions as needed. When a service requires a consistent date or timestamp across multiple models, capture it once at the beginning of the service function and pass it to the relevant helpers and repository operations.

## Errors

When a conversion fails, use a reasonable default when one exists and document the recovery scenario and fallback behavior. If no suitable default exists, return the failure through the function's error contract.

At the application surface, where a failure is displayed to a user, use contextual error reporting while preserving the cause.

For reusable libraries whose consumers may react to failure kinds, expose a meaningful higher-level error type that describes what went wrong programmatically.

## Comments

Include comments that preserve meaningful context beyond the code's mechanics. External commitments and change-sensitive policy values deserve an explicit explanation.

For example, if support guarantees recovery for exactly 30 days, a recovery-window constant's comment should preserve that promise and its exact value. This makes the consequence of changing the value visible to a future editor. State verified commitments rather than inventing a reason.

## Tests

- Prefer separate, behavior-named tests for distinct scenarios, including closely related boundary cases. Each scenario should have its own failure report and be easy to change or remove.
- Keep those scenarios independently runnable rather than bundling assertions into a table-driven loop that stops at its first failure. Shared fixture helpers are compatible with this preference.

## Refine from review feedback

When the user asks to incorporate a PR correction or another concrete example, update the narrowest applicable rule while retaining its reason, scope, and exceptions.

Keep shared preferences here, language-specific decisions under `references/languages/`, and framework-specific decisions under `references/frameworks/`. Add a reference only when concrete guidance exists, with a conditional read link above. Keep project-only conventions local unless the user adopts them as a personal default.
