function Test-HPUri {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Uri
    )

    try {
        $response = Invoke-WebRequest -Uri $Uri -Method Head -UseBasicParsing -MaximumRedirection 5 -ErrorAction Stop
        [pscustomobject]@{
            Success    = $true
            StatusCode = [int]$response.StatusCode
            Error      = $null
        }
    }
    catch {
        try {
            $response = Invoke-WebRequest -Uri $Uri -Method Get -UseBasicParsing -MaximumRedirection 5 -Headers @{ Range = 'bytes=0-0' } -ErrorAction Stop
            [pscustomobject]@{
                Success    = $true
                StatusCode = [int]$response.StatusCode
                Error      = $null
            }
        }
        catch {
            [pscustomobject]@{
                Success    = $false
                StatusCode = $null
                Error      = $_.Exception.Message
            }
        }
    }
}
