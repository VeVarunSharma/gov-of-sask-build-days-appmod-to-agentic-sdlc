# Lab 04: Application modernization

Choose one first-class track:

- [Java Asset Manager](java/) — supported on Windows, macOS, or Linux.
- [.NET BookCatalog](dotnet/) — the classic baseline requires Windows,
  Visual Studio/MSBuild, .NET Framework 4.8, and LocalDB.

Both tracks extend the contract-first workflow from
[Lab 01](../01-spec-driven-development/README.md). GitHub Copilot Plan mode and
a human-approved, durable repository specification define intent, constraints,
acceptance criteria, allowed paths, validation, and stop conditions before
modernization tooling runs. `modernize assess` then contributes repository
evidence, and `modernize plan create` turns the approved contract plus that
evidence into a specialized technical modernization plan.

The required sequence is: approved specification -> `modernize assess` ->
human-reviewed Modernize plan -> `upgrade-agent` execution.

A generated modernization plan is a proposal, not approval and not a second
specification framework. Reconcile it against the durable specification before
execution. Review its scope, allowed paths, security and data handling, cost,
validation, stop conditions, deployment boundaries, and cleanup. Resolve every
conflict in favor of the approved specification or revise and reapprove that
specification.

Modernize may generate a plan task file as tool output. That file is part of
the reviewed technical proposal; it does not make the optional repository ADR,
test-strategy, or implementation-task-breakdown templates required.

The `upgrade-agent` plugin in the GitHub Copilot app performs the reviewed
runtime/framework execution. Participants approve bounded increments and
inspect commands and diffs; the plugin does not redefine requirements. Both
tracks preserve language-specific tooling and provide a local/no-deployment
completion path. Complete only the selected track and do not edit the other
imported application.

Azure deployment is optional. Each track documents a local/no-deployment
completion path and requires exact cleanup evidence when Azure resources were
created.
