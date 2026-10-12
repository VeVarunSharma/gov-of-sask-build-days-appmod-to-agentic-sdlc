# ADR 0001: single-host .NET 10 target for BookCatalog

- **Status:** Reference accepted
- **Date:** 2026-10-10
- **Decision owners:** Workshop application team
- **Related specification:** [modernization-specification.md](modernization-specification.md)

## Context

BookCatalog is one small MVC 5 web project on .NET Framework 4.8 with EF6 and
disposable LocalDB data. It has no separate service boundary, authentication
system, production data-transfer requirement, or evidence that requires a
gradual route-by-route cutover. The approved Azure target is Linux App Service
with Azure SQL, Key Vault, and a user-assigned managed identity.

## Decision drivers

1. Preserve catalog behavior with the fewest temporary architectures.
2. Remove unsupported System.Web and EF6 dependencies.
3. Keep data handling explicit and safe for a disposable sample.
4. Make local validation precede any cloud cost or permission.
5. Keep rollback and diagnosis understandable within a workshop.

## Options considered

### Option A: one in-place ASP.NET Core MVC host

- **Benefits:** Direct .NET 10 target; no proxy or dual-host operations; simple
  route, deployment, configuration, and cleanup model; fits the small app and
  disposable data.
- **Costs and risks:** A larger one-time application diff; Razor, controller,
  hosting, and EF changes must converge before the complete app runs.

### Option B: side-by-side ASP.NET Core host with YARP/System.Web adapters

- **Benefits:** Routes could move gradually and the legacy host could remain
  available during a long migration.
- **Costs and risks:** Two hosts, proxy ownership, temporary compatibility
  packages, shared-data decisions, more deployment surfaces, and cleanup burden
  with no repository evidence that the sample needs them.

### Option C: keep MVC 5/EF6 and deploy the legacy host

- **Benefits:** Smallest source diff.
- **Costs and risks:** Does not meet the .NET 10/Linux target, retains
  System.Web/classic project constraints, and avoids rather than completes the
  modernization.

## Decision

Choose Option A. Convert the existing application in place to one SDK-style
ASP.NET Core MVC project targeting .NET 10. Replace EF6 with EF Core SQL Server,
use a new disposable `BookCatalogModernizedLab` database, and seed it through
the initial migration. Do not transfer old MDF records.

Use Development integrated authentication locally. In Azure, bootstrap schema
with the approved administrator, grant the user-assigned runtime identity CRUD
on `dbo.Books`, and load the passwordless connection setting from Key Vault.

## Consequences

- **Positive:** One supported runtime, one host, one route surface, one EF
  model, and a direct Linux App Service deployment.
- **Negative:** The upgrade must change project, host, MVC, Razor, configuration,
  and data access in a coordinated sequence.
- **Follow-up:** Build after each bounded increment; preserve a pre-execution
  commit; complete local behavior/persistence checks before Azure.

## Validation

The decision works when the Release build passes, `/Books` and CRUD/validation
behavior match the approved specification, a changed record survives restart,
the legacy framework/package surface is gone, and the Azure or no-deployment
path completes safely. Revisit the decision if later evidence introduces
non-disposable production data, route-by-route availability requirements, or a
separate legacy application that cannot cut over with this project.
