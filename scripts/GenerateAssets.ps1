param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot "..\src\Unidecode\Assets")
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$resolvedOutput = [System.IO.Path]::GetFullPath($OutputDirectory)
[System.IO.Directory]::CreateDirectory($resolvedOutput) | Out-Null

function New-UnidecodeImage {
    param(
        [Parameter(Mandatory)] [string]$Name,
        [Parameter(Mandatory)] [int]$Width,
        [Parameter(Mandatory)] [int]$Height
    )

    $bitmap = [System.Drawing.Bitmap]::new($Width, $Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.Clear([System.Drawing.Color]::FromArgb(0, 120, 212))
        $fontSize = [Math]::Max(10, [Math]::Floor([Math]::Min($Width, $Height) * 0.55))
        $font = [System.Drawing.Font]::new("Segoe UI", $fontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
        $brush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
        $format = [System.Drawing.StringFormat]::new()
        try {
            $format.Alignment = [System.Drawing.StringAlignment]::Center
            $format.LineAlignment = [System.Drawing.StringAlignment]::Center
            $graphics.DrawString("U", $font, $brush, [System.Drawing.RectangleF]::new(0, 0, $Width, $Height), $format)
        }
        finally {
            $format.Dispose()
            $brush.Dispose()
            $font.Dispose()
        }

        $path = Join-Path $resolvedOutput $Name
        $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

New-UnidecodeImage "SplashScreen.scale-200.png" 1240 600
New-UnidecodeImage "LockScreenLogo.scale-200.png" 48 48
New-UnidecodeImage "Square150x150Logo.scale-200.png" 300 300
New-UnidecodeImage "Square44x44Logo.scale-200.png" 88 88
New-UnidecodeImage "Square44x44Logo.targetsize-24_altform-unplated.png" 24 24
New-UnidecodeImage "StoreLogo.png" 50 50
New-UnidecodeImage "Wide310x150Logo.scale-200.png" 620 300
Write-Host "Generated MSIX assets in $resolvedOutput"
