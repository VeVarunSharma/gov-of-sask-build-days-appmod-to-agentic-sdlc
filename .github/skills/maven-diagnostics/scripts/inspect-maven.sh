#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/../../../.." && pwd)"
project_root="${1:-legacy-src/java-asset-manager}"
root="$(cd -- "$repo_root/$project_root" && pwd)"

case "$root" in
  "$repo_root"/*) ;;
  *) echo "Project root must be inside the repository." >&2; exit 2 ;;
esac

mapfile -t poms < <(find "$root" -type f -name pom.xml -not -path '*/target/*' | sort)
if ((${#poms[@]} == 0)); then
  echo "No pom.xml files found under $root" >&2
  exit 1
fi

echo "Maven inventory: $root"
for pom in "${poms[@]}"; do
  relative="${pom#"$repo_root"/}"
  echo
  echo "POM: $relative"
  grep -E '<(groupId|artifactId|version|java.version|module|scope)>' "$pom" |
    sed -E 's/^[[:space:]]+/  /' || true
done

echo
printf 'Wrapper files:'
[[ -f "$root/mvnw" ]] && printf ' mvnw'
[[ -f "$root/mvnw.cmd" ]] && printf ' mvnw.cmd'
echo
echo 'Inspection complete; no files or dependencies were changed.'
