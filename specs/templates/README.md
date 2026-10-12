# Specification templates

## Required durable artifact

1. [Change specification](change-specification.md) — the only artifact required
   by Lab 01. It records evidence, outcomes, constraints, edge cases,
   acceptance criteria, the execution boundary, validation, stop conditions,
   and human approval.

## Optional escalation tools

Use these only when the required change specification cannot carry enough
detail for safe review:

- [Architecture decision record](architecture-decision-record.md) — compare
  consequential technical options and document an approved trade-off.
- [Test strategy](test-strategy.md) — coordinate multiple validation layers,
  environments, or high-risk cases.
- [Implementation task breakdown](implementation-task-breakdown.md) — sequence
  dependent work across components or owners.

Link any optional artifact from the required change specification. Its presence
does not replace or approve that specification.

## Post-approval handoff

- [Autonomous issue body](autonomous-issue-body.md) — convert an approved
  specification into the bounded execution contract consumed by issue-to-PR
  automation.

Double-brace values such as `{{short title}}` are authoring placeholders.
Replace every placeholder and remove instructional notes before committing a
participant specification or creating an issue. The examples contain no
placeholders and are not approvals to modify their referenced applications.
