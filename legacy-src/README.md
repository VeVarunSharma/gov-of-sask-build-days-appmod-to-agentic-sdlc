# Legacy source applications

This directory contains the imported starting-state applications used by the
modernization lab:

- [Java Asset Manager](java-asset-manager/) for the Java track. It supports
  Windows, macOS, and Linux and has a
  [documented upstream test defect](../facilitator/recovery/java/known-upstream-test.md).
- [.NET BookCatalog](dotnet-bookcatalog/) for the .NET track. Its classic
  ASP.NET MVC 5 baseline requires Windows, Visual Studio/MSBuild, .NET
  Framework 4.8, and LocalDB.

Participants choose one track. Preserve each application's upstream attribution
and follow the selected
[Lab 04 modernization guide](../labs/04-app-modernization/). Do not treat this
directory as a capstone output location or copy changes between tracks.

See [third-party notices](../THIRD_PARTY_NOTICES.md) and the
[pinned source manifest](../UPSTREAM_SOURCES.yml) for provenance and licenses.
