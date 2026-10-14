[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory)] [string] $SubscriptionId,
    [Parameter(Mandatory)] [string] $ResourceGroupName,
    [Parameter(Mandatory)] [string] $ExpectedNamePrefix,
    [Parameter(Mandatory)] [string] $RequiredTagName,
    [Parameter(Mandatory)] [string] $RequiredTagValue,
    [switch] $Execute,
    [string] $ConfirmResourceGroup
)

$ErrorActionPreference = 'Stop'
foreach ($value in @($SubscriptionId, $ResourceGroupName, $ExpectedNamePrefix, $RequiredTagName, $RequiredTagValue)) {
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw 'Subscription, resource-group, prefix, and tag-name inputs must be non-empty.'
    }
}
$parsedSubscriptionId = [guid]::Empty
if (-not [guid]::TryParse($SubscriptionId, [ref] $parsedSubscriptionId)) {
    throw "SubscriptionId must be an explicit subscription GUID; received '$SubscriptionId'."
}
if ($RequiredTagName -notmatch '^[A-Za-z0-9_.:-]+$') {
    throw 'RequiredTagName may contain only letters, numbers, underscore, period, colon, and hyphen.'
}
if ($ResourceGroupName.IndexOfAny([char[]] '*?[]') -ge 0) {
    throw 'Refusing cleanup: wildcard characters are not accepted in resource-group names.'
}
if (-not $ResourceGroupName.StartsWith($ExpectedNamePrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing cleanup: '$ResourceGroupName' does not start with '$ExpectedNamePrefix'."
}
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw 'Azure CLI was not found. This script does not install or authenticate.'
}

$accountJson = & az account show --subscription $SubscriptionId --output json 2>&1
if ($LASTEXITCODE -ne 0) { throw "Unable to resolve the exact subscription '$SubscriptionId': $accountJson" }
$account = $accountJson | ConvertFrom-Json
if ($account.id -ne $SubscriptionId) { throw "Azure resolved subscription '$($account.id)', not '$SubscriptionId'." }

$groupJson = & az group show --subscription $SubscriptionId --name $ResourceGroupName --output json 2>&1
if ($LASTEXITCODE -ne 0) { throw "Unable to resolve the exact resource group '$ResourceGroupName': $groupJson" }
$group = $groupJson | ConvertFrom-Json
if (-not [string]::Equals($group.name, $ResourceGroupName, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Azure resolved resource group '$($group.name)', not '$ResourceGroupName'."
}
$actualTag = $group.tags.$RequiredTagName
if ($actualTag -ne $RequiredTagValue) {
    throw "Refusing cleanup: tag '$RequiredTagName' must equal '$RequiredTagValue'; actual value: '$actualTag'."
}

Write-Host "Account:      $($account.user.name)"
Write-Host "Subscription: $($account.name) ($($account.id))"
Write-Host "Resource group: $($group.name)"
Write-Host "Safety tag:     $RequiredTagName=$actualTag"
& az resource list --subscription $SubscriptionId --resource-group $ResourceGroupName `
    --query '[].{name:name,type:type,location:location}' --output table
if ($LASTEXITCODE -ne 0) { throw 'Unable to enumerate cleanup candidates.' }

if (-not $Execute) {
    Write-Host ''
    Write-Host 'DRY RUN: no resources were deleted. Pass -Execute and -ConfirmResourceGroup with the exact name to request deletion.'
    return
}
if ($ConfirmResourceGroup -cne $ResourceGroupName) {
    throw 'Refusing cleanup: -ConfirmResourceGroup must exactly match -ResourceGroupName (case-sensitive).'
}

if ($PSCmdlet.ShouldProcess("resource group '$ResourceGroupName' in subscription '$SubscriptionId'", 'Delete exact resource group')) {
    & az group delete --subscription $SubscriptionId --name $ResourceGroupName --yes --no-wait
    if ($LASTEXITCODE -ne 0) { throw 'Azure rejected the resource-group deletion request.' }
    Write-Host 'Deletion request submitted for the exact resource group.'
}
