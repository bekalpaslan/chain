@echo off
REM Start Nginx for The Chain Application
REM This script assumes Nginx is installed at C:\nginx

echo ============================================
echo The Chain - Starting Nginx Web Server
echo ============================================
echo.

REM Check if Nginx is installed
if not exist "C:\nginx\nginx.exe" (
    echo ERROR: Nginx not found at C:\nginx\nginx.exe
    echo.
    echo Please install Nginx first:
    echo 1. Download from: https://nginx.org/en/download.html
    echo 2. Extract to C:\nginx
    echo 3. Run this script again
    echo.
    pause
    exit /b 1
)

REM Check if configuration file exists
if not exist "%~dp0nginx.conf" (
    echo ERROR: nginx.conf not found in project directory
    echo Expected location: %~dp0nginx.conf
    echo.
    pause
    exit /b 1
)

REM Copy configuration to Nginx
echo Copying configuration file...
copy /Y "%~dp0nginx.conf" "C:\nginx\conf\nginx.conf" >nul
if %errorlevel% neq 0 (
    echo ERROR: Failed to copy configuration file
    echo You may need to run this script as Administrator
    pause
    exit /b 1
)
echo Configuration copied successfully!
echo.

REM Test configuration
echo Testing Nginx configuration...
cd /d C:\nginx
nginx.exe -t
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Nginx configuration test failed
    echo Please check the configuration file
    pause
    exit /b 1
)
echo Configuration test passed!
echo.

REM Check if Nginx is already running
tasklist /fi "imagename eq nginx.exe" 2>nul | find /i "nginx.exe" >nul
if %errorlevel% equ 0 (
    echo Nginx is already running. Reloading configuration...
    nginx.exe -s reload
    echo Configuration reloaded!
) else (
    echo Starting Nginx...
    start nginx.exe
    echo Nginx started!
)

echo.
echo ============================================
echo Nginx is now running!
echo ============================================
echo.
echo Web Application: http://localhost
echo Backend API:     http://localhost/api/v1
echo Health Check:    http://localhost/health
echo.
echo To stop Nginx, run: stop-nginx.bat
echo To view logs:    C:\nginx\logs\
echo.
echo ============================================
pause
