@echo off
REM Script to generate new upload keystore and export certificate for Google Play upload key reset

echo ========================================
echo Generate Upload Key for Google Play Reset
echo ========================================
echo.
echo This script will:
echo 1. Generate a new upload keystore
echo 2. Export the certificate as PEM file
echo.
echo IMPORTANT: Remember the password you set!
echo.
pause

echo.
echo Step 1: Generating new upload keystore...
echo.
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Failed to generate keystore!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Step 2: Exporting certificate as PEM...
echo ========================================
echo.

keytool -export -rfc -keystore upload-keystore.jks -alias upload -file upload_certificate.pem

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo SUCCESS!
    echo ========================================
    echo.
    echo Files created:
    echo - upload-keystore.jks (KEEP THIS SAFE!)
    echo - upload_certificate.pem (Upload this to Google Play Console)
    echo.
    echo Next steps:
    echo 1. Go back to Google Play Console
    echo 2. Upload the file: upload_certificate.pem
    echo 3. Select your reason for reset
    echo 4. Submit the request
    echo.
    echo After approval, update android/key.properties with:
    echo   storePassword=YOUR_PASSWORD
    echo   keyPassword=YOUR_PASSWORD
    echo   keyAlias=upload
    echo   storeFile=app/upload-keystore.jks
    echo.
) else (
    echo.
    echo ERROR: Failed to export certificate!
    echo Make sure you entered the correct password.
    echo.
)

pause

