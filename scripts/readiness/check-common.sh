#!/usr/bin/env bash
set -uo pipefail

failures=0
acknowledge_copilot=false
subscription_id=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --acknowledge-copilot-app) acknowledge_copilot=true ;;
    --subscription-id)
      shift
      [[ $# -gt 0 ]] || { echo "ERROR: --subscription-id requires a value." >&2; exit 2; }
      subscription_id="$1"
      ;;
    *) echo "ERROR: unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

pass() { printf '[PASS] %s: %s\n' "$1" "$2"; }
fail() { printf '[FAIL] %s: %s\n       Action: %s\n' "$1" "$2" "$3" >&2; failures=$((failures + 1)); }
has() { command -v "$1" >/dev/null 2>&1; }

if has git; then pass "Git" "$(git --version 2>&1)"; else fail "Git" "git was not found on PATH." "Install Git from https://git-scm.com/downloads."; fi

if has gh; then
  pass "GitHub CLI" "$(gh --version 2>&1 | head -n 1)"
  if gh auth status --hostname github.com >/dev/null 2>&1; then
    pass "GitHub CLI authentication" "Authenticated to github.com."
  else
    fail "GitHub CLI authentication" "gh is not authenticated to github.com." "Run: gh auth login --hostname github.com"
  fi
  if aw_version="$(gh aw --version 2>&1)" || aw_version="$(gh aw version 2>&1)"; then
    pass "gh-aw extension" "${aw_version%%$'\n'*}"
  else
    fail "gh-aw extension" "$aw_version" "Run: gh extension install github/gh-aw"
  fi
else
  fail "GitHub CLI" "gh was not found on PATH." "Install GitHub CLI from https://cli.github.com/."
  fail "GitHub CLI authentication" "Cannot check authentication without gh." "Install gh, then run gh auth login."
  fail "gh-aw extension" "Cannot check gh-aw without gh." "Install gh, then run gh extension install github/gh-aw."
fi

if $acknowledge_copilot; then
  pass "GitHub Copilot app (manual)" "Participant confirmed installation, sign-in, and entitlement."
else
  fail "GitHub Copilot app (manual)" "Command-line verification is not available." "Verify the app manually, then rerun with --acknowledge-copilot-app."
fi

if has modernize; then
  modernize_version="$(modernize --version 2>&1)" || modernize_version="$(modernize --help 2>&1 | head -n 1)"
  pass "Modernize CLI" "${modernize_version%%$'\n'*}"
else
  fail "Modernize CLI" "modernize was not found on PATH." "Install it from https://github.com/microsoft/modernize-cli."
fi

if has docker; then
  pass "Docker CLI" "$(docker --version 2>&1)"
  if engine="$(docker info --format 'Server {{.ServerVersion}} via {{.Name}}' 2>&1)" && [[ -n "$engine" ]]; then pass "Docker engine" "$engine"; else fail "Docker engine" "$engine" "Start Docker and verify the current context."; fi
else
  fail "Docker CLI" "docker was not found on PATH." "Install Docker Desktop or a compatible runtime."
  fail "Docker engine" "Cannot contact an engine without Docker CLI." "Install and start Docker."
fi

if has az; then
  pass "Azure CLI" "$(az version --query '"azure-cli"' -o tsv 2>&1)"
  account_args=(account show -o json)
  [[ -z "$subscription_id" ]] || account_args+=(--subscription "$subscription_id")
  if account="$(az "${account_args[@]}" 2>&1)"; then
    account_id="$(az "${account_args[@]}" --query id -o tsv 2>/dev/null)"
    if [[ -n "$subscription_id" && "$account_id" != "$subscription_id" ]]; then
      fail "Azure login and subscription context" "Resolved subscription '$account_id', expected '$subscription_id'." "Run az account set --subscription '$subscription_id'."
    else
      account_name="$(az "${account_args[@]}" --query 'join(``, [name, ` (`, id, `)`])' -o tsv 2>/dev/null)"
      pass "Azure login and subscription context" "$account_name"
    fi
  else
    fail "Azure login and subscription context" "$account" "Run az login, then verify az account show."
  fi
else
  fail "Azure CLI" "az was not found on PATH." "Install Azure CLI."
  fail "Azure login and subscription context" "Cannot check Azure context without az." "Install Azure CLI and run az login."
fi

for tool in node npm; do
  if has "$tool"; then pass "${tool^^}" "$("$tool" --version 2>&1)"; else fail "${tool^^}" "$tool was not found on PATH." "Install the current Node.js LTS release."; fi
done

printf '\n%d check(s) failed.\n' "$failures"
(( failures == 0 ))
