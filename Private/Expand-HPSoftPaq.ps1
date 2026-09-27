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
    #   spxxxxx.exe /s /e /f "C:\Path\To\Extract"
    #
    # The current HP WinPE SoftPaq (sp173204) has been verified to extract
    # successfully with this syntax while returning process exit code 1168.
    $argumentLine = '/s /e /f "{0}"' -f $DestinationPath

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
