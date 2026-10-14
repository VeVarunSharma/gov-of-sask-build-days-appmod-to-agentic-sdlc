# Repository skills

Each subdirectory contains a reusable `SKILL.md` and optional scripts. The
GitHub Copilot app discovers skills from `.github/skills/<skill-name>/SKILL.md`
and loads one when the request matches its frontmatter description or the user
invokes it by name.

| Skill | Use it for |
| --- | --- |
| `maven-diagnostics` | Maven reactor, dependency, and test-failure triage |
| `dotnet-msbuild-diagnostics` | Classic NuGet/MSBuild or SDK-style .NET triage |
| `modernization-assessment-review` | Reviewing an assessment before planning |

Diagnostic scripts are read-only: they inspect manifests and reports but do not
restore, build, update, publish, deploy, or edit the repository. Run the script
directly to verify its behavior before relying on the skill.
