# Change specification: Show generic error pages instead of detailed errors

## Metadata

- **Owner:** @mahmedGos (Lab 01, .NET track)
- **Status:** Approved
- **Source root:** `legacy-src/dotnet-bookcatalog/shared-legacy-app`
- **Related issue:** Not created

## Problem and outcomes

### Problem

The BookCatalog web app shows full ASP.NET error detail to every user. Paths
below are relative to the source root.

- `src/BookCatalog.Web/Web.config` sets `<customErrors mode="Off" />` and
  `<compilation debug="true" targetFramework="4.8" />` in the only
  configuration file. There is no `Web.Release.config` transform. Any
  unhandled exception therefore shows the ASP.NET "Server Error in
  Application" page to local and remote users. That page includes the
  exception type, message, stack trace, source excerpts, and framework
  version.
- `src/BookCatalog.Web/App_Start/FilterConfig.cs` (`RegisterGlobalFilters`)
  registers `HandleErrorAttribute`. That attribute has no effect while custom
  errors are off. No `Error` view exists either: `Views/Shared/` contains only
  `_Layout.cshtml`, and `src/BookCatalog.Web/BookCatalog.Web.csproj` lists no
  error view in its `Content Include` items.
- `src/BookCatalog.Web/Controllers/BooksController.cs` returns
  `HttpNotFound()` from `Details`, `Edit`, and `Delete` (GET) when
  `db.Books.Find(id)` returns `null`. `src/BookCatalog.Web/App_Start/RouteConfig.cs`
  maps only `{controller}/{action}/{id}`, so unknown URLs fall through to the
  default ASP.NET/IIS 404 pages.

Affected people:

- catalog users, who see confusing technical pages;
- operators and security reviewers, who must treat stack traces and version
  details as information disclosure; and
- Lab 04 modernizers, who would otherwise carry this risk forward.

### Desired outcomes

1. No user, local or remote, sees exception or server diagnostic detail when a
   request fails with an unhandled error (500) or a not-found result (404).
2. Users see a generic page that matches the site layout and links back to the
   catalog (`/Books`).
3. Failed responses keep their real HTTP status code (404 or 500). They are not
   redirected and do not report success.
4. The application no longer compiles in debug mode at runtime.

### Success measures

