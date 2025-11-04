# 🚨 CLAUDE START HERE - Critical Project Context

> **📍 PRIMARY SOURCE OF TRUTH:** Read the main **[README.md](README.md)** first.
> **⭐ NEXT TASK:** See **[NEXT_STEPS_ROADMAP.md](NEXT_STEPS_ROADMAP.md)** for the current implementation plan.

---

## ⚡ Critical Reminders

1.  **📖 Read the `README.md`**: It contains the corrected architecture, project structure, and core mechanics. Do not trust other documents if they conflict with it.

2.  **🔐 Password Management**: Do **NOT** update passwords directly in the database. Always use the `/api/v1/users/set-password` endpoint. See `README.md` for details.

3.  **🎟️ Automatic Tickets**: Tickets are **created automatically** by the system. Users do not "generate" them. The UI should only have a "View Ticket" button.

4.  **Frontend Architecture**: The project is moving to a **single Flutter application**. The `public-app` is being removed. The `private-app` will serve both public and authenticated views. See `NEXT_STEPS_ROADMAP.md`.

5.  **Project Name**: The repository is `ticketz`, but the project is **"The Chain"**. "Tickets" are invitations.

## 🚀 Quick Start

```bash
# Start all services
docker-compose up -d

# Access the application
# - Web App: http://localhost:3001
# - Backend API: http://localhost:8080
```

---
*Last Updated: 2025-10-30*