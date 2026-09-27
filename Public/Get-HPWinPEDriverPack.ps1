function Get-HPWinPEDriverPack {
    <#
    .SYNOPSIS
        Discovers HP Client Windows PE 10/11 driver packs from HP's official catalog.

    .DESCRIPTION
        Reads HP's current Windows PE driver pack page dynamically. By default, the newest
        WinPE 10/11 x64 driver pack is returned. Use -All to return every WinPE 10/11 pack
        currently listed by HP, or filter by exact version or SoftPaq number.

    .PARAMETER All
        Return every WinPE 10/11 driver pack currently listed by HP.

    .PARAMETER Version
        Return the driver pack with this exact HP pack version.

    .PARAMETER SoftPaq
        Return the driver pack with this SoftPaq number, for example sp173204.

    .EXAMPLE
        Get-HPWinPEDriverPack

    .EXAMPLE
        Get-HPWinPEDriverPack -All

    .EXAMPLE
        Get-HPWinPEDriverPack -Version '3.40'
    #>
    [CmdletBinding(DefaultParameterSetName = 'Latest')]
    param(
        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(Mandatory, ParameterSetName = 'Version')]
        [string]$Version,

        [Parameter(Mandatory, ParameterSetName = 'SoftPaq')]
        [string]$SoftPaq
    )

    $packs = @(Get-HPWinPECatalog)

    switch ($PSCmdlet.ParameterSetName) {
        'All' {
            $packs
        }
        'Version' {
            $matches = @($packs | Where-Object Version -eq $Version)
            if ($matches.Count -eq 0) {
                throw "HP WinPE driver pack version '$Version' was not found in the current HP catalog."
            }
            $matches
        }
        'SoftPaq' {
            $normalized = $SoftPaq.ToLowerInvariant()
            $matches = @($packs | Where-Object SoftPaq -eq $normalized)
            if ($matches.Count -eq 0) {
                throw "HP WinPE driver pack SoftPaq '$SoftPaq' was not found in the current HP catalog."
            }
            $matches
        }
        default {
            $packs | Select-Object -First 1
        }
    }
}
