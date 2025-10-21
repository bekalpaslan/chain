Write-Host "Setting passwords for all 50 test users..." -ForegroundColor Green

for ($i = 1; $i -le 50; $i++) {
    $username = "testuser_{0:D2}" -f $i
    Write-Host "Setting password for $username..." -ForegroundColor Yellow

    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/temp/set-password" `
            -Method POST `
            -Body @{
                username = $username
                password = "password123"
            } `
            -ContentType "application/x-www-form-urlencoded"

        Write-Host "Success: $($response.message)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to set password for $username : $_" -ForegroundColor Red
    }

    # Small delay to avoid overwhelming the server
    Start-Sleep -Milliseconds 100
}

Write-Host "`nAll passwords have been set!" -ForegroundColor Green