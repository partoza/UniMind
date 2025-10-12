Write-Host "Switching to TEST mode..." -ForegroundColor Green
Copy-Item "lib\main_test.dart" "lib\main.dart" -Force
Write-Host "✅ Switched to TEST mode" -ForegroundColor Green
Write-Host "You can now run: flutter run" -ForegroundColor Yellow
