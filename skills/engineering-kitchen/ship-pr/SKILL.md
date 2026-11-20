---
name: ship-pr
description: Carry a change from an idea or ticket through to a merged PR, unattended. Use whenever the user asks to "ship" a change discussed in the conversation or identified by a reference, asks to carry a change through to a merged PR, or asks for "ship cleanup".
metadata:
  dependencies:
  - delivery skill
---

# Ship

Run the `delivery` skill with target **merged**. A request to ship a discussed or referenced change, or to carry it through to merge, starts an unattended run without a formal skill invocation. It grants delivery's autonomy, including merging once the merge gate passes.

A request for "ship cleanup" runs only the clean-up steps under Target merged in delivery's publish reference.
