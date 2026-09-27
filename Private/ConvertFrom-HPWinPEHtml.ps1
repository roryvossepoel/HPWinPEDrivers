function ConvertFrom-HPWinPEHtml {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Html,

        [Parameter(Mandatory)]
        [uri]$BaseUri
    )

    $rows = [regex]::Matches($Html, '(?is)<tr\b[^>]*>(.*?)</tr>')
    $result = foreach ($row in $rows) {
        $cells = @(
            [regex]::Matches($row.Groups[1].Value, '(?is)<t[dh]\b[^>]*>(.*?)</t[dh]>') |
                ForEach-Object {
                    $text = [regex]::Replace($_.Groups[1].Value, '(?is)<[^>]+>', ' ')
                    $text = [System.Net.WebUtility]::HtmlDecode($text)
                    ([regex]::Replace($text, '\s+', ' ')).Trim()
                }
        )

        if ($cells.Count -lt 5 -or $cells[0] -ne 'WinPE 10/11') {
            continue
        }

        $softPaq = ([regex]::Match($cells[2], '(?i)sp\d+')).Value.ToLowerInvariant()
        if (-not $softPaq) {
            continue
        }

        $hrefs = @(
            [regex]::Matches($row.Groups[1].Value, '(?is)href\s*=\s*["'']([^"'']+)["'']') |
                ForEach-Object { [System.Net.WebUtility]::HtmlDecode($_.Groups[1].Value) }
        )

        $downloadHref = $hrefs |
            Where-Object { $_ -match '(?i)sp\d+\.exe(?:\?|$)' } |
            Select-Object -First 1

        if (-not $downloadHref) {
            continue
        }

        $releaseNotesHref = $hrefs |
            Where-Object { $_ -ne $downloadHref } |
            Select-Object -First 1

        $releaseDate = [datetime]::MinValue
        $dateParsed = [datetime]::TryParseExact(
            $cells[3],
            'MM/dd/yyyy',
            [System.Globalization.CultureInfo]::InvariantCulture,
            [System.Globalization.DateTimeStyles]::None,
            [ref]$releaseDate
        )
        if (-not $dateParsed) {
            $releaseDate = $null
        }

        $downloadUri = [uri]::new($BaseUri, $downloadHref)
        $releaseNotesUri = if ($releaseNotesHref) { [uri]::new($BaseUri, $releaseNotesHref) } else { $null }

        $item = [pscustomobject]@{
            PSTypeName      = 'HPWinPEDrivers.DriverPack'
            Manufacturer    = 'HP'
            WinPE           = $cells[0]
            Version         = $cells[1]
            SoftPaq         = $softPaq
            ReleaseDate     = $releaseDate
            Architecture    = 'x64'
            FileName        = "$softPaq.exe"
            DownloadUrl     = $downloadUri.AbsoluteUri
            ReleaseNotesUrl = if ($releaseNotesUri) { $releaseNotesUri.AbsoluteUri } else { $null }
            SourceUrl       = $BaseUri.AbsoluteUri
        }
        $item.PSObject.TypeNames.Insert(0, 'HPWinPEDrivers.DriverPack')
        $item
    }

    @($result | Sort-Object ReleaseDate -Descending)
}
