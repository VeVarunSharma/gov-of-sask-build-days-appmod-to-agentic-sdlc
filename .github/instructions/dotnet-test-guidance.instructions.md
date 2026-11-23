---
applyTo: "capstone-src/api-dotnet/tests/**/*.cs"
---

# .NET API test guidance

- Use the test framework and conventions declared in
  `capstone-src/api-dotnet/tests/WorkItems.Api.Tests/WorkItems.Api.Tests.csproj`;
  follow the existing xUnit `[Fact]` and `Assert` patterns.
- Test repository behavior through `InMemoryWorkItemRepository` and its
  `IWorkItemRepository` contract. Inject a controlled `TimeProvider` for
  timestamp behavior; consult `capstone-src/contracts/openapi.yml` when
  testing API response contracts.
- From the repository root, run
  `dotnet test capstone-src/api-dotnet/tests/WorkItems.Api.Tests/WorkItems.Api.Tests.csproj`.
- Keep tests deterministic and isolated with synthetic, in-memory data and
  controlled time. Do not rely on live cloud services, network access,
  databases or LocalDB, production or participant data, or wall-clock sleeps.
- Defer general .NET and MSBuild practices to
  `.github/instructions/dotnet.instructions.md`; keep this file specific to
  test guidance.
