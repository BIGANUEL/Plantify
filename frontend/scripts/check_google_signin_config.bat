@echo off
REM Google Sign-In Configuration Checker for Windows
REM This script verifies Google Sign-In configuration for Android

echo ==========================================
echo Google Sign-In Configuration Checker
echo ==========================================
echo.

REM Check if we're in the frontend directory
if not exist "android" (
    echo Error: This script must be run from the frontend directory
    exit /b 1
)

echo 1. Checking Package Name...
findstr /C:"applicationId" android\app\build.gradle.kts >nul 2>&1
if %errorlevel% neq 0 (
    echo    [X] Could not find package name in build.gradle.kts
) else (
    echo    [OK] Package name found in build.gradle.kts
    echo    Please verify it matches: com.example.plantify
)
echo.

echo 2. Checking Google Client ID...
findstr /C:"googleClientId" lib\core\constants\app_constants.dart >nul 2>&1
if %errorlevel% neq 0 (
    echo    [X] Could not find Google Client ID in app_constants.dart
) else (
    echo    [OK] Client ID found in app_constants.dart
    echo    Please verify it matches your Google Cloud Console Client ID
)
echo.

echo 3. Getting SHA-1 Fingerprint...
cd android
if exist "gradlew.bat" (
    echo    Running gradlew signingReport...
    call gradlew.bat signingReport > ..\..\gradle_output.txt 2>&1
    
    echo    [OK] Gradle report generated
    echo    Please check gradle_output.txt for SHA-1 fingerprint
    echo    Look for "SHA1:" under "Variant: debug"
) else (
    echo    [X] gradlew.bat not found
)
cd ..
echo.

echo 4. Verification Checklist:
echo    Please verify the following in Google Cloud Console:
echo    https://console.cloud.google.com/apis/credentials
echo.
echo    [ ] OAuth client type is 'Android' (not 'Web' or 'Installed')
echo    [ ] Package name matches exactly: com.example.plantify
echo    [ ] SHA-1 fingerprint is added (check gradle_output.txt)
echo    [ ] Client ID matches your app_constants.dart
echo    [ ] Wait 5-10 minutes after making changes in Google Cloud Console
echo.

echo 5. Common Issues:
echo    - If SignInHubActivity opens and closes immediately:
echo      → Check SHA-1 fingerprint is correct
echo      → Verify package name matches exactly (case-sensitive)
echo      → Ensure OAuth client type is 'Android'
echo      → Wait 5-10 minutes after updating Google Cloud Console
echo.
echo    - Error code 10 (DEVELOPER_ERROR):
echo      → SHA-1 fingerprint mismatch
echo      → Package name mismatch
echo      → Wrong Client ID
echo.

echo ==========================================
echo Check complete!
echo ==========================================
pause

