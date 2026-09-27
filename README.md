# HPWinPEDrivers

[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/HPWinPEDrivers?label=PowerShell%20Gallery)](https://www.powershellgallery.com/packages/HPWinPEDrivers)

`HPWinPEDrivers` is a PowerShell module that dynamically discovers and downloads the current HP Client Windows PE driver pack.

> **Note:** Version 1.0.1 renamed the discovery command from `Get-HPWinPEDriverPack` to `Get-HPWinPEDriverPackInfo` to avoid a command-name conflict with the OSD PowerShell module.

The module uses HP's official **HP Client Windows PE Driver Packs** page at runtime. It does not maintain a hardcoded SoftPaq number or driver-pack version.

## Why

HP publishes a generic Windows PE 10/11 x64 driver pack for supported HP business notebooks, desktops, and workstations. That makes repository creation much simpler than model-specific driver sources: discover the newest pack, download the current SoftPaq, extract it, and retain the resulting WinPE driver repository.

`HPWinPEDrivers` automates that process:

1. Read HP's official Windows PE driver-pack catalog.
2. Discover the currently published WinPE 10/11 packs.
3. Select the newest pack by default.
4. Optionally generate and validate a JSON manifest without downloading the SoftPaq.
5. Download the selected SoftPaq.
6. Extract its contents without installing anything.
7. Publish only the extracted driver repository plus metadata.
8. Skip rebuilding when the destination already contains the same HP version and SoftPaq.

The module does **not** inject drivers into a WIM and does not perform operating-system deployment.

## HP source

The module uses this HP-maintained source at runtime:

- [HP Client Windows PE Driver Packs](https://ftp.ext.hp.com/pub/caps-softpaq/cmit/HP_WinPE_DriverPack.html)

HP describes these packages as INF-based Windows PE drivers intended for bare-metal operating-system deployment. They are not intended as full-Windows driver packs.

## Installation

### From GitHub

Clone the repository and import the module manifest:

```powershell
Import-Module .\HPWinPEDrivers.psd1 -Force
```

## Commands

### Discover the current HP WinPE driver pack

```powershell
Get-HPWinPEDriverPackInfo
```

Typical output:

```text
WinPE       Version SoftPaq   ReleaseDate Architecture
-----       ------- -------   ----------- ------------
WinPE 10/11 3.40    sp173204  06/22/2026  x64
```

Return every WinPE 10/11 pack currently listed by HP:

```powershell
Get-HPWinPEDriverPackInfo -All
```

Select a specific published version:

```powershell
Get-HPWinPEDriverPackInfo -Version '3.40'
```

or SoftPaq:

```powershell
Get-HPWinPEDriverPackInfo -SoftPaq 'sp173204'
```

## Manifest / dry run

The current HP publication can be recorded without downloading the SoftPaq:

```powershell
New-HPWinPEManifest -Path '.\HPWinPE.Manifest.json'
```

Validate that the discovered SoftPaq URL is reachable:

```powershell
New-HPWinPEManifest -Path '.\HPWinPE.Manifest.json' -Validate
```

The manifest records the current HP version, SoftPaq, release date, architecture, download URL, release-notes URL, source URL, and validation result.

## Build the driver repository

```powershell
Save-HPWinPEDriverPack -Path 'C:\WinPE\HP'
```

The newest published WinPE 10/11 pack is selected automatically.

A specific published version can also be selected:

```powershell
Save-HPWinPEDriverPack -Version '3.40' -Path 'C:\WinPE\HP'
```

Use `-Force` to rebuild an unchanged destination.

## Output

Example:

```text
C:\WinPE\HP\
├── <HP extracted driver-pack content>
└── .hpwinpe.json
```

The downloaded SoftPaq is temporary working data and is not retained in the final repository.

The `.hpwinpe.json` file records the source version and SoftPaq used to build the repository. A later run compares this metadata with HP's current publication and skips the download when the output is already current.

## HP SoftPaq exit code 1168

The current HP WinPE package `sp173204` has been verified to extract successfully with:

```text
sp173204.exe /s /e /f "<target-path>"
```

while the process still returns exit code `1168`.

Because of that behavior, `HPWinPEDrivers` does not treat exit code `1168` alone as a failed extraction. It accepts `0` and `1168`, but only considers the operation successful when the extraction directory actually contains output. An empty extraction directory still causes the build to fail.

This behavior was reproduced independently outside the module using `Start-Process -Wait -PassThru`, where `sp173204` returned `1168` while creating the expected `WinPE10_3.40` payload.

## Safety and validation

The module intentionally fails rather than silently guessing when:

- HP's source page no longer yields a WinPE 10/11 package;
- a requested version or SoftPaq is no longer present in the current HP table;
- the selected SoftPaq cannot be downloaded;
- SoftPaq extraction returns an unexpected exit code;
- extraction completes without producing content.

If HP changes the HTML structure or current publication, the scheduled live CI smoke test should make that visible.

## Requirements

- Windows is required for `Save-HPWinPEDriverPack` because the HP SoftPaq executable performs the extraction.
- Windows PowerShell 5.1 or PowerShell 7+ is supported by the module manifest.
- Internet access to HP's Client Management Solutions and SoftPaq download hosts is required.

## CI

The repository contains:

- Pester tests for module export and HP table parsing;
- Windows PowerShell 5.1 module import validation;
- Gallery package staging validation;
- a live HP smoke test that discovers the current driver pack and validates its download URL;
- a weekly scheduled smoke test to detect upstream HP catalog changes.

## License

MIT
