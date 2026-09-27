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

    # HP SoftPaq generations are sensitive to the exact /f syntax.
    # Use the compact form shown in HP examples and recent working reports:
    #   spxxxxx.exe /e -fC:\Path\To\Extract /s
    $arguments = @(
        '/e',
        ('-f{0}' -f $DestinationPath),
        '/s'
    )

    $process = Start-Process -FilePath $SoftPaqPath -ArgumentList $arguments -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        throw "HP SoftPaq extraction failed with exit code $($process.ExitCode)."
    }

    if (-not (Get-ChildItem -LiteralPath $DestinationPath -Force | Select-Object -First 1)) {
        throw 'HP SoftPaq extraction completed but the destination directory is empty.'
    }
}
