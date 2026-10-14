#!/usr/bin/env bash
set -uo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/../.." && pwd)"
app_root="$repo_root/legacy-src/java-asset-manager"
failures=0

pass() { printf '[PASS] %s: %s\n' "$1" "$2"; }
fail() { printf '[FAIL] %s: %s\n       Action: %s\n' "$1" "$2" "$3" >&2; failures=$((failures + 1)); }

declare -a java_candidates=()
for variable in JAVA8_HOME JDK8_HOME JAVA21_HOME JDK21_HOME JAVA_HOME; do
  value="${!variable:-}"
  [[ -z "$value" ]] || java_candidates+=("$value/bin/java")
done
command -v java >/dev/null 2>&1 && java_candidates+=("$(command -v java)")
for candidate in /usr/lib/jvm/*/bin/java /Library/Java/JavaVirtualMachines/*/Contents/Home/bin/java; do
  [[ -x "$candidate" ]] && java_candidates+=("$candidate")
done

found8=""
found21=""
for java_path in "${java_candidates[@]}"; do
  [[ -x "$java_path" ]] || continue
  version_line="$("$java_path" -version 2>&1 | head -n 1)"
  if [[ "$version_line" =~ version\ \"1\.8 ]]; then found8="$version_line ($java_path)"; fi
  if [[ "$version_line" =~ version\ \"21(\.|\"|$) ]]; then found21="$version_line ($java_path)"; fi
done

if [[ -n "$found8" ]]; then pass "JDK 8" "$found8"; else fail "JDK 8" "No JDK 8 installation was detected." "Install JDK 8 and set JAVA8_HOME or JDK8_HOME."; fi
if [[ -n "$found21" ]]; then pass "JDK 21" "$found21"; else fail "JDK 21" "No JDK 21 installation was detected." "Install JDK 21 and set JAVA21_HOME or JDK21_HOME."; fi

wrapper="$app_root/mvnw"
properties="$app_root/.mvn/wrapper/maven-wrapper.properties"
wrapper_version=""
if [[ -f "$properties" ]]; then
  wrapper_version="$(sed -nE 's#.*apache-maven-([0-9]+\.[0-9]+\.[0-9]+)-bin.*#\1#p' "$properties" | head -n 1)"
fi
if [[ -x "$wrapper" && "$wrapper_version" =~ ^3\.([89]|[1-9][0-9])\. ]]; then
  pass "Maven wrapper 3.8+" "mvnw is configured for Maven $wrapper_version."
else
  fail "Maven wrapper 3.8+" "A usable Maven 3.8+ wrapper was not detected." "Restore the imported Maven wrapper files."
fi

if command -v mvn >/dev/null 2>&1; then
  maven_line="$(mvn --version 2>&1 | head -n 1)"
  if [[ "$maven_line" =~ Apache\ Maven\ (3\.([89]|[1-9][0-9])\.) ]]; then
    pass "Maven 3.8+ or wrapper" "$maven_line"
  elif [[ -x "$wrapper" && "$wrapper_version" =~ ^3\.([89]|[1-9][0-9])\. ]]; then
    pass "Maven 3.8+ or wrapper" "System Maven is unsuitable, but mvnw provides Maven $wrapper_version."
  else
    fail "Maven 3.8+ or wrapper" "$maven_line" "Install Maven 3.8+ or restore the wrapper."
  fi
elif [[ -x "$wrapper" ]]; then
  pass "Maven 3.8+ or wrapper" "mvn is not on PATH; mvnw provides Maven $wrapper_version."
else
  fail "Maven 3.8+ or wrapper" "Neither mvn nor an executable wrapper is available." "Install Maven 3.8+ or restore mvnw."
fi

printf '\n%d check(s) failed.\n' "$failures"
(( failures == 0 ))
