# Repository custom agents

Files ending in `.agent.md` are repository-scoped agents discovered by the
GitHub Copilot app. Frontmatter declares the display name, description, and
allowed tools; the Markdown body is the agent's operating contract.

| Agent | Purpose | Writable? |
| --- | --- | --- |
| `shared-spec-review` | Review specifications shared across tracks | No |
| `java-modernization-planner` | Plan Java modernization from repository evidence | No |
| `dotnet-modernization-planner` | Plan .NET modernization from repository evidence | No |
| `java-test-specialist` | Add or repair focused Java tests | Yes, Java test paths only |
| `dotnet-test-specialist` | Add or repair focused .NET tests | Yes, .NET test paths only |

Select an agent from the Copilot app's agent picker, then give it a bounded
request. Planning and review agents intentionally omit edit and execute tools.
Test agents may edit and execute, but their instructions restrict both paths and
commands.
