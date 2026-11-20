# TypeScript preferences

Apply these to TypeScript code alongside the shared preferences in the skill entry point.

## External data

Type data whose shape the program has not checked as `unknown`. This covers `JSON.parse` results, `response.json()`, values read from storage, native-module payloads, and event or message payloads. Narrow or parse the value before using it. Also write `unknown`, not `any`, wherever a type is genuinely open, so the compiler keeps checking every use.

Giving an unchecked value a type annotation, as in `const session: StoredSession = JSON.parse(raw)`, makes the same unchecked claim as `as`. Treat it the same way.

## Schema validation

Parse external data with the project's established schema library, such as Zod, and use the parsed result rather than the original input. Where a project has none, validate in a parse function whose return type comes from its checks.

Use strict object schemas, such as `z.strictObject` in Zod 4, to enforce the shared unknown-field policy.

## Type assertions

Let narrowing, annotations, and parsing establish types. In production code, use `as` only in these cases:

- after a check of everything the target type promises beyond the source type;
- to widen to a supertype, as in `(KNOWN_ROLES as readonly string[]).includes(code)`;
- to work around a specific compiler limitation, with a short comment naming it.

`as const` is not covered by this rule. Test doubles may use `as` to stand in for objects they only partly build.

## Type guards

Write each type guard so its body checks everything its predicate claims beyond the parameter's declared type. A guard that checks less is an unchecked assertion with a name.

## Variant types

Model a value with several distinct shapes as a union of object types, so each shape carries exactly the fields it needs. If a bug makes you ask whether two fields can occur together, tighten the type until the compiler answers.

- When code branches on the variant, give every member a shared literal discriminant, such as `kind` holding a string literal or enum member.
- When callers choose between mutually exclusive fields, as in caller-facing configuration, mark each absent field `?: never` so that supplying both fails to compile. Narrowing with `in` is sound only once the fields are exclusive in this way.

## Exhaustive switches

Make every switch over a union or enum fail to compile when a new member is added. Where the project enables `@typescript-eslint/switch-exhaustiveness-check`, that rule covers this. Otherwise, end the switch with a default arm that assigns the whole narrowed value to `never` and throws; when the switch is on a discriminant such as `shape.kind`, assign `shape`, since TypeScript narrows the object itself. The throw also rejects values from untyped callers at runtime:

```ts
default: {
  const unhandled: never = shape;
  throw new Error(`unsupported shape: ${JSON.stringify(unhandled)}`);
}
```

## Object literals

Type object literals with an annotation or `satisfies` instead of `as`, so the compiler reports missing and excess properties. Use `satisfies` when the value should keep its literal types, as in a constant table declared `as const satisfies Record<string, Options>`.

## Branded types

TypeScript compares types by structure, so an alias such as `type UserId = string` does not keep identifiers apart. Apply the shared domain-type preference with a brand, such as `string & { readonly __brand: "UserId" }`.

Create branded values only in the guard or parse function that does the validation, so that holding the type proves the check ran.
