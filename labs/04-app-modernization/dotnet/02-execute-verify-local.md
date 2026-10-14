# Execute and verify locally

Do not start this part until the durable specification has human approval, the
assessment has been checked against repository evidence, and the generated
Modernize plan has been reconciled with the specification and reviewed. The
plan is a technical proposal subordinate to the approved specification.

```powershell
$source = 'legacy-src\dotnet-bookcatalog\shared-legacy-app'
$project = "$source\src\BookCatalog.Web\BookCatalog.Web.csproj"
$toolRoot = 'legacy-src\dotnet-bookcatalog'
$efProject = 'shared-legacy-app\src\BookCatalog.Web\BookCatalog.Web.csproj'
```

## 1. Execute with the Upgrade agent

In the GitHub Copilot app, select **Upgrade** in the agent picker. `/agent`
should list `upgrade-agent:upgrade`.

Start with a steering prompt that forces the agent to use the approved records
and pause before changes:

```text
Upgrade only legacy-src/dotnet-bookcatalog/shared-legacy-app from .NET
Framework 4.8 ASP.NET MVC 5 and EF6 to .NET 10 ASP.NET Core MVC and EF Core.

Treat these approved files as constraints:
- specs/dotnet-bookcatalog-modernization.md
- any optional ADR linked from the specification
- .github/modernize/bookcatalog-dotnet10/plan.md
- .github/modernize/bookcatalog-dotnet10/tasks.json

First inspect the solution and show how your proposed runtime/framework upgrade
stages map to the approved acceptance criteria and reviewed tasks. Identify any
conflict instead of choosing a new requirement. Cite the exact allowed files,
validation command, and stop condition after each stage. Do not edit until I
approve that mapping. Do not inspect Java paths, create a side-by-side host,
add YARP/System.Web adapters, migrate old MDF data, store a password, deploy
Azure resources, or claim a command passed without running it.
```

Review scope, allowed paths, security/data handling, validation, stop
conditions, and deployment/cleanup exclusions in the mapping. Then approve one
increment at a time. Useful follow-up prompts are below.

### Increment A: project and host

```text
Execute only the approved project/host increment. Convert the web project to
Microsoft.NET.Sdk.Web targeting net10.0, replace legacy package references,
create the ASP.NET Core entry point, preserve the Books/Index default route,
serve static content, and migrate the Razor infrastructure required to compile.
Remove Global.asax, App_Start, Web.config runtime configuration, and System.Web
only when their replacement is present. Run restore and a Release build.
Stop after reporting the exact diff and command result.
```

Expected direction, not a file dump:

- `Microsoft.NET.Sdk.Web` and `<TargetFramework>net10.0</TargetFramework>`;
- no `packages.config`, MVC 5, WebPages, EF6, or `System.Web` references;
- ASP.NET Core controllers with views, static files, routing, and the
  `{controller=Books}/{action=Index}/{id?}` default; and
- Razor imports/start files appropriate for ASP.NET Core.

### Increment B: MVC behavior

```text
Execute only the approved MVC behavior increment. Migrate BooksController and
the five Books views to ASP.NET Core MVC. Preserve active-only title ordering,
details/create/edit/delete behavior, model validation, antiforgery on mutations,
and NotFound for missing IDs. Apply the approved decision for the user-agent
diagnostic. Keep the existing sample styling where practical. Run a Release
build and stop with the actual result.
```

Do not "fix" a build by removing validation, antiforgery, actions, or views.

### Increment C: EF Core and local data

```text
Execute only the approved EF Core increment. Replace EF6 with EF Core SQL
Server, register the DbContext through dependency injection, use async database
operations where appropriate, and add an initial migration with deterministic
seed data: six active books and one inactive Matrix record.

Use local integrated authentication and database BookCatalogModernizedLab.
Use an InitializeDatabase configuration flag so Development can apply
migrations, while Production is false. Never call EnsureDeleted or recreate the
database on every startup. Existing MDF records are disposable and are not
transferred. Run dotnet tool restore, restore, migration validation, and a
Release build. Stop with exact results.
```

Keep all EF Core 10 packages on a compatible 10.x line. The repository tool
manifest is at `legacy-src\dotnet-bookcatalog\.config\dotnet-tools.json`.

### Increment D: Azure-ready configuration

```text
Execute only the approved Azure-ready configuration increment. Preserve local
appsettings.Development configuration. In Production, when KeyVaultName is
present, load Key Vault with Azure.Identity and the user-assigned identity
identified by AZURE_CLIENT_ID. Read ConnectionStrings:BookCatalogContext from
configuration; never add a SQL password or secret value to source.

Remain compatible with the imported assets under
legacy-src/dotnet-bookcatalog/examples/azure: the Bicep settings
KeyVaultName, AZURE_CLIENT_ID, InitializeDatabase=false, and the Key Vault
secret ConnectionStrings--BookCatalogContext. Build locally. Do not provision
or deploy anything.
```

