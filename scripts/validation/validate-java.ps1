[CmdletBinding()]
param(
    [switch] $SkipTests,
    [string] $JavaHome
)

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$appRoot = Join-Path $repoRoot 'legacy-src\java-asset-manager'
$wrapper = Join-Path $appRoot 'mvnw.cmd'
if (-not (Test-Path $wrapper)) {
    throw "Maven wrapper not found at '$wrapper'. Restore the imported application files."
}

$selectedJavaHome = $JavaHome
if (-not $selectedJavaHome) { $selectedJavaHome = $env:JAVA8_HOME }
if (-not $selectedJavaHome) { $selectedJavaHome = $env:JDK8_HOME }

if ($selectedJavaHome) {
    $java = Join-Path $selectedJavaHome 'bin\java.exe'
    if (-not (Test-Path $java)) {
        throw "JDK 8 java.exe was not found under '$selectedJavaHome'. Correct -JavaHome, JAVA8_HOME, or JDK8_HOME."
    }
    $env:JAVA_HOME = $selectedJavaHome
    $env:Path = "$(Join-Path $selectedJavaHome 'bin');$env:Path"
} else {
    $javaCommand = Get-Command java -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $javaCommand) {
        throw 'Java was not found. Install JDK 8 and set JAVA8_HOME (or pass -JavaHome).'
    }
    $java = $javaCommand.Source
}

$javaVersion = (& $java -version 2>&1 | Select-Object -First 1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $javaVersion -notmatch 'version "1\.8') {
    throw "The imported baseline requires JDK 8; selected Java reported '$javaVersion'. Set JAVA8_HOME or pass -JavaHome."
}

Push-Location $appRoot
try {
    $arguments = @('-B', '-ntp')
    if ($SkipTests) { $arguments += @('-DskipTests', 'package') } else { $arguments += 'test' }
    & $wrapper @arguments
    if ($LASTEXITCODE -ne 0) { throw "Java baseline validation failed with exit code $LASTEXITCODE." }
}
finally {
    Pop-Location
}
