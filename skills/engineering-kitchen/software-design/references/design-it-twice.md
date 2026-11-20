# Design It Twice

Based on Ousterhout's "Design It Twice": explore substantially different shapes for a module, a deepening candidate, or an open architectural decision before committing to one.

Use the vocabulary in [the skill entry point](../SKILL.md) and the project's domain vocabulary. Read [Deepening](deepening.md) when dependencies affect the candidate interfaces.

## Frame the problem

Explain the constraints every candidate must satisfy, the current caller needs, and the dependencies and their categories. Include a rough code sketch when it makes those constraints concrete; keep the sketch illustrative so it does not prematurely select the interface.

## Explore different interfaces

Scale the exploration to the decision:

- **The user asked for alternatives, or the decision is a one-way door** (hard to undo once merged, such as a schema or an external contract): when delegation is available and permitted, use three parallel subagents with distinct design constraints, and a fourth when a cross-seam dependency strategy deserves its own exploration.
- **Any other decision, or no delegation**: explore two or three alternatives directly, each as a short sketch.

Ground every candidate, from a subagent or your own sketch, in the same technical context: relevant file paths, callers, coupling, dependency categories, domain vocabulary, and the behavior to place behind the seam. Vary the design objective:

- **Minimal interface:** Aim for one to three entry points and high leverage per entry point.
- **Flexibility:** Support the concrete use cases and extension needs identified in the brief.
- **Common caller:** Make the most common caller's task trivial.
- **Dependency strategy, when useful:** Explore a different arrangement of ports, adapters, and internal seams.

The candidates should differ in their interface and distribution of caller knowledge, rather than in names alone. Each candidate should provide:

1. Types and entry points, including invariants, ordering, and errors.
2. A usage example for an actual caller.
3. The behavior and complexity hidden behind the interface.
4. Dependencies, seam locations, and adapters.
5. Tradeoffs in depth, locality, flexibility, and testing.

## Compare and recommend

Present each candidate before comparing them. Explain how much callers must learn, where changes concentrate, and why each seam belongs in its proposed location.

Recommend the strongest design for the stated constraints. Propose a hybrid only when specific elements work well together, and explain how they fit. Keep implementation within the user's requested scope.