If the agent creates its own assessment, plan, dashboard, or report artifacts,
retain only what it actually generated and report the real paths. Do not invent
an upgrade scenario ID or backfill a success report.

The Modernize CLI also exposes
`modernize plan execute --source legacy-src\dotnet-bookcatalog\shared-legacy-app --plan-name bookcatalog-dotnet10 --language dotnet`.
Do not run that command after choosing the Copilot app Upgrade agent: two
executors can race or duplicate edits. This lab uses the Upgrade agent for
reviewed runtime/framework execution so the participant can review and steer
each increment in the app. Neither executor may redefine the approved
specification.

## 2. Build and inspect

Run from the monorepo root:

```powershell
dotnet --list-sdks
dotnet tool restore --tool-manifest legacy-src\dotnet-bookcatalog\.config\dotnet-tools.json
dotnet restore $source\BookCatalog.sln
dotnet build $source\BookCatalog.sln -c Release --no-restore
if ($LASTEXITCODE -ne 0) { throw "Modernized Release build failed." }
```

Inspect the diff:

```powershell
git diff -- $source
git diff --name-only
```

Stop and investigate if the diff includes Java, another lab, the root README,
workflow files, credentials, generated `bin`/`obj`, or unrelated cleanup.

Confirm:

- the project targets `net10.0`;
- the app uses ASP.NET Core MVC and EF Core, not compatibility shims;
- the DbContext is injected and disposed by DI;
- model validation limits remain;
- state-changing actions validate antiforgery tokens;
- no production secret or SQL password is committed;
- production does not initialize or delete the database; and
- the Key Vault secret name maps to
  `ConnectionStrings:BookCatalogContext`.

## 3. Create or update the local database

The old MDF is not an input. Use the new named LocalDB database:
`BookCatalogModernizedLab`.

If this is the first modernized run:

```powershell
Push-Location $toolRoot
try {
    dotnet ef database update `
        --project $efProject `
        --startup-project $efProject
    if ($LASTEXITCODE -ne 0) { throw "EF Core database update failed." }
}
finally {
    Pop-Location
}
```

If a disposable attempt has the wrong schema, explicitly drop only the new lab
database and then reapply migrations:

```powershell
Push-Location $toolRoot
try {
    dotnet ef database drop `
        --project $efProject `
        --startup-project $efProject `
        --force
    if ($LASTEXITCODE -ne 0) { throw "EF Core database drop failed." }

    dotnet ef database update `
        --project $efProject `
        --startup-project $efProject
    if ($LASTEXITCODE -ne 0) { throw "EF Core database update failed." }
}
finally {
    Pop-Location
}
```

Never delete another database. Never create an empty MDF.

## 4. Local HTTP and behavior verification

Start the app in one PowerShell window:

```powershell
dotnet run --project $project --urls http://127.0.0.1:5080
```

In another window:

```powershell
$response = Invoke-WebRequest http://127.0.0.1:5080/Books `
    -UseBasicParsing
if ($response.StatusCode -ne 200) { throw "Local smoke test failed." }
if ($response.Content -notmatch 'Book Catalog') {
    throw "Catalog heading was not found."
}
```

Then use a browser for the stateful checks:

1. On a fresh database, confirm six active books and no inactive Matrix row.
2. Confirm titles are ascending.
3. Try missing title/author and years outside 1800-2100; validation must reject
   them.
4. Create a uniquely named active book.
5. Open details, edit its title, and confirm the new title in the list.
6. Stop and restart the app. Confirm the edited title remains.
7. Delete that book and confirm it no longer appears.
8. Request a nonexistent ID for details/edit/delete and confirm a 404 result,
   not an unhandled exception.
9. Confirm the approved user-agent diagnostic decision.

Do not require the seven seed records to be inserted again after every restart.
That would hide a destructive initialization bug.

If a test project exists after the upgrade, run it:

```powershell
dotnet test $source\BookCatalog.sln -c Release --no-build
```

Do not describe "no test projects found" as automated behavior coverage. Record
the manual checks separately.

## 5. Local checkpoint

Ask the Copilot app for a skeptical review:

```text
Review the modernized BookCatalog diff against the approved specification,
reviewed plan, and any linked optional ADR.
Focus on functional regressions, ASP.NET Core routing/MVC/antiforgery behavior,
EF Core lifetime and query semantics, deterministic seeding, non-destructive
restart persistence, configuration precedence, Key Vault secret mapping, and
managed identity selection. Cite exact changed lines. Do not edit or claim
tests passed.
```

Resolve high-confidence findings and rerun the smallest affected check plus the
Release build.

**Execute/Verify checkpoint:** commit only after the build, local HTTP smoke
test, CRUD/validation checks, and restart persistence pass. If Azure access is
not approved, continue to the no-deployment path in the next part; local
completion remains valid.
