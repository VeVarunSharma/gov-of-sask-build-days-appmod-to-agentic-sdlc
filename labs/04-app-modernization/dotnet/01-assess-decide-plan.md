# Specify, assess, and reconcile the technical plan

This part carries the approved durable specification from Lab 01 into the
modernization workflow, creates repository evidence, and reconciles the
generated technical plan with the approved contract. Run commands from the
monorepo root unless a step says otherwise.

```powershell
$source = 'legacy-src\dotnet-bookcatalog\shared-legacy-app'
if (-not (Test-Path "$source\BookCatalog.sln")) {
    throw "Run this lab from the monorepo root."
}
```

## 0. Specify: confirm the approved durable contract

Use the [Lab 01 Plan-mode workflow](../../01-spec-driven-development/README.md)
before running modernization tooling. Its committed specification, not the
planning chat and not a later generated plan, is the durable source of intent,
constraints, acceptance criteria, allowed paths, validation, non-goals, and
stop conditions.

For this track, use:

```powershell
$spec = 'specs\dotnet-bookcatalog-modernization.md'
if (-not (Test-Path $spec)) {
    Copy-Item specs\templates\change-specification.md $spec
}
```

In a fresh GitHub Copilot Plan-mode session, refine that file without changing
application code:

```text
Using the Lab 01 contract-first method, refine
specs/dotnet-bookcatalog-modernization.md for modernizing only
legacy-src/dotnet-bookcatalog/shared-legacy-app.

Define the user-visible intent, preserved and intentionally changed behavior,
constraints, non-goals, Given/When/Then acceptance criteria, exact allowed
paths, primary local validation, security and data boundaries, cost and
deployment constraints, cleanup obligations, and stop conditions. The target
direction is .NET 10 ASP.NET Core MVC and EF Core, but do not invent repository
facts and do not choose implementation details that require assessment
evidence. Do not edit application code or create a technical execution plan.
```

Challenge the draft as a skeptical maintainer, resolve or mark blockers, commit
the specification, and record human approval. **Stop** if the specification is
missing, unapproved, or ambiguous. Do not compensate by creating another
requirements framework or by treating Modernize output as the contract.

**Specify checkpoint:** record the specification path and commit, reviewer and
approval date, selected source root, baseline command, unresolved blockers, and
confirmation that implementation has not started.

## 1. Assess: establish the legacy baseline

### Build

The classic web project uses .NET Framework 4.8, old-style MSBuild project
format, `packages.config`, ASP.NET MVC 5/System.Web, EF6, and LocalDB. `dotnet
build` is not the baseline command.

Run the repository wrapper:

```powershell
.\scripts\validation\validate-dotnet.ps1 -Configuration Release
```

The equivalent boundary from the source root is:

```powershell
Push-Location $source
try {
    msbuild BookCatalog.sln -restore -p:Configuration=Release
    if ($LASTEXITCODE -ne 0) { throw "Legacy Release build failed." }
}
finally {
    Pop-Location
}
```

**Stop** if the build fails. Record the first error. Repair missing Visual
Studio workloads or targeting packs with Visual Studio Installer. Do not copy
MSBuild web targets between machines and do not create an empty MDF to work
around a LocalDB attachment error.

### Run and observe

1. Open
   `legacy-src\dotnet-bookcatalog\shared-legacy-app\BookCatalog.sln` in Visual
   Studio.
2. Restore packages, rebuild, select IIS Express, and press F5.
3. Record the actual URL and check:
   - the catalog opens at `/` and `/Books`;
   - six active seed books are visible in title order on a fresh database;
   - the inactive Matrix record is not listed;
   - details, create, edit, and delete work;
   - create requires **Active** to be selected for the new book to appear;
   - validation rejects missing title/author and invalid year values; and
   - an edit survives a stop/start of IIS Express.

Existing disposable data can change the counts. Record what you observed rather
than claiming a fresh database. The source evidence for the starting contract
is:

- `Controllers\BooksController.cs`: active-only title ordering and CRUD;
- `Models\Book.cs`: validation and defaults;
- `Models\ApplicationDbContext.cs`: EF6 initializer and seven seed records;
- `App_Start\RouteConfig.cs`: Books/Index default route; and
- `Web.config`: LocalDB integrated authentication.