- Every failure probe in the acceptance criteria returns the expected status
  code. None of them returns a body containing a diagnostic marker. The
  markers are `Server Error in`, `Stack Trace`, `Exception`,
  `Version Information`, `Source Error`, and local file paths such as `C:\`.
- Every normal-behavior probe in AC-7 matches the pre-change behavior.

## Functional requirements

| ID | Requirement | Evidence or rationale |
| --- | --- | --- |
| FR-1 | When a request throws an unhandled exception, the app shall return HTTP 500 with a generic error page. | `Web.config` `customErrors mode="Off"`; `FilterConfig.RegisterGlobalFilters` |
| FR-2 | When an action returns `HttpNotFound()`, or no route, file, or handler matches the URL, the app shall return HTTP 404 with a generic not-found page. | `BooksController.Details/Edit/Delete`; `RouteConfig.RegisterRoutes` |
| FR-3 | No error response shall contain exception type, message, stack trace, source excerpt, file path, or framework/server version detail. | Decision D4 |
| FR-4 | Generic pages shall contain a short message and a link to `/Books`. They shall not show a reference ID or any request-specific data. | Decision D4 |
| FR-5 | FR-1 to FR-4 shall apply to requests from localhost as well as remote requests. | Decision D2 |
| FR-6 | Error responses shall be returned directly with their original status code. There shall be no 3xx redirect to an error URL. | Decision D7 |
| FR-7 | Runtime compilation shall not run in debug mode. | `Web.config` `compilation debug="true"`; decision D5 |
| FR-8 | Successful catalog behavior shall be unchanged. This covers active-only, title-ordered listing; Create, Edit, and Delete flows; inline validation messages; and routes. | `BooksController.Index` and the POST actions |

## Constraints and out of scope

### Constraints

- **Allowed paths:**
    - `legacy-src/dotnet-bookcatalog/shared-legacy-app/src/BookCatalog.Web/Web.config`
    - `legacy-src/dotnet-bookcatalog/shared-legacy-app/src/BookCatalog.Web/Views/Shared/`:
    **new** files only. The existing `_Layout.cshtml` must not change.
    - `legacy-src/dotnet-bookcatalog/shared-legacy-app/src/BookCatalog.Web/BookCatalog.Web.csproj`:
    only added `<Content Include="Views\Shared\..." />` items for the new files.
- **Primary validation command:** run
  `msbuild BookCatalog.sln -restore -p:Configuration=Release` from the source
  root in Developer PowerShell for Visual Studio.
- **Required supplemental evidence:** run the IIS Express + LocalDB HTTP checks
  in the acceptance criteria. A successful build alone does not prove this
  change (decision D8).
- **Compatibility:** preserve the following unchanged: routes, controllers,
  models, `Views/Web.config`, `FilterConfig.cs`, `Global.asax.cs`, the
  connection string, the classic csproj format, and `packages.config`. Error
  pages may use the existing layout.
- **Dependencies:** add no NuGet package, assembly reference, binding redirect,
  or `packages/` change.
- **Data and security:**
    - Do not add secrets or real data.
    - Error pages must not read the database, the model, `ViewBag`, request
    headers, query values, or exception data.
    - Add no logging or telemetry (decision D4).

### Exclusions (out of scope)

- Logging, telemetry, correlation or reference IDs, and health endpoints.
- Custom handling for statuses other than 404 and 500 (for example 400, 401,
  403, 414).
- `Web.Release.config` or `Web.Debug.config` transforms.
- Changes to controllers, models, routes, or filters, and controller-based
  error actions.
- ASP.NET Core or EF Core migration, styling or layout cleanup, and Azure or
  hosting configuration.
- Fixing the underlying causes of errors, such as non-numeric `id` binding.

## Edge cases

| Type | Condition | Expected behavior |
| --- | --- | --- |
| Normal | `GET /Books` with seeded data | HTTP 200. Only active books appear, ordered by title, as today. |
| Normal | Create, Edit, or Delete a valid book | Same redirects and persisted results as today. |
| Normal | POST Create with an empty Title | The form is shown again with inline validation messages, not an error page. |
| Failure | Unhandled exception, e.g. `GET /Books/Details/abc` | HTTP 500 and the generic page, with no diagnostic detail. |
| Failure | The task-owned LocalDB database in a disposable app copy is unavailable during a catalog request | HTTP 500 and the generic page. The page renders without database access. |
| Failure | POST Edit without an anti-forgery token | HTTP 500 and the generic page, with no diagnostic detail. |
| Failure | The error page itself cannot render | No detailed output. Treat this as a stop condition. |
| Boundary | `GET /Books/Details/999999` (id does not exist) | HTTP 404 and the generic not-found page. |
| Boundary | `GET /Nope/Nothing` (unknown controller) | HTTP 404 and the generic not-found page. |
| Boundary | `GET /Content/missing.css` (missing static file) | HTTP 404 with no server or version detail. |
| Compatibility | Requests from localhost via IIS Express | Same generic pages as remote requests. |
| Compatibility | Lab 04 HTTP smoke check expects 200 from the app root | Still returns 200. |

## Acceptance criteria

All HTTP checks use IIS Express with the app running against disposable
LocalDB data. They request the site's base URL (for example
`http://localhost:<port>`) from the same machine with
`Invoke-WebRequest -MaximumRedirection 0 -SkipHttpErrorCheck` (PowerShell 7),
or the equivalent catch in PowerShell 5.1, and record the status code and the
diagnostic-marker search for each probe.

