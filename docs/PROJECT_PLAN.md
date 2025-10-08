### **1. Executive Summary**

**Project Name:** *The Chain*
**Type:** Social Mobile Game / Viral Network
**Goal:** Create a global, self-propagating social experience where every participant is part of a single continuous chain, growing through invitation and accountability.
**Current Status:** Month 2 - Core Development Phase (85% Complete)
**Last Updated:** October 8, 2025 - 14:00 CET

The Chain is both a minimalist social game and a global participation experiment. It combines time-based pressure, transparency, and virality to encourage collective effort and curiosity.

#### **Development Progress Summary**
- ✅ **Backend MVP:** Spring Boot microservices fully operational with JWT auth, ticket system, chain tracking
- ✅ **Mobile Foundation:** Flutter app with complete UI, state management, backend integration tested
- ✅ **Infrastructure:** Docker containerization complete, local development environment running
- ✅ **End-to-End Flow:** Full registration chain working - seed user → ticket generation → new user registration
- 🔄 **In Progress:** Stats/profile screens, WebSocket real-time updates
- ⏳ **Next Phase:** Beta testing, production deployment, app store preparation

---

### **2. Problem Statement**

Traditional social networks are bloated, noisy, and lack a sense of shared purpose. Users are isolated in their own clusters, disconnected from a unified social experience.

**The Chain** addresses this by:

* Creating a single, linear chain connecting every participant.
* Turning social connection into a *collective challenge*.
* Using transparency and time limits to foster engagement and accountability.

---

### **3. Objectives**

1. **Design and launch** a mobile app where participants can join a growing chain.
2. **Implement a time-limited ticket system** that controls attachment flow and creates urgency.
3. **Build a transparent visualization** showing the global scale and real-time growth.
4. **Encourage viral propagation** through QR-based ticket sharing.
5. **Maintain anonymity and privacy** while supporting optional geo data.

---

### **4. Target Audience**

* **Age Range:** 16–40
* **Personas:**

  * *Social Explorers* who enjoy new social experiments
  * *Gamified Influencers* who like to see their impact
  * *Casual Users* curious about trends and global participation
* **Regions:** Global; designed to be language-light and emoji-friendly

---

### **5. Competitive Landscape**

| Platform           | Key Concept                | The Chain’s Differentiator                         |
| ------------------ | -------------------------- | -------------------------------------------------- |
| BeReal             | Real-time social updates   | The Chain focuses on connection, not content.      |
| Wordle             | Global daily participation | The Chain has continuous, global continuity.       |
| Social Token Games | Reward-based networks      | The Chain uses social accountability, not rewards. |

---

### **6. Success Metrics**

| Metric                        | Description                                   |
| ----------------------------- | --------------------------------------------- |
| **Chain Continuity Duration** | How long the chain remains unbroken.          |
| **Ticket Usage Rate**         | Percentage of tickets used before expiry.     |
| **Active Growth Rate**        | Number of daily new participants.             |
| **Geo Spread**                | Number of countries represented in the chain. |
| **Engagement Time**           | Average time spent in the app per user.       |

---

### **7. Project Timeline (Initial 6-Month Plan)**

| Phase                      | Duration   | Status         | Deliverables                                     |
| -------------------------- | ---------- | -------------- | ------------------------------------------------ |
| **1. Concept & Design**    | Month 1    | ✅ **COMPLETE** | UX/UI prototypes, gameplay flow                  |
| **2. Core Development**    | Months 2–3 | 🔄 **IN PROGRESS** | Backend, ticket system, mobile app MVP           |
| **3. Testing & Iteration** | Month 4    | ⏳ Pending     | Beta testing, UX optimization                    |
| **4. Launch Preparation**  | Month 5    | ⏳ Pending     | Marketing materials, release build               |
| **5. Global Launch**       | Month 6    | ⏳ Pending     | App Store + Play Store release                   |
| **6. Post-Launch Updates** | Ongoing    | ⏳ Pending     | New features, visual analytics, community events |

#### **Current Progress (Month 2 - Development Phase - 85% Complete)**

**✅ Completed:**
- Project documentation and technical architecture
- Backend (Spring Boot) microservices:
  - User management & authentication (JWT)
  - Ticket generation & validation system
  - Chain tracking & statistics
  - Database schema (PostgreSQL)
  - RESTful API endpoints
  - Security configuration with public endpoints
  - Seed user system for chain initialization
- Mobile app (Flutter) foundation:
  - Complete architecture with Riverpod state management
  - All core screens implemented
  - Service layer & API integration
  - QR code generation & scanning
  - Location services integration
  - Authentication flow with backend
  - Error handling & loading states
  - Backend connectivity configured
- Infrastructure:
  - Docker containerization complete
  - docker-compose.yml with PostgreSQL, Redis, Backend
  - Health monitoring via Spring Boot Actuator
  - Environment configuration for development
  - Successfully tested end-to-end registration flow

**🔄 In Progress:**
- WebSocket implementation for real-time updates
- Stats screen with live chain visualization
- Profile screen with user history

**⏳ Next Steps:**
- Firebase push notifications setup
- Production deployment configuration
- CI/CD pipeline setup (GitHub Actions)
- Beta testing environment preparation
- Performance optimization

---

### **8. Technical Implementation Status**

