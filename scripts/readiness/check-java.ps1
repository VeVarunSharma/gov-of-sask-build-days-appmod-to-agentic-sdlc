[CmdletBinding()]
param()

. (Join-Path $PSScriptRoot 'Readiness.Common.ps1')
$results = New-ReadinessResults
$repoRoot = Get-RepositoryRoot
$appRoot = Join-Path $repoRoot 'legacy-src\java-asset-manager'

$candidateHomes = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($name in @('JAVA8_HOME', 'JDK8_HOME', 'JAVA21_HOME', 'JDK21_HOME', 'JAVA_HOME')) {
    $value = [Environment]::GetEnvironmentVariable($name)
    if ($value) { [void] $candidateHomes.Add($value) }
}

$pathJava = Get-CommandPath 'java'
if ($pathJava) {
    [void] $candidateHomes.Add((Split-Path (Split-Path $pathJava -Parent) -Parent))
}

foreach ($root in @(
    (Join-Path $env:ProgramFiles 'Microsoft'),
    (Join-Path $env:ProgramFiles 'Java'),
    (Join-Path $env:ProgramFiles 'Eclipse Adoptium'),
    (Join-Path $env:ProgramFiles 'Zulu'),
    (Join-Path ${env:ProgramFiles(x86)} 'Java')
)) {
    if ($root -and (Test-Path $root)) {
        Get-ChildItem $root -Directory -Recurse -Depth 1 -ErrorAction SilentlyContinue |
            Where-Object { Test-Path (Join-Path $_.FullName 'bin\java.exe') } |
            ForEach-Object { [void] $candidateHomes.Add($_.FullName) }
    }
}

$detected = @()
foreach ($javaHome in $candidateHomes) {
    $java = Join-Path $javaHome 'bin\java.exe'
    if (-not (Test-Path $java)) { continue }
    $version = Invoke-ReadinessCommand $java @('-version')
    $firstLine = ($version.Output -split "`n")[0]
    $major = $null
    if ($firstLine -match 'version "(?:1\.)?(\d+)') { $major = [int] $Matches[1] }
    if ($major) {
        $detected += [pscustomobject]@{ Major = $major; Home = $javaHome; Detail = $firstLine }
    }
}

foreach ($major in @(8, 21)) {
    $match = $detected | Where-Object Major -eq $major | Select-Object -First 1
    Add-ReadinessResult $results "JDK $major" ($null -ne $match) `
        $(if ($match) { "$($match.Detail) at $($match.Home)" } else { "No JDK $major installation was detected." }) `
        "Install JDK $major and set JAVA${major}_HOME (or JDK${major}_HOME) to its installation directory."
}

$wrapper = Join-Path $appRoot 'mvnw.cmd'
$properties = Join-Path $appRoot '.mvn\wrapper\maven-wrapper.properties'
$wrapperVersion = ''
if (Test-Path $properties) {
    $distribution = Select-String -Path $properties -Pattern 'apache-maven-(\d+\.\d+\.\d+)-bin' | Select-Object -First 1
    if ($distribution) { $wrapperVersion = $distribution.Matches[0].Groups[1].Value }
}
$wrapperOkay = (Test-Path $wrapper) -and $wrapperVersion -and ([version]$wrapperVersion -ge [version]'3.8.0')
Add-ReadinessResult $results 'Maven wrapper 3.8+' $wrapperOkay `
    $(if ($wrapperOkay) { "mvnw.cmd is configured for Maven $wrapperVersion." } else { 'A usable Maven 3.8+ wrapper was not detected in the Java app.' }) `
    'Restore the imported Maven wrapper files; do not replace the application build manually.'

$mvn = Get-CommandPath 'mvn'
if ($mvn) {
    $mvnVersion = Invoke-ReadinessCommand $mvn @('--version')
    $systemOkay = $mvnVersion.ExitCode -eq 0 -and $mvnVersion.Output -match 'Apache Maven ([0-9.]+)' -and ([version]$Matches[1] -ge [version]'3.8.0')
    Add-ReadinessResult $results 'Maven 3.8+ or wrapper' ($systemOkay -or $wrapperOkay) `
        $(if ($systemOkay) { ($mvnVersion.Output -split "`n")[0] } elseif ($wrapperOkay) { "System Maven is unsuitable, but mvnw.cmd provides Maven $wrapperVersion." } else { ($mvnVersion.Output -split "`n")[0] }) `
        'Install Maven 3.8+ or restore the checked-in Maven wrapper.'
} else {
    Add-ReadinessResult $results 'Maven 3.8+ or wrapper' $wrapperOkay `
        $(if ($wrapperOkay) { "mvn is not on PATH; mvnw.cmd provides Maven $wrapperVersion." } else { 'Neither Maven 3.8+ nor a usable wrapper was found.' }) `
        'Install Maven 3.8+ or restore the checked-in Maven wrapper.'
}

Complete-ReadinessCheck $results
