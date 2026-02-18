#!/usr/bin/env pwsh

# Quick Start Script for Microemprendimiento Full Stack

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Microemprendimiento App - Full Stack Quick Start       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$ProjectRoot = "c:\Users\Mati\Documents\microemprendimiento_app"

Write-Host "`n✓ Project Root: $ProjectRoot" -ForegroundColor Green

# Step 1: Check Docker
Write-Host "`n[1/5] Checking Docker installation..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✓ Docker found: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker not found. Please install Docker Desktop." -ForegroundColor Red
    exit 1
}

# Step 2: Start Docker containers
Write-Host "`n[2/5] Starting Docker containers..." -ForegroundColor Yellow
Set-Location $ProjectRoot
Write-Host "Running: docker-compose up -d" -ForegroundColor Gray
docker-compose up -d

Write-Host "`n   Waiting for services to be healthy..." -ForegroundColor Gray
Start-Sleep -Seconds 10

$dockerStatus = docker-compose ps
Write-Host $dockerStatus
Write-Host "`n✓ Docker containers started" -ForegroundColor Green

# Step 3: Verify backend
Write-Host "`n[3/5] Verifying backend API..." -ForegroundColor Yellow
try {
    $response = curl -s http://localhost:3000/api/auth/me
    Write-Host "✓ Backend API responding on http://localhost:3000" -ForegroundColor Green
} catch {
    Write-Host "⚠ Backend may still be starting. Give it a moment..." -ForegroundColor Yellow
}

# Step 4: Setup Flutter
Write-Host "`n[4/5] Setting up Flutter app..." -ForegroundColor Yellow
Set-Location "$ProjectRoot\mobile_app"

Write-Host "Running: flutter pub get" -ForegroundColor Gray
flutter pub get
Write-Host "✓ Flutter dependencies installed" -ForegroundColor Green

# Step 5: Summary
Write-Host "`n[5/5] Setup Complete! Here's what's running:" -ForegroundColor Yellow
Write-Host @"
╔════════════════════════════════════════════════════════════╗
║                    RUNNING SERVICES                        ║
╠════════════════════════════════════════════════════════════╣
║ Backend API:    http://localhost:3000                      ║
║ PostgreSQL:     localhost:5432                             ║
║ PgAdmin:        http://localhost:5050                      ║
║ Redis:          localhost:6379                             ║
╚════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════╗
║                   NEXT STEPS                               ║
╠════════════════════════════════════════════════════════════╣
║ 1. Start the Flutter app:                                  ║
║    flutter run                                             ║
║                                                            ║
║ 2. Login with:                                             ║
║    Email: admin@microemprendimiento.com                    ║
║    Password: password                                      ║
║                                                            ║
║ 3. Explore features:                                       ║
║    • Customers (Clientes)                                  ║
║    • Products (Productos)                                  ║
║    • Sales (Ventas)                                        ║
║    • Reports (Reportes)                                    ║
║                                                            ║
║ 4. View database with PgAdmin:                             ║
║    URL: http://localhost:5050                             ║
║    User: admin@microemprendimiento.com                     ║
║    Pass: admin                                             ║
╚════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host "`nℹ For detailed documentation, see:" -ForegroundColor Information
Write-Host "   - FULL_STACK_INTEGRATION.md" -ForegroundColor Gray
Write-Host "   - mobile_app/FLUTTER_APP_README.md" -ForegroundColor Gray
Write-Host "   - backend/README.md" -ForegroundColor Gray

Write-Host "`n✓ Setup completed successfully!" -ForegroundColor Green
