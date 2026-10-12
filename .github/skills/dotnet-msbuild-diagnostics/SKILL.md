---
name: dotnet-msbuild-diagnostics
description: Diagnose NuGet restore, MSBuild, SDK selection, package-reference, framework-target, and .NET test failures or audit dependencies in this monorepo without automatically changing project files.
---

# NuGet and MSBuild diagnostics

Use this skill for either
`legacy-src/dotnet-bookcatalog/shared-legacy-app` or
`capstone-src/api-dotnet`, never both in the same diagnosis.

## Guardrails

- Distinguish the classic .NET Framework 4.8 `packages.config` solution from
  the SDK-style capstone before proposing commands or edits.
- Start read-only. Do not restore, clear caches, update packages, rewrite a
  project, create a database, publish, or deploy without explicit approval.
- Never display authenticated NuGet source credentials or secret MSBuild
  properties. Do not read user-level NuGet configuration contents.
- Do not treat `dotnet` CLI incompatibility with the classic project as proof
  that the project is corrupt; use Visual Studio MSBuild where documented.

## Procedure

1. Read the solution/project files, package declarations, `global.json`, nearest
   README, and complete first error.
2. Inventory the selected root:

   ```powershell
   .\.github\skills\dotnet-msbuild-diagnostics\scripts\inspect-dotnet.ps1 -ProjectRoot legacy-src\dotnet-bookcatalog\shared-legacy-app
   ```

   ```bash
   bash ./.github/skills/dotnet-msbuild-diagnostics/scripts/inspect-dotnet.sh capstone-src/api-dotnet
   ```

3. Classify the failure: SDK/toolset discovery, target framework/reference
   assemblies, NuGet source/restore, package compatibility, MSBuild target,
   compilation, test adapter, or runtime.
4. If execution is approved, use the documented toolchain and smallest command:
   classic `msbuild BookCatalog.sln -restore -p:Configuration=Release`, or
   capstone `dotnet test <test-project> --filter <test>`.
5. For a dependency audit, record package, requested/resolved version,
   declaration file, target framework, compatibility concern, and validation
   needed before an update.

Report evidence, root cause or ranked hypotheses, the smallest proposed change,
and exact validation. Do not implement upgrades unless asked.
