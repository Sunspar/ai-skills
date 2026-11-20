# Execute

Turn one ready ticket into commits on the task branch, with proof for every acceptance criterion.

## Build

1. Load the `software-design` skill, with its references for the languages and frameworks you touch.
2. Plan in the session, not in a file. Break the ticket into commit-sized changes: one function or type with its tests, or one bug fix. Each change compiles and passes on its own and becomes one commit.
3. Build test-first with the `tdd` skill at the seams the spec chose. For a bug fix, watch the regression test fail before the fix and keep that output as proof. When the cause of a failure is unknown, use `diagnosing-bugs` first.
4. Make the smallest change that meets every acceptance criterion. Fix the case that happened, not every case that could. Run type checks and focused tests as you go.

## Stay in scope

- **Outside the ticket**: file each piece of out-of-scope work as a follow-up in the tracker, or in the place the project instructions name for follow-ups, and leave that code as it is.
- **The spec of record is wrong or incomplete**: take the smallest reading that keeps the intent, record it as an assumption, and comment on the ticket with what you found.

## Proof

Proof is evidence you observed yourself in this session: a command output, a reproduction, a screenshot. Use the most direct proof the change allows:

- Reproduce the original failure, apply the fix, then watch the same reproduction pass.
- Complete the local CI checks below.
- Add one focused test that fails without the change, when the behavior has none and the repo has a test setup.
- For UI and runtime behavior, run the app and look at the change. Green mocked tests do not prove that the user experience works. Attach screenshots to the PR when they help and you have a way to upload them.

Map each acceptance criterion to its proof. A human check gets no proof from you: list what a person must observe, and how. Any other criterion without proof means you lack full confidence: ask the user.

## Local CI checks

Read the repository's CI workflows, the scripts they invoke, and the project instructions to find the validation tasks that apply to the change. Run their actual commands locally: formatting, linting, type checking, tests, builds, generation checks, and security checks, where defined and applicable. Use the prescribed toolchain, flags, services, and environment setup when available. This gate covers validation tasks only.

Fix failures the change caused, and rerun the affected checks until they pass. Checks must cover the final diff, so repeat the affected ones after review fixes, rebases, or later changes, before pushing. Record each command and its observed result for the PR and the report.

- **Pre-existing failures**: record evidence that they also fail on the base, and keep unrelated repairs out of this change.
- **Checks needing unavailable secrets, runners, services, or remote infrastructure**: run a supported local equivalent when one exists, and state the difference in coverage.
- Report every check that stays unrun or failing, and why. Keep local results separate from pending remote CI.

## Done when

Every acceptance criterion maps to proof you observed or is listed as a human check, every applicable local check passes on the final commit, and every change is committed on the task branch.
