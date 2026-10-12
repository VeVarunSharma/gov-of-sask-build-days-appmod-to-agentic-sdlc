#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/../../../.." && pwd)"
requested="${1:?Usage: check-assessment.sh <assessment.md>}"
file="$(cd -- "$(dirname -- "$requested")" && pwd)/$(basename -- "$requested")"
case "$file" in
  "$repo_root"/*) ;;
  *) echo "Assessment must be inside the repository." >&2; exit 2 ;;
esac
[[ -f "$file" ]] || { echo "File not found: $file" >&2; exit 2; }

required=(
  'current state'
  'goals'
  'constraints'
  'dependencies'
  'risks'
  'recommendation'
  'validation'
  'rollback'
  'open decisions'
  'evidence'
)

missing=()
for heading in "${required[@]}"; do
  if ! grep -Eiq "^#{1,6}[[:space:]]+.*${heading}" "$file"; then
    missing+=("$heading")
  fi
done

placeholders="$(grep -Eio '\b(TODO|TBD|FIXME)\b|\{\{[^}]+\}\}' "$file" | sort -u | paste -sd ', ' - || true)"

echo "Assessment: $file"
if ((${#missing[@]})); then
  printf 'Missing headings: %s\n' "$(IFS=', '; echo "${missing[*]}")"
else
  echo 'Missing headings: none'
fi
echo "Unresolved placeholders: ${placeholders:-none}"

if ((${#missing[@]})) || [[ -n "$placeholders" ]]; then
  exit 1
fi

echo 'Structural review passed. Repository evidence still requires human or agent verification.'
