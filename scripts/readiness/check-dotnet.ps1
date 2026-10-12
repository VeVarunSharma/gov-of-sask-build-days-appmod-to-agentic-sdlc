[CmdletBinding()]
param()

. (Join-Path $PSScriptRoot 'Readiness.Common.ps1')
$results = New-ReadinessResults

if ($env:OS -ne 'Windows_NT') {
    Add-ReadinessResult $results 'Windows host' $false 'The BookCatalog legacy baseline requires Windows.' 'Run this check on Windows with Visual Studio web development tools installed.'
    Complete-ReadinessCheck $results
}

$dotnet = Get-CommandPath 'dotnet'
if ($dotnet) {
    $sdks = Invoke-ReadinessCommand $dotnet @('--list-sdks')
    Add-ReadinessResult $results '.NET 10 SDK' ($sdks.ExitCode -eq 0 -and $sdks.Output -match '(?m)^10\.') $sdks.Output 'Install a stable .NET 10 SDK.'
    $runtimes = Invoke-ReadinessCommand $dotnet @('--list-runtimes')
    Add-ReadinessResult $results '.NET 10 runtime' ($runtimes.ExitCode -eq 0 -and $runtimes.Output -match '(?m)^Microsoft\.NETCore\.App 10\.') $runtimes.Output 'Install the .NET 10 runtime through Visual Studio Installer or the .NET download page.'
    Add-ReadinessResult $results 'ASP.NET Core 10 runtime' ($runtimes.ExitCode -eq 0 -and $runtimes.Output -match '(?m)^Microsoft\.AspNetCore\.App 10\.') $runtimes.Output 'Install the ASP.NET Core 10 runtime/hosting component.'
} else {
    foreach ($name in @('.NET 10 SDK', '.NET 10 runtime', 'ASP.NET Core 10 runtime')) {
        Add-ReadinessResult $results $name $false 'dotnet was not found on PATH.' 'Install the stable .NET 10 SDK and runtimes.'
    }
}

$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$msbuildPath = $null
$vsInstall = $null
if (Test-Path $vswhere) {
    $found = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -find 'MSBuild\**\Bin\MSBuild.exe' 2>$null | Select-Object -First 1
    if ($found) {
        $msbuildPath = $found
        $vsInstall = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -property installationPath 2>$null | Select-Object -First 1
    }
}
if (-not $msbuildPath) { $msbuildPath = Get-CommandPath 'MSBuild.exe' }
Add-ReadinessResult $results 'Visual Studio MSBuild' ($null -ne $msbuildPath) `
    $(if ($msbuildPath) { $msbuildPath } else { 'MSBuild.exe was not found.' }) `
    'Use Visual Studio Installer to add MSBuild and the ASP.NET and web development workload.'

$webTargets = @()
if ($vsInstall) {
    $webTargets = @(Get-ChildItem (Join-Path $vsInstall 'MSBuild\Microsoft\VisualStudio') -Filter 'Microsoft.WebApplication.targets' -Recurse -ErrorAction SilentlyContinue)
}
if ($webTargets.Count -eq 0) {
    $fallbackTargetsRoot = Join-Path ${env:ProgramFiles(x86)} 'MSBuild\Microsoft\VisualStudio'
    if (Test-Path $fallbackTargetsRoot) {
        $webTargets = @(Get-ChildItem $fallbackTargetsRoot -Filter 'Microsoft.WebApplication.targets' -Recurse -ErrorAction SilentlyContinue)
    }
}
Add-ReadinessResult $results 'WebApplication MSBuild targets' ($webTargets.Count -gt 0) `
    $(if ($webTargets.Count -gt 0) { $webTargets[0].FullName } else { 'Microsoft.WebApplication.targets was not found.' }) `
    'Use Visual Studio Installer to add the ASP.NET and web development workload.'

$frameworkRoot = Join-Path ${env:ProgramFiles(x86)} 'Reference Assemblies\Microsoft\Framework\.NETFramework\v4.8'
$targetingPack = Join-Path $frameworkRoot 'mscorlib.dll'
Add-ReadinessResult $results '.NET Framework 4.8 targeting pack' (Test-Path $targetingPack) `
    $(if (Test-Path $targetingPack) { $frameworkRoot } else { "$frameworkRoot is missing." }) `
    'Use Visual Studio Installer to add the .NET Framework 4.8 targeting pack and development tools.'

$iisExpress = Join-Path ${env:ProgramFiles(x86)} 'IIS Express\iisexpress.exe'
if (-not (Test-Path $iisExpress)) {
    $iisExpress = Join-Path $env:ProgramFiles 'IIS Express\iisexpress.exe'
}
Add-ReadinessResult $results 'IIS Express' (Test-Path $iisExpress) `
    $(if (Test-Path $iisExpress) { $iisExpress } else { 'iisexpress.exe was not found.' }) `
    'Use Visual Studio Installer to add IIS Express.'

$localDb = Get-CommandPath 'SqlLocalDB.exe'
if (-not $localDb) {
    $localDb = Get-ChildItem (Join-Path $env:ProgramFiles 'Microsoft SQL Server') -Filter 'SqlLocalDB.exe' -File -Recurse -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending |
        Select-Object -First 1 -ExpandProperty FullName
}
if ($localDb) {
    $localDbInfo = Invoke-ReadinessCommand $localDb @('info', 'MSSQLLocalDB')
    $localDbDetail = if ($localDbInfo.Output -match 'not created') {
        "SQL LocalDB is installed at $localDb; the automatic MSSQLLocalDB instance will be created on first use."
    } else {
        $localDbInfo.Output
    }
    Add-ReadinessResult $results 'SQL Server LocalDB MSSQLLocalDB' ($localDbInfo.ExitCode -eq 0) $localDbDetail 'Install SQL Server Express LocalDB and ensure the MSSQLLocalDB instance is registered.'
} else {
    Add-ReadinessResult $results 'SQL Server LocalDB MSSQLLocalDB' $false 'SqlLocalDB.exe was not found on PATH.' 'Install SQL Server Express LocalDB, then reopen the terminal.'
}

Complete-ReadinessCheck $results
