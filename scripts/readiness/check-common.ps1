[CmdletBinding()]
param(
    [switch] $AcknowledgeCopilotApp,
    [string] $SubscriptionId
)

. (Join-Path $PSScriptRoot 'Readiness.Common.ps1')
$results = New-ReadinessResults

$git = Get-CommandPath 'git'
if ($git) {
    $version = Invoke-ReadinessCommand $git @('--version')
    Add-ReadinessResult $results 'Git' ($version.ExitCode -eq 0) $version.Output 'Install Git and ensure git is on PATH.'
} else {
    Add-ReadinessResult $results 'Git' $false 'git was not found on PATH.' 'Install Git from https://git-scm.com/downloads and reopen the terminal.'
}

$gh = Get-CommandPath 'gh'
if ($gh) {
    $version = Invoke-ReadinessCommand $gh @('--version')
    Add-ReadinessResult $results 'GitHub CLI' ($version.ExitCode -eq 0) (($version.Output -split "`n")[0]) 'Install or repair GitHub CLI.'
    $auth = Invoke-ReadinessCommand $gh @('auth', 'status', '--hostname', 'github.com')
    Add-ReadinessResult $results 'GitHub CLI authentication' ($auth.ExitCode -eq 0) `
        $(if ($auth.ExitCode -eq 0) { 'Authenticated to github.com.' } else { $auth.Output }) `
        'Run: gh auth login --hostname github.com'

    $aw = Invoke-ReadinessCommand $gh @('aw', '--version')
    if ($aw.ExitCode -ne 0) {
        $aw = Invoke-ReadinessCommand $gh @('aw', 'version')
    }
    Add-ReadinessResult $results 'gh-aw extension' ($aw.ExitCode -eq 0) $aw.Output 'Install it explicitly with: gh extension install github/gh-aw'
} else {
    Add-ReadinessResult $results 'GitHub CLI' $false 'gh was not found on PATH.' 'Install GitHub CLI from https://cli.github.com/.'
    Add-ReadinessResult $results 'GitHub CLI authentication' $false 'Cannot check authentication without gh.' 'Install gh, then run: gh auth login --hostname github.com'
    Add-ReadinessResult $results 'gh-aw extension' $false 'Cannot check gh-aw without gh.' 'Install gh, then run: gh extension install github/gh-aw'
}

Add-ReadinessResult $results 'GitHub Copilot app (manual)' $AcknowledgeCopilotApp.IsPresent `
    $(if ($AcknowledgeCopilotApp) { 'Participant confirmed the app is installed, signed in, and licensed.' } else { 'Command-line verification is not available.' }) `
    'Open the GitHub Copilot app, verify it is signed in with an entitled account, then rerun with -AcknowledgeCopilotApp.'

$modernize = Get-CommandPath 'modernize'
if ($modernize) {
    $modernizeVersion = Invoke-ReadinessCommand $modernize @('--version')
    if ($modernizeVersion.ExitCode -ne 0) {
        $modernizeVersion = Invoke-ReadinessCommand $modernize @('--help')
    }
    Add-ReadinessResult $results 'Modernize CLI' ($modernizeVersion.ExitCode -eq 0) (($modernizeVersion.Output -split "`n")[0]) 'Repair the Modernize CLI and ensure modernize is on PATH.'
} else {
    Add-ReadinessResult $results 'Modernize CLI' $false 'modernize was not found on PATH.' 'Install GitHub Copilot Modernization Agent CLI from https://github.com/microsoft/modernize-cli and reopen the terminal.'
}

$docker = Get-CommandPath 'docker'
if ($docker) {
    $dockerClient = Invoke-ReadinessCommand $docker @('--version')
    Add-ReadinessResult $results 'Docker CLI' ($dockerClient.ExitCode -eq 0) $dockerClient.Output 'Install Docker Desktop or another compatible Docker CLI.'
    $dockerEngine = Invoke-ReadinessCommand $docker @('info', '--format', 'Server {{.ServerVersion}} via {{.Name}}')
    Add-ReadinessResult $results 'Docker engine' ($dockerEngine.ExitCode -eq 0 -and $dockerEngine.Output) $dockerEngine.Output 'Start Docker Desktop (or the configured Docker engine) and verify the current context.'
} else {
    Add-ReadinessResult $results 'Docker CLI' $false 'docker was not found on PATH.' 'Install Docker Desktop or another compatible container runtime.'
    Add-ReadinessResult $results 'Docker engine' $false 'Cannot contact an engine without Docker CLI.' 'Install and start Docker.'
}

$az = Get-CommandPath 'az'
if ($az) {
    $azVersion = Invoke-ReadinessCommand $az @('version', '--output', 'json')
    Add-ReadinessResult $results 'Azure CLI' ($azVersion.ExitCode -eq 0) $(if ($azVersion.ExitCode -eq 0) { 'Azure CLI responds.' } else { $azVersion.Output }) 'Install or repair Azure CLI.'
    $accountArguments = @('account', 'show', '--output', 'json')
    if ($SubscriptionId) { $accountArguments += @('--subscription', $SubscriptionId) }
    $account = Invoke-ReadinessCommand $az $accountArguments
    if ($account.ExitCode -eq 0) {
        try {
            $context = $account.Output | ConvertFrom-Json
            $detail = "$($context.name) ($($context.id)); tenant $($context.tenantId); user $($context.user.name)"
            $matches = -not $SubscriptionId -or $context.id -eq $SubscriptionId
            Add-ReadinessResult $results 'Azure login and subscription context' $matches $detail "Select the required subscription with: az account set --subscription $SubscriptionId"
        }
        catch {
            Add-ReadinessResult $results 'Azure login and subscription context' $false $account.Output 'Run az login, then select the participant subscription.'
        }
    } else {
        Add-ReadinessResult $results 'Azure login and subscription context' $false $account.Output 'Run az login, then verify access with az account show.'
    }
} else {
    Add-ReadinessResult $results 'Azure CLI' $false 'az was not found on PATH.' 'Install Azure CLI from https://aka.ms/installazurecliwindows.'
    Add-ReadinessResult $results 'Azure login and subscription context' $false 'Cannot check Azure context without az.' 'Install Azure CLI, run az login, and select the participant subscription.'
}

foreach ($tool in @('node', 'npm')) {
    $path = Get-CommandPath $tool
    if ($path) {
        $version = Invoke-ReadinessCommand $path @('--version')
        Add-ReadinessResult $results $tool.ToUpperInvariant() ($version.ExitCode -eq 0) $version.Output "Repair $tool and ensure it is on PATH."
    } else {
        Add-ReadinessResult $results $tool.ToUpperInvariant() $false "$tool was not found on PATH." 'Install the current Node.js LTS release, which includes npm.'
    }
}

Complete-ReadinessCheck $results
