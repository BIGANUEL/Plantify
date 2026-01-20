# PowerShell script to get SHA-1 fingerprint for Google Sign-In
# Run this script from the frontend directory

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "SHA-1 Fingerprint Retriever" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the frontend directory
if (-not (Test-Path "android")) {
    Write-Host "Error: This script must be run from the frontend directory" -ForegroundColor Red
    exit 1
}

Write-Host "Changing to android directory..." -ForegroundColor Yellow
Push-Location android

if (Test-Path "gradlew.bat") {
    Write-Host "Running gradlew signingReport..." -ForegroundColor Yellow
    Write-Host ""
    
    $output = & .\gradlew.bat signingReport 2>&1
    
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "SHA-1 Fingerprint Results:" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Look for SHA1 in the output
    $sha1Lines = $output | Select-String -Pattern "SHA1:" | Select-Object -First 5
    
    if ($sha1Lines) {
        Write-Host "Found SHA-1 fingerprints:" -ForegroundColor Green
        Write-Host ""
        
        foreach ($line in $sha1Lines) {
            # Extract SHA-1 value
            if ($line -match "SHA1:\s*([0-9A-F:]+)") {
                $sha1 = $matches[1]
                Write-Host "  SHA-1: $sha1" -ForegroundColor Green
            } else {
                Write-Host "  $line" -ForegroundColor Yellow
            }
        }
        
        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host "Next Steps:" -ForegroundColor Cyan
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "1. Copy the SHA-1 fingerprint above" -ForegroundColor Yellow
        Write-Host "2. Go to Google Cloud Console:" -ForegroundColor Yellow
        Write-Host "   https://console.cloud.google.com/apis/credentials" -ForegroundColor Cyan
        Write-Host "3. Click on your Android OAuth Client ID" -ForegroundColor Yellow
        Write-Host "4. Add the SHA-1 fingerprint if not already added" -ForegroundColor Yellow
        Write-Host "5. Verify package name: com.example.plantify" -ForegroundColor Yellow
        Write-Host "6. Wait 5-10 minutes for changes to propagate" -ForegroundColor Yellow
        Write-Host ""
    } else {
        Write-Host "Could not find SHA-1 in gradle output." -ForegroundColor Red
        Write-Host ""
        Write-Host "Full output:" -ForegroundColor Yellow
        Write-Host $output
        Write-Host ""
        Write-Host "Please check the output above manually." -ForegroundColor Yellow
    }
} else {
    Write-Host "Error: gradlew.bat not found in android directory" -ForegroundColor Red
    Write-Host "Make sure you're running this from the frontend directory" -ForegroundColor Yellow
}

Pop-Location

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Done!" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