### AC-1: Unhandled exception shows a generic 500 page

- **Given** the app is running
- **When** a user requests `/Books/Details/abc`
- **Then** the status is 500. The body contains a generic message and a link to
  `/Books`, and contains none of the diagnostic markers from the success
  measures.
- **Verification:** HTTP probe (status and marker search) and a browser check.

### AC-2: Missing record shows a generic 404 page

- **Given** no book has id 999999
- **When** a user requests `/Books/Details/999999`, `/Books/Edit/999999`, or
  `/Books/Delete/999999`
- **Then** each status is 404 and each body contains the generic not-found
  content with no diagnostic markers.
- **Verification:** One HTTP probe per URL.

### AC-3: Unknown URL shows a generic 404 page

- **Given** the app is running
- **When** a user requests `/Nope/Nothing` and `/Content/missing.css`
- **Then** each status is 404 and no diagnostic markers appear. `/Nope/Nothing`
  shows the generic not-found content.
- **Verification:** One HTTP probe per URL.

### AC-4: Errors are not redirected

- **Given** the probes in AC-1 to AC-3
- **When** each probe runs with redirects disabled
- **Then** no first response is 3xx, and no `Location` header points to an
  error URL.
- **Verification:** Record the status code and `Location` header for each
  probe.

### AC-5: Localhost sees the generic pages

- **Given** the probes run from localhost against IIS Express
- **When** AC-1 to AC-3 are evaluated
- **Then** they pass without any remote host or configuration change.
- **Verification:** The probes in AC-1 to AC-3 are localhost requests.

### AC-6: The error page does not need the database

- **Given** a disposable copy of the app is configured to use a task-owned
  LocalDB instance and synthetic data only
- **When** the task-owned database becomes unavailable and a user requests
  `/Books`
- **Then** the status is 500 and the generic page renders with no diagnostic
  markers.
- **Verification:** In the disposable app copy only, set its temporary
  connection string to the task-owned instance and populate it with synthetic
  data. Confirm the app is not using the configured shared `MSSQLLocalDB`
  instance before making the task-owned database unavailable. Record the
  isolation method, instance name, HTTP status, and response. Never connect to
  or stop a live or shared database. If the task-owned instance cannot be
  isolated and identified, do not run this check.

### AC-7: Normal catalog behavior is preserved

- **Given** the seeded catalog, including the inactive "The Matrix: The
  Shooting Script" record
- **When** a user opens `/Books`, creates, edits, and deletes a synthetic book,
  and submits Create with an empty Title
- **Then** `/Books` returns 200 with only active books in title order. The CRUD
  round-trip succeeds. The invalid Create shows inline validation messages
  instead of an error page.
- **Verification:** Browser check recorded with observed results.

### AC-8: Debug compilation is off

- **Given** the change is applied
- **When** a reviewer reads `src/BookCatalog.Web/Web.config`
- **Then** the `system.web/compilation` element does not enable debug mode
- **Verification:** Diff review.

### AC-9: Build succeeds

- **Given** the documented .NET Framework 4.8 and Visual Studio build
  prerequisites
- **When** the primary validation command runs from the source root
- **Then** it exits 0 with no build errors
- **Verification:** Record the command, the exit status, and the build summary.

### AC-10: Diff stays in scope

- **Given** an implementation branch based on the implementation-baseline
  commit identified in the issue's execution boundary
- **When** a reviewer compares that baseline with the implementation branch
  and inspects staged, unstaged, and untracked changes
- **Then** only allowed implementation paths appear. The csproj diff contains
  only added `Content Include` items for the new `Views/Shared/` files. No
  generated `App_Data` database files are committed.
