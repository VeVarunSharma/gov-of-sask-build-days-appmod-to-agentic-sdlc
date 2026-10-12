# Autonomous change request

> Create this issue only from a committed, human-approved change specification.
> Replace every placeholder and remove this note before issue creation.

## Problem

{{Concise observable problem and who it affects.}}

## Outcome

{{The measurable state that should be true after this issue is complete.}}

## Execution boundary

- **Source specification:** `{{specs/short-change-name.md}}`
- **Source root:** `{{one repository-relative directory}}`
- **Allowed paths:**
  - `{{repository-relative path or glob contained by the source root}}`
- **Protected paths:** {{explicit exclusions, including every path outside the allowed list}}
- **Authoritative validation command:** `{{one non-interactive command run from the source root}}`
- **Environment prerequisites:** {{tools/services, or "none"}}

An autonomous implementation must not edit outside the allowed paths. If that
boundary is insufficient, stop and request human guidance instead of expanding
scope.

## Requirements

- **FR-1:** {{observable behavior}}
- **FR-2:** {{observable behavior}}
- **NFR-1:** {{measurable quality or compatibility condition}}

## Acceptance criteria

### AC-1: {{behavior}}

- **Given** {{state}}
- **When** {{action}}
- **Then** {{observable result}}

### AC-2: {{boundary or failure behavior}}

- **Given** {{state}}
- **When** {{action}}
- **Then** {{observable result}}

## Out of scope

- {{Excluded work}}

## Validation and evidence

- **Targeted checks:** {{tests mapped to acceptance criteria}}
- **Regression checks:** {{behavior that must remain unchanged}}
- **Evidence required in PR:** command, exit status, and concise result; explain
  any check that could not run.

## Supporting context

- **Relevant paths and symbols:** `{{path:symbol}}`
- **Optional ADR:** {{relative link or "not required"}}
- **Optional test strategy:** {{relative link or "not required"}}
- **Optional task breakdown:** {{relative link or "not required"}}

Do not treat this context as permission to ignore contradictory repository
evidence. Stop and report the contradiction.

## Stop conditions

Stop and report rather than guess, broaden scope, or continue if:

- repository evidence contradicts the approved specification;
- an acceptance criterion requires a path outside the allowed paths;
- a prerequisite or the authoritative validation command is unavailable,
  unsafe, destructive, or irreproducible;
- validation fails and the failure cannot be resolved inside the approved
  boundary;
- a secret, production resource, dependency, schema, or public API change is
  required but not explicitly approved; or
- any unresolved question could materially change behavior or scope.

## Human review gate

- [ ] The source specification and approved commit were reviewed.
- [ ] Problem and outcome reviewed
- [ ] Allowed paths and protected paths reviewed
- [ ] Acceptance criteria and validation command reviewed
- [ ] Exclusions, stop conditions, risks, data handling, and dependency changes
      reviewed
- **Reviewer:** {{human name}}
- **Approval date:** {{YYYY-MM-DD}}
- **Approved specification commit:** {{commit SHA}}

Automation may begin only after every checkbox is selected and reviewer fields
are complete.

## Agent completion checklist

- [ ] Diff is limited to allowed paths.
- [ ] Each acceptance criterion is satisfied with evidence.
- [ ] Authoritative validation passes, or the PR clearly reports a reproducible
      environment blocker.
- [ ] No unrelated cleanup, dependency upgrade, or generated artifact is
      included.
- [ ] PR links this issue and summarizes risks and follow-up work.
