# Lab 03: Custom agents and skills

Build reusable Copilot behavior with the least privilege needed for the job.
You will inspect repository custom agents and skills, create one bounded agent
from a starter, invoke an existing diagnostic skill, and verify tool and path
boundaries in the GitHub Copilot app.

## Outcomes

By the end of this lab, you can:

- distinguish an agent persona from an on-demand reusable skill;
- create valid agent and skill frontmatter in the expected locations;
- choose allowed tools based on required actions, not convenience;
- invoke and verify repository agents and skills in the Copilot app; and
- prove a diagnostic script is read-only and rooted in the selected track.

## Formats, placement, and discovery

### Custom agents

Repository agents live at `.github/agents/<name>.agent.md`:

```markdown
---
name: example-reviewer
description: Review one artifact without editing or executing commands.
tools:
  - read
  - search
---

# Operating instructions
```

The `description` helps users choose the agent. `tools` is an allowlist:

- `read` reads selected repository content;
- `search` discovers relevant repository evidence;
- `edit` changes files; and
- `execute` runs commands.

Do not grant `edit` or `execute` to a review or planning agent. A tool being
allowed does not remove the need for path, command, and stop boundaries in the
Markdown body.

### Skills

Repository skills live at `.github/skills/<skill-name>/SKILL.md`:

```markdown
---
name: example-skill
description: Diagnose a specific problem and state when this skill should load.
---

# Procedure and guardrails
```

A skill packages reusable procedure and may include `scripts/`, examples, or
supporting references in its directory. Copilot loads a skill when the request
matches its description or when you explicitly ask to use it.

## Inspect the supplied assets

Open [the agent catalog](../../.github/agents/README.md) and
[the skill catalog](../../.github/skills/README.md). Compare:

- read-only specification and modernization planning agents;
- Java and .NET test agents with `edit` and `execute`; and
- diagnostic skills whose scripts inspect manifests without restoring or
  changing dependencies.

For each asset, identify its allowed source root, writable paths, permitted
commands, validation expectation, and stop condition.

## Exercise A: create a bounded review agent

Copy
[`starter/change-readiness-review.agent.md`](starter/change-readiness-review.agent.md)
to `.github/agents/change-readiness-review.agent.md`. Replace the marked
sections so it reviews one approved change specification before implementation.

The finished agent must:

1. allow only `read` and `search`;
2. inspect one `specs/` document and its selected Java or .NET root;
3. check allowed paths, acceptance criteria, validation, and stop conditions;
4. refuse implementation and cross-track investigation; and
5. return a clear readiness decision with repository evidence.

Start a new Copilot session, select **change-readiness-review** from the agent
picker, and ask it to review one example in `specs/examples/`. Confirm the UI
shows only the allowed tools and that no file changes or command approvals are
requested.

## Exercise B: invoke a diagnostic skill

Choose one track and prompt Copilot in the default coding agent:

```text
Use the maven-diagnostics skill to inventory the imported Java Maven reactor.
Run only its read-only inspection script. Do not run Maven or edit files.
```

or:

```text
Use the dotnet-msbuild-diagnostics skill to inventory the imported classic
.NET solution. Run only its read-only inspection script. Do not restore, build,
or edit files.
```

In the Copilot app:

1. confirm the matching `SKILL.md` appears in References/context;
2. inspect the proposed command before approving it;
3. confirm output lists manifests and dependencies for only the selected root;
4. check the source-control view remains unchanged; and
5. ask for one diagnosis that distinguishes evidence from hypotheses.

You can also run the scripts yourself from the repository root:

```powershell
.\.github\skills\maven-diagnostics\scripts\inspect-maven.ps1
.\.github\skills\dotnet-msbuild-diagnostics\scripts\inspect-dotnet.ps1
```

```bash
bash ./.github/skills/maven-diagnostics/scripts/inspect-maven.sh
bash ./.github/skills/dotnet-msbuild-diagnostics/scripts/inspect-dotnet.sh
```

## Optional extension: create a skill

Copy [`starter/skill-template/SKILL.md`](starter/skill-template/SKILL.md) to
`.github/skills/<new-skill>/SKILL.md`. Give it one triggerable purpose, a
read-only first step, explicit forbidden actions, and a reproducible result.
Do not duplicate a supplied diagnostic skill.

## Verification checklist

- [ ] Agent and skill filenames and directories match the discovery rules.
- [ ] YAML frontmatter is valid and descriptions state when to use the asset.
- [ ] The review agent has only `read` and `search`.
- [ ] Instructions declare selected roots, writable paths, commands, and stops.
- [ ] The Copilot app discovers the agent after a new session/reload.
- [ ] The invoked skill appears in References/context.
- [ ] Read-only script execution leaves source control unchanged.
- [ ] Output and conclusions are limited to one selected technology track.

Facilitator examples are under
[`facilitator/reference-solutions/copilot/lab-03/`](../../facilitator/reference-solutions/copilot/lab-03/).
