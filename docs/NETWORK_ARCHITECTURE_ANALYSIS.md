# Network & Integration Architecture Analysis

## Executive Summary

The Chain application currently has a **complex multi-layer architecture** with multiple deployment scenarios running simultaneously:
- **Production Docker Stack**: Nginx + Backend + PostgreSQL + Redis (Containers)
- **Development Services**: Flutter dev server + Background Spring Boot instances
- **Static Frontend**: Simple HTML landing page

## Current Network Topology

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                                 │
├─────────────────────────────────────────────────────────────────────┤
│ Browser → Port 80    (Nginx/Docker)     → Flutter Web Production    │
│ Browser → Port 3000  (Flutter Dev)      → Flutter Web Development   │
│ Browser → Port 8085  (Python Server)    → HTML Landing Page         │
│ Mobile  → Port 8080  (10.0.2.2)        → Android Emulator          │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│                         PROXY LAYER                                  │
├─────────────────────────────────────────────────────────────────────┤
│ Nginx Container (chain-nginx)                                       │
│ • Port 80 → Serves Flutter build from /usr/share/nginx/html        │
│ • /api/* → Proxy to host.docker.internal:8080                      │
│ • /api/v1/ws/* → WebSocket proxy to backend                        │
│ • Gzip compression, caching, security headers                      │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│                      APPLICATION LAYER                               │
├─────────────────────────────────────────────────────────────────────┤
│ Backend Container (chain-backend) - Port 8080                       │
│ • Spring Boot 3.2.0 with context path /api/v1                      │
│ • REST API + WebSocket endpoints                                    │
│ • JWT authentication, CORS enabled                                  │
│ • Connection pooling: HikariCP (20 max)                            │
│                                                                      │
│ Background Services (Native processes):                             │
│ • Port 8081 - Spring Boot (attempted, likely failed)               │
│ • Process 79cb08 - Spring Boot prod profile                        │
│ • Process b7edd5 - Spring Boot port 8081                           │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│                         DATA LAYER                                   │
├─────────────────────────────────────────────────────────────────────┤
│ PostgreSQL Container (chain-postgres) - Port 5432                   │
│ • Database: chaindb                                                 │
│ • Connection pool: 5-20 connections                                 │
│ • Health checks every 10s                                           │
│                                                                      │
│ Redis Container (chain-redis) - Port 6379                           │
│ • Cache layer, 256MB max memory                                     │
│ • LRU eviction policy                                               │
│ • Lettuce pool: 2-8 connections                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Port Allocation Matrix

| Port | Service | Container/Process | Status | Purpose |
|------|---------|------------------|---------|----------|
| 80 | Nginx | chain-nginx (Docker) | ✅ Active | Production web server |
| 3000 | Flutter Dev | Native processes (2x) | ⚠️ Redundant | Development server |
| 5432 | PostgreSQL | chain-postgres (Docker) | ✅ Active | Database |
| 6379 | Redis | chain-redis (Docker) | ✅ Active | Cache |
| 8080 | Spring Boot | chain-backend (Docker) | ✅ Active | Backend API |
| 8081 | Spring Boot | Native (attempted) | ❌ Failed | Unused instance |
| 8085 | Python HTTP | Native | ❓ Unknown | Legacy frontend |

## Service Communication Patterns

### 1. Client → Backend Communication

#### Docker Stack (Production Path)
```
Client → :80 (Nginx) → host.docker.internal:8080 → Backend Container
         ↓                                            ↓
    Static Files                                 PostgreSQL + Redis
```

#### Direct Access (Development Path)
```
Client → :8080 (Direct) → Backend Container → PostgreSQL + Redis
Client → :3000 (Flutter) → localhost:8080 → Backend Container
```

### 2. WebSocket Communication
```
Client WebSocket → :80/api/v1/ws/* → Nginx Upgrade → :8080/api/v1/ws/chain
                                      ↓
                              Connection: upgrade
                              Upgrade: websocket
```

### 3. Inter-Service Communication
```
Backend Container ←→ PostgreSQL Container (TCP :5432)
                 ←→ Redis Container (TCP :6379)

Network: chain-network (Docker bridge)
```

## Integration Points Analysis

### 1. Frontend Integration Points

#### Flutter Web (Mobile App)
- **URL Configuration**: Platform-aware (kIsWeb detection)
- **Web**: `http://localhost:8080/api/v1`
- **Android**: `http://10.0.2.2:8080/api/v1`
- **WebSocket**: `ws://localhost:8080/api/v1/ws/chain`

#### HTML Landing Page
- **Static fetch**: `http://localhost:8080/api/v1/chain/stats`
- **Polling**: 30-second intervals
- **No authentication required**

### 2. Backend Integration Points

#### REST API Endpoints
- `/auth/**` - Public (registration, login)
- `/tickets/**` - Public (legacy)
- `/chain/stats` - Public (statistics)
- `/chain/my-info` - Authenticated
- `/actuator/**` - Public (health, metrics)

#### Security Configuration
- CORS: All origins allowed (development)
- JWT: 1-hour access, 30-day refresh
- Headers: X-User-Id required for authenticated endpoints

### 3. Database Integration
```yaml
PostgreSQL:
  - URL: jdbc:postgresql://postgres:5432/chaindb
  - Pool: 5-20 connections (HikariCP)
  - Timeout: 30s connect, 10m idle, 30m max lifetime

Redis:
  - URL: redis://redis:6379
  - Pool: 2-8 connections (Lettuce)
  - Timeout: 2s
```

## Architecture Issues & Recommendations

### 🔴 Critical Issues

1. **Multiple Backend Instances**
   - **Problem**: Background processes on ports 8080/8081 conflict with Docker
   - **Impact**: Resource waste, port conflicts, confusion
   - **Solution**: Kill all native processes, use only Docker

2. **Redundant Frontend Services**
   - **Problem**: Flutter dev server (2 instances) + Nginx + Python server
   - **Impact**: Port 3000 conflict, resource duplication
   - **Solution**: Use only Nginx for production, Flutter dev for development

3. **Nginx Health Check Failing**
   - **Status**: "unhealthy" in docker-compose ps
   - **Likely Cause**: `/health` endpoint configuration
   - **Solution**: Verify nginx.docker.conf health location

### 🟡 Performance Concerns

1. **Connection Pool Sizing**
   - PostgreSQL: 20 max connections might be high for single backend
   - Redis: 8 connections sufficient
   - Recommendation: Monitor actual usage, reduce to 10 PostgreSQL connections

2. **WebSocket Timeout**
   - Current: 7 days (excessive)
   - Recommendation: 1 hour with ping/pong keepalive

3. **Static Asset Caching**
   - Current: 1 year for all assets
   - Issue: Flutter chunks change frequently
   - Solution: Hash-based filenames, shorter cache for main.dart.js

### 🟢 Best Practices Implemented

1. **Container Isolation**: Proper Docker networking
2. **Health Checks**: All services have health endpoints
3. **Reverse Proxy**: Nginx handles SSL termination (when configured)
4. **Platform Detection**: Flutter adapts to web/mobile
5. **Environment Variables**: Configuration externalized

## Network Security Analysis

### Current State
```
✅ Internal Docker network isolation
✅ Proxy headers (X-Real-IP, X-Forwarded-For)
✅ Security headers (X-Frame-Options, X-Content-Type-Options)
❌ HTTPS not configured
❌ CORS too permissive (all origins)
❌ No rate limiting
❌ JWT secret in plain text
❌ No network segmentation
```

### Recommended Security Improvements

1. **Enable HTTPS**
   ```nginx
   listen 443 ssl http2;
   ssl_certificate /etc/nginx/ssl/cert.pem;
   ssl_protocols TLSv1.2 TLSv1.3;
   ```

2. **Restrict CORS**
   ```java
   .allowedOrigins("https://thechain.app")
   .allowedMethods("GET", "POST", "PUT", "DELETE")
   ```

3. **Add Rate Limiting**
   ```nginx
   limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
   location /api/ {
       limit_req zone=api burst=20 nodelay;
   }
   ```

## Data Flow Diagram

```
User Action → Frontend → API Request → Backend Processing → Database
     ↓            ↓           ↓              ↓                ↓
   Input    Flutter/HTML   HTTP/WS    Spring Boot      PostgreSQL
                            ↓              ↓                ↓
                         Nginx Proxy   Business Logic   Persistence
                            ↓              ↓                ↓
                         Load Balance  JWT Validation    Transaction
                            ↓              ↓                ↓
                         SSL Termination  Redis Cache    Response
                                          ↓
                                     WebSocket Push → Client Update
```

## Scalability Analysis

### Current Limitations
1. **Single Backend Instance**: No horizontal scaling
2. **Database on Same Host**: I/O contention
3. **No Load Balancing**: Single point of failure
4. **Stateful WebSockets**: Complicates scaling

### Scaling Path
```
Phase 1: Current (Single Host)
├── All services in Docker
└── Single backend instance

Phase 2: Horizontal Scaling
├── Multiple backend containers
├── Nginx load balancing
└── Redis for session sharing

Phase 3: Distributed
├── Kubernetes deployment
├── Separate database host
├── CDN for static assets
└── Message queue for async

Phase 4: Global Scale
├── Multi-region deployment
├── Database replication
├── Edge caching (CloudFlare)
└── Microservices architecture
```

## Monitoring & Observability

### Current Monitoring
- Docker health checks
- Spring Boot Actuator endpoints
- Basic logging to stdout

### Missing Observability
- No metrics aggregation
- No distributed tracing
- No log aggregation
- No performance monitoring
- No error tracking

### Recommended Stack
```yaml
Metrics: Prometheus + Grafana
Logging: ELK Stack (Elasticsearch, Logstash, Kibana)
Tracing: Jaeger or Zipkin
APM: DataDog or New Relic
Errors: Sentry
```

## Cost Analysis

### Current Resource Usage
```
Service         CPU    Memory    Disk
Nginx           <1%    10 MB     50 MB
Backend         5-10%  500 MB    100 MB
PostgreSQL      2%     50 MB     500 MB
Redis           <1%    10 MB     10 MB
Flutter Dev     5%     200 MB    0 MB
-------------------------------------------
Total           ~15%   770 MB    660 MB
```

### Production Deployment Costs (Estimated)
```
AWS t3.medium (2 vCPU, 4GB RAM): $30/month
RDS PostgreSQL: $15/month
ElastiCache Redis: $13/month
CloudFront CDN: $5/month
Total: ~$63/month

Alternative (DigitalOcean):
Droplet 2GB: $12/month
Managed PostgreSQL: $15/month
Total: ~$27/month
```

## Recommendations Summary

### Immediate Actions
1. ✅ Kill redundant background processes
2. ✅ Fix Nginx health check
3. ✅ Choose single frontend strategy
4. ✅ Document current architecture

### Short-term (1-2 weeks)
1. Configure HTTPS with Let's Encrypt
2. Implement proper CORS restrictions
3. Add rate limiting
4. Set up basic monitoring (Prometheus/Grafana)
5. Externalize configuration properly

### Medium-term (1-2 months)
1. Implement horizontal scaling
2. Add centralized logging
3. Set up CI/CD pipeline
4. Implement blue-green deployment
5. Add integration tests

### Long-term (3-6 months)
1. Migrate to Kubernetes
2. Implement microservices where appropriate
3. Add global CDN
4. Implement event-driven architecture
5. Multi-region deployment

## Conclusion

The current architecture demonstrates good containerization practices but suffers from **service redundancy** and **missing production features**. The Docker-based deployment provides a solid foundation, but immediate cleanup of redundant processes and proper SSL configuration are critical for production readiness.

**Architecture Score: 6/10**
- ✅ Good: Containerization, separation of concerns
- ⚠️ Needs Work: Security, monitoring, redundancy
- ❌ Missing: HTTPS, rate limiting, production config

---

Generated with Claude Code - Network Architecture Analysis