# Module Design

Read this when defining a module's interface, choosing a seam, or restructuring responsibilities. Use the vocabulary and shared principles in [the skill entry point](../SKILL.md).

## Evaluate the complete interface

An interface includes implicit knowledge as well as declared types. When assessing its complexity, include the facts a caller must remember: valid states, call order, error handling, configuration, and performance constraints.

Treat the complete caller-facing surface as the module's interface, even when several methods or types express it. A TypeScript `interface` declaration or a class's public method signatures describe only part of that surface.

For a proposed interface, ask:

- Which constraints can the module enforce instead of making callers remember them?
- Can it offer fewer entry points or simpler inputs without moving complexity into callers?
- Does each entry point expose useful behavior, or mostly relay an internal operation?
- Will a behavior change be localized, or require coordinated changes across callers?
- Can callers and tests exercise the behavior through the same interface?

## Depth and internal composition

A shallow module asks callers to understand nearly as much complexity as its implementation contains. Adding such a module can increase the number of concepts callers must learn without providing useful leverage.

Depth comes from the work the interface saves callers. A large implementation does not establish depth, and a small implementation can still provide a useful abstraction. Use the deletion test from the entry point to distinguish hidden complexity from added indirection.

Internal composition can remain fine-grained. Private helpers, internal modules, and their tests do not have to become part of the containing module's caller-facing interface. Keep an internal seam private when only the implementation and its own tests need it.

## Adapter role and seam placement

An adapter's role is distinct from its implementation's size. A Postgres repository can have a substantial implementation while filling a narrow adapter role. An in-memory fake can have a small implementation while satisfying a broad interface. Say "adapter" when discussing the slot it fills and "implementation" when discussing its code.

Choose where behavior must vary before deciding how much implementation to put behind that seam. A module can span deployment tiers when its caller-facing interface hides the transport and coordination details. It can also use an existing connector internally without exposing another port to callers.

Read [Deepening](deepening.md) when dependency ownership and available test adapters determine which arrangement is practical. Read [Design it twice](design-it-twice.md) when the user wants substantially different candidate interfaces compared.