- **Verification:** The issue must identify both the reviewed specification
  commit and a separate implementation-baseline commit containing its approval
  record. Before implementation, review the specification diff between those
  commits and stop if it contains changes beyond the approval record. Set
  `$implementationBaseline` to the baseline SHA from the issue. Verify it is
  an ancestor with `git merge-base --is-ancestor $implementationBaseline HEAD`;
  stop if it is not. Review `git diff --name-only $implementationBaseline HEAD`,
  `git diff --name-only`, `git diff --cached --name-only`, and
  `git status --short --untracked-files=all`, along with the actual diffs.

## Non-functional requirements

| ID | Quality | Testable requirement | Verification |
| --- | --- | --- | --- |
| NFR-1 | Security/privacy | Error responses disclose no exception, path, version, or request data. | Marker search in AC-1 to AC-3 and AC-6 |
| NFR-2 | Reliability | Error pages render with the database unavailable. | AC-6 |
| NFR-3 | Maintainability | No new package, reference, binding redirect, controller, or filter. | Diff review of the csproj, `packages.config`, and `Web.config` |
| NFR-4 | Scope | The diff is limited to the allowed paths. | AC-10 |

## Assumptions, dependencies, and risks

| Item | Type | Validation or mitigation |
| --- | --- | --- |
| `/Books/Details/abc` raises an unhandled exception (non-nullable `int id` binding), which gives a no-code 500 trigger. | Assumption | Confirm before changes, when collecting implementation baseline evidence. If it does not produce a 500, stop and pick a different documented trigger with reviewer approval. |
| MVC `HandleErrorAttribute` covers unhandled exceptions only. `HttpNotFound()` and unmatched URLs need a separate mechanism within the allowed paths. | Risk | Stop if the 404 requirements cannot be met without changing a disallowed path. |
| `Views/Web.config` registers `BlockViewHandler` for every path under `Views/`, so files there cannot be requested directly. | Risk | The chosen mechanism must work with this. Stop rather than edit `Views/Web.config` or move files outside the allowed paths. |
| The configured `MSSQLLocalDB` instance may be shared with other work. | Risk | The owner approved a disposable app copy with a temporary connection string to a task-owned LocalDB instance, without accessing the live database (2026-11-23). Never connect to or stop the shared instance for AC-6. |
| Running the app creates `App_Data\BookCatalog.mdf`, which is not covered by `.gitignore`. | Risk | Never commit, hand-edit, or pre-create MDF/LDF files (`legacy-src/dotnet-bookcatalog/AGENTS.md`). Confirm this with AC-10. |
| Turning off debug compilation also affects local F5 debugging, because there is no config transform. | Accepted risk | Accepted by the owner (decision D5). Developers can still debug by temporarily changing the setting locally. That temporary edit must not be committed. |
| Visual Studio MSBuild, the .NET Framework 4.8 targeting pack, IIS Express, and SQL Server LocalDB are available. | Dependency | Observed for the build. Confirm IIS Express and LocalDB before the AC HTTP checks. |

## Plan-mode review checkpoint

### Evidence

- **Current behavior:**
    - `src/BookCatalog.Web/Web.config` sets `customErrors mode="Off"` and
    `compilation debug="true"`.
    - `src/BookCatalog.Web/App_Start/FilterConfig.cs:RegisterGlobalFilters`
    adds `HandleErrorAttribute`, but no `Error` view exists.
    - `src/BookCatalog.Web/Controllers/BooksController.cs:Details/Edit/Delete`
    return `HttpNotFound()`.
    - `src/BookCatalog.Web/App_Start/RouteConfig.cs:RegisterRoutes` defines a
    single default route.
    - `src/BookCatalog.Web/Views/Web.config` blocks direct requests to
    `Views/`.
- **Existing tests:** None found. The solution has no test project
  (`legacy-src/dotnet-bookcatalog/AGENTS.md`).
