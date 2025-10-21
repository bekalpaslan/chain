@echo off
echo Setting passwords for all 50 test users...

for /L %%i in (1,1,50) do (
    set NUM=%%i
    if %%i lss 10 (
        set USERNAME=testuser_0%%i
    ) else (
        set USERNAME=testuser_%%i
    )

    echo Setting password for !USERNAME!...
    curl -X POST "http://localhost:8080/temp/set-password?username=!USERNAME!&password=password123" -H "Content-Type: application/x-www-form-urlencoded"
    echo.
    timeout /t 1 /nobreak > nul
)