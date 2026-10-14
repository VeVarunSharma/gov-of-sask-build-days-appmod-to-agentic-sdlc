#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    if ! command -v powershell.exe >/dev/null 2>&1; then
      echo "[FAIL] PowerShell: powershell.exe is required to inspect Visual Studio prerequisites." >&2
      exit 1
    fi
    ps_script="$script_dir/check-dotnet.ps1"
    if command -v cygpath >/dev/null 2>&1; then ps_script="$(cygpath -w "$ps_script")"; fi
    exec powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "$ps_script"
    ;;
  *)
    echo "[FAIL] Windows host: BookCatalog is an ASP.NET MVC 5/.NET Framework application."
    echo "       Action: run scripts/readiness/check-dotnet.ps1 on Windows with Visual Studio web tools installed."
    exit 1
    ;;
esac
