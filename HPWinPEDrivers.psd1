@{
    RootModule           = 'HPWinPEDrivers.psm1'
    ModuleVersion        = '1.0.0'
    GUID                 = 'd40d475f-41e6-4ed4-a362-9b74a24277f4'
    Author               = 'Rory Vossepoel'
    CompanyName          = ''
    Copyright            = '(c) 2026 Rory Vossepoel. All rights reserved.'
    Description          = 'Dynamically discovers and downloads the current HP Client Windows PE driver pack.'
    PowerShellVersion    = '5.1'
    CompatiblePSEditions = @('Desktop', 'Core')

    FunctionsToExport    = @(
        'Get-HPWinPEDriverPack',
        'New-HPWinPEManifest',
        'Save-HPWinPEDriverPack'
    )
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()

    PrivateData = @{
        PSData = @{
            Tags         = @('HP', 'WinPE', 'WindowsPE', 'Driver', 'OSD', 'Deployment')
            LicenseUri   = 'https://github.com/roryvossepoel/HPWinPEDrivers/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/roryvossepoel/HPWinPEDrivers'
            ReleaseNotes = 'Initial public release. Dynamically discovers the current HP WinPE 10/11 driver pack, validates source metadata, and builds a local driver repository from the official HP SoftPaq.'
        }
    }
}
