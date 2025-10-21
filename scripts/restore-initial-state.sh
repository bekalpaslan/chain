#!/bin/bash

# Script to restore database to initial state
# Usage: ./scripts/restore-initial-state.sh

set -e

echo "=========================================="
echo "Restoring Database to Initial State"
echo "=========================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running"
    exit 1
fi

# Check if database container is running
if ! docker ps | grep -q chain-postgres; then
    echo "Error: PostgreSQL container (chain-postgres) is not running"
    echo "Please start it with: docker-compose up -d postgres"
    exit 1
fi

echo ""
echo "This will:"
echo "  1. Drop all existing data"
echo "  2. Restore the initial state (seed user only)"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Restore cancelled"
    exit 0
fi

echo ""
echo "Stopping backend service..."
docker-compose stop backend

echo "Restoring database dump..."
docker exec -i chain-postgres psql -U chain_user -d chaindb < backend/src/main/resources/db/dumps/initial_state_dump.sql

echo "Restarting backend service..."
docker-compose up -d backend

echo ""
echo "=========================================="
echo "Database Restored Successfully!"
echo "=========================================="
echo ""
echo "Seed user credentials:"
echo "  Username: alpaslan"
echo "  Password: alpaslan"
echo "  Position: #1"
echo "  Display name: The Seeder"
echo ""
echo "You can now login at: http://localhost:3000"
echo "=========================================="
