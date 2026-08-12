param(
    [Parameter(Mandatory)] [string]$IdentityName,
    [Parameter(Mandatory)] [string]$Publisher,
    [Parameter(Mandatory)] [string]$PublisherDisplayName,
    [string]$ManifestPath = (Join-Path $PSScriptRoot "..\src\Unidecode\Package.appxmanifest")
)

$ErrorActionPreference = "Stop"

foreach ($value in @{
    IdentityName = $IdentityName
    Publisher = $Publisher
    PublisherDisplayName = $PublisherDisplayName
}.GetEnumerator()) {
    if ([string]::IsNullOrWhiteSpace($value.Value)) {
        throw "$($value.Key) cannot be empty."
    }
}

$resolvedManifest = [System.IO.Path]::GetFullPath($ManifestPath)
[xml]$manifest = [System.IO.File]::ReadAllText($resolvedManifest)
$manifest.Package.Identity.Name = $IdentityName
$manifest.Package.Identity.Publisher = $Publisher
$manifest.Package.Properties.PublisherDisplayName = $PublisherDisplayName

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

Write-Host "Applied Microsoft Store package identity '$IdentityName'."
