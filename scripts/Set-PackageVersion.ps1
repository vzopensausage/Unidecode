param(
    [Parameter(Mandatory)] [string]$Tag,
    [string]$ManifestPath = (Join-Path $PSScriptRoot "..\src\Unidecode\Package.appxmanifest")
)

$ErrorActionPreference = "Stop"
$versionText = $Tag.TrimStart("v").Split("-")[0]
$parts = $versionText.Split(".")
if ($parts.Count -lt 1 -or $parts.Count -gt 4 -or ($parts | Where-Object { $_ -notmatch '^\d+$' })) {
    throw "Tag '$Tag' does not contain a valid numeric version. Expected v1, v1.2, v1.2.3, or v1.2.3.4."
}

$normalized = @($parts + @("0", "0", "0", "0"))[0..3] -join "."
foreach ($part in $normalized.Split(".")) {
    if ([int]$part -gt 65535) {
        throw "Each MSIX version component must be between 0 and 65535."
    }
}

$resolvedManifest = [System.IO.Path]::GetFullPath($ManifestPath)
[xml]$manifest = [System.IO.File]::ReadAllText($resolvedManifest)
$manifest.Package.Identity.Version = $normalized
$settings = [System.Xml.XmlWriterSettings]::new()
$settings.Indent = $true
$settings.Encoding = [System.Text.UTF8Encoding]::new($false)
$writer = [System.Xml.XmlWriter]::Create($resolvedManifest, $settings)
try {
    $manifest.Save($writer)
}
finally {
    $writer.Dispose()
}
Write-Host "Set MSIX version to $normalized"