#### **Backend (Spring Boot)**
| Component | Status | Notes |
|-----------|--------|-------|
| User Entity & Repository | ✅ Complete | PostgreSQL schema, JPA mappings |
| Authentication System | ✅ Complete | JWT-based auth, security config |
| Ticket System | ✅ Complete | Generation, validation, expiry tracking |
| Chain Statistics | ✅ Complete | Real-time stats calculation |
| REST API Endpoints | ✅ Complete | `/api/v1/auth`, `/api/v1/tickets`, `/api/v1/chain` |
| Exception Handling | ✅ Complete | Global exception handler |
| Security Configuration | ✅ Complete | CORS, public endpoints, JWT filter |
| Seed User System | ✅ Complete | Initial chain starter |
| Docker Configuration | ✅ Complete | Multi-stage Dockerfile, optimized |
| Health Monitoring | ✅ Complete | Spring Boot Actuator endpoints |
| WebSocket Server | ⏳ Pending | For real-time chain updates |
| CI/CD Pipeline | ⏳ Pending | GitHub Actions workflow |

#### **Mobile App (Flutter)**
| Component | Status | Notes |
|-----------|--------|-------|
| Project Structure | ✅ Complete | Clean architecture, feature-based |
| State Management | ✅ Complete | Riverpod providers configured |
| API Client | ✅ Complete | Dio with JWT interceptors |
| Authentication Flow | ✅ Complete | Splash, scan, register screens integrated |
| Ticket Features | ✅ Complete | Generate & scan QR codes with backend |
| Home Screen | ✅ Complete | Chain position, user info display |
| Location Services | ✅ Complete | Geolocator integration |
| Error Handling | ✅ Complete | SnackBars, retry mechanisms |
| Backend Integration | ✅ Complete | Connected to Docker backend |
| API Configuration | ✅ Complete | Emulator/device-specific URLs |
| Stats Screen | 🔄 In Progress | Chain visualization |
| Profile Screen | 🔄 In Progress | User history, settings |
| WebSocket Client | ⏳ Pending | Real-time updates |
| Push Notifications | ⏳ Pending | Firebase messaging |
| App Store Build | ⏳ Pending | Release configuration |

#### **Infrastructure**
| Component | Status | Notes |
|-----------|--------|-------|
| PostgreSQL Database | ✅ Complete | Schema implemented, seed data, tested |
| Docker Compose | ✅ Complete | Full stack local development |
| Docker Networks | ✅ Complete | Isolated container networking |
| Health Checks | ✅ Complete | All services monitored |
| Environment Config | ✅ Complete | .env files, profiles |
| Redis Cache | ✅ Complete | Running in Docker, configured |
| End-to-End Testing | ✅ Complete | Full registration flow verified |
| Cloud Deployment | ⏳ Pending | AWS/GCP configuration |
| CDN Setup | ⏳ Pending | For QR code images |
| Production Monitoring | ⏳ Pending | Logging, metrics, alerts |

---

### **9. Risk Management**

| Risk                                     | Mitigation                                                         |
| ---------------------------------------- | ------------------------------------------------------------------ |
| **Low engagement after initial novelty** | Add global milestones, mini-events, and visual unlocks.            |
| **Privacy concerns (geo data)**          | Make location sharing fully optional and generalized.              |
| **Server overload from viral growth**    | Use scalable cloud infrastructure with load balancing.             |
| **QR abuse or fake tickets**             | Use cryptographically signed QR tickets tied to server validation. |
| **Chain stagnation**                     | Implement chain reactivation events and “chain revival” rewards.   |

---

### **9. Budget Estimate (for 6 months)**

| Category           | Description                       | Cost Estimate (€) |
| ------------------ | --------------------------------- | ----------------: |
| Development        | 2 iOS/Android devs + backend dev  |            90,000 |
| Design             | UX/UI designer + visual identity  |            25,000 |
| Infrastructure     | Cloud hosting, CDN, database      |            10,000 |
| Marketing          | Pre-launch campaigns, influencers |            30,000 |
| Legal & Compliance | GDPR, ToS, privacy policy         |             5,000 |
| **Total Estimate** |                                   |   **≈ 160,000 €** |

---

### **10. Milestones & Deliverables**

1. ✅ **Foundation Complete (Week 1-2):** Project structure, documentation, and technical design finalized.
2. ✅ **Backend MVP (Week 3-4):** Core API endpoints, database schema, authentication system implemented.
3. ✅ **Mobile App Foundation (Week 4-5):** UI screens, state management, API integration completed.
4. ✅ **Docker Infrastructure (Week 5-6):** Complete containerization, local dev environment, health monitoring.
5. ✅ **Integration Testing (Week 6):** End-to-end flow verified, seed → ticket → registration chain working.
6. 🔄 **Feature Completion (Week 7-8):** Stats visualization, profile screens, WebSocket real-time updates.
7. ⏳ **Beta Release (Week 9-12):** Testing with 100-1,000 users, performance optimization.
8. ⏳ **Public Launch (Month 4-5):** App store submission, marketing campaign.
9. ⏳ **Growth Phase (Month 6+):** Scale to 10K, 100K users, implement events and challenges.

---

### **11. Expected Outcomes**

* A viral, self-sustaining social ecosystem.
* Organic user acquisition through the chain dynamic.
* Strong data and engagement analytics for future monetization (optional).
* Recognition as a unique social experiment blending psychology, technology, and art.

---

### **12. Long-Term Vision**

* Introduce **Chain Stories:** allow each participant to add a short phrase or emoji to their chain link.
* Develop **visual chain maps** showing user clusters.
* Add **optional tokenized proof-of-participation (PoP)** for digital collectibles.
* Potential future spin-offs: *Chain 2.0 – The Web of Chains*, introducing cross-chain interactions.

---

**Prepared for:**
Project Management & Investment Review Board

**Author:**
Alpaslan Bek — Concept Originator & Product Vision Lead
