Add-Type -AssemblyName System.Drawing

$width = 256
$height = 256
$bmp = New-Object System.Drawing.Bitmap($width, $height)
$rnd = New-Object System.Random

# Generate grayscale noise
for($y = 0; $y -lt $height; $y++) {
    for($x = 0; $x -lt $width; $x++) {
        $gray = $rnd.Next(120, 180)
        $color = [System.Drawing.Color]::FromArgb(255, $gray, $gray, $gray)
        $bmp.SetPixel($x, $y, $color)
    }
}

# Save the image
$outputPath = Join-Path $PSScriptRoot "assets\noise.png"
$bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

Write-Host "Noise texture generated: $outputPath"
