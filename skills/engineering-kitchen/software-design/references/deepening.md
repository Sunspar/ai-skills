# Deepening

Read this when consolidating shallow modules or moving scattered behavior behind a smaller interface. Use the vocabulary and seam discipline in [the skill entry point](../SKILL.md).

## Dependency categories

Classify the candidate's dependencies to choose where substitution belongs and how to test the behavior. Consolidation should reduce caller knowledge or improve locality; the dependency category determines how it can be done.

### In-process

Pure computation or in-memory state with no I/O can be consolidated and tested directly through the resulting interface. Introduce no adapter solely to call in-process code.

### Local-substitutable

For dependencies with suitable local test stand-ins, such as PGLite for Postgres or an in-memory filesystem, run the stand-in in the test suite and exercise the deepened module through its interface. Check that the stand-in supports the behavior the tests need.

Keep the dependency seam internal when callers do not need to select an adapter. For backend persistence, prefer the existing ORM connection or transaction handle; [Backend structure](backend-structure.md) defines its ownership and test contracts.

### Remote but owned

For services the project owns across a network, use an injected transport adapter at a port when transport substitution is justified. Production may use HTTP, gRPC, or a queue; tests may use an in-memory adapter. Keep domain logic in the deep module and transport details in the adapter.

### True external

For third-party services such as Stripe or Twilio, inject the external dependency through an appropriate interface and use a mock adapter in focused tests. Keep third-party transport details behind the seam.

## Seam placement

Keep a dependency seam internal unless its selection or behavior is part of what callers need to control. Production and test adapters can justify substitution, but an existing connector may already supply that seam. Add another port only when it hides meaningful complexity or supports actual variation.

## Replace redundant tests while preserving behavior

Test the deepened module's observable behavior through its interface. Cover the distinct contracts and meaningful regressions protected by the old tests before removing them.

Delete tests tied to removed shallow modules or implementation details once their meaningful coverage is replaced. Retain tests for surviving internal modules when they protect distinct behavior at those modules' own interfaces. Avoid accumulating two suites that verify the same behavior at different levels merely to preserve the old structure.
