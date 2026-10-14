# Change specification: {{short title}}

> Remove this note and every placeholder before review. Link claims about
> current behavior to repository-relative paths and symbols. This file is the
> single required durable artifact; create optional supporting artifacts only
> when the escalation guidance in the template index applies.

## Metadata

- **Owner:** {{person or team}}
- **Status:** Draft
- **Source root:** `{{repository-relative directory}}`
- **Related issue:** {{URL or "not created"}}

## Problem and outcomes

### Problem

{{Who is affected, what observable problem occurs, and what repository evidence
shows the current behavior?}}

### Desired outcomes

1. {{Measurable user or operator outcome}}
2. {{Measurable engineering or modernization outcome}}

### Success measures

- {{Signal and target that demonstrate the outcome}}

## Functional requirements

| ID | Requirement | Evidence or rationale |
| --- | --- | --- |
| FR-1 | The system shall {{observable behavior}}. | `{{path:symbol}}` |
| FR-2 | When {{condition}}, it shall {{response}}. | {{reason}} |

## Constraints and out of scope

### Constraints

- **Allowed paths:**
  - `{{repository-relative path or glob contained by the source root}}`
- **Primary validation command:** `{{one non-interactive command run from the source root}}`
- **Compatibility:** {{behavior or contract to preserve}}
- **Dependencies:** {{dependency rule}}
- **Data and security:** {{handling requirements}}

### Exclusions (out of scope)

- {{Explicitly excluded behavior, component, migration, or cleanup}}

## Edge cases

| Type | Condition | Expected behavior |
| --- | --- | --- |
| Normal | {{representative successful case}} | {{observable result}} |
| Failure | {{dependency or input failure}} | {{safe response}} |
| Boundary | {{limit or empty case}} | {{observable result}} |
| Compatibility | {{existing contract or environment}} | {{preserved behavior}} |

## Acceptance criteria

### AC-1: {{behavior}}

- **Given** {{initial state}}
- **When** {{action}}
- **Then** {{observable result}}
- **Verification:** {{automated test or reproducible check}}

### AC-2: {{failure or boundary behavior}}

- **Given** {{initial state}}
- **When** {{action}}
- **Then** {{observable result}}
- **Verification:** {{automated test or reproducible check}}

## Non-functional requirements

| ID | Quality | Testable requirement | Verification |
| --- | --- | --- | --- |
| NFR-1 | Reliability | {{threshold or invariant}} | {{check}} |
| NFR-2 | Security/privacy | {{required behavior}} | {{check}} |
| NFR-3 | Maintainability | {{dependency limit}} | {{check}} |

Delete irrelevant rows; do not retain vague goals such as "fast," "secure," or
"user-friendly" without a measurable condition.

## Assumptions, dependencies, and risks

| Item | Type | Validation or mitigation |
| --- | --- | --- |
| {{statement}} | Assumption / dependency / risk | {{validation}} |

## Plan-mode review checkpoint

### Evidence

- **Current behavior:** `{{repository-relative path:symbol}}` — {{observed behavior}}
- **Existing tests:** `{{repository-relative path or "none found"}}`
- **Baseline validation evidence:** `{{command}}` — {{exit status and concise result, or exact unavailable prerequisite}}

### Unresolved questions

- [ ] {{Question, owner, and decision deadline, or replace this item with "None"}}

The specification is not ready for approval while a question can change scope,
acceptance criteria, allowed paths, exclusions, or validation.

### Boundary and validation review

- [ ] Evidence citations were checked against the repository.
- [ ] Allowed paths include all anticipated implementation and test changes and
      nothing unrelated.
- [ ] The primary validation command is safe, non-interactive, and runnable
      from the stated source root.
- [ ] Acceptance criteria cover the required normal, failure, boundary, and
      compatibility behavior.
- [ ] Exclusions prevent unrelated modernization or cleanup.

### Stop conditions

Stop and request human guidance if:

- repository evidence contradicts this specification;
- an unresolved question could materially change behavior or scope;
- satisfying a criterion requires a path outside the allowed paths;
- the baseline or primary validation fails for a reason caused by the proposed
  change, or the command is missing, destructive, or irreproducible;
- a missing prerequisite prevents required evidence from being collected;
- a secret, credential, production resource, destructive action, dependency
  change, schema change, or public API change is required but not explicitly
  approved; or
- implementation or validation cannot satisfy the acceptance criteria without
  expanding the approved contract.

### Human approval

- [ ] I reviewed the evidence, unresolved questions, allowed paths, acceptance
      criteria, validation command, exclusions, risks, and stop conditions.
- **Reviewer:** {{human name}}
- **Approval date:** {{YYYY-MM-DD}}
- **Approved specification commit:** {{commit SHA}}

Change **Status** to `Approved` only after the checkbox is selected and the
reviewer, date, and commit fields are complete. Planning approval authorizes
issue preparation, not implementation.
