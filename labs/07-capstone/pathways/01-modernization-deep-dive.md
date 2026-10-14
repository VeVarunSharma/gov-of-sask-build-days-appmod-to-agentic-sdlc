# Pathway A: Deepen Java or .NET modernization

Extend the application you selected in Lab 04. Do not restart the migration,
switch language tracks, or make a broad platform rewrite. Choose one
participant-valued improvement that can be accepted and validated independently.

## Good slices

- add one bounded user journey with validation and tests;
- remove one remaining legacy dependency behind an approved replacement;
- improve health, diagnostics, or operational configuration;
- strengthen accessibility, error handling, or resilience;
- add a safe persistence or integration boundary using synthetic data; or
- close one documented modernization risk with measurable evidence.

The domain remains participant-selected. Do not add high-stakes eligibility or
decision logic, and do not connect to a real Government of Saskatchewan system.

## Plan

1. Use your existing Lab 04 source root:
   `legacy-src\java-asset-manager` **or**
   `legacy-src\dotnet-bookcatalog\shared-legacy-app`.
2. Baseline the current build and tests before editing.
3. Add the capstone slice to an approved specification under
   `specs/capstone/`.
4. Record behavior to preserve, changed behavior, allowed paths, exclusions,
   data rules, and stop conditions.
5. Ask the read-only capstone review agent to challenge scope and evidence.
6. Implement in the smallest coherent increments and validate after each one.

Do not change the other language track, replace a working architecture merely
for novelty, migrate real data, or mix Azure provisioning into local feature
work.

## Challenge choices

### Beginner

- Add one tested validation, query, display, or error-handling improvement.
- Preserve all existing accepted behavior.
- Record a before/after result and the authoritative build command.

### Intermediate

- Add a feature across UI/API/data boundaries or replace one legacy
  integration behind a testable interface.
- Add automated negative-path and restart/persistence coverage.
- Update operational documentation and the selected track's instructions.

### Advanced

- Add least-privilege cloud-ready configuration, resilience, observability, or
  a guarded `gh-aw` verification workflow.
- Include threat-model and failure-mode evidence.
- Prove rollback or no-op behavior without weakening an existing safeguard.

## Required validation

For the modernized Java reactor, run from the repository root:

```powershell
.\legacy-src\java-asset-manager\mvnw.cmd -B -ntp `
  -f .\legacy-src\java-asset-manager\pom.xml clean verify
```

For the modernized .NET solution, use the variables and commands from the
[Lab 04 local verification guide](../../04-app-modernization/dotnet/02-execute-verify-local.md).
At minimum, run:

```powershell
$source = 'legacy-src\dotnet-bookcatalog\shared-legacy-app'
dotnet restore $source\BookCatalog.sln
dotnet build $source\BookCatalog.sln -c Release --no-restore
dotnet test $source\BookCatalog.sln -c Release --no-build
```

If the modernized solution has no test project, the final command may report no
tests. Record that honestly and execute the documented HTTP, CRUD, validation,
and restart checks; do not represent manual checks as automated tests.

For either track:

```powershell
git diff --check
git diff --name-only
```

The gate passes only when the selected build succeeds, affected tests pass,
acceptance behavior is observed, and the diff stays inside approved paths.

## Optional combinations

- Use [Pathway B](02-public-service-app.md) to build a separate React
  experience only when the API boundary is explicit and testable.
- Use [Pathway C](03-agentic-workflow.md) to automate a recurring validation or
  review pain point.
- Follow the selected Lab 04 Azure section for deployment. Do not invent a
  second deployment path during the capstone.
