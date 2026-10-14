# Facilitator reference: capstone

Use this guide to review capstone scope, evidence, and demos. It is an
acceptance reference, not a prescribed domain or a finished application.
Participants retain ownership of the problem and user group.

## Expected participant assets

- an approved specification under `specs/capstone/`;
- a selected source root and explicit allowlist;
- capstone-specific repository instructions;
- a bounded review agent or validation skill;
- changed application or workflow files;
- tests plus exact build/validation evidence;
- architecture/data-flow, privacy, security, accessibility, and limitation
  notes; and
- a short demo script with cleanup/audit evidence when applicable.

Starter assets remain under
[`labs/07-capstone/starter/`](../../../labs/07-capstone/starter/). A participant
must narrow and complete them; copying unchanged templates is not completion.

## Safe example charters

These examples demonstrate scope, not required domains:

<!-- markdownlint-disable MD013 -->

| Charter | User and slice | Explicit exclusions |
| --- | --- | --- |
| Facility maintenance board | A facilities coordinator records a synthetic repair item, changes status, and sees validation feedback. | No resident reports, addresses, worker performance scoring, dispatch, or emergency response. |
| Park amenity inventory | A content editor updates a fictional amenity record and previews an accessible public summary. | No reservations, payments, permits, visitor identities, or official publication. |
| Road-work communication planner | A communications user drafts a fictional non-emergency notice and tracks review status. | No live road control, emergency alerts, location tracking, or autonomous publishing. |
| Application upgrade dashboard | An engineering lead records synthetic modernization actions and reviews validation evidence. | No production telemetry, credentials, automatic deployment, or employee evaluation. |
| Build-failure triage workflow | A maintainer manually runs a guarded workflow that summarizes synthetic/test CI evidence into one issue. | No secret access, production remediation, CI modification, or unbounded issue creation. |

<!-- markdownlint-enable MD013 -->

Reject examples that use real personal data, imitate an official production
service without disclosure, or determine benefits, justice, health, tax,
licensing, employment, or enforcement outcomes.

## Pathway review

### A. Modernization deep dive

- The team stays in its selected Java or .NET root.
- The slice closes one accepted modernization need rather than reopening the
  whole migration.
- Existing behavior is baselined and preserved unless the specification
  intentionally changes it.
- Java `clean verify` or the .NET Release build/test plus required behavior
  checks pass.
- Cloud configuration remains local-first, secretless, and optional.

### B. React plus API

- The team uses React plus exactly one API unless parity is an explicit,
  achievable acceptance criterion.
- Domain language is consistent across contract, client, API, and tests.
- Loading, empty, error, and rejected-input behavior are demonstrable.
- Server validation remains authoritative.
- React lint/test/build and the selected API's Release gate pass.
- In-memory reset behavior is either accepted or replaced by tested,
  approved, non-production persistence.

### C. Advanced `gh-aw`

- The workflow addresses a specific engineering pain point.
- Activation, authorized actors, untrusted inputs, paths, tools, network,
  quotas, validation, safe outputs, no-op, audit, disablement, and rollback are
  documented.
- The generated lock file is compiler-owned.
- `gh aw compile --strict --validate --actionlint` and `gh aw validate` pass.
- Conventional `ci-*.yml` files are unchanged.
- A write-capable live run occurs only in an approved disposable fork.

## Safety and evidence review

Ask the team to point to evidence for:

1. synthetic-data design and prohibited data;
2. trust boundaries and server/workflow input validation;
3. least-privilege tools, identities, paths, and network access;
4. secret handling and log redaction;
5. accessibility checks;
6. human accountability and prohibited high-stakes decisions;
7. failure, empty, rejected, restart, rollback, or no-op behavior; and
8. actual command results rather than model claims.

Stop a demo if it exposes a token, connection string, real person, production
endpoint, sensitive log, or unapproved cloud resource. Preserve the evidence
needed to understand the event without copying the sensitive value.

## Judging guidance

Use the participant
[24-point rubric](../../../labs/07-capstone/README.md#judging-rubric).

- A score of **4** requires directly observable evidence.
- A polished interface cannot compensate for missing safety or validation.
- A safe no-deployment or workflow no-op outcome can earn full credit.
- More features do not earn more credit when scope, tests, or explanation
  become weaker.
- Resolve ties in favor of the safer, smaller, more reproducible solution.

## Facilitator validation

Run the gates for every selected pathway exactly as documented:

- [Modernization validation](../../../labs/07-capstone/pathways/01-modernization-deep-dive.md#required-validation)
- [React plus API validation](../../../labs/07-capstone/pathways/02-public-service-app.md#required-validation)
- [`gh-aw` validation](../../../labs/07-capstone/pathways/03-agentic-workflow.md#required-validation)

Then check:

```powershell
git diff --check
git status --short
```

Review generated output, local environment files, dependencies, deployment
evidence, and logs before anything is committed. Do not ask teams to dispatch
a write-capable workflow or deploy Azure merely to improve a score.

## Demo timing

Suggested five-minute format:

1. 45 seconds: problem, users, boundaries, and level;
2. 2 minutes: successful end-to-end slice;
3. 45 seconds: failure, empty, rejected, restart, or no-op behavior;
4. 45 seconds: tests, agentic boundaries, privacy, and security; and
5. 45 seconds: limitations, cleanup/audit evidence, and next step.
