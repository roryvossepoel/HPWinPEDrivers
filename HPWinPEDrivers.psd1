@{
    RootModule           = 'HPWinPEDrivers.psm1'
    ModuleVersion        = '1.0.1'
    GUID                 = 'd40d475f-41e6-4ed4-a362-9b74a24277f4'
    Author               = 'Rory Vossepoel'
    CompanyName          = ''
    Copyright            = '(c) 2026 Rory Vossepoel. All rights reserved.'
    Description          = 'PowerShell module to dynamically discover, validate, download, and extract the current HP Windows PE 10/11 driver pack from HP''s official SoftPaq catalog.'
    PowerShellVersion    = '5.1'
    CompatiblePSEditions = @('Desktop', 'Core')

    FunctionsToExport    = @(
        'Get-HPWinPEDriverPackInfo',
        'New-HPWinPEManifest',
        'Save-HPWinPEDriverPack'
    )
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()

    PrivateData = @{
        PSData = @{
            Tags         = @('HP', 'WinPE', 'WindowsPE', 'Driver', 'Drivers', 'OSD', 'Deployment', 'SoftPaq', 'Automation')
            LicenseUri   = 'https://github.com/roryvossepoel/HPWinPEDrivers/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/roryvossepoel/HPWinPEDrivers'
            ReleaseNotes = 'Renames Get-HPWinPEDriverPack to Get-HPWinPEDriverPackInfo to avoid a command-name conflict with the OSD PowerShell module. No alias is retained, allowing HPWinPEDrivers to be installed alongside OSD without -AllowClobber.'
        }
    }
}
