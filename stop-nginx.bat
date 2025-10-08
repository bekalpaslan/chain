@echo off
REM Stop Nginx Web Server

echo ============================================
echo The Chain - Stopping Nginx Web Server
echo ============================================
echo.

REM Check if Nginx is installed
if not exist "C:\nginx\nginx.exe" (
    echo ERROR: Nginx not found at C:\nginx\nginx.exe
    pause
    exit /b 1
)

REM Check if Nginx is running
tasklist /fi "imagename eq nginx.exe" 2>nul | find /i "nginx.exe" >nul
if %errorlevel% neq 0 (
    echo Nginx is not running.
    echo.
    pause
    exit /b 0
)

REM Stop Nginx
echo Stopping Nginx...
cd /d C:\nginx
nginx.exe -s stop

REM Wait a moment
timeout /t 2 /nobreak >nul

REM Verify it stopped
tasklist /fi "imagename eq nginx.exe" 2>nul | find /i "nginx.exe" >nul
if %errorlevel% equ 0 (
    echo Warning: Nginx is still running
    echo Trying to force quit...
    taskkill /f /im nginx.exe >nul 2>&1
) else (
    echo Nginx stopped successfully!
)

echo.
echo ============================================
pause
