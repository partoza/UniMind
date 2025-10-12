@echo off
echo Switching to PRODUCTION mode...
copy lib\main_production.dart lib\main.dart
echo ✅ Switched to PRODUCTION mode
echo You can now run: flutter run
pause
