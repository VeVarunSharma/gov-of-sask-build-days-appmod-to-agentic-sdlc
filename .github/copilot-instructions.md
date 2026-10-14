# Repository-wide Copilot baseline

This global baseline applies to GitHub Copilot coding agents, cloud agents, and
pull request review. It complements, rather than replaces, scoped guidance.

- Before working, read the root [`AGENTS.md`](../AGENTS.md), the nearest
  co-located `AGENTS.md`, and every applicable path-specific
  [instruction](instructions/README.md). Do not rely on implied automatic
  precedence; stop and report conflicting guidance.
- Use Plan mode and obtain approval for a durable [specification](../specs/README.md)
  before significant, cross-cutting, or modernization changes.
- Keep implementation within one selected Java or .NET track unless the
  approved specification explicitly spans both. Preserve imported baselines,
  provenance, structure, and unrelated behavior.
- Never commit secrets or real personal, participant, customer, or tenant data;
  use visibly synthetic examples.
- Run the narrowest deterministic validation documented by applicable scoped
  guidance, report the observable result, and treat CI as merge authority.
- Never hand-edit generated `gh-aw` `.lock.yml` files; edit their Markdown
  sources and regenerate them with repository-pinned tooling.
- Stop when a required tool, dependency, permission, input, or approval is
  missing. Report the prerequisite instead of inventing success.
