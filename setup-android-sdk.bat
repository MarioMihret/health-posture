@echo off
echo Setting up Android SDK for Flutter APK build...
echo.

REM Create directory for Android SDK
set ANDROID_HOME=%USERPROFILE%\android-sdk
mkdir "%ANDROID_HOME%" 2>nul

echo Please follow these steps:
echo.
echo 1. Download Command Line Tools from:
echo    https://developer.android.com/studio#command-line-tools-only
echo.
echo 2. Extract the downloaded zip to:
echo    %ANDROID_HOME%\cmdline-tools\latest\
echo.
echo 3. Run this command after extraction:
echo    "%ANDROID_HOME%\cmdline-tools\latest\bin\sdkmanager" --install "platform-tools" "platforms;android-34" "build-tools;34.0.0"
echo.
echo 4. Set environment variables:
setx ANDROID_HOME "%ANDROID_HOME%"
setx PATH "%PATH%;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\cmdline-tools\latest\bin"

echo.
echo Press any key to open the download page...
pause >nul
start https://developer.android.com/studio#command-line-tools-only
