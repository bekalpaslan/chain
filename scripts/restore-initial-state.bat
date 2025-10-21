@echo off
REM Script to restore database to initial state (Windows)
REM Usage: scripts\restore-initial-state.bat

echo ==========================================
echo Restoring Database to Initial State
echo ==========================================

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo Error: Docker is not running
    exit /b 1
)

REM Check if database container is running
docker ps | findstr chain-postgres >nul 2>&1
if errorlevel 1 (
    echo Error: PostgreSQL container (chain-postgres) is not running
    echo Please start it with: docker-compose up -d postgres
    exit /b 1
)

echo.
echo This will:
echo   1. Drop all existing data
echo   2. Restore the initial state (seed user only)
echo.
set /p confirm="Are you sure you want to continue? (yes/no): "

if not "%confirm%"=="yes" (
    echo Restore cancelled
    exit /b 0
)

echo.
echo Stopping backend service...
docker-compose stop backend

echo Restoring database dump...
docker exec -i chain-postgres psql -U chain_user -d chaindb < backend\src\main\resources\db\dumps\initial_state_dump.sql

echo Restarting backend service...
docker-compose up -d backend

echo.
echo ==========================================
echo Database Restored Successfully!
echo ==========================================
echo.
echo Seed user credentials:
echo   Username: alpaslan
echo   Password: alpaslan
echo   Position: #1
echo   Display name: The Seeder
echo.
echo You can now login at: http://localhost:3000
echo ==========================================
