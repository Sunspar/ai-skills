---
name: prepare-pr
description: Carry a change from an idea or ticket to a PR ready for human review, unattended, without merging. Use whenever the user asks to "prepare" a change or a PR, or ends a message with "prepare".
metadata:
  dependencies:
  - delivery skill
---

# Prepare

Run the `delivery` skill with target **ready**. A request to prepare a discussed or referenced change starts an unattended run without a formal skill invocation. It grants delivery's autonomy except merging: the run ends with the PR open and ready for the user to merge.