The request user-agent diagnostic is not catalog behavior. If you adopt the
approved example in
[`specs/examples/dotnet-remove-user-agent.md`](../../../specs/examples/dotnet-remove-user-agent.md),
record its removal as an intentional delta. Otherwise make an explicit decision
instead of silently losing or retaining it.

### Run `modernize assess`

Authenticate first, then run the current non-interactive interface:

```powershell
gh auth status
modernize --version

$assessmentOutput = '.github\modernize\assessment\bookcatalog'
modernize assess `
    --source $source `
    --output-path $assessmentOutput `
    --format markdown
if ($LASTEXITCODE -ne 0) { throw "Modernize assessment failed." }
```

`--source` is repeatable, but this lab supplies exactly one .NET source. Do not
add the monorepo root or Java application. `--output-path` prevents ambiguity
about where the report belongs.

Inspect every report file the CLI says it generated. Do not assume a filename.
Check that the assessment identifies, with repository evidence:

- .NET Framework 4.8 and classic web-project format;
- ASP.NET MVC 5, `System.Web`, Global.asax, route/filter startup, and Razor
  compatibility work;
- `packages.config` and package replacement/removal;
- EF6 `DbContext`, initializer, LocalDB attachment string, model validation,
  seed data, and the data cutover decision;
- .NET 10 SDK-style ASP.NET Core MVC as the proposed target;
- EF Core SQL Server as the target data provider;
- missing automated tests and required manual behavior checks; and
- Azure as a later, separately gated deployment rather than proof of the local
  upgrade.

If the assessment misses or contradicts repository evidence, annotate the
report or add a companion note. Never edit a report to imply the CLI produced a
finding that it did not produce.

### Copilot review prompt

Open the repository in the GitHub Copilot app and use the default agent for an
evidence review:

```text
Review the actual Modernize CLI assessment under
.github/modernize/assessment/bookcatalog against only
legacy-src/dotnet-bookcatalog/shared-legacy-app.

Identify missing or unsupported claims. Cite exact repository paths and symbols.
Cover the .NET Framework 4.8 web project, MVC 5/System.Web, packages.config,
EF6/LocalDB, seed and CRUD behavior, current validation, and target risks.
Do not edit application code. Do not invent Modernize CLI output.
```

**Assess checkpoint:** preserve the build result, behavior notes, assessment
paths, and review findings. Stop if the classic baseline is not understood.

## 2. Reconcile evidence and record the architecture

The durable specification is the only required contract artifact. Record the
architecture decisions there. If the alternatives and consequences need more
detail than the specification can carry, optionally create and link an ADR:

```powershell
New-Item -ItemType Directory -Force specs\decisions | Out-Null
$adr = 'specs\decisions\adr-0001-bookcatalog-target-architecture.md'
if (-not (Test-Path $adr)) {
    Copy-Item specs\templates\architecture-decision-record.md $adr
}
```

Use this Copilot app prompt:

```text
Reconcile the actual Modernize assessment and cited source evidence with:
- specs/dotnet-bookcatalog-modernization.md
- the optional specs/decisions/adr-0001-bookcatalog-target-architecture.md,
  only if it is linked from the specification

The approved specification remains the requirements contract. Add or correct
evidence and record technical decisions in the specification or its optional
linked ADR. If evidence requires a change to intent, constraints, acceptance
criteria, allowed paths, validation, or stop conditions, stop and return to
Plan mode; revise, recommit, and obtain human reapproval before continuing.

Required decisions:
- target .NET 10 and ASP.NET Core MVC in one host;
- replace EF6 with EF Core SQL Server;
- preserve active-only title ordering, CRUD, validation, antiforgery, and
  restart persistence;
- use disposable workshop data and recreate/seed a new
  BookCatalogModernizedLab database; do not migrate old MDF records;
- record whether the request user-agent diagnostic is removed;
- use migrations and never delete/recreate the database on every startup;
- local integrated authentication, with no password in configuration;
- Azure App Service plus Azure SQL, Key Vault, and a user-assigned managed
  identity only after local verification;
- no side-by-side System.Web host, YARP proxy, shared legacy schema, SQL
  password, or production hardening claim; and
- no-deployment completion when policy, quota, cost approval, or roles block
  Azure.

