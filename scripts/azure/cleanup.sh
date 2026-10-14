#!/usr/bin/env bash
set -euo pipefail

subscription_id=""; resource_group=""; expected_prefix=""; tag_name=""; tag_value=""
execute=false; confirmation=""
require_value() {
  local option="$1"
  [[ $# -ge 2 && -n "$2" ]] || { echo "ERROR: $option requires a non-empty value." >&2; exit 2; }
}
while [[ $# -gt 0 ]]; do
  case "$1" in
    --subscription-id) require_value "$1" "${2:-}"; subscription_id="$2"; shift ;;
    --resource-group) require_value "$1" "${2:-}"; resource_group="$2"; shift ;;
    --expected-prefix) require_value "$1" "${2:-}"; expected_prefix="$2"; shift ;;
    --tag-name) require_value "$1" "${2:-}"; tag_name="$2"; shift ;;
    --tag-value) require_value "$1" "${2:-}"; tag_value="$2"; shift ;;
    --what-if) execute=false ;;
    --execute) execute=true ;;
    --confirm-resource-group) require_value "$1" "${2:-}"; confirmation="$2"; shift ;;
    *) echo "ERROR: unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done
for value in subscription_id resource_group expected_prefix tag_name tag_value; do
  [[ -n "${!value}" ]] || { echo "ERROR: --${value//_/-} is required." >&2; exit 2; }
done
[[ "$subscription_id" =~ ^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$ ]] || {
  echo "ERROR: --subscription-id must be an explicit subscription GUID." >&2
  exit 1
}
[[ "$tag_name" =~ ^[A-Za-z0-9_.:-]+$ ]] || { echo "ERROR: --tag-name contains unsupported characters." >&2; exit 1; }
[[ "$resource_group" == "$expected_prefix"* ]] || { echo "ERROR: refusing cleanup; name must start with '$expected_prefix'." >&2; exit 1; }
[[ "$resource_group" != *[\*\?\[\]]* ]] || { echo "ERROR: refusing cleanup; wildcard characters are not accepted." >&2; exit 1; }
command -v az >/dev/null 2>&1 || { echo "ERROR: Azure CLI is required." >&2; exit 1; }

account_id="$(az account show --subscription "$subscription_id" --query id -o tsv)"
[[ "$account_id" == "$subscription_id" ]] || { echo "ERROR: exact subscription was not resolved." >&2; exit 1; }
group_name="$(az group show --subscription "$subscription_id" --name "$resource_group" --query name -o tsv)"
group_name_lower="$(printf '%s' "$group_name" | tr '[:upper:]' '[:lower:]')"
resource_group_lower="$(printf '%s' "$resource_group" | tr '[:upper:]' '[:lower:]')"
[[ "$group_name_lower" == "$resource_group_lower" ]] || { echo "ERROR: exact resource group was not resolved." >&2; exit 1; }
actual_tag="$(az group show --subscription "$subscription_id" --name "$resource_group" --query "tags.\"$tag_name\"" -o tsv)"
[[ "$actual_tag" == "$tag_value" ]] || { echo "ERROR: safety tag mismatch for '$tag_name'." >&2; exit 1; }

az account show --subscription "$subscription_id" --query '{account:user.name,tenant:tenantId,subscription:name,id:id}' -o table
printf 'Resource group: %s\nSafety tag: %s=%s\n' "$group_name" "$tag_name" "$actual_tag"
az resource list --subscription "$subscription_id" --resource-group "$resource_group" --query '[].{name:name,type:type,location:location}' -o table

if ! $execute; then
  echo "DRY RUN: no resources were deleted. Add --execute and an exact --confirm-resource-group value after review."
  exit 0
fi
[[ "$confirmation" == "$resource_group" ]] || { echo "ERROR: confirmation must exactly match '$resource_group'." >&2; exit 1; }
az group delete --subscription "$subscription_id" --name "$resource_group" --yes --no-wait
echo "Deletion request submitted for the exact resource group."
