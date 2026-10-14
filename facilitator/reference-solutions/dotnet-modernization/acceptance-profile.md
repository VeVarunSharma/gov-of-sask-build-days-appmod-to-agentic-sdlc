# BookCatalog modernization acceptance profile

## Starting evidence

| Concern | Repository evidence |
| --- | --- |
| Runtime/project | `legacy-src/dotnet-bookcatalog/shared-legacy-app/src/BookCatalog.Web/BookCatalog.Web.csproj` targets .NET Framework 4.8, uses classic web project imports, and sets C# 7.3. |
| Web framework | The project references MVC 5, WebPages, Razor 3, and System.Web; `Global.asax.cs` and `App_Start` configure startup. |
| Routes | `App_Start/RouteConfig.cs` maps the default to `Books/Index`. |
| Data | `Models/ApplicationDbContext.cs` uses EF6 and `DropCreateDatabaseIfModelChanges`. |
| Local connection | `Web.config` uses integrated LocalDB with an attached `BookCatalog.mdf`. |
| Behavior | `BooksController.cs` filters `IsActive`, orders by `Title`, and implements details/create/edit/delete. |
| Validation | `Models/Book.cs` requires title/author, limits string lengths, and allows published years 1800-2100. |
| Seed | The initializer has six active books and one inactive Matrix record with fixed dates. |
| Diagnostic | `BooksController.Index` passes the request user agent and `Views/Books/Index.cshtml` displays it. |

## Expected approved decisions

- Target `net10.0` with `Microsoft.NET.Sdk.Web`.
- Replace MVC 5/System.Web with one ASP.NET Core MVC host.
- Replace EF6 with EF Core SQL Server 10.x and dependency injection.
- Use `BookCatalogModernizedLab` for disposable local data.
- Preserve catalog CRUD, validation, active filtering, title ordering,
  antiforgery, 404 handling, and restart persistence.
- Remove the user-agent diagnostic when adopting the repository's approved
  example specification; otherwise record the alternative explicitly.
- Use deterministic migration seed data. Never delete/recreate on every start.
- Do not transfer the old MDF or share a schema with the legacy host.
- Production reads the connection string from Key Vault using a user-assigned
  managed identity; source contains no password.
- Azure remains optional and separately gated.

## Expected implementation shape

Exact filenames may differ, but a credible result contains:

- SDK-style web project targeting .NET 10;
- ASP.NET Core `Program.cs` with controllers/views, static files, routing, and
  a Books/Index default route;
- ASP.NET Core-compatible Razor infrastructure and all five Books views;
- controller constructor injection of the EF Core context;
- `Microsoft.EntityFrameworkCore.SqlServer`, design/tooling support needed for
  migrations, `Azure.Identity`, and Key Vault configuration packages;
- a first EF Core migration creating `Books` and deterministic seed rows;
- Development LocalDB configuration and production Key Vault loading;
- a guarded `InitializeDatabase` path that can migrate Development but is false
  in the imported Azure template; and
- no `packages.config`, System.Web adapters, YARP, SQL password, or committed
  generated output.

## Required evidence

### Assessment and decision

- The learner created and obtained human approval for
  `specs/dotnet-bookcatalog-modernization.md` with the Lab 01 Plan-mode method
  before running modernization tooling.
- The learner ran `modernize assess` on the exact .NET source root.
- The actual report is retained and reviewed; unsupported claims are annotated.
- Assessment evidence was reconciled with the durable spec and any linked
  optional ADR; any contract change was reapproved.
- The spec and any optional ADR have no template placeholders or
  scope-changing questions.
- A human approved behavior, data, architecture, security, cost, and cleanup.
- The generated Modernize plan is recorded as a proposal, contains incremental
  validation and valid `tasks.json`, and was reconciled with the approved spec
  for scope, allowed paths, security, cost, validation, stop conditions,
  deployment boundaries, and cleanup.

### Local execution

- `dotnet restore` and `dotnet build -c Release` pass on the modernized solution.
- EF migration application succeeds against `BookCatalogModernizedLab`.
- `/Books` returns 200 and contains the catalog heading.
- Fresh seed expectations, ordering, validation, CRUD, missing-ID 404s, and the
  user-agent decision are manually checked.
- A newly edited book survives application restart.
- Diff review shows no Java, workflow, root README, secret, or unrelated change.

### Azure or no-deployment

Deployment evidence must include Bicep build, reviewed what-if, helper bootstrap,
publish, HTTPS smoke, cloud CRUD/restart persistence, and exact group deletion.

A no-deployment completion must instead include the actual policy/quota/role or
cost blocker, all local evidence, local Bicep/Node/schema validation, what-if
status, and cleanup of any created group. It must not claim a deployment.

## High-value review findings

Look closely for:

- `EnsureDeleted`, `DropCreateDatabaseIfModelChanges`, or unconditional
  migration in Production;
- seed dates based on `DateTime.Now`, which destabilize migrations;
- a scoped DbContext stored in a singleton or manually retained/disposed;
- sync-over-async controller calls or changed active/title query semantics;
- missing antiforgery attributes on create/edit/delete POST actions;
- missing `NotFound` handling;
- `app.UseStaticFiles`, routing, or the default route omitted;
- Key Vault loaded before enough configuration exists to identify it;
- use of a system-assigned identity when the Bicep supplies a user-assigned one;
- a secret value, SQL password, or deployment output committed to Git;
- runtime identity granted schema-owner/DDL permissions;
- the app attempting to initialize Azure SQL despite
  `InitializeDatabase=false`; and
- cleanup targeting a name other than the exact recorded group.
