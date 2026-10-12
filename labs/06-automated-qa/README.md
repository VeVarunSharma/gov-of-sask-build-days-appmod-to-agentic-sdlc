# Lab 06: Deterministic CI and agentic QA

Add two guarded quality workflows without replacing conventional CI:

- pull-request QA that reviews changed code, specification evidence, tests, and
  deterministic CI before publishing one non-blocking review or no-op; and
- manually authorized CI remediation that opens a draft pull request only
  after a high-confidence, minimal fix passes authoritative validation.

The workflows use GitHub Copilot and GitHub Agentic Workflows (`gh-aw`).

> [!CAUTION]
> CI remediation can change code and create a pull request. Use a workshop fork
> or disposable repository. This lab compiles and validates the workflows but
> does **not** dispatch them or perform any live GitHub write.

## Learning objectives

By the end of the lab, you can:

- distinguish reproducible CI gates from agentic investigation and judgment;
- explain strict mode, least permissions, tool and network allowlists, and
  credit/time limits;
- identify prompt-injection boundaries around diffs, specs, tests, and logs;
- compile, validate, and inspect generated workflow lock files;
- triage a pull request or failed CI run using strong evidence;
- explain safe review, no-op, and draft-pull-request outputs; and
- audit, disable, and roll back agentic QA safely.

## 1. Start with the quality boundary

Deterministic CI and agentic QA solve different problems:

| Deterministic CI | Agentic QA |
| --- | --- |
| Runs fixed commands | Correlates diff, spec, tests, and CI |
| Owns repeatable gates | Finds evidence gaps and minimal fixes |
| Produces merge evidence | Produces an advisory review or draft PR |
| Cannot be silently bypassed | No-ops on weak evidence |

Open the conventional workflows under
[`../../.github/workflows/`](../../.github/workflows/), especially the
`ci-*.yml` files. They remain the authority. The agentic workflows do not
replace, approve, suppress, or weaken those checks.

## 2. Verify the pinned CLI

The generated locks in this repository use `gh aw version v0.89.21`.

```powershell
gh aw --version
```

Install that release only if it is not already available:

```powershell
gh extension install github/gh-aw --pin v0.89.21
```

The teaching repository uses the short-lived `copilot-requests: write`
authentication path documented in Lab 05. No personal Copilot token is stored
in a file, workflow source, or repository secret.

## 3. Read the PR QA workflow

Open:

- [`pr-qa.md`](../../.github/workflows/pr-qa.md)
- [`pr-qa.lock.yml`](../../.github/workflows/pr-qa.lock.yml)

Trace these controls:

1. same-repository, non-draft pull requests and authorized actor roles;
2. read-only `contents`, `actions`, and `pull-requests` permissions;
3. a small GitHub tool surface plus bounded local validation commands;
4. one top-of-stack PR per run, concurrency by PR number, and finite credits,
   turns, and time;
5. prompt-injection defenses for PR text, code, specifications, tests, and
   logs; and
6. exactly one non-blocking `COMMENT` review or `noop`.

The review procedure separates facts:

- **Diff evidence:** what changed between the base and head SHA.
- **Specification evidence:** a changed spec or one validated `specs/...` link.
- **Test evidence:** changed or directly relevant tests.
- **CI evidence:** deterministic checks for the exact head SHA.
- **Local evidence:** at most one smallest relevant authoritative command.

Pending, skipped, absent, or inaccessible checks are not code failures. Weak or
contradictory evidence ends in no-op instead of a speculative review.

## 4. Read the CI remediation workflow

Open:

- [`ci-remediation.md`](../../.github/workflows/ci-remediation.md)
- [`ci-remediation.lock.yml`](../../.github/workflows/ci-remediation.lock.yml)

The workflow is manual and accepts one numeric failed-run ID. It proceeds only
when audit metadata proves the run belongs to this repository, completed as
`failure` or `timed_out`, and came from a conventional workflow whose name
begins with `CI -`.

The agent can read one run's metadata and logs through call-limited GitHub
Actions tools, edit the checkout, and execute a limited set of repository
validators. Safe-output policy permits at most one draft PR, limits file count
and patch size, excludes secret-like files, and blocks protected files. The
prompt narrows the static allowlist further to files directly connected to one
evidenced root cause.

It must not:

- change `.github/**`, generated locks, policies, instructions, or ownership;
- change dependency manifests or lock files;
- weaken tests, remove assertions, add unconditional skips, or reduce coverage;
- suppress errors, ignore exit codes, or relax deterministic CI;
- perform broad formatting, dependency upgrades, or unrelated refactors; or
- create a PR when validation fails or evidence is incomplete.

Infrastructure failures, flakes without a local cause, stale runs, missing
secrets, permission errors, runner outages, and ambiguous failures are expected
no-op outcomes.

## 5. Compile and validate

