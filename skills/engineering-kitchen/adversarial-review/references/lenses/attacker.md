# Attacker

Review the change the way an attacker would: look for a path from input you control to something you should not reach. Input includes users, external services, files, queues, databases, and configuration. Finding IDs: `AT1`, `AT2`, and so on.

Check:

- **Authentication and authorization:** missing or late checks, confused-deputy behavior, privilege escalation, tenant isolation, and insecure defaults.
- **Unsafe interpretation:** SQL, command, or template injection; XSS; path traversal; SSRF; unsafe deserialization; and client-controlled queries. Check parameterization, encoding, and validation at the actual boundary.
- **Sensitive data:** secrets or personal data exposed through responses, logs, errors, caches, analytics, or overly broad reads. Describe where a secret is without reproducing its value.
- **Integrity and availability:** replay, races, destructive operations, unbounded work, and attacker-controlled resource consumption.
- **Cryptography and secrets:** incorrect verification, weak randomness, embedded credentials, and unnecessary secret propagation.
- **Dependencies and configuration:** reachable vulnerable behavior, compromised provenance, exposed services, relaxed controls, and excessive permissions. Check advisories with the ecosystem's audit tools and authoritative package sources. An advisory becomes a vulnerability only when its path is reachable.

A finding needs a broken invariant and a plausible path through the changed behavior, from source to sink or from attacker to impact. Give the preconditions, the impact, your confidence, and the smallest remediation. Local conventions do not excuse an evidenced vulnerability. When the path is unproven, report an **unresolved risk** instead of a finding: state the unknown and the check that would resolve it, without claiming a vulnerability.

Rate impact separately from confidence:

- **critical:** practical exploitation causes catastrophic compromise.
- **high:** plausible exploitation crosses a major trust boundary, or compromises sensitive data, authorization, or system integrity.
- **medium:** meaningful impact with narrower reach or substantial preconditions.
- **low:** limited impact, or a defense-in-depth weakness.

Severity: a concrete vulnerability with critical, high, or medium impact is high. One with low impact is medium. Mark an unresolved risk as blocking when it could stop the change from shipping.

If you find no plausible attack path, say so, and list the surface you reviewed and the limits of your review.

Map findings to `~/agent-brain/principles/boundary-discipline.md` when validation sits at the wrong boundary, and otherwise to `none`.
