function Write-HPStatus {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [switch]$Quiet
    )

    if (-not $Quiet) {
        Write-Host $Message
    }
}
