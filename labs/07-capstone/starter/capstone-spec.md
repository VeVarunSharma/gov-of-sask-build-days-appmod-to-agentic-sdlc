# Capstone specification template

> Starter template: copy this file to `specs/capstone/<team-name>.md` and
> replace every `{marked placeholder}` before approval.

## Approval

- Status: `{Draft | Approved}`
- Approved by: `{human reviewer}`
- Approval date: `{YYYY-MM-DD}`
- Selected pathway and level: `{A, B, C, or combination; level}`

## Problem and users

- Problem: `{observable problem}`
- Direct user: `{role, not a real person's name}`
- Affected users: `{roles or groups}`
- Current evidence: `{observation, sample, or workshop assumption}`
- Intended outcome: `{measurable improvement}`

## Demo slice

`{Describe one three-minute end-to-end journey.}`

## Requirements

1. `{functional requirement}`
2. `{quality, accessibility, or operational requirement}`
3. `{evidence requirement}`

## Constraints

- Time and scope: `{boundary}`
- Selected source root: `{one root}`
- Allowed paths: `{explicit allowlist}`
- Technology: `{selected runtime/client/workflow}`
- Synthetic data rule: `{how fictional data is recognizable}`
- External systems: `{none, mocked, or explicitly approved}`

## Exclusions

- Real personal, resident, employee, client, case, health, justice, tax,
  licensing, benefits, or production data.
- High-stakes eligibility, entitlement, enforcement, health, employment, or
  licensing decisions.
- `{other non-goals}`

## Privacy

- Data fields needed: `{minimal fields}`
- Prohibited data: `{sensitive or identifying fields}`
- Retention: `{in-memory, disposable local, or approved test retention}`
- Logging/telemetry: `{what is recorded and redacted}`

## Security

- Trust boundaries: `{browser, API, repository input, workflow, cloud}`
- Authorization assumption: `{workshop-only assumption}`
- Input validation: `{client and server/workflow controls}`
- Secret handling: `{environment or secret store; never source}`
- Abuse and prompt-injection cases: `{cases and mitigations}`

## Acceptance criteria

1. Given `{state}`, when `{action}`, then `{observable result}`.
2. Given `{invalid or missing state}`, when `{action}`, then `{safe result}`.
3. `{automated test or validation criterion}`.
4. `{privacy/security/accessibility criterion}`.

## Validation

Run from `{working directory}` in this order:

```text
{exact deterministic command or short ordered command list}
```

Manual checks:

1. `{observable check}`
2. `{failure, empty, no-op, or restart check}`

## Stop conditions

Stop and request human review when:

- a change is required outside the allowed paths;
- validation would require disabling a safeguard;
- real or production data, credentials, or endpoints are discovered;
- Azure scope, cost, identity, or cleanup is not approved; or
- workflow output or permissions exceed this specification.

## Demo and evidence

- Demo script: `{repository path}`
- Test/build evidence: `{command output summary or run URL}`
- Architecture/data-flow sketch: `{repository path}`
- Azure cleanup evidence: `{not used | repository-safe evidence}`
- `gh-aw` audit evidence: `{not used | run URL}`
- Known limitations: `{honest limitations}`
