# Validation scripts

Baseline wrappers resolve paths relative to their own location, so they can be
launched from any working directory.

```powershell
.\scripts\validation\validate-java.ps1
.\scripts\validation\validate-dotnet.ps1
```

```bash
./scripts/validation/validate-java.sh
./scripts/validation/validate-dotnet.sh # Git Bash on Windows
```

The Java wrapper selects JDK 8 from `JAVA8_HOME` or `JDK8_HOME` when set,
verifies the selected Java version, and runs the imported Maven reactor tests.
PowerShell also accepts `-JavaHome <path>`. The .NET wrapper restores
`packages.config` dependencies and builds the classic solution with Visual
Studio MSBuild. Use `-SkipTests` in PowerShell or `--skip-tests` in bash only
when you need a compile/package diagnostic. The .NET baseline is intentionally
Windows-only.
