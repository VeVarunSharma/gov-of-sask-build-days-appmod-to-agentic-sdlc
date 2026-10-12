# .NET example: remove request-specific browser diagnostics

> Reference example only. It does not authorize changes to the imported source.

## Metadata

- **Owner:** Workshop application team
- **Status:** Reference example — not approved for execution
- **Source root:** `legacy-src/dotnet-bookcatalog/shared-legacy-app`
- **Related issue:** Not created

## Problem and outcomes

`src/BookCatalog.Web/Controllers/BooksController.cs` reads
`HttpContext.Request.UserAgent` in `Index`, and
`src/BookCatalog.Web/Views/Books/Index.cshtml` renders it. Browser diagnostics
are unrelated to catalog behavior, expose request metadata in the UI, and add
an avoidable `System.Web` coupling to the action being carried into
modernization.

The change should remove this diagnostic while preserving the active-book list.
Success means the page no longer renders request user-agent data and catalog
ordering and actions are unchanged.

## Functional requirements

- **FR-1:** Return active books ordered by title as the index action does today.
- **FR-2:** Do not read or pass the request user-agent value.
- **FR-3:** Do not render a browser/user-agent diagnostic block.

## Constraints and out of scope

- **Allowed paths:**
  - `legacy-src/dotnet-bookcatalog/shared-legacy-app/src/BookCatalog.Web/Controllers/BooksController.cs`
  - `legacy-src/dotnet-bookcatalog/shared-legacy-app/src/BookCatalog.Web/Views/Books/Index.cshtml`
- **Primary validation command:**
  `msbuild BookCatalog.sln -restore -p:Configuration=Release`
- Preserve routes, model types, database behavior, list columns, and CRUD links.
- Add no package or configuration change.

### Exclusions (out of scope)

- ASP.NET Core migration, styling cleanup, telemetry, broader `System.Web`
  removal, package changes, and configuration changes.

## Edge cases

| Type | Condition | Expected behavior |
| --- | --- | --- |
| Normal | Active books exist | Only active books appear in title order with current actions. |
| Failure | Request has no user-agent header | The page renders without a diagnostic or error. |
| Boundary | Request has an empty or unusually long user-agent value | The value and diagnostic label are never rendered. |
| Compatibility | Existing routes, models, columns, and CRUD links | Their behavior remains unchanged. |

## Acceptance criteria

### AC-1: Catalog behavior is preserved

- **Given** active and inactive books exist
- **When** a user opens `/Books`
- **Then** only active books appear, ordered by title, with existing actions
  available
- **Verification:** Focused browser check with active and inactive records

### AC-2: Browser diagnostic is removed

- **Given** a request includes any `User-Agent` header
- **When** a user opens `/Books`
- **Then** the response does not display that value or a `YOUR BROWSER` label
- **Verification:** Browser check with a distinctive user-agent value and a
  source diff confirming the request value is not read

### AC-3: Build remains valid

- **Given** documented .NET Framework build prerequisites are installed
- **When** the primary validation command runs from the source root
- **Then** restore and build complete successfully
- **Verification:** Record the command, exit status, and concise build result

## Non-functional requirements

- **NFR-1:** Add no replacement request metadata to logs, model state, or view
  data. Verify by diff review.
- **NFR-2:** Introduce no dependency or public contract. Review project and API
  diffs.
- **NFR-3:** Limit the diff to the two allowed files. Verify with
  `git diff --name-only`.

## Assumptions, dependencies, and risks

An undocumented demonstration may rely on the diagnostic. Repository evidence
shows no functional dependency; human review should confirm its removal before
automation. No fallback diagnostic is added.

Deleting the diagnostic is preferred to abstracting it because no catalog
requirement supports preserving the behavior. Any future telemetry needs a
separate specification with explicit privacy and operational requirements.

## Plan-mode review checkpoint

### Evidence

- **Current behavior:**
  `legacy-src/dotnet-bookcatalog/shared-legacy-app/src/BookCatalog.Web/Controllers/BooksController.cs`
  reads `HttpContext.Request.UserAgent`, and
  `legacy-src/dotnet-bookcatalog/shared-legacy-app/src/BookCatalog.Web/Views/Books/Index.cshtml`
  renders the value.
- **Existing tests:** Automated coverage for this view behavior must be
  confirmed in the source root.
- **Baseline validation evidence:** Not recorded for this non-executable
  reference example; a real specification must record the command result or an
  exact prerequisite blocker before approval.

### Unresolved questions

- None in the illustrative scope. A real planning session must verify test
  coverage and the baseline result.

### Boundary and validation review

- [x] Evidence and the intended behavior are linked.
- [x] Allowed paths contain the anticipated implementation.
- [x] One primary validation command is stated.
- [x] Acceptance criteria cover normal, failure, boundary, and compatibility
      behavior.
- [x] Exclusions prevent broader migration, telemetry, and cleanup.

### Stop conditions

Stop and request human guidance if repository evidence differs, validation
cannot run, another path, package, or configuration must change, the diagnostic
has a functional consumer, credentials or production resources are needed, or
catalog filtering, ordering, routes, models, columns, or actions would change.

### Human approval

- [ ] Execution approval is intentionally not granted for this reference.
- **Reviewer:** Not applicable — reference example
- **Approval date:** Not applicable — reference example
- **Approved specification commit:** Not applicable — reference example
