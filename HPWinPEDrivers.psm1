Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:WinPEDriverPackUrl = 'https://ftp.ext.hp.com/pub/caps-softpaq/cmit/HP_WinPE_DriverPack.html'

$privateScripts = Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'Private') -Filter '*.ps1' -File | Sort-Object Name
$publicScripts  = Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'Public')  -Filter '*.ps1' -File | Sort-Object Name

foreach ($scriptFile in @($privateScripts) + @($publicScripts)) {
    . $scriptFile.FullName
}

Update-TypeData -TypeName 'HPWinPEDrivers.DriverPack' -DefaultDisplayPropertySet @(
    'WinPE', 'Version', 'SoftPaq', 'ReleaseDate', 'Architecture'
) -Force

Update-TypeData -TypeName 'HPWinPEDrivers.Result' -DefaultDisplayPropertySet @(
    'Version', 'SoftPaq', 'Status', 'Path'
) -Force

Export-ModuleMember -Function @(
    'Get-HPWinPEDriverPack',
    'New-HPWinPEManifest',
    'Save-HPWinPEDriverPack'
)
