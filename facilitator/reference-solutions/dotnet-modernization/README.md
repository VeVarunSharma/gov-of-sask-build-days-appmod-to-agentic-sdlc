# .NET modernization facilitator reference

These files define the expected decisions and evidence for the BookCatalog
track. They are not captured Modernize CLI or upgrade-agent output. Never hand
them to participants as proof that their commands ran.

## Contents

- [Acceptance profile](acceptance-profile.md): source evidence, expected
  modernization shape, local/cloud checks, and common review findings.
- [Reference modernization specification](modernization-specification.md):
  an example of a completed, testable spec.
- [Optional reference architecture decision](adr-0001-target-architecture.md):
  an example of using the ADR escalation template for the single-host .NET
  10/EF Core decision and rejected alternatives.
- [Azure review checklist](azure-review-checklist.md): facilitator gates for
  what-if, managed identity, Key Vault, smoke tests, no-deployment, and cleanup.

The learner's generated reports, paths, package versions, and agent summaries
remain authoritative for that run. Compare them to the acceptance criteria;
do not replace missing evidence with this reference.
