# .NET BookCatalog recovery guide

Use recovery only after the learner saves:

- the first failing command and complete first error;
- `git status --short`;
- `git diff -- legacy-src/dotnet-bookcatalog/shared-legacy-app`; and
- the last known passing checkpoint.

Do not replace the learner's application with a duplicate solution tree. Repair
the smallest failed seam, rerun the smallest relevant check, and then rerun the
Release build.

## Recovery ladder

### 1. Legacy baseline does not build

Use Visual Studio Installer to restore **ASP.NET and web development**, MSBuild,
.NET Framework 4.8 targeting tools, and IIS Express. Confirm LocalDB with:

```powershell
sqllocaldb info MSSQLLocalDB
```

Then rerun:

```powershell
.\scripts\validation\validate-dotnet.ps1 -Configuration Release
```

Do not create an empty MDF, copy web targets from another machine, or start the
upgrade without a baseline.

### 2. Modernize assessment or plan fails

- Confirm the durable specification was created with the Lab 01 Plan-mode
  method and approved before assessment. Do not replace it with generated plan
  text.
- Confirm `gh auth status`, `modernize --version`, source path, and network.
- Use exactly one `--source` pointing at `shared-legacy-app`.
- Preserve actual tool output. Do not create a fake report or guess its name.
- Validate `tasks.json` with `ConvertFrom-Json`.
- Reconcile the generated plan with the approved spec and any linked optional
  ADR for scope, allowed paths, security, cost, validation, stop conditions,
  deployment, and cleanup before execution.
- If the CLI is unavailable during the event, stop at the gate and record the
  blocker; do not substitute an unreviewed free-form rewrite.

### 3. Upgrade agent is missing

In the GitHub Copilot app, open **Settings > Plugins**, add
`microsoft/upgrade-agent-plugins`, allow it, expand the marketplace, and install
`upgrade-agent`. Run `/agent` and look for `upgrade-agent:upgrade`, or select
**Upgrade** in the picker.

If **Install** still appears, close other Visual Studio, VS Code, and Copilot
CLI instances before retrying. VS Code is not required by the lab.

### 4. Project converts but does not build

Inspect the first compiler/MSBuild error. Common minimums:

- `Microsoft.NET.Sdk.Web`, `net10.0`, and no classic
  `Microsoft.WebApplication.targets`;
- ASP.NET Core MVC services and endpoint routing;
- `_ViewImports.cshtml` importing MVC tag helpers and the model namespace;
- `_ViewStart.cshtml` selecting the layout;
- static files under `wwwroot` or an intentional static-file mapping;
- no MVC 5 `Html.ActionLink` overload assumptions, `HttpNotFound`,
  `ActionResult` namespaces, or `System.Web` types; and
- no `packages.config` references still required by code.

Use the small [ASP.NET Core host patch card](aspnet-core-host-patch.md) only
when the learner's generated structure matches its assumptions.

### 5. EF Core fails

- Keep EF Core packages and `dotnet-ef` on compatible 10.x versions.
- Register the context as scoped through DI.
- Replace EF6 namespaces and initializer APIs.
- Use deterministic values in `HasData`/migration seed.
- Use `BookCatalogModernizedLab`, not the attached legacy MDF.
- Remove `EnsureDeleted` and unconditional Production migration.
- Generate and inspect the migration before applying it.

Use the small [EF Core patch card](ef-core-patch.md) only after comparing it to
the learner's model and configuration.

### 6. Local app starts but behavior regresses

Check in this order:

1. default route reaches Books/Index;
2. query still filters `IsActive` and orders by `Title`;
3. POST actions have antiforgery validation;
4. model annotations remain;
5. missing IDs return `NotFound`;
6. seed has six active and one inactive record;
7. startup migrates only when the explicit Development flag is true; and
8. a user edit survives restart.

Do not accept styling as proof of behavior.

### 7. Azure what-if/deploy is blocked

Use the no-deployment path. Record the real policy/quota/role/cost error, retain
local evidence, validate Bicep/Node/schema, and delete any tagged group. Do not:

- assign yourself Owner/User Access Administrator;
- add a SQL password;
- grant the runtime identity DDL/schema-owner;
- use `0.0.0.0` as the client address;
- broaden public access; or
- change region/SKU without approval.

### 8. Azure app returns 500

Check the first App Service exception, then:

- the user-assigned identity is attached and its client ID matches
  `AZURE_CLIENT_ID`;
- Key Vault contains `ConnectionStrings--BookCatalogContext`;
- the runtime identity has Key Vault Secrets User;
- bootstrap created `Books` and the runtime database principal;
- the connection string uses managed identity and the expected client ID; and
- `InitializeDatabase` remains false.

Role propagation can take time, but delay is not proof. Recheck actual
assignments before retrying the same reviewed operation.

### 9. Cleanup fails

Do not delete a similarly named group. Re-read `.azure-lab\outputs.json`,
confirm the subscription and `workshop=dotnet-modernization` tag, rerun the
helper cleanup, and verify:

```powershell
az group exists --name $resourceGroup --output tsv
```

Completion requires `false`. Escalate a persistent deletion lock or policy
failure to the subscription owner with the exact group ID.
