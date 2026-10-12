# Lab 04 .NET track: modernize BookCatalog

Modernize the imported BookCatalog sample from ASP.NET MVC 5 on .NET
Framework 4.8 and EF6 to ASP.NET Core MVC on .NET 10 and EF Core. This track
extends the contract-first workflow from
[Lab 01](../../01-spec-driven-development/README.md):

> **Specify and approve -> Assess -> Create and reconcile plan -> Execute -> Verify**

The GitHub Copilot app is the agent experience for this lab. Visual Studio is
required only to establish and inspect the Windows-only legacy web baseline.
Do not substitute VS Code instructions.

The approved durable specification is the source of intent, constraints,
acceptance criteria, allowed paths, validation, and stop conditions.
`modernize assess` adds repository evidence. `modernize plan create` proposes
the specialized technical sequence. The Upgrade agent executes only after that
proposal has been reconciled with the approved specification and reviewed by a
human.

## Outcomes

By the end of the lab, you will have:

- a human-approved durable modernization specification created with the Lab 01
  Plan-mode method;
- a recorded legacy build and behavior baseline;
- a Modernize CLI assessment produced by `modernize assess`;
- an evidence-reconciled specification, with an optional architecture decision
  record when the trade-offs need separate treatment;
- a reviewed and reconciled Modernize CLI technical plan;
- an ASP.NET Core MVC application targeting .NET 10 with EF Core;
- repeatable local build, data, and behavior evidence; and
- either a verified Azure App Service deployment or a documented
  no-deployment completion caused by policy, quota, or role constraints.

## Source and boundaries

- **Source root:** `legacy-src\dotnet-bookcatalog\shared-legacy-app`
- **Solution:** `BookCatalog.sln`
- **Imported Azure assets:**
  `legacy-src\dotnet-bookcatalog\examples\azure`
- **Track:** .NET only. Do not inspect or change the Java track.
- **Data classification:** disposable workshop data. Do not point any command
  at a business database.

Create a lab branch before editing the imported application. Your branch is
your working copy; Git preserves the imported starting state.

```powershell
git switch -c lab/dotnet-modernization
git status --short
```

If the branch already exists, switch to it rather than creating another one.
Do not run `git reset --hard` over work you need to keep.

## Time and prerequisites

Allow 3-4 hours for the local path and another 45-90 minutes for the controlled
Azure path.

Complete [Lab 00 readiness](../../00-readiness/README.md) first, and use the
[Lab 01 Plan-mode method](../../01-spec-driven-development/README.md) to create
and obtain human approval for the durable modernization specification before
assessment. Do not introduce another SDD framework or treat a generated tool
plan as a replacement specification. The .NET track requires:

- Windows, not WSL, for the classic web baseline;
- Visual Studio 2026 or Visual Studio 2022 17.14.17 or later;
- **ASP.NET and web development**, MSBuild, IIS Express, .NET Framework 4.8
  targeting tools, and SQL Server Express LocalDB;
- a stable .NET 10 SDK and runtime;
- authenticated GitHub CLI and the GitHub Copilot app;
- Modernize CLI on `PATH`;
- the `microsoft/upgrade-agent-plugins` marketplace and `upgrade-agent` plugin
  installed in the GitHub Copilot app;
- Azure CLI and Node.js 24 or a compatible version for the optional deployment;
  and
- an approved Azure subscription, region, naming scope, budget, and permission
  to create role assignments.

Run the readiness checks from the monorepo root:

```powershell
.\scripts\readiness\check-common.ps1 -AcknowledgeCopilotApp
.\scripts\readiness\check-dotnet.ps1
```

The current GitHub Copilot app plugin interface is **Settings > Plugins**:

1. Add the `microsoft/upgrade-agent-plugins` marketplace and select **Allow**.
2. Expand **upgrade-agent-plugins** and install **upgrade-agent**.
3. In a Copilot app session, run `/agent` and confirm
   `upgrade-agent:upgrade`, or use the agent picker and confirm **Upgrade**.

If the button still says **Install**, close other Visual Studio, VS Code, and
Copilot CLI instances before retrying. The lab itself does not require VS Code.

Current interface references:

