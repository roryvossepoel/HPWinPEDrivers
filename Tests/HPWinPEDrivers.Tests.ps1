Import-Module (Join-Path $PSScriptRoot '..\HPWinPEDrivers.psd1') -Force

Describe 'HPWinPEDrivers module' {
    It 'exports the expected public commands' {
        $commands = @(Get-Command -Module HPWinPEDrivers | Select-Object -ExpandProperty Name)
        $commands | Should -Contain 'Get-HPWinPEDriverPack'
        $commands | Should -Contain 'New-HPWinPEManifest'
        $commands | Should -Contain 'Save-HPWinPEDriverPack'
    }

    It 'has a valid module manifest' {
        { Test-ModuleManifest (Join-Path $PSScriptRoot '..\HPWinPEDrivers.psd1') -ErrorAction Stop } |
            Should -Not -Throw
    }
}

Describe 'ConvertFrom-HPWinPEHtml' {
    InModuleScope HPWinPEDrivers {
        It 'parses and orders WinPE 10/11 packs while ignoring legacy WinPE rows' {
            $html = @'
<table>
<tr><th>HP WinPE Driver Pack</th><th>Version</th><th>SoftPaq #</th><th>Date</th><th>SoftPaq Exe</th><th>Release Notes</th></tr>
<tr>
<td>WinPE 10/11</td><td>3.30</td><td>sp172442</td><td>04/30/2026</td>
<td><a href="../../softpaq/sp172001-172500/sp172442.exe">sp172442</a></td>
<td><a href="softpaq/WinPE11.html">Release Notes</a></td>
</tr>
<tr>
<td>WinPE 10/11</td><td>3.40</td><td>sp173204</td><td>06/22/2026</td>
<td><a href="../../softpaq/sp173001-173500/sp173204.exe">sp173204</a></td>
<td><a href="softpaq/WinPE11.html">Release Notes</a></td>
</tr>
<tr>
<td>WinPE 5</td><td>1.03</td><td>sp71912</td><td>09/14/2015</td>
<td><a href="sp71912.exe">sp71912</a></td><td></td>
</tr>
</table>
'@

            $packs = @(ConvertFrom-HPWinPEHtml -Html $html -BaseUri ([uri]'https://ftp.ext.hp.com/pub/caps-softpaq/cmit/HP_WinPE_DriverPack.html'))

            $packs.Count | Should -Be 2
            $packs[0].Version | Should -Be '3.40'
            $packs[0].SoftPaq | Should -Be 'sp173204'
            $packs[0].Architecture | Should -Be 'x64'
            $packs[0].DownloadUrl | Should -Be 'https://ftp.ext.hp.com/pub/softpaq/sp173001-173500/sp173204.exe'
            $packs[1].Version | Should -Be '3.30'
        }
    }
}
