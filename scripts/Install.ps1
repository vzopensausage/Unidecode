param(
    [ValidateSet("x64", "ARM64")]
    [string]$Architecture = $(if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "ARM64" } else { "x64" })
)

$ErrorActionPreference = "Stop"
$certificate = Get-ChildItem -Path $PSScriptRoot -Filter "Unidecode.cer" | Select-Object -First 1
$package = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter "*.msix" |
    Where-Object { $_.FullName -match $Architecture } |
    Select-Object -First 1

if (-not $certificate) {
    throw "Unidecode.cer was not found next to this script."
}
if (-not $package) {
    throw "No $Architecture MSIX package was found."
}

Write-Host "Trusting the Unidecode test certificate for the current user..."
Import-Certificate -FilePath $certificate.FullName -CertStoreLocation "Cert:\CurrentUser\TrustedPeople" | Out-Null
Write-Host "Installing $($package.Name)..."
Add-AppxPackage -Path $package.FullName
Write-Host "Installed. Reload extensions from PowerToys Command Palette if Unidecode is not immediately visible."
