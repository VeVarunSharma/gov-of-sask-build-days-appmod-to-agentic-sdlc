#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/../.." && pwd)"
app_root="$repo_root/legacy-src/java-asset-manager"
wrapper="$app_root/mvnw"

[[ -x "$wrapper" ]] || { echo "ERROR: Maven wrapper is missing or not executable at $wrapper" >&2; exit 1; }
goal="test"
declare -a maven_args=()
if [[ "${1:-}" == "--skip-tests" ]]; then
  goal="package"
  shift
  maven_args+=("-DskipTests")
fi
[[ $# -eq 0 ]] || { echo "ERROR: unknown argument: $1" >&2; exit 2; }

java_home="${JAVA8_HOME:-${JDK8_HOME:-}}"
if [[ -n "$java_home" ]]; then
  if command -v cygpath >/dev/null 2>&1 && [[ "$java_home" =~ ^[A-Za-z]:\\ ]]; then
    java_home="$(cygpath -u "$java_home")"
  fi
  java_command="$java_home/bin/java"
  [[ -x "$java_command" ]] || { echo "ERROR: JDK 8 java was not found under '$java_home'. Correct JAVA8_HOME or JDK8_HOME." >&2; exit 1; }
  export JAVA_HOME="$java_home"
  export PATH="$JAVA_HOME/bin:$PATH"
else
  java_command="$(command -v java || true)"
  [[ -n "$java_command" ]] || { echo "ERROR: Java was not found. Install JDK 8 and set JAVA8_HOME." >&2; exit 1; }
fi

java_version="$("$java_command" -version 2>&1 | head -n 1)"
[[ "$java_version" =~ version\ \"1\.8 ]] || {
  echo "ERROR: The imported baseline requires JDK 8; selected Java reported '$java_version'." >&2
  echo "       Action: set JAVA8_HOME or JDK8_HOME to a JDK 8 installation." >&2
  exit 1
}

cd "$app_root"
exec "$wrapper" -B -ntp "${maven_args[@]}" "$goal"
