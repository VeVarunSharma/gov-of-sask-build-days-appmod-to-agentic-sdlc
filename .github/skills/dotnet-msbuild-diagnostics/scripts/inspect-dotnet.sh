#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/../../../.." && pwd)"
project_root="${1:-capstone-src/api-dotnet}"
root="$(cd -- "$repo_root/$project_root" && pwd)"

case "$root" in
  "$repo_root"/*) ;;
  *) echo "Project root must be inside the repository." >&2; exit 2 ;;
esac

echo ".NET inventory: $root"
while IFS= read -r file; do
  relative="${file#"$repo_root"/}"
  echo
  echo "File: $relative"
  case "$file" in
    *.csproj|*/packages.config)
      grep -E '<(TargetFramework|TargetFrameworks|TargetFrameworkVersion|PackageReference|package )' "$file" |
        sed -E 's/^[[:space:]]+/  /' || true
      ;;
  esac
done < <(
  find "$root" -type f \( -name '*.sln' -o -name '*.csproj' -o -name packages.config -o -name global.json \) \
    -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/packages/*' | sort
)

echo
echo 'Inspection complete; no restore, build, or file change was performed.'
