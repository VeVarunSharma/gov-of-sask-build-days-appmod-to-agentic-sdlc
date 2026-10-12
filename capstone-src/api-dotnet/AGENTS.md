# .NET API local guide

Agents should read the repository [root guide](../../AGENTS.md) plus this
nearest local guide; do not assume one file automatically overrides another.

## Scope map

- `WorkItems.slnx` is the solution entry point.
- `src/WorkItems.Api/` contains the .NET 10 minimal API, validation/CORS setup,
  domain model, and thread-safe in-memory repository.
- `tests/WorkItems.Api.Tests/` contains the xUnit repository tests.
- The shared API shape is owned by
  [`../contracts/openapi.yml`](../contracts/openapi.yml).

## Work and validate

Use `capstone-src\api-dotnet` as the working directory:

```powershell
dotnet restore WorkItems.slnx
dotnet build WorkItems.slnx --configuration Release --no-restore --nologo
dotnet test WorkItems.slnx --configuration Release --no-build --nologo
dotnet run --project src\WorkItems.Api
```

There is no standalone lint command; compiler diagnostics plus the Release
build and tests are the configured local gate.

## Boundaries

- Preserve nullable-reference settings, thin endpoints, explicit validation,
  and deterministic repository behavior. In-memory data resets on restart.
- Do not edit generated `bin/` or `obj/` content or commit logs, credentials,
  tokens, connection strings, production data, or participant data.
- Keep secrets out of `appsettings*.json`. Configure URLs through
  `--urls`/`ASPNETCORE_URLS` and comma-separated browser origins through
  `Cors__AllowedOrigins`; do not broaden CORS without approval.

## More detail

Follow the [.NET instructions](../../.github/instructions/dotnet.instructions.md),
the [capstone starter guide](../README.md), and the
[React plus API pathway](../../labs/07-capstone/pathways/02-public-service-app.md).
Keep approved requirements under [specifications](../../specs/README.md).
Escalate shared-contract, React, deployment, or multi-root changes to the root
guide and read every affected local guide.
