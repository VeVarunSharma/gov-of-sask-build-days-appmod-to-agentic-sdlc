# Path-specific Copilot instructions

GitHub Copilot automatically discovers `*.instructions.md` files in this
directory. Each file uses YAML frontmatter with an `applyTo` glob followed by
Markdown guidance:

```markdown
---
applyTo: "path/**/*.ext"
---

# Guidance
```

Keep repository-wide rules in
[`../copilot-instructions.md`](../copilot-instructions.md). Put only rules that
become more accurate for a path or technology here.

| File | Intended scope |
| --- | --- |
| `java.instructions.md` | Java/Maven application code |
| `dotnet.instructions.md` | C# and MSBuild project files |
| `react-typescript.instructions.md` | React/TypeScript capstone UI |
| `docs-specs.instructions.md` | Labs, specifications, and facilitator docs |
| `infrastructure.instructions.md` | Azure/IaC and operational scripts |
| `agentic-workflows.instructions.md` | Agents, skills, and workflow lab content |

The scopes are deliberately rooted in this monorepo. Do not replace them with a
single broad `**/*` rule: that would make Java, .NET, and React guidance compete.
