[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
$file = (Resolve-Path $Path).Path
$relativeFile = [IO.Path]::GetRelativePath($repoRoot, $file)
if ([IO.Path]::IsPathRooted($relativeFile) -or
    $relativeFile -eq '..' -or
    $relativeFile.StartsWith("..$([IO.Path]::DirectorySeparatorChar)")) {
    throw 'Path must be inside the repository.'
}
$content = Get-Content -LiteralPath $file -Raw
$required = @(
    'current state',
    'goals',
    'constraints',
    'dependencies',
    'risks',
    'recommendation',
    'validation',
    'rollback',
    'open decisions',
    'evidence'
)

$missing = foreach ($heading in $required) {
    if ($content -notmatch "(?im)^#{1,6}\s+.*$([regex]::Escape($heading)).*$") {
        $heading
    }
}

$placeholders = [regex]::Matches($content, '(?i)\b(TODO|TBD|FIXME)\b|\{\{[^}]+\}\}') |
    ForEach-Object Value |
    Sort-Object -Unique

Write-Output "Assessment: $file"
Write-Output "Missing headings: $(if ($missing) { $missing -join ', ' } else { 'none' })"
Write-Output "Unresolved placeholders: $(if ($placeholders) { $placeholders -join ', ' } else { 'none' })"

if ($missing -or $placeholders) {
    exit 1
}

Write-Output 'Structural review passed. Repository evidence still requires human or agent verification.'
