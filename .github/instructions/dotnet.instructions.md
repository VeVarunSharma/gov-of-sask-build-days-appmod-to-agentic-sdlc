---
applyTo: "legacy-src/dotnet-bookcatalog/**/*.cs,legacy-src/dotnet-bookcatalog/**/*.csproj,legacy-src/dotnet-bookcatalog/**/*.config,capstone-src/api-dotnet/**/*.cs,capstone-src/api-dotnet/**/*.csproj"
---

# .NET and MSBuild

- Determine whether the file belongs to the classic ASP.NET MVC 5 baseline or
  the SDK-style capstone API. Do not apply ASP.NET Core patterns to the classic
  project unless an approved modernization plan calls for that migration.
- Preserve .NET Framework 4.8, `packages.config`, EF6, and the existing solution
  layout in `legacy-src/dotnet-bookcatalog/shared-legacy-app` during ordinary
  maintenance. Avoid hand-editing generated `obj/`, `bin/`, or package content.
- Keep controllers thin, preserve model validation, and make database behavior
  explicit. Never point the sample at a production or business database.
- Add or update tests in the owning test project when one exists. Tests must be
  deterministic and must not depend on IIS, LocalDB, Azure, or the network
  unless explicitly classified as integration tests.
- Validate the classic baseline with
  `msbuild BookCatalog.sln -restore -p:Configuration=Release` from
  `legacy-src/dotnet-bookcatalog/shared-legacy-app`. Validate the capstone API
  with `dotnet test capstone-src/api-dotnet/tests/WorkItems.Api.Tests/WorkItems.Api.Tests.csproj`.
- Preserve nullable-reference and analyzer settings from the nearest project
  file rather than assuming repository-wide defaults.