- **Baseline validation evidence:** On 2026-11-23, from the source root, the
  Visual Studio 18 `MSBuild.exe BookCatalog.sln -restore -p:Configuration=Release`
  exited 0. Restore reported "Nothing to do" and the build produced
  `BookCatalog.Web -> src\BookCatalog.Web\bin\BookCatalog.Web.dll`.
  `git status --short` was clean afterward. `msbuild` is not on the default
  PATH, so use Developer PowerShell. The runtime HTTP baseline was not
  collected during planning, to avoid creating LocalDB files.

### Recorded decisions

| ID | Decision (owner: @mahmedGos) |
| --- | --- |
| D1 | Target gap: stop exposing detailed errors. |
| D2 | Generic pages for everyone, including localhost. |
| D3 | Cover unhandled 500s and 404s, both `HttpNotFound()` and unknown URLs. |
| D4 | Generic message and a catalog link only. No exception data, reference ID, or new logging. |
| D5 | Turning off debug compilation is in scope. |
| D6 | Editable: `Web.config`, new files in `Views/Shared/`, and csproj `Content Include` additions only. |
| D7 | Keep the original status codes, with no redirect. |
| D8 | The build is the primary gate. The IIS Express + LocalDB HTTP checks are required supplemental evidence. |
| D9 | AC-6 may use a disposable app copy and a task-owned LocalDB instance with a temporary connection string, without accessing the live database. Approved by @mahmedGos on 2026-11-23. |

### Unresolved questions

- None.

### Pre-implementation evidence check

- Confirm that `/Books/Details/abc` produces an unhandled 500 using a
  disposable app copy and synthetic data before implementation. If it does
  not, stop and request reviewer guidance rather than selecting another
  trigger.

### Boundary and validation review

- [x] Evidence citations were checked against the repository.
- [x] Allowed paths include all anticipated implementation and test changes and
      nothing unrelated.
- [x] The primary validation command is safe, non-interactive, and runnable
      from the stated source root.
- [x] Acceptance criteria cover the required normal, failure, boundary, and
      compatibility behavior.
- [x] Exclusions prevent unrelated modernization or cleanup.

### Stop conditions

Stop and request human guidance if:

- repository evidence contradicts this specification, for example if an
  `Error` view or config transform already exists, or `/Books/Details/abc` does
  not produce a 500;
- an unresolved question could materially change behavior or scope;
- meeting a criterion requires editing a path outside the allowed paths. This
  includes controllers, `FilterConfig.cs`, `Global.asax.cs`,
  `Views/Web.config`, `_Layout.cshtml`, routes, or models;
- status codes cannot be kept without a redirect, or an error page needs
  database, model, request, or exception data;
- any probe shows diagnostic detail, including when the error page itself
  fails;
- the baseline build fails before changes, or the primary validation fails
  after them;
- Visual Studio MSBuild, IIS Express, or LocalDB is unavailable, so required
  evidence cannot be collected (record the exact missing prerequisite);
- the disposable AC-6 app copy cannot be verified as using only its task-owned
  LocalDB instance and synthetic data;
- a secret, credential, real data, Azure or production resource, package or
  reference change, committed connection-string change, or destructive
  database action is required (for example deleting an MDF or forcing
  re-creation). The temporary connection-string change in the disposable
  AC-6 app copy is the only approved exception; or
- implementation or validation cannot satisfy the acceptance criteria without
  expanding the approved contract.

### Human approval

- [x] I reviewed the evidence, unresolved questions, allowed paths, acceptance
      criteria, validation command, exclusions, risks, and stop conditions.
- **Reviewer:** @mahmedGos
- **Approval date:** 2026-11-23
- **Approved specification commit:** `314588995a50569e6451ada56f10f843589e9f7c`

The previous specification revision at
`783d891545c4fffebaa38360018bc4bb4810ba95` was recorded as reviewed by
@mahmedGos on 2026-11-23. This AC-10 revision was approved on 2026-11-23.

Change **Status** to `Approved` only after the checkbox is selected and the
reviewer, date, and commit fields are complete. Planning approval authorizes
issue preparation, not implementation.
