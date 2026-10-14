[CmdletBinding()]
param([ValidateSet('Debug', 'Release')] [string] $Configuration = 'Debug')

if ($env:OS -ne 'Windows_NT') {
    throw 'The BookCatalog .NET Framework baseline can only be built on Windows.'
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$solution = Join-Path $repoRoot 'legacy-src\dotnet-bookcatalog\shared-legacy-app\BookCatalog.sln'
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$msbuild = $null
if (Test-Path $vswhere) {
    $msbuild = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -find 'MSBuild\**\Bin\MSBuild.exe' 2>$null | Select-Object -First 1
}
if (-not $msbuild) {
    $command = Get-Command MSBuild.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) { $msbuild = $command.Source }
}
if (-not $msbuild) {
    throw 'MSBuild was not found. Install Visual Studio with ASP.NET and web development tools.'
}

& $msbuild $solution '/nologo' '/m' '/restore' '/verbosity:minimal' "/p:Configuration=$Configuration" '/p:RestorePackagesConfig=true'
if ($LASTEXITCODE -ne 0) { throw "BookCatalog baseline build failed with exit code $LASTEXITCODE." }
