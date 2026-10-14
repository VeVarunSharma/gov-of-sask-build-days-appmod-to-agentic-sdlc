# Pathway C: Automate an engineering pain point with `gh-aw`

Build one advanced GitHub Agentic Workflow that addresses a recurring
engineering pain point. The workflow must be useful when it safely does
nothing, and every write must pass through a constrained safe output.

## Suitable problems

- summarize a failed build and create one bounded triage issue;
- check specification-to-test traceability and report gaps;
- prepare a dependency-update advisory without applying upgrades;
- review documentation or API-contract drift;
- collect flaky-test evidence and update one tracking issue; or
- prepare a draft pull request inside one approved capstone source root.

Do not automate resident or employee decisions, production incident actions,
secret rotation, deployment approval, security finding suppression, or
unbounded code remediation.

## Design contract

Document:

1. the trigger and who is authorized to activate it;
2. untrusted inputs and prompt-injection handling;
3. read, search, edit, shell, GitHub, and network tools actually needed;
4. static and dynamic path boundaries;
5. time, turn, AI-credit, file, and output quotas;
6. one or more deterministic validation commands;
7. safe outputs and their sanitization;
8. no-op conditions;
9. audit evidence; and
10. disable, rollback, and recovery steps.

Prefer manual dispatch, schedule, or a narrowly authorized label/comment
trigger. The agent job should be read-only to GitHub where possible; a
permission-isolated safe-output job performs any approved mutation.

## Challenge choices

### Beginner

- Adapt one Lab 05 workflow to a different engineering artifact.
- Keep activation manual and output read-only or `noop`.
- Compile, validate, and explain every permission.

### Intermediate

- Add one quota-limited issue, comment, or draft-PR safe output.
- Validate dynamic input against an approved specification or issue contract.
- Demonstrate both a valid result and an intentional no-op case.

### Advanced

- Combine multiple read-only evidence sources with strict network allowlists.
- Add a draft-PR path limited to one approved subtree and validation command.
- Demonstrate prompt-injection resistance, safe-output sanitization, audit
  review, disablement, and rollback in a disposable fork.

## Implement

Create `.github/workflows/<workflow-name>.md`. Follow the
[Lab 05 operating model](../../05-agentic-workflows/README.md) and current
[`gh-aw` documentation](https://github.github.com/gh-aw/). Do not hand-edit
`.github/workflows/<workflow-name>.lock.yml`.

If the workflow can edit code, limit it to exactly one of:

- `legacy-src/java-asset-manager/**`;
- `legacy-src/dotnet-bookcatalog/shared-legacy-app/**`;
- `capstone-src/web-react/**`;
- `capstone-src/api-java/**`; or
- `capstone-src/api-dotnet/**`.

Protect `.github/workflows/`, repository settings, credentials, generated
dependency folders, and unrelated tracks from agent edits. Workflow source
changes are made by participants through normal review, never by the running
workflow itself.

## Required validation

Set the exact Markdown filename without the extension:

```powershell
$workflowName = 'replace-with-workflow-name'
gh aw --version
gh aw compile $workflowName --strict --validate --actionlint
gh aw validate $workflowName
git diff -- ".github/workflows/$workflowName.lock.yml"
git diff --name-only -- .github/workflows/ci-*.yml
gh aw run $workflowName --help
```

The gate passes when compilation and validation succeed, generated changes are
reviewed, conventional CI workflows are unchanged, activation syntax is
understood, and the workflow has explicit no-op and recovery behavior.

Do not dispatch a write-capable run for required validation. An optional live
run requires a disposable workshop fork, explicit maintainer approval, a
reviewed trigger, and no production resources or data.

## Optional live-run evidence

For an approved disposable run, preserve:

```powershell
$run = 'replace-with-run-id-or-url'
gh aw status
gh aw logs $run
gh aw audit $run
gh aw outcomes $run
```

Show the activation actor, input boundary, tool and network calls, quota use,
validation result, safe output, and at least one no-op or rejected-input case.
Disable the workflow immediately if its scope or output differs from the
reviewed contract.
