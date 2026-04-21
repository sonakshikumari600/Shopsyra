@echo off
echo ========================================
echo Building ShopSyra User App APK
echo ========================================
echo.

echo Step 1: Cleaning previous builds...
call flutter clean
echo.

echo Step 2: Getting dependencies...
call flutter pub get
echo.

echo Step 3: Building APK (Release)...
call flutter build apk --release
echo.

echo ========================================
echo Build Complete!
echo ========================================
echo.
echo APK Location:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo You can install this APK on your Android device.
echo.
pause
