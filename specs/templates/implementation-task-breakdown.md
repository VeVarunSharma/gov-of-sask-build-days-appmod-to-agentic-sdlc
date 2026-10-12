# Implementation tasks: {{change title}}

> Optional escalation tool. Create a task breakdown only when dependent work,
> multiple components, or multiple owners need explicit sequencing. It does not
> expand the required specification's allowed paths or authorize
> implementation.

- **Specification:** {{relative link}}
- **Allowed paths:** `{{repository-relative paths or globs}}`
- **Validation command:** `{{command run from the source root}}`

## Tasks

### T1: {{small implementation unit}}

- **Depends on:** None
- **Paths:** `{{path}}`
- **Change:** {{observable responsibility, not speculative code}}
- **Done when:** {{testable result}}
- **Verify:** `{{targeted command or check}}`

### T2: {{small implementation unit}}

- **Depends on:** T1
- **Paths:** `{{path}}`
- **Change:** {{observable responsibility}}
- **Done when:** {{testable result}}
- **Verify:** `{{targeted command or check}}`

### T3: Validate the complete change

- **Depends on:** T1, T2
- **Paths:** No source changes expected
- **Change:** Run the primary validation and review the diff against the
  allowlist and acceptance criteria.
- **Done when:** Evidence is recorded and no unrelated changes remain.
- **Verify:** `{{primary validation command}}`

## Stop conditions

Stop and request human guidance if:

- satisfying a criterion requires a path outside the allowlist;
- the validation command is missing, destructive, or irreproducible;
- repository evidence contradicts the specification;
- a schema, public API, production dependency, or credential must change; or
- an unresolved decision could materially alter behavior.
