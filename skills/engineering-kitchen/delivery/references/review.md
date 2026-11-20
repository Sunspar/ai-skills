# Review

Get an `adversarial-review` PASS that covers the final diff.

1. **Rebase** onto the latest tip of the base (on a frontier, the integration tip). Rerun the affected proof and local CI checks.
2. **Run `adversarial-review` in loop mode.** Pass it the worktree path, the base, and as intent the ticket's link and acceptance criteria and its out-of-scope list. Also pass the gate classes so far, and your proof and check results.
3. **Check the gate.** Compare the final diff against the gate definitions in `SKILL.md`, and add every class it trips, whatever the reviewers concluded.
4. **File follow-ups.** File each medium finding the verdict declined as a follow-up (`execute.md`, Stay in scope). Low findings stay in the verdict.
5. **Keep the verdict current.** A later change that alters the reviewed diff (a babysit fix or a meaningful rebase) needs its proof, checks, and review again, from the lenses whose territory it touched.

Act on the verdict:

- **PASS**: go to publish.
- **CONTESTED**: the user decides. Ask (`SKILL.md`, Asking the user).
- **INCOMPLETE**: supply what it names (missing evidence, an unreadable standard, a failed lens), then review again. An INCOMPLETE you cannot resolve counts as a failed attempt.
- **REJECT**: the attempt failed; see the timebox.

## Timebox

A ticket gets two attempts. An attempt fails when review ends REJECT, when its loop ends stuck (`adversarial-review`'s term: a finding still disputed after two replies, or the round budget spent), when an INCOMPLETE cannot be resolved, or when proof or local CI cannot pass after your fixes. A second attempt must change the approach, using what the failure taught.

After the second failure, stop the ticket. Comment on it with what you tried, the open findings, and whether it needs a split or a spec change, then ask the user. A third attempt with no new information would repeat the second.

## Done when

A PASS verdict covers the final diff, and the gate classes are final.