- [GitHub Copilot modernization CLI](https://github.com/microsoft/modernize-cli)
- [Modernize CLI command reference](https://learn.microsoft.com/azure/developer/github-copilot-app-modernization/modernization-agent/cli-commands)
- [Install GitHub Copilot upgrade in the Copilot app](https://learn.microsoft.com/dotnet/core/porting/github-copilot-upgrade/install)
- [Upgrade-agent plugin](https://github.com/microsoft/upgrade-agent-plugins/tree/main/plugins/upgrade-agent)

## Lab map

1. [Specify, assess, and reconcile the technical plan](01-assess-decide-plan.md)
2. [Execute and verify locally](02-execute-verify-local.md)
3. [Prepare, deploy, verify, and clean up Azure](03-azure-deploy-cleanup.md)

Use the [facilitator recovery guide](../../../facilitator/recovery/dotnet/)
only after recording the first failing command and preserving your diff. The
[reference solution](../../../facilitator/reference-solutions/dotnet-modernization/)
is an acceptance profile, not captured or fabricated agent output.

## Checkpoints and stop conditions

| Gate | Checkpoint required to continue | Stop when |
| --- | --- | --- |
| Specify | The durable spec defines approved intent, constraints, acceptance criteria, allowed paths, validation, and stop conditions. | The spec is missing, unapproved, ambiguous, or still contains a scope-changing question. |
| Assess | Readiness passes, the classic Release build is recorded, baseline behavior is observed, and the generated assessment is checked against repository evidence. | A prerequisite is missing, the baseline fails, or the assessment cites files outside the .NET source root. |
| Plan | `plan.md` and `tasks.json` are treated as proposals and reconciled with the approved spec, assessment, and any linked optional ADR. Scope, allowed paths, security, cost, validation, stop conditions, deployment boundaries, and cleanup are reviewed. | The plan conflicts with the spec; proposes a side-by-side host, business-data migration, passwords, Java changes, or deployment before local verification; or lacks bounded validation and cleanup. |
| Execute | Each increment builds before the next one starts. | The agent wants to bypass tests, rewrite unrelated code, remove antiforgery validation, or hide an unexplained error. |
| Verify | Local behavior and persistence pass; Azure either passes its gates or has a documented blocker and cleanup. | A smoke test fails, a resource group is not owned by this lab, or cleanup cannot be confirmed. |

## Expected artifacts

Paths created by tools can vary by installed version. Record the paths printed
by the tool; do not create a report merely to make this checklist look complete.

| Artifact | Expected location or evidence |
| --- | --- |
| Baseline record | Commit/notes containing the exact build command, result, and manual behavior observations |
| Assessment | The directory supplied to `modernize assess --output-path`; retain the actual report files generated |
| Durable modernization specification | `specs/dotnet-bookcatalog-modernization.md`, created and approved with the Lab 01 Plan-mode method |
| Optional decision record | `specs/decisions/adr-0001-bookcatalog-target-architecture.md`, only when the architecture trade-offs need a separate record |
| Modernize technical plan | `.github/modernize/bookcatalog-dotnet10/plan.md` and `tasks.json`, retained as reviewed proposals subordinate to the approved specification |
| Upgrade-agent record | The actual files and summary reported by the plugin; do not invent a scenario ID or output |
| Modernized application | Reviewed changes under the BookCatalog source root |
| Local verification | Release build, EF Core database, HTTP smoke check, and manual CRUD/persistence record |
| Azure preparation | `.azure-lab/schema.sql`, Bicep build output, and reviewed what-if result |
| Azure deployment | `.azure-lab/outputs.json`, publish ZIP, smoke evidence, and confirmed group deletion |
| No-deployment path | `.azure-lab/no-deployment.md` with the actual blocker, completed local evidence, and cleanup result |

Treat `.azure-lab` as local evidence. Do not commit deployment outputs, publish
archives, access tokens, connection strings, or logs that contain secrets.

## Completion

The local path is mandatory. The Azure path is complete in one of two ways:

- **Deployment completion:** the app is published, smoke and persistence checks
  pass, and the exact dedicated resource group is deleted; or
- **No-deployment completion:** local verification passes, Bicep is built,
  what-if is reviewed when permissions allow it, the real blocker is recorded,
  no unsafe workaround is attempted, and any created group is deleted.

Do not claim an agent action, command result, Azure deployment, smoke test, or
cleanup that you did not observe.
