[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$gerberArchive = Join-Path $projectRoot 'Gerber_PCB_MicroAmplifier_2022-04-06.zip'
$bomPath = Join-Path $projectRoot 'BOM_PCB_MicroAmplifier_2022-04-06.csv'
$pickAndPlacePath = Join-Path $projectRoot 'PickAndPlace_PCB_MicroAmplifier_2022-04-06.csv'

$expectedEntries = @(
    'Drill_NPTH_Through.DRL',
    'Drill_PTH_Through.DRL',
    'Gerber_TopLayer.GTL',
    'Gerber_BottomLayer.GBL',
    'Gerber_TopSilkscreenLayer.GTO',
    'Gerber_BottomSilkscreenLayer.GBO',
    'Gerber_TopPasteMaskLayer.GTP',
    'Gerber_TopSolderMaskLayer.GTS',
    'Gerber_BottomSolderMaskLayer.GBS',
    'Gerber_BoardOutlineLayer.GKO'
)

Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($gerberArchive)
try {
    $entryNames = @($archive.Entries | ForEach-Object FullName)
    $missingEntries = @($expectedEntries | Where-Object { $_ -notin $entryNames })
    if ($missingEntries.Count -gt 0) {
        throw "File produttivi mancanti: $($missingEntries -join ', ')"
    }

    foreach ($entry in $archive.Entries) {
        if ([String]::IsNullOrWhiteSpace($entry.Name)) { continue }
        if ($entry.FullName.Contains('..') -or [IO.Path]::IsPathRooted($entry.FullName)) {
            throw "Percorso non sicuro nell'archivio: $($entry.FullName)"
        }
        $reader = New-Object IO.StreamReader($entry.Open())
        try { $content = $reader.ReadToEnd() } finally { $reader.Dispose() }
        if ($entry.Name -match '\.(GTL|GBL|GTO|GBO|GTP|GTS|GBS|GKO)$' -and $content -notmatch '%MOMM\*%') {
            throw "Unità metriche non dichiarate in $($entry.Name)"
        }
        if ($entry.Name -match '\.DRL$' -and $content -notmatch '(?m)^METRIC') {
            throw "Unità metriche non dichiarate in $($entry.Name)"
        }
    }
}
finally {
    $archive.Dispose()
}

$bom = @(Import-Csv -LiteralPath $bomPath -Delimiter "`t")
$placements = @(Import-Csv -LiteralPath $pickAndPlacePath -Delimiter "`t")
$bomDesignators = @(
    $bom | ForEach-Object { $_.Designator -split ',' } | ForEach-Object { $_.Trim() } | Sort-Object -Unique
)
$placementDesignators = @($placements.Designator | Sort-Object -Unique)
$missingPlacements = @($bomDesignators | Where-Object { $_ -notin $placementDesignators })
$unexpectedPlacements = @($placementDesignators | Where-Object { $_ -notin $bomDesignators })

if ($missingPlacements.Count -gt 0 -or $unexpectedPlacements.Count -gt 0) {
    throw "BOM e Pick-and-Place non coincidono. Mancanti: $($missingPlacements -join ', '); inattesi: $($unexpectedPlacements -join ', ')"
}

$totalQuantity = ($bom | Measure-Object -Property Quantity -Sum).Sum
if ([int]$totalQuantity -ne $placements.Count) {
    throw "Quantità BOM ($totalQuantity) diversa dalle posizioni Pick-and-Place ($($placements.Count))."
}

[pscustomobject]@{
    Result = 'PASS'
    GerberAndDrillFiles = $expectedEntries.Count
    BomRows = $bom.Count
    Components = [int]$totalQuantity
    PickAndPlaceRows = $placements.Count
    Units = 'Metric'
}