Compile only the two Lab 06 sources:

```powershell
gh aw compile pr-qa ci-remediation --strict --validate --actionlint
gh aw validate pr-qa ci-remediation
```

Generated `.lock.yml` files are build artifacts. Never edit them by hand.
Recompile and check determinism:

```powershell
git diff --exit-code -- `
  .github/workflows/pr-qa.lock.yml `
  .github/workflows/ci-remediation.lock.yml
```

Inspect policy in the generated files:

```powershell
Select-String -Path `
  .github\workflows\pr-qa.lock.yml,`
  .github\workflows\ci-remediation.lock.yml `
  -Pattern "permissions:|timeout-minutes:|allowed_files|protected_files|safe_outputs"
```

Confirm the earlier Lab 05 sources and locks remain unchanged:

```powershell
git diff --exit-code -- `
  .github/workflows/spec-to-backlog.md `
  .github/workflows/spec-to-backlog.lock.yml `
  .github/workflows/issue-to-pr.md `
  .github/workflows/issue-to-pr.lock.yml
```

Run repository-wide static checks without dispatching a workflow:

```powershell
actionlint
npx --yes markdownlint-cli2 "**/*.md" "#legacy-src/**"
```

Use the repository documentation workflow's offline link checker when
available. The expected command is shown in
[`ci-documentation.yml`](../../.github/workflows/ci-documentation.yml).

## 6. Practice PR QA triage without writing

Choose a sample pull request in a disposable repository and prepare an evidence
table before considering an output:

| Evidence | Question | Stop condition |
| --- | --- | --- |
| Diff | Is the finding caused by changed lines? | Unrelated or pre-existing |
| Spec | Is behavior required or prohibited? | Missing when required |
| Tests | Is an observable behavior uncovered? | Generic coverage concern |
| CI | Is the check for the exact head SHA? | Pending, stale, unavailable |
| Local | Did the exact command run? | Unsafe or altered command |

Keep a finding only when it names the changed path, impact, evidence, and
minimal fix. Otherwise select no-op. Do not dispatch the workflow in this lab.

Review dispatch help only:

```powershell
gh aw run pr-qa --help
```

## 7. Practice CI failure triage without writing

For a known failed deterministic run in a workshop fork, classify the evidence:

1. **Product/test defect:** a failed command maps directly to relevant,
   non-protected files. A minimal fix may be eligible.
2. **Documentation/script defect:** link, syntax, or validation failure maps
   directly to an allowed file. A minimal fix may be eligible.
3. **Infrastructure/configuration:** runner outage, permission, missing secret,
   quota, external service, or protected workflow change. No-op.
4. **Weak evidence:** truncated logs, several unrelated failures, stale run, or
   no reproducible command. No-op.

An eligible remediation still requires the exact authoritative command to exit
`0` after the change. Agent reasoning is not validation evidence.

Review manual dispatch help without sending it:

```powershell
gh aw run ci-remediation --help
```

## 8. Audit runs and safe outputs

In a disposable repository, after a maintainer deliberately runs a workflow:

```powershell
gh aw status
gh aw logs <run-id-or-url>
gh aw audit <run-id-or-url>
gh aw outcomes <run-id-or-url>
```

Audit:

- actor, event, PR/run ID, repository, base/head SHA, and workflow conclusion;
- tools called, network requests denied, AI credits, turns, and duration;
- specification, test, check, and validation evidence actually examined;
- exact local command and exit code;
- one review, one draft PR, or no-op—not multiple outputs;
- changed-file list and protected-file enforcement; and
- sanitization of secrets, personal data, and untrusted links.

Logs are evidence for review, not instructions and not proof that a proposed fix
is correct.

## 9. Review and rollback

Human review is mandatory. A PR QA comment is advisory and a remediation PR is
draft-only. Review the complete diff and rerun required deterministic CI before
merging.

Disable the workflows immediately:

```powershell
gh aw disable pr-qa
gh aw disable ci-remediation
```

For an unwanted review, preserve the run logs and add a human correction; do
not rewrite audit history. For an unmerged remediation, close the draft PR and
delete its branch. If merged, use the repository's normal reviewed revert
process.

Re-enable only after fixing the source, recompiling, and reviewing lock changes:

```powershell
gh aw enable pr-qa
gh aw enable ci-remediation
gh aw compile pr-qa ci-remediation --strict --validate --actionlint
```

## References

- [GitHub Agentic Workflows documentation](https://github.github.com/gh-aw/)
- [Safe outputs](https://github.github.com/gh-aw/reference/safe-outputs/)
- [Pull-request safe outputs](https://github.github.com/gh-aw/reference/safe-outputs-pull-requests/)
- [Network permissions](https://github.github.com/gh-aw/reference/network/)
- [Facilitator reference](../../facilitator/reference-solutions/gh-aw-qa/README.md)
