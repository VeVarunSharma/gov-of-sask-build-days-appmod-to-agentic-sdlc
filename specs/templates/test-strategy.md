# Test strategy: {{change title}}

> Optional escalation tool. Create a separate test strategy only when the
> required change specification cannot clearly coordinate multiple validation
> layers, environments, data sets, or high-risk cases. It does not replace the
> specification's acceptance criteria or primary validation command.

- **Specification:** {{relative link}}
- **Source root:** `{{repository-relative directory}}`
- **Primary validation command:** `{{command run from source root}}`

## Test objectives

- {{Behavior or risk this strategy must verify}}

## Coverage map

| Requirement | Level | Scenario | Evidence |
| --- | --- | --- | --- |
| FR-1 / AC-1 | Unit | {{case}} | {{assertion}} |
| NFR-1 | Static | {{case}} | {{threshold}} |

## Test data and environment

- **Fixtures/sample data:** {{non-sensitive data}}
- **Required services:** {{service and safe configuration, or "none"}}
- **Unavailable dependency behavior:** {{skip, fake, or fail rule}}

## Regression checks

- {{Existing behavior that must remain unchanged}}

## Failure evidence

Capture the failing command, exit code, and first actionable error. Never report
a skipped or unavailable check as passing.

## Completion evidence

- [ ] Primary validation command passes.
- [ ] Every acceptance criterion has recorded evidence.
- [ ] Manual checks identify tester, date, and result.
- [ ] No credentials, tokens, or sensitive production data appear in evidence.
