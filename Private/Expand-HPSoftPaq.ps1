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

    # HP documents extraction as:
    #   /s /e /f <target-path>
    #
    # Start-Process joins ArgumentList items into a single command line. Quote the
    # target path explicitly so profile paths containing spaces survive parsing.
    $argumentLine = '/s /e /f "{0}"' -f $DestinationPath

    $process = Start-Process -FilePath $SoftPaqPath -ArgumentList $argumentLine -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        throw "HP SoftPaq extraction failed with exit code $($process.ExitCode)."
    }

    if (-not (Get-ChildItem -LiteralPath $DestinationPath -Force | Select-Object -First 1)) {
        throw 'HP SoftPaq extraction completed but the destination directory is empty.'
    }
}
