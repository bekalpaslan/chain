# Database Dumps

This directory contains database dumps for various states of The Chain application.

## Available Dumps

### `initial_state_dump.sql`
- **Description**: Clean initial state with only the seed user
- **Created**: 2025-10-20
- **Contents**:
  - Seed user (alpaslan / alpaslan)
    - Position: #1
    - Display name: "The Seeder"
    - Chain key: SEED00000001
    - Email verified: true
  - Default chain rules (version 1)
  - Predefined badges (chain_savior, chain_guardian, chain_legend)
  - All empty tables ready for use

## How to Restore a Dump

### Option 1: Using Docker (Recommended)

```bash
# Stop the backend service
docker-compose stop backend

# Restore the dump to the running PostgreSQL container
docker exec -i chain-postgres psql -U chain_user -d chaindb < backend/src/main/resources/db/dumps/initial_state_dump.sql

# Restart the backend
docker-compose up -d backend
```

### Option 2: Complete Reset with Dump

```bash
# Stop all services
docker-compose down

# Remove database volume
docker volume rm ticketz_postgres_data

# Start only database
docker-compose up -d postgres

# Wait for database to be ready
sleep 5

# Restore the dump
docker exec -i chain-postgres psql -U chain_user -d chaindb < backend/src/main/resources/db/dumps/initial_state_dump.sql

# Start all services
docker-compose up -d
```

### Option 3: Using psql directly (if you have local PostgreSQL client)

```bash
psql -h localhost -p 5432 -U chain_user -d chaindb < backend/src/main/resources/db/dumps/initial_state_dump.sql
```

## Creating New Dumps

To create a new dump of the current database state:

```bash
# Create a dump with timestamp
docker exec chain-postgres pg_dump -U chain_user -d chaindb --clean --if-exists > backend/src/main/resources/db/dumps/dump_$(date +%Y%m%d_%H%M%S).sql

# Or create a named dump for a specific state
docker exec chain-postgres pg_dump -U chain_user -d chaindb --clean --if-exists > backend/src/main/resources/db/dumps/state_description.sql
```

## Dump Format

All dumps use the following options:
- `--clean`: Include commands to clean (drop) database objects before recreating them
- `--if-exists`: Use IF EXISTS when dropping objects to avoid errors if they don't exist
- Plain SQL format for easy inspection and version control

## Notes

- Dumps include the complete database schema and data
- Flyway migration history is preserved in dumps
- All dumps are in plain SQL format for readability and Git-friendliness
- Password hashes are included (BCrypt format)
