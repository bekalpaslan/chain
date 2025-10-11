# The Chain

> "Grow with solidarity and trust. A social experiment."

A viral social network where participants form a single, global chain by inviting one person each through time-limited QR code tickets.

## 🔗 Concept

The Chain is a minimalist social experience that combines social curiosity, viral dynamics, and collective accountability. A single chain connects everyone — starting from one seed — and every new participant must be attached through a one-time, time-limited invitation ticket.

## 🎯 Core Mechanics

- Each user generates **one shareable QR code ticket**
- Tickets expire after **24 hours**
- Unused tickets return to sender and are logged as "wasted attempts"
- All attachments are **publicly visible**
- Users receive a unique **Chain Key** upon joining

## 🏗️ Architecture

- **Frontend**: Flutter (iOS, Android, Web/PWA)
- **Backend**: Java Spring Boot microservices
- **Database**: PostgreSQL + Redis
- **Real-time**: WebSocket for live updates

## 📁 Project Structure

```
the-chain/
├── docs/                  # Project documentation
├── backend/              # Spring Boot microservices (coming soon)
├── mobile/               # Flutter application (coming soon)
└── infrastructure/       # Docker, K8s configs (coming soon)
```

## 📚 Documentation

**📖 [Complete Documentation Index](DOCS_INDEX.md)** - Organized guide to all documentation

### Essential Reading
- [Implementation Status](docs/IMPLEMENTATION_STATUS.md) - **PRIMARY REFERENCE** - Complete technical status (v2.4)
- [Deployment Status](DEPLOYMENT_STATUS.md) - Current deployment and access URLs
- [API Specification](docs/API_SPECIFICATION.md) - REST API endpoints and contracts
- [Hybrid Authentication](docs/HYBRID_AUTHENTICATION_IMPLEMENTATION.md) - Email/password + device fingerprint (33/33 tests passing)

### Quick Links
- [Project Definition](docs/PROJECT_DEFINITION.md) - Vision and concept
- [Database Schema](docs/DATABASE_SCHEMA.md) - Database structure and relationships
- [Security Model](docs/SECURITY_MODEL.md) - Security architecture
- [Testing Guide](docs/TESTING_GUIDE.md) - How to run tests
- [Flutter Implementation](docs/FLUTTER_IMPLEMENTATION_COMPLETE.md) - Flutter dual app guide

## 🚀 Getting Started

### Prerequisites
- Docker & Docker Compose
- Java 17+ (for backend development)
- Flutter SDK (for frontend development)

### Quick Start

```bash
# Clone the repository
git clone https://github.com/your-username/ticketz.git
cd ticketz

# Start the backend services
docker-compose up -d

# Access the applications
# - Backend API: http://localhost:8080
# - Public App: http://localhost:3000
# - Private App: http://localhost:3001
```

### Authentication

The Chain supports **hybrid authentication** with two flexible login methods:

1. **Email/Password** - Traditional login with BCrypt password hashing + optional device registration
2. **Device Fingerprint** - Passwordless, zero-friction login using SHA-256 device fingerprinting

**Test with seed user (Email/Password):**
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alpaslan@alpaslan.com",
    "password": "alpaslan"
  }'
```

**Test with device fingerprint:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "web_489323232",
    "deviceFingerprint": "2d23d5f144c842a766b91e0853be834ea85143ff80ba5b6926ac64330a02bc2d"
  }'
```

See [Hybrid Authentication Documentation](docs/HYBRID_AUTHENTICATION_IMPLEMENTATION.md) for complete implementation details.

## 📊 Success Metrics

- Daily new attachments
- Ticket usage rate before expiration
- Chain continuity duration
- Geographic spread
- Retention rates

## 👥 Target Audience

Mobile-first users aged 16-40 who enjoy social experiments, gamification, and global participation.

## 📄 License

*To be determined*

---

**Current Status**: ✅ Backend Deployed | ✅ Flutter Public App Running | 🚀 Phase 3 in Progress

See [DEPLOYMENT_STATUS.md](DEPLOYMENT_STATUS.md) for detailed deployment information.

**Author**: Alpaslan Bek
**Last Updated**: October 9, 2025
