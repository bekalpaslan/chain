# Build and Deploy Admin Dashboard with New Mystique Components

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Admin Dashboard Build and Deploy" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clean previous builds
Write-Host "[1/5] Cleaning previous builds..." -ForegroundColor Yellow
if (Test-Path "build/web") {
    Remove-Item -Recurse -Force "build/web"
    Write-Host "  [OK] Removed old build directory" -ForegroundColor Green
}
if (Test-Path ".dart_tool") {
    Write-Host "  [OK] Cleaned .dart_tool cache" -ForegroundColor Green
}

# Set Flutter path
$FlutterPath = "C:\Users\alpas\IdeaProjects\flutter\flutter\bin\flutter.bat"

# Step 2: Get Flutter dependencies
Write-Host ""
Write-Host "[2/5] Getting Flutter dependencies..." -ForegroundColor Yellow
& $FlutterPath pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [ERROR] Failed to get dependencies" -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] Dependencies downloaded" -ForegroundColor Green

# Step 3: Build Flutter web app
Write-Host ""
Write-Host "[3/5] Building Flutter web app (this may take 2-3 minutes)..." -ForegroundColor Yellow
& $FlutterPath build web --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [ERROR] Flutter build failed" -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] Flutter web app built successfully" -ForegroundColor Green

# Step 4: Rebuild Docker container
Write-Host ""
Write-Host "[4/5] Rebuilding Docker container..." -ForegroundColor Yellow
Set-Location ../..
docker-compose build admin-dashboard
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [ERROR] Docker build failed" -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] Docker image built" -ForegroundColor Green

# Step 5: Deploy container
Write-Host ""
Write-Host "[5/5] Deploying container..." -ForegroundColor Yellow
docker-compose up -d admin-dashboard
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [ERROR] Deployment failed" -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] Container deployed" -ForegroundColor Green

# Success message
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "[SUCCESS] Build Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Admin Dashboard is now running at:" -ForegroundColor White
Write-Host "  http://localhost:3002" -ForegroundColor Cyan
Write-Host ""
Write-Host "New components integrated:" -ForegroundColor White
Write-Host "  - MystiqueStatusBadge (animated pulsing)" -ForegroundColor Gray
Write-Host "  - MystiqueEmotionIndicator (color-coded)" -ForegroundColor Gray
Write-Host "  - WCAG AA compliant colors" -ForegroundColor Gray
Write-Host ""
Write-Host "Press Ctrl+C to stop viewing logs" -ForegroundColor Yellow

# Show container logs
docker logs -f chain-admin-dashboard
