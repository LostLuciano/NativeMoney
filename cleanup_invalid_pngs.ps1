# Script to clean up invalid PNG files
# These files are JPEG files with .png extension that cause pngcrush errors during build
# Run this script after closing Xcode

$files = @("welcome_card.png", "splash_logo.png", "onboarding_wallet.png", "onboarding_robot.png")
$basePath = "MonassistNative"

Write-Host "Cleaning up invalid PNG files..."
Write-Host "Make sure Xcode is closed before running this script!"
Write-Host ""

foreach ($file in $files) {
    $fullPath = Join-Path $basePath $file
    
    if (Test-Path $fullPath) {
        try {
            Remove-Item $fullPath -Force
            Write-Host "✓ Deleted $file"
        } catch {
            Write-Host "✗ Error deleting $file : $_"
        }
    } else {
        Write-Host "⚠ File not found: $file"
    }
}

Write-Host ""
Write-Host "Cleanup complete!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Run: git status"
Write-Host "2. Run: git add -A"
Write-Host "3. Run: git commit -m 'chore: remove invalid PNG files'"
Write-Host "4. Run: git push origin main"
