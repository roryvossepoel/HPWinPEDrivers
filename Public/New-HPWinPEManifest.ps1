function New-HPWinPEManifest {
    <#
    .SYNOPSIS
        Builds a manifest for the current HP Client Windows PE driver pack.

    .DESCRIPTION
        Resolves the newest WinPE 10/11 x64 driver pack from HP's official catalog and writes
        its metadata to JSON. With -Validate, the SoftPaq download URL is also checked.

    .PARAMETER Path
        Destination JSON manifest path.

    .PARAMETER Validate
        Validate that the current SoftPaq URL is reachable.

    .EXAMPLE
        New-HPWinPEManifest -Path '.\HPWinPE.Manifest.json' -Validate
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [switch]$Validate
    )

    $pack = Get-HPWinPEDriverPackInfo
    $urlValidation = $null

    if ($Validate) {
        $urlValidation = Test-HPUri -Uri $pack.DownloadUrl
    }

    $validationStatus = if (-not $Validate -or $urlValidation.Success) { 'Passed' } else { 'Failed' }

    $manifest = [pscustomobject]@{
        SchemaVersion  = 1
        GeneratedAtUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        Source          = $script:WinPEDriverPackUrl
        DriverPack      = $pack
        Validation      = [pscustomobject]@{
            Performed   = [bool]$Validate
            Status      = $validationStatus
            DownloadUrl = $urlValidation
        }
    }

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $manifest | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $Path -Encoding UTF8
    Write-Output $manifest

    if ($Validate -and -not $urlValidation.Success) {
        throw "HP WinPE manifest validation failed. The manifest was written to '$Path' with details."
    }
}
