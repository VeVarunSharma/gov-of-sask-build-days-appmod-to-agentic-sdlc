# Readiness scripts

These scripts only inspect the workstation. They do not install, upgrade, log
in, or otherwise repair prerequisites.

Run from any directory:

```powershell
# Windows PowerShell 5.1 or PowerShell 7+
.\scripts\readiness\check-common.ps1 -AcknowledgeCopilotApp
.\scripts\readiness\check-java.ps1
.\scripts\readiness\check-dotnet.ps1
```

```bash
# Linux/macOS, WSL, or Git Bash (where the checked tool is supported)
./scripts/readiness/check-common.sh --acknowledge-copilot-app
./scripts/readiness/check-java.sh
./scripts/readiness/check-dotnet.sh
```

The Copilot application cannot be verified reliably from a command line. The
common check therefore fails until the participant has manually confirmed the
application is installed, signed in, and licensed by passing the acknowledgement
flag.

The .NET legacy baseline is Windows-only. `check-dotnet.sh` delegates to the
PowerShell check when run from Git Bash and fails with an actionable message on
Linux, macOS, and WSL.
