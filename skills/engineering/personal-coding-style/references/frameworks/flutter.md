# Flutter Preferences

Apply these to Flutter code alongside the shared preferences in the skill entry point.

## Presentation fragments

Prefer widget classes for named UI fragments by default. For a trivial single-value display, such as directly rendering a name in `Text`, a small widget-returning helper is appropriate.

Use a widget class when the fragment manipulates its inputs, includes additional presentation logic, or combines multiple values whose formatting may change.

## Widget lists

When composing widget lists, prefer spreading a mapped iterable, such as `...dogs.map((d) => DogTile(dog: d))`, over a collection `for`. The mapping reads more clearly to the user.

Use multiple spreads when several sequences contribute children; they can appear alongside fixed widgets and collection `if` elements. Both collection `for` and spread expressions support multiple sequences in one list, so this preference is about readability rather than a restriction of either form.

## Text fields

Use explicit `TextEditingController`s for text fields by default, including simple fields that do not currently need programmatic editing. Read their values when constructing submission input; the owning widget manages their lifetime and disposal.

## Form submission

Expose form submission as a no-argument `submit()` or `onSubmit()` operation that higher-level controls and event hooks can trigger.

The form owns field collection, validation, pre-submit work, and the actual submission workflow. Gather the current values from its controllers and child field components, validate the fields, and coordinate any required external calls and server writes through the feature's service or repository APIs.

Parents trigger that operation without constructing or passing an input object or knowing the form's submission details. The form defines what submission entails and can delegate parts of the work to helpers or services.

After a successful save, report completion through a hook such as `onSaved`. The host page owns navigation and other page-level reactions to completion; keep the form a lower-level component.

## Complete editor resets

Both key-based recreation and explicit state synchronization are acceptable for an intentional full reset. Use a new key when recreating the editor preserves rendering, visual stability, and accessibility behavior. Prefer resetting the existing state when recreation would cause rendering problems, flicker, or accessibility issues.
