# Rust Preferences

Apply these to Rust code alongside the shared preferences in the skill entry point.

## Identifier types

Use distinct wrapper structs for semantically different identifiers such as `UserId` and `TeamId`, even without additional methods, so swapped arguments fail to compile.

Aliases to the same primitive are the same type and do not provide that protection. The shared validation and input-grouping preferences apply through Rust types and structs.

## Deserialization

For structs deserialized with Serde, add `#[serde(deny_unknown_fields)]` by default to enforce the shared unknown-field policy.

## Fallible workflows

For distinct fallible workflow steps, prefer sequential statements with `?`. Use existing error conversions or `map_err` to translate failures into the function's unified error type. Intermediate variables are worthwhile when they make the sequence clearer.

Chaining remains appropriate for a coherent sequence of operations on the same object. The preference for `?` is not a general rejection of chaining.

## Repeated implementations

Use a small `macro_rules!` macro when substantially identical code is repeated across many types or modules and a shared definition simplifies maintenance. Centralize the repeated implementation so a behavior change reaches every invocation and callers have less code to write and keep in mind.

Implementing `Auditable` and `SoftDeletable` across database models is an established example: the implementation stays the same while the target type varies. Keep the macro focused on that common implementation, with inputs for the actual variation. This complements the shared helper guidance: broad repetition of identical code can justify a macro even when the individual implementation is straightforward.

## Ownership

Prefer borrowed references wherever the source data's intended use permits. Avoid cloning owned data just to remove minor borrowing friction.

Cloning can be justified by mutation or ownership requirements, or by substantial ergonomic difficulty with borrowing. Give a clear, concrete explanation for that tradeoff. Slight annoyances do not meet the user's bar; this is not a prohibition on ordinary `Copy` scalar values.

## Clock reads

With Chrono, use `Utc::now()` for local reads of the current UTC time. The shared time preference determines when a service should capture and pass a consistent value instead.

## Error-reporting tools

For application-surface error reporting, reach for a contextual report such as `anyhow` where it fits the project. Preserve the underlying cause. The shared distinction between surface reporting and programmatically handled library errors still applies.
