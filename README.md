# The Chain

> "Grow with solidarity and trust. A social experiment."

**The Chain** is a minimalist social experience that combines social curiosity, viral dynamics, and collective accountability. It's a viral social network where participants form a single, global chain by inviting one person each through time-limited QR code tickets.

> ⚠️ **Project Name Warning:** The repository folder is named `ticketz`, but this is **not** a support ticket system. The project is "The Chain," and "tickets" are the time-limited invitations used to grow the chain.

## 🔗 Concept

A single, global chain connects everyone, starting from one seed user. Every new participant must be attached by another user through a one-time, time-limited invitation ticket. The goal is to collaboratively grow the chain as long as possible.

## 🎯 Core Mechanics

### Two-Tier Membership System

- **Candidates (Probationary Period)**: New users start as "candidates" and must prove themselves by successfully inviting someone.
- **Permanent Members (Verified)**: Users become "permanent" when their invitee successfully invites someone else (achieving depth-2 in the chain).

### Ticket System

- **Automatic Tickets**: Upon joining, each candidate **automatically receives** one shareable QR code ticket. **Users do not generate tickets manually.**
- **Variable Time Limits**: Tickets expire with decreasing time windows:
  - First attempt: **24 hours**
  - Second attempt: **12 hours** (after first strike)
  - Third attempt: **6 hours** (after second strike)
- **3-Strike Rule**: If a candidate's ticket expires unused 3 times, they are **removed** from the chain.
- **Smart Chain Reversion**: When a candidate fails, the ticket reverts to the **last permanent member** up the chain (not just the immediate parent), preventing cascading failures.
- **Limited Visibility**: Each user can only see their direct inviter and the person they invited, maintaining privacy and focus.
- **Chain Key**: Each user receives a unique, permanent "Chain Key" as proof of their position in the chain.
- **Progression Path**: Candidate → Successfully invite someone → Their invitee invites someone → **Promoted to Permanent!**

## 🏗️ Architecture

The project uses a modern, containerized architecture:

- **Frontend**: A single Flutter application (for Web, iOS, and Android) that serves as the user-facing dashboard. It provides a public, read-only view for unauthenticated users and a full-featured experience for logged-in members.
- **Backend**: Java Spring Boot microservices handle business logic, authentication, and data management.
- **Database**: PostgreSQL for primary data storage and Redis for caching and session management.
- **Real-time**: WebSockets are used for live updates of chain statistics and events.
- **Infrastructure**: The entire stack is containerized with Docker and orchestrated with Docker Compose for consistent development and deployment.

## 🚀 Latest Updates

**November 5, 2025**: Successfully implemented the **Candidate/Permanent Membership System**!
- Two-tier membership with automatic promotions
- Variable ticket expiration times (24h → 12h → 6h)
- Smart chain reversion to last permanent member
- Full documentation in [docs/IMPLEMENTATION_PROGRESS.md](docs/IMPLEMENTATION_PROGRESS.md)

## 📁 Project Structure

The repository is organized into the following key directories:

```
ticketz/
├── docs/              # Project documentation
│   ├── IMPLEMENTATION_PROGRESS.md  # Latest development status
│   └── DATABASE_SCHEMA.md         # Complete schema documentation
├── backend/           # Java Spring Boot microservices
├── frontend/          # Flutter application (single app for all platforms)
│   ├── private-app/   # Source code for the main Flutter app
│   └── shared/        # Shared Dart code (API client, models)
├── docker-compose.yml # Main Docker orchestration file
└── README.md          # This file
```

## 📚 Key Documentation

- **[NEXT_STEPS_ROADMAP.md](NEXT_STEPS_ROADMAP.md)**: The most up-to-date development plan.
- **[docs/IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md)**: Detailed technical status of the backend and infrastructure.
- **[docs/API_SPECIFICATION.md](docs/API_SPECIFICATION.md)**: REST API endpoints and contracts.
- **[docs/DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md)**: The complete database structure.

## 🚀 Getting Started

### Prerequisites
- Docker & Docker Compose
- Java 17+ (for native backend development)
- Flutter SDK (for native frontend development)

### Quick Start

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/ticketz.git
    cd ticketz
    ```
2.  **Start all services:**
    ```bash
    docker-compose up -d
    ```
3.  **Access the application:**
    - **Web App**: [http://localhost:3001](http://localhost:3001)
    - **Backend API**: [http://localhost:8080](http://localhost:8080)

## 🔐 Authentication

The application uses a hybrid authentication system.

> ⚠️ **Password Management**: Never update passwords directly in the database, as Spring Security's BCrypt hashing will cause them to fail. **Always use the API endpoint** to set or reset passwords.
> ```bash
> # Example: Set a user's password
> curl -X POST http://localhost:8080/api/v1/users/set-password \
>   -H "Content-Type: application/json" \
>   -d '{ "email": "user@example.com", "newPassword": "yourpassword" }'
> ```

### Login Methods:
1.  **Email/Password**: Traditional login with BCrypt password hashing.
2.  **Device Fingerprint**: Passwordless login using a SHA-256 device fingerprint.

See [docs/HYBRID_AUTHENTICATION_IMPLEMENTATION.md](docs/HYBRID_AUTHENTICATION_IMPLEMENTATION.md) for complete details.

## 📄 License

*To be determined*
