# Specifications

This directory holds the durable change contract produced by the Plan-mode
exercise and the reusable material for creating it.

- [`templates/change-specification.md`](templates/change-specification.md) is
  the single required durable artifact template for Lab 01.
- [`templates/`](templates/) also contains optional escalation tools and the
  issue handoff template used after approval.
- [`examples/`](examples/) contains completed Java and .NET examples.
- [Lab 01](../labs/01-spec-driven-development/) explains the GitHub Copilot app
  workflow and the required human approval gate.

Create participant specifications as `specs/<short-change-name>.md`. Keep
requirements observable, allowed paths repository-relative and inside the
stated source root, validation commands runnable from that source root, and
credentials or participant-specific values out of committed documents.

An architecture decision record, test strategy, or implementation task
breakdown is optional. Create one only when the change needs that additional
review or coordination; do not create it merely to complete Lab 01.
