function Expand-HPSoftPaq {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SoftPaqPath,

        [Parameter(Mandatory)]
        [string]$DestinationPath
    )

    if (-not (Test-HPWindowsPlatform)) {
        throw 'HP SoftPaq extraction requires Windows.'
    }

    if (-not (Test-Path -LiteralPath $DestinationPath)) {
        New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
    }

    # Newer HP SoftPaqs can be strict about switch formatting. Use the compact
    # extraction syntax that works with the current HP WinPE SoftPaq:
    #   spxxxxx.exe /e -fC:\Path\To\Extract /s
    $argumentLine = '/e -f{0} /s' -f $DestinationPath

    $process = Start-Process -FilePath $SoftPaqPath -ArgumentList $argumentLine -Wait -PassThru

    $hasContent = [bool](Get-ChildItem -LiteralPath $DestinationPath -Force | Select-Object -First 1)

    # Some HP SoftPaqs return 1168 even after a successful extraction.
    # Treat that code as success only when extraction actually produced content.
    $acceptedExitCodes = @(0, 1168)
    if ($process.ExitCode -notin $acceptedExitCodes) {
        throw "HP SoftPaq extraction failed with exit code $($process.ExitCode)."
    }

    if (-not $hasContent) {
        throw "HP SoftPaq extraction returned exit code $($process.ExitCode), but the destination directory is empty."
    }
}
