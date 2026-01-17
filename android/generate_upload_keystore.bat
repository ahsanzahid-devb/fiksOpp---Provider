@echo off
REM Script to generate a new upload keystore after Google Play upload key reset
REM Run this AFTER you've completed the upload key reset in Google Play Console

echo ========================================
echo Upload Keystore Generator
echo ========================================
echo.
echo This script will help you generate a new upload keystore.
echo Make sure you have completed the upload key reset in Google Play Console first!
echo.
pause

set /p KEYSTORE_NAME="Enter keystore filename (e.g., upload-keystore.jks): "
set /p KEY_ALIAS="Enter key alias (e.g., upload): "
set /p VALIDITY="Enter validity in days (default 10000): "

if "%VALIDITY%"=="" set VALIDITY=10000

echo.
echo Generating keystore...
echo.

keytool -genkey -v -keystore app\%KEYSTORE_NAME% -keyalg RSA -keysize 2048 -validity %VALIDITY% -alias %KEY_ALIAS%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Keystore generated successfully!
    echo ========================================
    echo.
    echo Location: android\app\%KEYSTORE_NAME%
    echo.
    echo Now verify the SHA-1 fingerprint:
    keytool -list -v -keystore app\%KEYSTORE_NAME% -alias %KEY_ALIAS%
    echo.
    echo IMPORTANT: Compare the SHA-1 fingerprint above with the one shown in Google Play Console!
    echo.
    echo Next steps:
    echo 1. Update android\key.properties with your keystore details
    echo 2. Build your app: flutter build appbundle --release
    echo.
) else (
    echo.
    echo ERROR: Failed to generate keystore. Please check the error messages above.
    echo.
)

pause

