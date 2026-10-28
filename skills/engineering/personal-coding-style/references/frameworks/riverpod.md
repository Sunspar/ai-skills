# Riverpod Preferences

Apply these when using Riverpod, alongside the shared preferences and the Flutter reference when relevant.

## Subscription granularity

Prefer selecting the smallest value a consumer needs when selection overhead is modest. For a cheap immutable property such as an identifier, default to `ref.watch(provider.select(...))`. Extra code is acceptable for a tighter dependency.

Use inexpensive selectors and immutable selected values with suitable equality. A full-model watch is acceptable when granular selection adds material overhead or the consumer actually needs the whole model. When overhead is a concrete concern, assess update frequency, selector and equality cost, subscription churn, and rebuild work rather than choosing by watcher count alone. Document non-obvious performance-driven choices.