Confirm the existing testable acceptance criteria, exact allowed paths, stop
conditions, cost/security boundaries, and verification commands. Mark
unsupported claims and open questions. Do not edit the application yet.
```

The specification, or optional ADR when used, must compare at least:

1. an in-place single-host cutover to ASP.NET Core MVC; and
2. a side-by-side/proxy migration.

For this small disposable sample, choose the single-host cutover unless your
assessment found contrary evidence. The negative consequence is a larger
one-time change; the containment is incremental commits and validation gates.

Hold a human reconciliation review. The reviewer must confirm:

- preserved and intentionally changed behavior;
- disposable-data/reseed policy;
- the new local database name;
- package and target-framework direction;
- managed identity and Key Vault boundaries;
- the public unauthenticated lab exposure;
- Azure cost and cleanup ownership; and
- the no-deployment path.

Remove every template placeholder before approval. **Stop** while a question
can change implementation, data handling, security, cost, validation, allowed
paths, stop conditions, deployment, or cleanup. Reapprove the durable
specification if assessment evidence changed its contract.

## 3. Plan: create and reconcile the specialized technical plan

Use the exact assessment report path emitted by your CLI version:

```powershell
$assessmentReport = Read-Host `
    'Enter the actual assessment report path printed by modernize'
if (-not (Test-Path $assessmentReport -PathType Leaf)) {
    throw "Assessment report does not exist: $assessmentReport"
}

modernize plan create `
    'Modernize BookCatalog from .NET Framework 4.8 MVC 5 and EF6 to .NET 10 ASP.NET Core MVC and EF Core, preserve the approved catalog behavior, verify locally, and prepare optional Azure-ready configuration without deploying, following the approved repository specification and any linked decision record' `
    --source $source `
    --plan-name bookcatalog-dotnet10 `
    --language dotnet `
    --assess-file-path $assessmentReport
if ($LASTEXITCODE -ne 0) { throw "Modernize plan creation failed." }
```

The current interface writes:

- `.github\modernize\bookcatalog-dotnet10\plan.md`
- `.github\modernize\bookcatalog-dotnet10\tasks.json`

Both files are editable before execution. They are generated proposals, not
approval and not a replacement for the durable specification. Do not accept
them only because a tool created them.

If that plan name already exists, stop and review it. Use the current
`--overwrite` option only when you intentionally want to replace that plan and
have preserved the reviewed version.

Use this Copilot app prompt:

```text
Review .github/modernize/bookcatalog-dotnet10/plan.md and tasks.json against:
- specs/dotnet-bookcatalog-modernization.md
- any optional ADR linked from the specification
- the actual assessment report
- the existing BookCatalog source

Treat the generated plan as a technical proposal subordinate to the approved
specification. Report every conflict before editing. Update only the plan
artifacts, and do not weaken or silently reinterpret approved acceptance
criteria. Make the work incremental:
1. convert to SDK-style .NET 10 web project and get a build;
2. migrate ASP.NET MVC hosting, routing, controllers, views, static content,
   validation, antiforgery, and 404 behavior;
3. migrate EF6 to EF Core with DI, deterministic seed data, and migrations;
4. verify local CRUD, active filtering, ordering, validation, and persistence;
5. add Azure Identity/Key Vault configuration without local secrets;
6. prepare and review the imported Bicep/helper flow;
7. publish, smoke test, and clean up only after explicit Azure gates.

Each task must name allowed paths, validation, rollback/containment, and stop
conditions. Review security and data handling, Azure cost gates, deployment
boundaries, no-deployment behavior, and exact cleanup. Do not execute the plan.
Do not add Java, VS Code, YARP, System.Web adapters, shared-schema migration,
passwords, or CI workflow work.
```

Before approval, review the proposal explicitly for:

- scope and exact editable paths;
- preservation of approved behavior and acceptance criteria;
- identity, secrets, data handling, and public exposure;
- local-first validation and failure/rollback boundaries;
- Azure cost, subscription, region, role, and deployment gates;
- stop conditions for ambiguity, scope escape, or failed validation; and
- no-deployment completion and exact cleanup.

If reconciliation would change the durable contract, revise and reapprove the
specification first. Do not maintain competing requirements in `plan.md`.

Check `tasks.json` remains valid JSON:

```powershell
Get-Content .github\modernize\bookcatalog-dotnet10\tasks.json -Raw |
    ConvertFrom-Json | Out-Null
```

**Plan checkpoint:** commit the approved durable spec, assessment notes,
reconciled plan, and any optional linked ADR before execution. Record who
reviewed the plan and any accepted risks. A suggested message is
`Document BookCatalog modernization decision and plan`.
