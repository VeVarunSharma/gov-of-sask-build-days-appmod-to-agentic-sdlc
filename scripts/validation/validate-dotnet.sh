#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    ps_script="$script_dir/validate-dotnet.ps1"
    command -v cygpath >/dev/null 2>&1 && ps_script="$(cygpath -w "$ps_script")"
    exec powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "$ps_script" "$@"
    ;;
  *)
    echo "ERROR: BookCatalog uses .NET Framework 4.8 and requires Windows Visual Studio MSBuild." >&2
    exit 1
    ;;
esac
