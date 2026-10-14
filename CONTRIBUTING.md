# Contributing

Keep changes scoped, evidence-led, and compatible with the repository's
one-checkout participant flow. Read the nearest `README.md`, `AGENTS.md`, and
path-specific Copilot instructions before editing. Do not commit credentials,
participant environment data, generated dependency folders, or build output.

## Imported source refreshes

`legacy-src/` contains pinned upstream snapshots. A refresh must be a dedicated,
reviewable change:

1. confirm the exact upstream revision and that its license permits reuse;
2. preserve the upstream license and attribution;
3. update `UPSTREAM_SOURCES.yml` and `THIRD_PARTY_NOTICES.md` together;
4. avoid unrelated formatting or behavior changes in imported code; and
5. run the affected baseline validation and document any upstream defect.

Do not import from an entry under `excluded_sources` unless a compatible,
explicit license is established and reviewed.

## Agentic workflow maintenance

GitHub Agentic Workflows is in public preview. This repository's locks use
`gh aw version v0.89.21`. Edit the Markdown workflow source, never its
`.lock.yml` output. Compile with the pinned CLI, inspect every generated diff,
and confirm conventional `ci-*.yml` files did not change:

```powershell
gh aw compile --strict --validate --no-check-update
gh aw validate --strict --no-check-update
git diff -- .github/workflows
actionlint -color
```

A `gh-aw` version change requires a separate reviewed update, recompilation of
all workflow sources, deterministic second-compile comparison, and lock/action
diff review.

## Documentation and validation

Keep participant instructions in `labs/` and facilitator-only operations in
`facilitator/`. Prefer repository-relative links and one authoritative
instruction rather than copying procedures into several indexes. Before
submitting:

```powershell
git diff --check
actionlint -color
```

Run the smallest affected build/test command documented under
[`scripts/validation/`](scripts/validation/). CI performs the authoritative
offline Markdown link/fragment scan. Update the
[validation report](facilitator/guide/VALIDATION.md) only with commands and
outcomes actually observed; never claim live Azure deployment or a live
write-capable workflow run from static validation.
