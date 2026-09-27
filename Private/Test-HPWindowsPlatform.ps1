function Test-HPWindowsPlatform {
    if ($PSVersionTable.PSEdition -eq 'Desktop') {
        return $true
    }

    if (Get-Variable -Name IsWindows -ErrorAction SilentlyContinue) {
        return [bool]$IsWindows
    }

    return ($env:OS -eq 'Windows_NT')
}
