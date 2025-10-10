@echo off
REM Export OpenAPI spec from running backend (Windows version)

setlocal

if "%BACKEND_URL%"=="" set BACKEND_URL=http://localhost:8080
if "%OUTPUT_FILE%"=="" set OUTPUT_FILE=backend\openapi.json

echo ========================================
echo OpenAPI Specification Export Tool
echo ========================================
echo.

REM Check if backend is running
echo Checking if backend is running at %BACKEND_URL%...
curl -s -f "%BACKEND_URL%/api/v1/actuator/health" > nul 2>&1
if errorlevel 1 (
    echo ERROR: Backend not running on %BACKEND_URL%
    echo.
    echo Please start the backend first:
    echo   - Local: mvn spring-boot:run
    echo   - Docker: docker-compose up -d backend
    echo.
    exit /b 1
)

echo SUCCESS: Backend is running
echo.

REM Fetch OpenAPI spec
echo Fetching OpenAPI specification...
curl -s -o "%OUTPUT_FILE%" "%BACKEND_URL%/api/v1/api-docs"
if errorlevel 1 (
    echo ERROR: Failed to fetch OpenAPI spec
    exit /b 1
)

echo SUCCESS: OpenAPI spec saved to: %OUTPUT_FILE%
echo.

echo Next steps:
echo   - View Swagger UI: %BACKEND_URL%/api/v1/swagger-ui.html
echo   - Generate Flutter client: cd frontend ^&^& ./generate-api-client.sh
echo   - View raw spec: type %OUTPUT_FILE%
echo.
echo Done!

endlocal
