# Lab 05: Agentic SDLC workflows

Build a guarded path from an approved specification to reviewable backlog
issues, then from one explicitly activated issue to a validated draft pull
request. The workflows use the GitHub Copilot engine and GitHub Agentic
Workflows (`gh-aw`).

> [!CAUTION]
> The second workflow can change code and create a pull request. Use a workshop
> fork or disposable repository. Do not apply `agent-ready` until a human has
> reviewed the issue boundary. This lab does not require a live write run.

## Learning objectives

By the end of the lab, you can:

- install and verify `gh-aw`;
- explain Markdown workflow frontmatter and generated lock files;
- compile and inspect guarded workflows;
- distinguish agent tools from permission-isolated safe outputs;
- trigger, observe, and audit a run without granting broad write permissions;
- understand no-op behavior, path protection, and rollback.

## 1. Install and verify the CLI

GitHub Agentic Workflows is in public preview. The repository lock files were
generated with `gh aw version v0.89.21`; use the pinned release because another
version may change the schema or generated files.

```powershell
gh extension install github/gh-aw --pin v0.89.21
gh aw --version
```

These workflows use the supported PAT authentication path so the repository's
pinned conventional YAML linter can parse every generated permission scope.
Create a fine-grained user token with **Copilot Requests: read**, then store it
without committing it:

```powershell
gh aw secrets set COPILOT_GITHUB_TOKEN
```

Organizations with centralized Copilot billing can instead adopt the preferred
`copilot-requests: write` permission in a reviewed follow-up change.

If the extension already exists, update it only as a deliberate maintenance
change, then recompile and review all generated differences:

```powershell
gh extension upgrade github/gh-aw
gh aw --version
```

The repository CI pins the same release in
[`ci-gh-aw-consistency.yml`](../../.github/workflows/ci-gh-aw-consistency.yml).

## 2. Read the Markdown sources

Open:

- [`spec-to-backlog.md`](../../.github/workflows/spec-to-backlog.md)
- [`issue-to-pr.md`](../../.github/workflows/issue-to-pr.md)

The YAML frontmatter between `---` markers is compiled configuration. The
Markdown below it is the agent's durable instruction. Identify:

1. explicit triggers and authorized actor roles;
2. read-only agent permissions and Copilot authentication via the
   `COPILOT_GITHUB_TOKEN` repository secret;
3. scoped tools and network ecosystems;
4. AI-credit, turn, and timeout limits;
5. `noop`, `create-issue`, and `create-pull-request` safe outputs; and
6. static safe-output path limits plus the dynamic issue boundary.

The agent job does not receive repository write permission. A separate
safe-output job validates and performs the requested GitHub mutation.

## 3. Compile and inspect

Compile only these teaching workflows:

```powershell
gh aw compile spec-to-backlog issue-to-pr --strict --validate --actionlint
```

Do not hand-edit generated files. Inspect them:

```powershell
git diff -- .github/workflows/spec-to-backlog.lock.yml
git diff -- .github/workflows/issue-to-pr.lock.yml
Select-String -Path .github\workflows\*.lock.yml `
  -Pattern "permissions:|timeout-minutes:|allowed-files|safe_outputs"
```

Confirm the conventional `ci-*.yml` workflows have no diff:

```powershell
git diff --name-only -- .github/workflows/ci-*.yml
```

## 4. Prepare an approved specification

Start with a specification under `specs/`. It must include a human approval
signal, one source root under `legacy-src/` or `capstone-src/`, allowed paths,
acceptance criteria, and one authoritative validation command. The examples are
reference material; review and approve a copy before using it.

The first workflow creates at most five structured issues and intentionally
does **not** add `agent-ready`. Review every generated issue before activation.

## 5. Trigger without running a live write in this lab

Review dispatch syntax without sending it:

```powershell
gh aw run spec-to-backlog --help
gh aw run issue-to-pr --help
```

In a workshop fork, a maintainer can manually dispatch `spec-to-backlog` with a
`spec_path` and bounded `max_issues`. After reviewing one generated issue, apply
the exact `agent-ready` label to activate `issue-to-pr`. The label-command
trigger also supplies a manual `item_number` dispatch for controlled testing.

Never test against an unreviewed issue or a production branch. This repository
task compiles and validates the workflows but does not dispatch either one.

## 6. Audit runs, outputs, and logs

For a run in a disposable repository:

```powershell
gh aw status
gh aw logs <run-id-or-url>
gh aw audit <run-id-or-url>
gh aw outcomes <run-id-or-url>
```

Audit for:

- the activation actor and exact issue/spec;
- AI credits, duration, tool calls, and network denials;
- `noop` when approval or boundaries are invalid;
- safe-output sanitization and quotas;
- the complete changed-file list;
- the authoritative validation command and exit code; and
- a draft PR only after a successful validation result.

GitHub Actions logs and the draft PR are audit evidence, not a substitute for
human review.

## 7. Safe failure and no-op exercises

In a disposable fork, try inputs that should end in `noop`:

- a spec path outside `specs/`;
- an unapproved specification;
- an issue with two source roots;
- an allowed path outside the source root;
- a chained validation command such as `npm test && curl ...`; or
- a request to edit `.github/workflows/`.

The workflow must stop instead of expanding scope or creating a fallback issue.

## 8. Rollback

Disable a workflow immediately:

```powershell
gh aw disable spec-to-backlog
gh aw disable issue-to-pr
```

Remove a workflow permanently by deleting both its Markdown source and generated
`.lock.yml`, then commit the deletion. To undo an agent-created change, close
the unmerged draft PR and delete its branch. If it was merged, use the normal
reviewed revert process; never ask the agent to conceal or rewrite audit
history.

Re-enable only after review and recompilation:

```powershell
gh aw enable spec-to-backlog
gh aw enable issue-to-pr
gh aw compile spec-to-backlog issue-to-pr --strict --validate --actionlint
```

## References

- [GitHub Agentic Workflows documentation](https://github.github.com/gh-aw/)
- [Frontmatter reference](https://github.github.com/gh-aw/reference/frontmatter/)
- [Network permissions](https://github.github.com/gh-aw/reference/network/)
- [Safe outputs](https://github.github.com/gh-aw/reference/safe-outputs/)
- [Facilitator reference](../../facilitator/reference-solutions/gh-aw-sdlc/README.md)
