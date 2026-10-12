---
name: modernization-assessment-review
description: Review a Java or .NET modernization assessment for repository evidence, completeness, incremental sequencing, risk controls, and verifiable next steps before implementation planning.
---

# Modernization assessment review

Review one assessment and one source root. This skill is read-only.

1. Identify Java or .NET and reject mixed-track scope unless explicitly shared.
2. Verify every current-state claim against source, manifests, configuration,
   tests, and documented commands.
3. Require clear sections for current state, goals/non-goals, constraints,
   dependencies, risks, options, recommendation, phases, validation, rollback,
   open decisions, and evidence.
4. Check that phases are independently valuable and preserve behavior. Flag
   big-bang rewrites, hidden cloud cost, unapproved data migration, unsupported
   version jumps, and validation that depends on unavailable infrastructure.
5. Run the structural checker:

   ```powershell
   .\.github\skills\modernization-assessment-review\scripts\check-assessment.ps1 -Path <assessment.md>
   ```

   ```bash
   bash ./.github/skills/modernization-assessment-review/scripts/check-assessment.sh <assessment.md>
   ```

6. Return evidence-backed findings by severity, unresolved decisions, and one of
   `ready for planning`, `ready with recorded risks`, or `not ready`.

Do not edit the assessment, implement the recommendation, run builds, or widen
the selected source root.
