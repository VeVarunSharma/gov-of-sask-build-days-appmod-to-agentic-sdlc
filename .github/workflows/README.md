# Workflows

Deterministic GitHub Actions and approved agentic workflow definitions belong
here.

- `ci-*.yml` files are conventional, deterministic CI. They run repeatable
  build, test, lint, documentation, provenance, and consistency gates.
- `*.md` workflow sources are GitHub Agentic Workflows (`gh-aw`) instructions.
- `*.lock.yml` files are compiler-owned outputs. Never edit them by hand.

Deterministic CI remains the merge authority. Agentic workflows may correlate
evidence, publish an advisory review, no-op, or propose a bounded draft pull
request through safe outputs; they do not replace or waive CI.

The lock files are pinned to the public-preview `gh aw version v0.89.21`.
Follow [CONTRIBUTING.md](../../CONTRIBUTING.md) for compilation, lock-diff, and
`actionlint` maintenance. Participant exercises start in
[Lab 05](../../labs/05-agentic-workflows/) and
[Lab 06](../../labs/06-automated-qa/).
