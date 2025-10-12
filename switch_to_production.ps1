Write-Host "Switching to PRODUCTION mode..." -ForegroundColor Green
Copy-Item "lib\main_production.dart" "lib\main.dart" -Force
Write-Host "✅ Switched to PRODUCTION mode" -ForegroundColor Green
Write-Host "You can now run: flutter run" -ForegroundColor Yellow
