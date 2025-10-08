# The Chain - Backend

Spring Boot backend service for The Chain social network.

## Tech Stack

- **Java 17**
- **Spring Boot 3.2**
- **PostgreSQL 15**
- **Redis 7**
- **Maven**

## Features Implemented

- ✅ User registration via invitation tickets
- ✅ JWT authentication
- ✅ Ticket generation with QR codes
- ✅ Ticket signature verification
- ✅ Chain statistics API
- ✅ Device fingerprinting
- ✅ Parent-child relationship management

## Prerequisites

- Docker & Docker Compose
- Java 17+ (for local development)
- Maven 3.9+ (for local development)

## Quick Start

### Using Docker Compose (Recommended)

```bash
# From project root
docker-compose up --build
```

The backend will be available at: `http://localhost:8080/api/v1`

### Local Development

```bash
# Start PostgreSQL and Redis
docker-compose up postgres redis -d

# Run application
cd backend
mvn spring-boot:run
```

## API Endpoints

### Health Check
```
GET /api/v1/auth/health
```

### Authentication
```
POST /api/v1/auth/register
POST /api/v1/auth/login
```

### Tickets
```
POST /api/v1/tickets/generate
GET /api/v1/tickets/{ticketId}
```

### Chain Stats
```
GET /api/v1/chain/stats
```

## Database

PostgreSQL with automatic schema initialization. Seed user "The Seeder" is created automatically.

## Configuration

Environment variables (see `application.yml`):

- `DB_HOST` - Database host (default: localhost)
- `DB_PORT` - Database port (default: 5432)
- `DB_NAME` - Database name (default: chaindb)
- `DB_USER` - Database user
- `DB_PASSWORD` - Database password
- `REDIS_HOST` - Redis host
- `REDIS_PORT` - Redis port
- `JWT_SECRET` - JWT signing secret (MUST change in production)

## Testing

```bash
mvn test
```

## Build

```bash
mvn clean package
```

## Next Steps

- [ ] Implement WebSocket for real-time updates
- [ ] Add proper JWT authentication filter
- [ ] Implement rate limiting
- [ ] Add comprehensive tests
- [ ] Integrate real geocoding service
