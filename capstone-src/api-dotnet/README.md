# Work items ASP.NET Core API

.NET 10 minimal API for the capstone starter. It implements the shared
[`OpenAPI contract`](../contracts/openapi.yml) with an in-memory repository.
Data resets when the process restarts.

Run from the repository root:

```powershell
dotnet run --project capstone-src\api-dotnet\src\WorkItems.Api
```

Validate from `capstone-src\api-dotnet`:

```powershell
dotnet restore WorkItems.slnx
dotnet build WorkItems.slnx --configuration Release --no-restore --nologo
dotnet test WorkItems.slnx --configuration Release --no-build --nologo
```

The local launch profile listens on `http://localhost:8081`. Configure allowed
browser origins with comma-separated `Cors__AllowedOrigins`. Keep server-side
validation and update the contract, React client, and tests when changing the
resource shape.

See the parent [capstone starter guide](../README.md) for safety, container, and
cross-project instructions.
