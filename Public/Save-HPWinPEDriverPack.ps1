function Save-HPWinPEDriverPack {
    <#
    .SYNOPSIS
        Downloads and extracts an HP Client Windows PE 10/11 driver pack.

    .DESCRIPTION
        Resolves the newest HP WinPE 10/11 x64 driver pack by default, downloads its SoftPaq,
        extracts the driver pack, and publishes the extracted content plus .hpwinpe.json metadata
        to the requested path.

        The SoftPaq executable and extraction workspace are temporary and are removed after a
        successful build. On failure, the temporary directory is preserved for troubleshooting.

    .PARAMETER Path
        Destination folder for the extracted HP WinPE driver repository.

    .PARAMETER Version
        Optional exact HP WinPE driver pack version. When omitted, the newest pack is used.

    .PARAMETER Force
        Rebuild even when the destination metadata records the same version and SoftPaq.

    .PARAMETER Quiet
        Suppress user-facing processing messages.

    .EXAMPLE
        Save-HPWinPEDriverPack -Path 'C:\WinPE\HP'

    .EXAMPLE
        Save-HPWinPEDriverPack -Version '3.40' -Path 'C:\WinPE\HP' -Force
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [string]$Version,

        [switch]$Force,

        [switch]$Quiet
    )

    if (-not (Test-HPWindowsPlatform)) {
        throw 'Save-HPWinPEDriverPack requires Windows because HP SoftPaq executables are used for extraction.'
    }

    $pack = if ($Version) {
        Get-HPWinPEDriverPack -Version $Version | Select-Object -First 1
    }
    else {
        Get-HPWinPEDriverPack
    }

    $metadataPath = Join-Path $Path '.hpwinpe.json'
    if (-not $Force -and (Test-Path -LiteralPath $metadataPath)) {
        try {
            $existing = Get-Content -LiteralPath $metadataPath -Raw | ConvertFrom-Json
            if ($existing.Version -eq $pack.Version -and $existing.SoftPaq -eq $pack.SoftPaq) {
                Write-HPStatus -Message "HP WinPE driver pack $($pack.Version) ($($pack.SoftPaq)) is already current." -Quiet:$Quiet

                $result = [pscustomobject]@{
                    PSTypeName = 'HPWinPEDrivers.Result'
                    Version    = $pack.Version
                    SoftPaq    = $pack.SoftPaq
                    Status     = 'Current'
                    Path       = $Path
                }
                $result.PSObject.TypeNames.Insert(0, 'HPWinPEDrivers.Result')
                return $result
            }
        }
        catch {
            Write-Verbose "Existing HP WinPE metadata could not be read and will be rebuilt: $($_.Exception.Message)"
        }
    }

    if (-not $PSCmdlet.ShouldProcess($Path, "Download and extract HP WinPE driver pack $($pack.Version) ($($pack.SoftPaq))")) {
        return
    }

    $resolvedPath = [IO.Path]::GetFullPath($Path)
    $workingRoot = Split-Path -Parent $resolvedPath
    if (-not $workingRoot) {
        $workingRoot = (Get-Location).Path
    }
    if (-not (Test-Path -LiteralPath $workingRoot)) {
        New-Item -ItemType Directory -Path $workingRoot -Force | Out-Null
    }

    $workingPath = Join-Path $workingRoot ('HPWinPEDrivers-' + [guid]::NewGuid().ToString('N'))
    $softPaqPath = Join-Path $workingPath $pack.FileName
    $extractPath = Join-Path $workingPath 'extracted'
    $stagePath = Join-Path $workingPath 'output'
    $buildSucceeded = $false

    try {
        New-Item -ItemType Directory -Path $workingPath -Force | Out-Null
        New-Item -ItemType Directory -Path $stagePath -Force | Out-Null

        Write-HPStatus -Message "Downloading HP WinPE driver pack $($pack.Version) ($($pack.SoftPaq))..." -Quiet:$Quiet
        Invoke-WebRequest -Uri $pack.DownloadUrl -OutFile $softPaqPath -UseBasicParsing -ErrorAction Stop

        Write-HPStatus -Message 'Extracting HP SoftPaq...' -Quiet:$Quiet
        Expand-HPSoftPaq -SoftPaqPath $softPaqPath -DestinationPath $extractPath

        foreach ($item in @(Get-ChildItem -LiteralPath $extractPath -Force)) {
            Copy-Item -LiteralPath $item.FullName -Destination $stagePath -Recurse -Force
        }

        $metadata = [pscustomobject]@{
            SchemaVersion   = 1
            GeneratedAtUtc  = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
            Manufacturer    = 'HP'
            WinPE           = $pack.WinPE
            Architecture    = $pack.Architecture
            Version         = $pack.Version
            SoftPaq         = $pack.SoftPaq
            ReleaseDate     = if ($pack.ReleaseDate) { $pack.ReleaseDate.ToString('yyyy-MM-dd') } else { $null }
            FileName        = $pack.FileName
            DownloadUrl     = $pack.DownloadUrl
            ReleaseNotesUrl = $pack.ReleaseNotesUrl
            SourceUrl       = $pack.SourceUrl
        }

        $metadata |
            ConvertTo-Json -Depth 10 |
            Set-Content -LiteralPath (Join-Path $stagePath '.hpwinpe.json') -Encoding UTF8

        if (Test-Path -LiteralPath $resolvedPath) {
            Remove-Item -LiteralPath $resolvedPath -Recurse -Force
        }

        Move-Item -LiteralPath $stagePath -Destination $resolvedPath

        $buildSucceeded = $true
        Write-HPStatus -Message "HP WinPE driver pack saved to '$resolvedPath'." -Quiet:$Quiet

        $result = [pscustomobject]@{
            PSTypeName = 'HPWinPEDrivers.Result'
            Version    = $pack.Version
            SoftPaq    = $pack.SoftPaq
            Status     = 'Saved'
            Path       = $resolvedPath
        }
        $result.PSObject.TypeNames.Insert(0, 'HPWinPEDrivers.Result')
        $result
    }
    catch {
        Write-HPStatus -Message "Build failed. Temporary working directory preserved for troubleshooting: '$workingPath'." -Quiet:$Quiet
        throw
    }
    finally {
        if ($buildSucceeded -and (Test-Path -LiteralPath $workingPath)) {
            Remove-Item -LiteralPath $workingPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
