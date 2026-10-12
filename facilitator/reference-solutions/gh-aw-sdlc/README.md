# Facilitator reference: guarded agentic SDLC

Use this reference to review Lab 05. The implementation is intentionally
production-shaped: autonomous within an approved boundary, read-only at the
agent layer, and writable only through quota-limited safe outputs.

## Expected assets

- `.github/workflows/spec-to-backlog.md`
- `.github/workflows/spec-to-backlog.lock.yml`
- `.github/workflows/issue-to-pr.md`
- `.github/workflows/issue-to-pr.lock.yml`
- `.gitattributes` marking `*.lock.yml` as generated
- `labs/05-agentic-workflows/README.md`

Generated lock files must be produced by `gh aw version v0.89.21`, not edited
by hand. Conventional `ci-*.yml` workflows must remain byte-for-byte unchanged.
The teaching repository uses the `COPILOT_GITHUB_TOKEN` secret authentication
path so its pinned conventional `actionlint` version can validate generated
locks; production organizations may prefer `copilot-requests: write`.

## Design review

### Spec to backlog

- Manual dispatch requires one `specs/...` path and a 1–5 issue limit.
- Approval is data validated by the agent, not inferred from a filename.
- Each created issue includes the source specification, one source root, an
  allowlist, protected paths, one validation command, and acceptance criteria.
- Generated issues are not automatically activated.
- Unsafe, incomplete, or already-satisfied work ends with `noop`.

### Issue to pull request

- The `agent-ready` label is a one-shot human activation decision; generated
  manual dispatch supports a specific `item_number`.
- Trigger roles are limited to `admin`, `maintainer`, and `write`.
- GitHub access is restricted to one read of one issue; `agent-ready` is also
  the explicit integrity-approval label for that untrusted content.
- Edit and shell tools are explicit; network access is limited to GitHub and
  the Java, .NET, and Node package ecosystems.
- The static safe-output allowlist permits only `legacy-src/**` and
  `capstone-src/**`; the prompt narrows each run to one issue-declared subtree
  and allowlist.
- Secret-like files are excluded, patch size/file count are capped, protected
  repository areas are forbidden, and no fallback issue is created.
- A draft PR is requested only after the issue's exact validation command exits
  successfully. Failure or ambiguity ends with `noop`.

## Prompt-injection discussion

Ask participants why issue and spec content are treated as untrusted even after
human approval. Expected points:

- approval authorizes a bounded outcome, not arbitrary embedded instructions;
- tool and network allowlists limit available capabilities;
- safe outputs separate model reasoning from GitHub write credentials;
- static path filters backstop prompt rules;
- no-op is a successful safety outcome, not a failed implementation; and
- logs, output quotas, draft status, and PR evidence preserve human oversight.

The dynamic one-subtree rule is checked by the agent against the issue contract,
while the safe-output layer enforces the broader static union. Facilitators
should call out this defense-in-depth distinction and require diff review.

## Validation checklist

Run from the repository root:

```powershell
gh aw --version
gh aw compile spec-to-backlog issue-to-pr --strict --validate --actionlint
gh aw validate spec-to-backlog issue-to-pr
git diff --name-only -- .github/workflows/ci-*.yml
```

Also validate Markdown links with the repository documentation check. Expected
results:

- both sources compile without warnings or errors;
- both generated lock files pass `actionlint`;
- recompilation produces no lock-file drift;
- no conventional CI workflow changes; and
- local Markdown links resolve.

Do not dispatch either write-capable workflow during repository validation.

## Recovery prompts

- **A spec is unapproved:** add a real human approval record; do not weaken the
  workflow.
- **The issue needs another subtree:** split the issue or revise it through
  human review; do not expand the running agent's scope.
- **Validation needs an unavailable command:** update the reviewed issue and
  workflow tool allowlist in a normal pull request, recompile, then reactivate.
- **An unexpected draft PR appears:** disable `issue-to-pr`, close the PR,
  preserve logs, audit the run, and rotate credentials only if the audit shows
  exposure.
