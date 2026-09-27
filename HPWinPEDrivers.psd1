@{
    RootModule           = 'HPWinPEDrivers.psm1'
    ModuleVersion        = '0.1.0'
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
            ReleaseNotes = 'Initial preview implementation.'
        }
    }
}
