# Docker Setup Guide - The Chain

## Prerequisites

- Docker Desktop installed
- Docker Compose installed
- At least 4GB RAM available for Docker

## Quick Start

### 1. Start All Services

```bash
docker-compose up -d
```

This will start:
- PostgreSQL (port 5432)
- Redis (port 6379)
- Spring Boot Backend (port 8080)

### 2. Check Service Health

```bash
# Check all containers status
docker-compose ps

# Check backend health endpoint
curl http://localhost:8080/api/v1/actuator/health

# View backend logs
docker-compose logs -f backend
```

### 3. Stop All Services

```bash
docker-compose down
```

### 4. Stop and Remove All Data

```bash
docker-compose down -v
```

## Development Workflow

### Building Backend Only

```bash
docker-compose build backend
```

### Restart Backend After Code Changes

```bash
docker-compose restart backend
```

### View Logs

```bash
# All services
docker-compose logs -f

# Backend only
docker-compose logs -f backend

# PostgreSQL only
docker-compose logs -f postgres
```

### Connect to PostgreSQL

```bash
docker exec -it chain-postgres psql -U chain_user -d chaindb
```

### Connect to Redis CLI

```bash
docker exec -it chain-redis redis-cli
```

## Environment Variables

Copy `.env.example` to `.env` and customize:

```bash
cp .env.example .env
```

**Important:** Change `JWT_SECRET` in production!

## API Endpoints

Once running, the backend is available at:

- Base URL: `http://localhost:8080/api/v1`
- Health: `http://localhost:8080/api/v1/actuator/health`
- Metrics: `http://localhost:8080/api/v1/actuator/metrics`

### Test Authentication

```bash
# Register a new user
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "latitude": 52.52,
    "longitude": 13.405
  }'
```

## Troubleshooting

### Backend won't start

1. Check if PostgreSQL is healthy:
   ```bash
   docker-compose ps postgres
   ```

2. Check backend logs:
   ```bash
   docker-compose logs backend
   ```

3. Verify database schema loaded:
   ```bash
   docker exec -it chain-postgres psql -U chain_user -d chaindb -c "\dt"
   ```

### Port conflicts

If ports are already in use, edit `docker-compose.yml`:

```yaml
services:
  backend:
    ports:
      - "8081:8080"  # Change host port
```

### Reset everything

```bash
docker-compose down -v
docker system prune -a
docker-compose up -d --build
```

## Production Considerations

1. **Change JWT_SECRET** - Use a secure random string
2. **Use environment variables** - Don't commit secrets
3. **Enable SSL/TLS** - Add reverse proxy (nginx/traefik)
4. **Set up monitoring** - Prometheus + Grafana
5. **Configure backups** - Regular PostgreSQL backups
6. **Resource limits** - Set memory/CPU limits in docker-compose

## Architecture

```
┌─────────────┐
│   Flutter   │
│  Mobile App │
└──────┬──────┘
       │ HTTP/WebSocket
       │
┌──────▼──────────────────────────┐
│     Spring Boot Backend         │
│  (Docker: chain-backend)        │
│  Port: 8080                     │
└──────┬──────────────────┬───────┘
       │                  │
       │                  │
┌──────▼──────┐   ┌───────▼──────┐
│ PostgreSQL  │   │    Redis     │
│   (chaindb) │   │   (cache)    │
│  Port: 5432 │   │  Port: 6379  │
└─────────────┘   └──────────────┘
```

## Next Steps

1. Connect Flutter mobile app to `http://localhost:8080`
2. Update `mobile/lib/core/config/api_config.dart`:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:8080/api/v1'; // Android Emulator
   // or
   static const String baseUrl = 'http://localhost:8080/api/v1'; // iOS Simulator
   ```
3. Test end-to-end user registration flow
