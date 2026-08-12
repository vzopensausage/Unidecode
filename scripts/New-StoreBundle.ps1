param(
    [Parameter(Mandatory)] [string]$PackagesRoot,
    [Parameter(Mandatory)] [string]$OutputPath
)

$ErrorActionPreference = "Stop"

$resolvedPackagesRoot = [System.IO.Path]::GetFullPath($PackagesRoot)
$resolvedOutputPath = [System.IO.Path]::GetFullPath($OutputPath)
$packageFiles = @(Get-ChildItem -Path $resolvedPackagesRoot -Recurse -Filter "*.msix" -File)

if ($packageFiles.Count -ne 2) {
    throw "Expected exactly two MSIX packages (x64 and ARM64), found $($packageFiles.Count)."
}

$bundleInput = Join-Path ([System.IO.Path]::GetDirectoryName($resolvedOutputPath)) "bundle-input"
[System.IO.Directory]::CreateDirectory($bundleInput) | Out-Null
foreach ($package in $packageFiles) {
    Copy-Item -LiteralPath $package.FullName -Destination (Join-Path $bundleInput $package.Name)
}

$programFilesX86 = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)")
$windowsKitsRoot = Join-Path $programFilesX86 "Windows Kits\10\bin"
$makeAppx = Get-ChildItem -Path $windowsKitsRoot -Recurse -Filter "makeappx.exe" -File |
    Where-Object { $_.Directory.Name -eq "x64" } |
    Sort-Object { [version]$_.Directory.Parent.Name } -Descending |
    Select-Object -First 1

if (-not $makeAppx) {
    throw "makeappx.exe was not found in the Windows SDK."
}

[System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($resolvedOutputPath)) | Out-Null
& $makeAppx.FullName bundle /d $bundleInput /p $resolvedOutputPath /o
if ($LASTEXITCODE -ne 0) {
    throw "makeappx failed with exit code $LASTEXITCODE."
}

Write-Host "Created Store bundle: $resolvedOutputPath"
