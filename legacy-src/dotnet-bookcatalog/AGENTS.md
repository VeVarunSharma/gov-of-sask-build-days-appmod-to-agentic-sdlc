# BookCatalog local guide

Agents should read the repository [root guide](../../AGENTS.md) plus this
nearest local guide; do not assume one file automatically overrides another.

## Scope map

- `shared-legacy-app/BookCatalog.sln` is the authoritative ASP.NET MVC 5,
  .NET Framework 4.8, EF6 solution.
- `shared-legacy-app/src/BookCatalog.Web/` contains controllers, models, views,
  configuration, and startup.
- `examples/azure/` is optional deployment material, not baseline application
  setup. Root Node files support imported workshop content, not the web app.

## Work and validate

Use `legacy-src\dotnet-bookcatalog\shared-legacy-app` as the working directory:

```powershell
nuget restore BookCatalog.sln -PackagesDirectory packages -NonInteractive
msbuild BookCatalog.sln -restore -p:Configuration=Release
```

The classic baseline requires Windows, Visual Studio MSBuild/web tooling,
.NET Framework 4.8 targeting tools, IIS Express, and SQL Server LocalDB.
There is no automated test project or standalone lint target. A successful
build is not a full pass: run the documented IIS Express/LocalDB CRUD smoke
check when the environment supports it and report any missing prerequisite.

## Boundaries

- Preserve classic project format, `packages.config`, EF6, solution layout,
  attribution, and unrelated behavior until an approved modernization plan
  changes them.
- Do not hand-edit `packages/`, `bin/`, `obj/`, generated database files, or
  create an empty MDF as a startup workaround.
- Keep the integrated-authentication sample pointed only at disposable
  LocalDB data. Never add secrets or connect it to a business database.
  Azure examples require separate scope, access, cost, and cleanup approval.

## More detail

Follow the [.NET instructions](../../.github/instructions/dotnet.instructions.md)
and, for Azure examples, the
[infrastructure instructions](../../.github/instructions/infrastructure.instructions.md).
Start with the [.NET modernization lab](../../labs/04-app-modernization/dotnet/README.md)
and its linked steps; use the [specification guidance](../../specs/README.md)
for approved scope. Escalate cross-track, automation, or repository-wide
changes to the root guide.
