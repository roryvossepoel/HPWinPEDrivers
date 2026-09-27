function Get-HPWinPECatalog {
    [CmdletBinding()]
    param()

    $response = Invoke-WebRequest -Uri $script:WinPEDriverPackUrl -UseBasicParsing -ErrorAction Stop
    $packs = @(ConvertFrom-HPWinPEHtml -Html $response.Content -BaseUri ([uri]$script:WinPEDriverPackUrl))

    if ($packs.Count -eq 0) {
        throw "No WinPE 10/11 driver packs could be discovered from HP source '$script:WinPEDriverPackUrl'."
    }

    $packs
}
