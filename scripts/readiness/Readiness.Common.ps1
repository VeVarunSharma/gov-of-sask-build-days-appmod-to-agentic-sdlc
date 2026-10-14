Set-StrictMode -Version Latest

function Get-RepositoryRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

function New-ReadinessResults {
    return ,([System.Collections.Generic.List[object]]::new())
}

function Add-ReadinessResult {
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [System.Collections.Generic.List[object]] $Results,
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [bool] $Passed,
        [Parameter(Mandatory)] [string] $Detail,
        [Parameter(Mandatory)] [string] $Action
    )

    $Results.Add([pscustomobject]@{
        Name   = $Name
        Passed = $Passed
        Detail = $Detail
        Action = $Action
    })
}

function Invoke-ReadinessCommand {
    param(
        [Parameter(Mandatory)] [string] $Command,
        [Parameter()] [string[]] $Arguments = @()
    )

    try {
        $output = & $Command @Arguments 2>&1 | Out-String
        return [pscustomobject]@{
            ExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
            Output   = $output.Trim()
        }
    }
    catch {
        return [pscustomobject]@{ ExitCode = 1; Output = $_.Exception.Message }
    }
}

function Complete-ReadinessCheck {
    param([Parameter(Mandatory)] [AllowEmptyCollection()] [System.Collections.Generic.List[object]] $Results)

    Write-Host ''
    Write-Host 'Readiness summary'
    Write-Host '-----------------'
    foreach ($result in $Results) {
        $label = if ($result.Passed) { 'PASS' } else { 'FAIL' }
        $color = if ($result.Passed) { 'Green' } else { 'Red' }
        Write-Host "[$label] $($result.Name): $($result.Detail)" -ForegroundColor $color
        if (-not $result.Passed) {
            Write-Host "       Action: $($result.Action)" -ForegroundColor Yellow
        }
    }

    $failed = @($Results | Where-Object { -not $_.Passed })
    Write-Host ''
    Write-Host "$($Results.Count - $failed.Count) passed; $($failed.Count) failed."
    if ($failed.Count -gt 0) {
        exit 1
    }
}

function Get-CommandPath {
    param([Parameter(Mandatory)] [string] $Name)
    $command = Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) { return $command.Source }
    return $null
}
