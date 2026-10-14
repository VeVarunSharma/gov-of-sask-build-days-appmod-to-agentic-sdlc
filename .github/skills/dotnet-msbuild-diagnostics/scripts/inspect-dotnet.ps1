[CmdletBinding()]
param(
    [string]$ProjectRoot = 'legacy-src\dotnet-bookcatalog\shared-legacy-app'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
$root = (Resolve-Path (Join-Path $repoRoot $ProjectRoot)).Path
$relativeRoot = [IO.Path]::GetRelativePath($repoRoot, $root)
if ([IO.Path]::IsPathRooted($relativeRoot) -or
    $relativeRoot -eq '..' -or
    $relativeRoot.StartsWith("..$([IO.Path]::DirectorySeparatorChar)")) {
    throw 'ProjectRoot must be inside the repository.'
}

Write-Output ".NET inventory: $root"
Get-ChildItem -Path $root -File -Recurse |
    Where-Object {
        $_.Extension -in @('.sln', '.csproj') -or $_.Name -in @('packages.config', 'global.json')
    } |
    Where-Object { $_.FullName -notmatch '[\\/](bin|obj|packages)[\\/]' } |
    Sort-Object FullName |
    ForEach-Object {
        $relative = [IO.Path]::GetRelativePath($repoRoot, $_.FullName)
        Write-Output ""
        Write-Output "File: $relative"
        if ($_.Extension -eq '.csproj' -or $_.Name -eq 'packages.config') {
            [xml]$xml = Get-Content -LiteralPath $_.FullName -Raw
            if ($_.Extension -eq '.csproj') {
                foreach ($name in @('TargetFramework', 'TargetFrameworks', 'TargetFrameworkVersion')) {
                    foreach ($property in @($xml.SelectNodes("//*[local-name()='$name']"))) {
                        if ($property.InnerText) {
                            Write-Output "  $name`: $($property.InnerText.Trim())"
                        }
                    }
                }
                foreach ($reference in @($xml.SelectNodes("//*[local-name()='PackageReference']"))) {
                    $include = $reference.GetAttribute('Include')
                    $version = $reference.GetAttribute('Version')
                    if (-not $version) {
                        $versionNode = $reference.SelectSingleNode("*[local-name()='Version']")
                        if ($null -ne $versionNode) { $version = $versionNode.InnerText.Trim() }
                    }
                    if (-not $version) { $version = '(managed)' }
                    Write-Output "  PackageReference: $include $version"
                }
            } else {
                foreach ($package in @($xml.SelectNodes("//*[local-name()='package']"))) {
                    Write-Output "  packages.config: $($package.GetAttribute('id')) $($package.GetAttribute('version')) [$($package.GetAttribute('targetFramework'))]"
                }
            }
        }
    }

Write-Output ""
Write-Output 'Inspection complete; no restore, build, or file change was performed.'
