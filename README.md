# The Chain

> "Grow with solidarity and trust. A social experiment."

**The Chain** is a minimalist social experience that combines social curiosity, viral dynamics, and collective accountability. It's a viral social network where participants form a single, global chain by inviting one person each through time-limited QR code tickets.

> ⚠️ **Project Name Warning:** The repository folder is named `ticketz`, but this is **not** a support ticket system. The project is "The Chain," and "tickets" are the time-limited invitations used to grow the chain.

## 🔗 Concept

A single, global chain connects everyone, starting from one seed user. Every new participant must be attached by another user through a one-time, time-limited invitation ticket. The goal is to collaboratively grow the chain as long as possible.

## 🎯 Core Mechanics

- **Automatic Tickets**: Upon joining, each user **automatically receives** one shareable QR code ticket. **Users do not generate tickets manually.**
- **Time Limit**: Tickets expire after **24 hours**.
- **3-Strike Rule**: If a user's invitation ticket expires unused 3 times, that user is **removed** from the chain. This is logged as 3 "strikes."
- **Chain Reversion**: If a user is removed, the ability to invite passes back to their inviter, who can then "save" the chain by inviting someone new.
- **Limited Visibility**: Each user can only see their direct inviter and the person they invited, maintaining privacy and focus.
- **Chain Key**: Each user receives a unique, permanent "Chain Key" as proof of their position in the chain.
- **One & Done**: Once a user successfully invites someone, their primary obligation is complete. They become a permanent link.

## 🏗️ Architecture

The project uses a modern, containerized architecture:

- **Frontend**: A single Flutter application (for Web, iOS, and Android) that serves as the user-facing dashboard. It provides a public, read-only view for unauthenticated users and a full-featured experience for logged-in members.
- **Backend**: Java Spring Boot microservices handle business logic, authentication, and data management.
- **Database**: PostgreSQL for primary data storage and Redis for caching and session management.
- **Real-time**: WebSockets are used for live updates of chain statistics and events.
- **Infrastructure**: The entire stack is containerized with Docker and orchestrated with Docker Compose for consistent development and deployment.

## 📁 Project Structure

The repository is organized into the following key directories:

```
ticketz/
├── docs/              # Project documentation
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
