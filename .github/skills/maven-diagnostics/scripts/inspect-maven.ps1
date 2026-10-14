[CmdletBinding()]
param(
    [string]$ProjectRoot = 'legacy-src\java-asset-manager'
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

$pomFiles = Get-ChildItem -Path $root -Filter pom.xml -File -Recurse |
    Where-Object { $_.FullName -notmatch '[\\/](target)[\\/]' } |
    Sort-Object FullName

$pomFiles = @($pomFiles)
if ($pomFiles.Count -eq 0) {
    throw "No pom.xml files found under $root"
}

function Get-XmlText {
    param(
        [System.Xml.XmlNode]$Node,
        [string]$XPath
    )

    $match = $Node.SelectSingleNode($XPath)
    if ($null -ne $match) {
        return $match.InnerText.Trim()
    }
    return $null
}

Write-Output "Maven inventory: $root"
foreach ($pom in $pomFiles) {
    [xml]$xml = Get-Content -LiteralPath $pom.FullName -Raw
    $project = $xml.project
    $relative = [IO.Path]::GetRelativePath($repoRoot, $pom.FullName)
    $groupId = Get-XmlText $project "*[local-name()='groupId']"
    if (-not $groupId) {
        $groupId = Get-XmlText $project "*[local-name()='parent']/*[local-name()='groupId']"
    }
    $artifactId = Get-XmlText $project "*[local-name()='artifactId']"
    $version = Get-XmlText $project "*[local-name()='version']"
    if (-not $version) {
        $version = Get-XmlText $project "*[local-name()='parent']/*[local-name()='version']"
    }
    Write-Output ""
    Write-Output "POM: $relative"
    Write-Output "  coordinate: $groupId`:$artifactId`:$version"
    $javaVersion = Get-XmlText $project "*[local-name()='properties']/*[local-name()='java.version']"
    if ($javaVersion) {
        Write-Output "  java.version: $javaVersion"
    }
    foreach ($module in @($project.SelectNodes("*[local-name()='modules']/*[local-name()='module']"))) {
        Write-Output "  module: $($module.InnerText.Trim())"
    }
    foreach ($dependency in @($project.SelectNodes("*[local-name()='dependencies']/*[local-name()='dependency']"))) {
        $dependencyGroup = Get-XmlText $dependency "*[local-name()='groupId']"
        $dependencyArtifact = Get-XmlText $dependency "*[local-name()='artifactId']"
        $scope = Get-XmlText $dependency "*[local-name()='scope']"
        $dependencyVersion = Get-XmlText $dependency "*[local-name()='version']"
        if (-not $scope) { $scope = 'compile' }
        if (-not $dependencyVersion) { $dependencyVersion = '(managed)' }
        Write-Output "  dependency: $dependencyGroup`:$dependencyArtifact`:$dependencyVersion [$scope]"
    }
}

$wrapper = Get-ChildItem -Path $root -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -in @('mvnw', 'mvnw.cmd') } |
    Select-Object -ExpandProperty Name
Write-Output ""
Write-Output "Wrapper files: $($wrapper -join ', ')"
Write-Output 'Inspection complete; no files or dependencies were changed.'
