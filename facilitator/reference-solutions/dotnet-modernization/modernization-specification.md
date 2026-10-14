# Change specification: modernize .NET BookCatalog

## Metadata

- **Owner:** Workshop application team
- **Status:** Reference approved
- **Source root:** `legacy-src/dotnet-bookcatalog/shared-legacy-app`
- **Related issue:** Not created

## Problem and outcomes

### Problem

BookCatalog is tied to .NET Framework 4.8, classic ASP.NET MVC 5/System.Web,
old-style project format, `packages.config`, EF6, and an attached LocalDB MDF.
The evidence is in `BookCatalog.Web.csproj`, `Web.config`,
`Global.asax.cs`, `App_Start`, and `Models/ApplicationDbContext.cs`. This limits
the app to the Windows legacy web toolchain and prevents the approved Linux App
Service target.

### Desired outcomes

1. Users retain the catalog CRUD, validation, filtering, ordering, and
   persistence behavior in ASP.NET Core MVC on .NET 10.
2. Operators can run locally with integrated authentication and optionally
   deploy through the reviewed Azure SQL, Key Vault, managed identity, Bicep,
   publish, smoke-test, and cleanup flow.

### Success measures

- Release restore/build and local HTTP/behavior checks pass.
- EF Core creates the disposable `BookCatalogModernizedLab` schema and seed once
  and preserves later edits across restarts.
- Azure either passes all controlled gates and cleanup, or the real blocker is
  documented without an unsafe workaround.

## Functional requirements

| ID | Requirement | Evidence or rationale |
| --- | --- | --- |
| FR-1 | `/` and `/Books` shall show only active books ordered by title. | `Controllers/BooksController.cs:Index`; `App_Start/RouteConfig.cs` |
| FR-2 | Details, create, edit, and delete shall preserve validation, antiforgery on mutations, and not-found behavior. | `BooksController.cs`; `Models/Book.cs`; Books views |
| FR-3 | A fresh database shall contain the six active seeds and one inactive Matrix seed with deterministic values. | `Models/ApplicationDbContext.cs:SeedBooks` |
| FR-4 | A created or edited record shall persist across an app restart. | Catalog data is persistent state; startup must not reset it. |
| FR-5 | The browser user-agent diagnostic shall be removed without replacing it in UI, logs, or view data. | Approved `specs/examples/dotnet-remove-user-agent.md` decision |
| FR-6 | Development may apply EF Core migrations when `InitializeDatabase` is true; Production shall not initialize schema. | Imported Bicep sets `InitializeDatabase=false`; bootstrap owns Azure schema. |
| FR-7 | Production shall read `ConnectionStrings:BookCatalogContext` from Key Vault with the configured user-assigned identity. | Imported Bicep/helper contract |

## Constraints and out of scope

### Constraints

- **Allowed application paths:**
  `legacy-src/dotnet-bookcatalog/shared-legacy-app/**`
- **Allowed planning paths:** the BookCatalog modernization spec, its linked
  optional ADR, and `.github/modernize/bookcatalog-dotnet10/**`
- **Compatibility:** .NET 10, ASP.NET Core MVC, EF Core SQL Server, local
  integrated authentication, Linux App Service.
- **Dependencies:** use compatible stable 10.x .NET/EF packages and the
  repository's `dotnet-ef` manifest.
- **Data and security:** disposable sample data only; no password, token, or
  secret value in source; Azure runtime receives CRUD on `dbo.Books`, not DDL.

### Out of scope

- Preserving or transferring old MDF records.
- Side-by-side hosting, YARP, System.Web adapters, or a shared legacy schema.
- User authentication and production network/backup/monitoring hardening.
- Java, other labs, root documentation, and workflow changes.

## Acceptance criteria

### AC-1: Active catalog behavior

- **Given** active and inactive seed books exist
- **When** a user opens `/Books`
- **Then** only active books appear in ascending title order
- **Verification:** local and Azure browser checks plus controller/query review

### AC-2: CRUD, validation, and not-found behavior

- **Given** the modernized app is running
- **When** a user submits invalid input, performs CRUD, or requests a missing ID
- **Then** validation and antiforgery are enforced, valid operations persist,
  and missing IDs return 404
- **Verification:** focused browser checks and changed-code review

### AC-3: Non-destructive persistence

- **Given** a user creates and edits a unique active book
- **When** the application restarts
- **Then** the edit remains and seed rows are not duplicated
- **Verification:** local restart check and, when deployed, App Service restart

### AC-4: Passwordless Azure configuration

- **Given** approved infrastructure and bootstrap have completed
- **When** App Service starts in Production
- **Then** the user-assigned identity reads the Key Vault setting and accesses
  Azure SQL without a stored password
- **Verification:** identity/secret metadata checks, HTTPS smoke, and cloud CRUD

### AC-5: Safe blocked-cloud completion

- **Given** policy, quota, role, provider, public-network, or cost approval
  prevents deployment
- **When** the learner completes the no-deployment path
- **Then** local evidence and IaC syntax are complete, the blocker is recorded,
  no control is weakened, and any created group is deleted
- **Verification:** `.azure-lab/no-deployment.md` and `az group exists`

## Non-functional requirements

| ID | Quality | Testable requirement | Verification |
| --- | --- | --- | --- |
| NFR-1 | Reliability | Startup shall not delete or recreate an existing modernized database. | Restart persistence and code search for destructive initialization |
| NFR-2 | Security/privacy | Source and committed artifacts contain no SQL password, token, secret value, or user-agent diagnostic. | Diff and secret review |
| NFR-3 | Maintainability | The application shall have one supported ASP.NET Core host and DI-managed EF Core context. | Project/package and architecture review |
| NFR-4 | Operability | Deployment shall use reviewed what-if, actual outputs, HTTPS smoke, and exact group cleanup. | Azure evidence record |

## Assumptions, dependencies, and risks

| Item | Type | Validation or mitigation |
| --- | --- | --- |
| .NET 10 SDK/runtime and Visual Studio legacy components are available. | Dependency | Lab 00 readiness and baseline build |
| Data is disposable. | Assumption | Human approval; never point at a business database |
| Public Azure endpoints are allowed for the workshop. | Risk | Separate approval; otherwise no-deployment path |
| Role assignment and SQL Entra administrator operations are permitted. | Dependency | What-if/deploy gate; no self-elevation |
| Agent transformations can regress Razor/MVC behavior. | Risk | Incremental builds, manual behavior checks, skeptical review |

## Open questions

None for the reference path. A learner-specific question reopens human approval
when it changes scope, data, security, cost, or acceptance criteria.
