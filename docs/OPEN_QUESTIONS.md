# Open Questions & Decisions

## Overview

This document tracks unresolved questions, design decisions pending approval, and areas requiring further discussion before development begins.

**Status Legend:**
- 🔴 **Blocker** - Must resolve before development starts
- 🟡 **Important** - Should resolve during sprint planning
- 🟢 **Nice to know** - Can be decided during implementation

---

## 1. Product & Business Questions

### 1.1 Chain Bootstrap Problem 🔴 BLOCKER

**Question:** How do we start the chain? Who is the seed user?

**Options:**
1. **Project creator as seed** - Alpaslan becomes position #1
2. **Symbolic seed account** - "The Chain" official account, managed by team
3. **First public claimer** - Launch ticket publicly, first scan wins
4. **Multiple seeds** - Start multiple independent chains (changes concept fundamentally)

**Implications:**
- Seed user has special status (position #1)
- Seed's ticket must be successfully claimed to start growth
- If seed ticket expires, chain growth stalls

**Recommendation:** Option 2 (symbolic seed) - create official "The Seeder" account, share first ticket via social media launch campaign.

**Decision:** ⏳ Pending

---

### 1.2 What Happens If Chain Breaks? 🔴 BLOCKER

**Question:** If tickets keep expiring and no one successfully attaches, does the chain "die"?

**Scenario:**
- User #1000 generates ticket
- Ticket expires (wasted)
- User #1000 generates another ticket
- Ticket expires again
- Repeat...
- No position #1001 is ever created

**Options:**
1. **Accept chain breaks** - It's part of the game, chain ends when growth stops
2. **Admin intervention** - Manually create attachments during low-growth periods
3. **Backup tickets** - Allow users to generate multiple tickets if previous ones fail
4. **Chain resurrection events** - Special campaigns to revive stalled chains

**Implications:**
- Affects long-term viability
- May need game design tweaks (extend expiration? allow multiple tickets?)

**Recommendation:** Option 1 for MVP (accept reality), Option 4 for post-launch (events to boost engagement).

**Decision:** ⏳ Pending

---

### 1.3 Monetization Strategy 🟡 Important

**Question:** How will The Chain make money (if at all)?

**Options:**
1. **Free forever** - No monetization, passion project
2. **Freemium** - Basic free, premium features (custom QR designs, stats insights, ad-free)
3. **Ads** - Display ads in stats view or feed
4. **Tokenization** - NFT chain keys, blockchain integration (future)
5. **Sponsorships** - Brands sponsor chain milestones or events
6. **Data licensing** - Anonymized social graph data (ethical concerns)

**Implications:**
- Affects architecture (payment processing, subscription management)
- Affects user trust (ads may hurt UX)
- Affects legal (ToS, privacy policy)

**Recommendation:** Free for MVP, explore options 2 or 5 post-launch based on user feedback.

**Decision:** ⏳ Pending

---

### 1.4 Geographic Restrictions 🟡 Important

**Question:** Should we launch globally or start with specific regions?

**Considerations:**
- GDPR (EU) vs. CCPA (California) vs. other privacy laws
- App Store / Play Store compliance varies by country
- Language support (MVP is English-only)
- Time zones affect 24-hour expiration perception

**Options:**
1. **Global from day 1** - Available worldwide, English only
2. **Soft launch** - Start with US/UK/Australia (English-speaking), expand later
3. **Regional chains** - Separate chains per region (changes core concept)

**Recommendation:** Option 2 (soft launch) - limits legal complexity, easier to manage initial growth.

**Decision:** ⏳ Pending

---

### 1.5 Age Restrictions 🟡 Important

**Question:** What is the minimum age to join The Chain?

**Considerations:**
- COPPA (US): Under 13 requires parental consent
- GDPR (EU): 16+ in most countries for data processing consent
- App Store: Can set age rating

**Options:**
1. **13+** - Standard for most social apps (requires parental consent mechanism)
2. **16+** - Simpler legally (no parental consent needed in EU)
3. **18+** - Simplest, but limits audience

**Recommendation:** 16+ for MVP (avoids parental consent complexity).

**Decision:** ⏳ Pending

---

## 2. Technical Questions

### 2.1 QR Code Generation: Client or Server? 🟡 Important

**Question:** Should QR codes be generated client-side or server-side?

**Client-side (Flutter library):**
- ✅ Faster (no API call)
- ✅ Less server load
- ❌ QR style inconsistency across devices
- ❌ Harder to add branding later

**Server-side (API returns image URL):**
- ✅ Consistent styling
- ✅ Can add branding, analytics tracking
- ✅ Can cache on CDN
- ❌ Extra API call
- ❌ Server storage for images

**Recommendation:** Server-side for MVP - ensures consistency, easier to iterate on design.

**Decision:** ⏳ Pending

---

### 2.2 WebSocket vs. Server-Sent Events (SSE) 🟢 Nice to know

**Question:** Use WebSocket or SSE for real-time updates?

**WebSocket:**
- ✅ Bidirectional (can push and receive)
- ✅ Lower latency
- ❌ More complex (connection management, reconnection)
- ❌ Harder to scale (stateful connections)

**SSE:**
- ✅ Simpler (HTTP-based)
- ✅ Auto-reconnect built-in
- ✅ Works through proxies/firewalls better
- ❌ One-way only (server → client)
- ❌ Limited browser support (but polyfills exist)

**Recommendation:** WebSocket for MVP (already planned in tech docs), SSE as fallback for web clients.

**Decision:** ⏳ Pending (likely WebSocket)

---

### 2.3 Database Partitioning Strategy 🟢 Nice to know

**Question:** When/how should we partition large tables?

**Candidates:**
- `events_log` - Could partition by date (monthly)
- `user_activity` - Could partition by date (monthly)
- `wasted_tickets` - Could partition by date (yearly)

**When to implement:**
- Only if tables exceed 10M rows
- Monitor query performance
- Not needed for MVP

**Recommendation:** Defer until Month 6 post-launch, monitor growth.

**Decision:** ⏳ Defer to operations team

---

### 2.4 Multi-Region Deployment 🟢 Nice to know

**Question:** Should we deploy in multiple regions for latency?

**Single-Region:**
- ✅ Simpler ops
- ✅ Lower cost
- ❌ Higher latency for distant users

**Multi-Region:**
- ✅ Lower latency globally
- ✅ Disaster recovery
- ❌ Complex (data replication, consistency)
- ❌ Higher cost

**Recommendation:** Single-region for MVP (US-East or EU-West), expand based on user distribution.

**Decision:** ⏳ Pending (likely single-region for MVP)

---

## 3. User Experience Questions

### 3.1 What Happens on Simultaneous Ticket Claims? 🔴 BLOCKER

**Question:** If two people scan the same ticket at the exact same time, who wins?

**Scenario:**
- Alice generates ticket
- Bob scans at 12:00:00.000
- Charlie scans at 12:00:00.050
- Both API requests arrive nearly simultaneously

**Technical Solution:**
- Database constraint ensures one-time use
- First transaction to commit wins
- Second transaction fails with error

**UX Question:** What does Charlie see?

**Options:**
1. **"Ticket already used"** - Honest but frustrating
2. **"This ticket expired"** - White lie to save face
3. **"Unable to join, please try again"** - Vague
4. **Retry with exponential backoff** - App automatically retries (bad: Charlie still fails)

**Recommendation:** Option 1 (honest error) - shows transparency, explains failure clearly.

**Decision:** ⏳ Pending

---

### 3.2 Display Name Uniqueness 🟡 Important

**Question:** Can multiple users have the same display name?

**Options:**
1. **Allow duplicates** - "Alice" can exist multiple times (disambiguate by chain key or position)
2. **Enforce uniqueness** - First "Alice" claims the name, others must choose different
3. **Auto-disambiguate** - "Alice", "Alice #2", "Alice #3"

**Implications:**
- Option 1: Simplest, but confusing in chain tree view
- Option 2: Frustrating for users, limits choices
- Option 3: Ugly but functional

**Recommendation:** Option 1 for MVP (allow duplicates, show position or chain key for disambiguation).

**Decision:** ⏳ Pending

---

### 3.3 Anonymous User Numbering 🟢 Nice to know

**Question:** What number should anonymous users show?

**Options:**
1. **Chain position** - "Anonymous #42" (matches position in chain)
2. **Random number** - "Anonymous #8271" (privacy, but meaningless)
3. **Sequential anonymous counter** - "Anonymous #1", "Anonymous #2" (separate from position)

**Recommendation:** Option 1 (chain position) - simpler, meaningful, reduces cognitive load.

**Decision:** ⏳ Pending (likely option 1)

---

### 3.4 Ticket Sharing UX 🟡 Important

**Question:** What's the primary sharing method for tickets?

**Options:**
1. **Show QR, assume in-person scan** - Minimalist, forces face-to-face
2. **Share button (deep link via SMS/WhatsApp)** - More viral, works remotely
3. **Both** - Flexibility

**Implications:**
- In-person only: Slower growth but more intentional connections
- Remote sharing: Faster growth but less personal

**Recommendation:** Option 3 (both) - QR for in-person, share button for remote, users choose.

**Decision:** ⏳ Pending (likely option 3)

---

### 3.5 Onboarding Tutorial Length 🟢 Nice to know

**Question:** How many steps in the first-time user tutorial?

**Options:**
1. **No tutorial** - Intuitive design, learn by doing
2. **3-step overlay** - Highlight key actions (generate ticket, view stats, profile)
3. **Full walkthrough** - 5+ screens explaining concept

**Recommendation:** Option 2 (3-step overlay) - balances education with minimalism.

**Decision:** ⏳ Pending

---

## 4. Security & Privacy Questions

### 4.1 Device Fingerprint Stability 🟡 Important

**Question:** What happens when a user's device fingerprint changes?

**Scenarios:**
- User updates OS (iOS 17 → iOS 18)
- User clears browser data (web)
- User gets new phone

**Current Design:**
- Device fingerprint used for login
- Fingerprint change = locked out

**Options:**
1. **Manual support recovery** - User contacts support with proof of identity
2. **Backup recovery method** - Email/phone verification (requires collecting email/phone)
3. **Graceful fingerprint update** - Allow fingerprint to drift slightly over time

**Recommendation:** Option 1 for MVP (manual support), consider Option 2 post-MVP.

**Decision:** ⏳ Pending

---

### 4.2 IP Logging Duration 🟢 Nice to know

**Question:** How long should we retain IP addresses in logs?

**Considerations:**
- GDPR: Personal data, minimize retention
- Security: Useful for abuse detection
- Storage: Logs can grow large

**Options:**
1. **7 days** - Minimal, only for immediate abuse detection
2. **30 days** - Standard practice for many services
3. **90 days** - Longer investigation window

**Recommendation:** 30 days for MVP (balance between security and privacy).

**Decision:** ⏳ Pending

---

### 4.3 Data Breach Notification 🟡 Important

**Question:** What is our data breach response plan?

**Legal Requirements:**
- GDPR: Notify within 72 hours if breach affects EU users
- CCPA: Notify without unreasonable delay if California users affected

**Plan Needed:**
1. Detection and assessment process
2. Notification templates (email to users, report to authorities)
3. Incident response team roles
4. Legal counsel contact

**Recommendation:** Draft plan before launch, include in operations documentation.

**Decision:** ⏳ Pending (assign to legal/compliance)

---

## 5. Design & Branding Questions

### 5.1 App Name 🔴 BLOCKER

**Question:** Is the official name "The Chain" or something else?

**Considerations:**
- "The Chain" - Simple, descriptive
- Trademark search needed
- Domain availability (thechain.app, thechain.com)
- App Store search optimization

**Action Items:**
- [ ] Trademark search
- [ ] Domain registration
- [ ] App Store name reservation

**Decision:** ⏳ Pending (legal check)

---

### 5.2 Visual Identity 🟡 Important

**Question:** What are the brand colors, logo, and style?

**From PROJECT_DEFINITION.md:**
- Style: Minimalist, bright, geometric
- Symbol: Chain link or glowing node motif
- Mood: Clean, calm, slightly mysterious

**Needed:**
- Primary color palette (2-3 colors)
- Logo design (app icon, wordmark)
- Typography (font families)
- Icon set

**Recommendation:** Hire designer for branding package (Month 1 of project plan).

**Decision:** ⏳ Pending (assign to designer)

---

### 5.3 App Icon 🟡 Important

**Question:** What should the app icon look like?

**Requirements:**
- Works at small sizes (iOS: 60x60px, Android: 48x48dp)
- Recognizable without text
- Reflects brand (chain link?)

**Options:**
1. Abstract chain link symbol
2. Two connected nodes
3. Stylized "C" for Chain
4. QR code motif

**Recommendation:** Option 1 or 2, decided by designer.

**Decision:** ⏳ Pending (designer task)

---

## 6. Legal & Compliance Questions

### 6.1 Terms of Service (ToS) 🔴 BLOCKER

**Question:** Who will draft the ToS?

**Key Clauses Needed:**
- User eligibility (age, location)
- Acceptable use policy (no abuse, harassment)
- Intellectual property (who owns content)
- Liability limitations
- Dispute resolution (arbitration?)
- Governing law (US? EU?)

**Recommendation:** Hire lawyer or use template service (Termly, Iubenda).

**Decision:** ⏳ Pending (legal task)

---

### 6.2 Privacy Policy 🔴 BLOCKER

**Question:** GDPR compliance - do we need a Data Protection Officer (DPO)?

**Requirements:**
- GDPR Art. 37: DPO required if processing data at large scale
- Threshold unclear (1000 users? 10,000? 100,000?)

**Options:**
1. **No DPO for MVP** - Below threshold, designate someone internally
2. **External DPO** - Hire consultant (€500-2000/month)
3. **DPO-as-a-Service** - Use service like OneTrust

**Recommendation:** Option 1 for MVP, reassess at 50K users.

**Decision:** ⏳ Pending (legal review)

---

### 6.3 Content Moderation 🟡 Important

**Question:** What is our policy on inappropriate display names?

**Examples of violations:**
- Hate speech
- Impersonation
- Profanity
- Spam/ads

**Options:**
1. **Reactive moderation** - Users report, admins review
2. **Automated filtering** - Block known bad words on input
3. **Manual approval** - Review all names before display (doesn't scale)

**Recommendation:** Option 2 (automated filtering) + Option 1 (user reports), for MVP.

**Decision:** ⏳ Pending

---

## 7. Operations Questions

### 7.1 Customer Support 🟡 Important

**Question:** How will users get help?

**Options:**
1. **Email only** - support@thechain.app
2. **In-app chat** - Live chat widget (requires staffing)
3. **FAQ / Help Center** - Self-service (reduces tickets)
4. **Community forum** - Users help each other

**Recommendation:** Option 1 + Option 3 for MVP (email + FAQ), consider Option 4 post-launch.

**Decision:** ⏳ Pending

---

### 7.2 On-Call Rotation 🟢 Nice to know

**Question:** Who handles production incidents after launch?

**Needed:**
- On-call schedule (24/7 or business hours?)
- Escalation path
- Incident response runbooks
- Paging tool (PagerDuty, OpsGenie)

**Recommendation:** Business hours only for MVP (9am-9pm in primary timezone), 24/7 if user base > 50K.

**Decision:** ⏳ Pending (ops team)

---

### 7.3 Backup Testing 🟡 Important

**Question:** How often should we test database restore from backups?

**Best Practice:**
- Test quarterly (every 3 months)
- Simulate disaster recovery scenario
- Measure RTO and RPO

**Recommendation:** Monthly tests for first 3 months post-launch, then quarterly.

**Decision:** ⏳ Pending (ops team)

---

## 8. Tracking & Decisions Log

| # | Question | Assigned To | Target Date | Status |
|---|----------|-------------|-------------|--------|
| 1.1 | Seed user strategy | Alpaslan | Before dev | 🔴 Open |
| 1.2 | Chain break handling | Alpaslan | Before dev | 🔴 Open |
| 1.3 | Monetization | Alpaslan | Month 3 | 🟡 Open |
| 1.4 | Geographic launch | Alpaslan | Before dev | 🟡 Open |
| 1.5 | Age restrictions | Legal | Before dev | 🟡 Open |
| 2.1 | QR generation method | Tech Lead | Sprint 1 | 🟡 Open |
| 2.2 | WebSocket vs SSE | Tech Lead | Sprint 1 | 🟢 Open |
| 2.3 | DB partitioning | Ops | Post-launch | 🟢 Deferred |
| 2.4 | Multi-region | Ops | Post-launch | 🟢 Deferred |
| 3.1 | Simultaneous claims UX | Product | Sprint 2 | 🔴 Open |
| 3.2 | Display name uniqueness | Product | Sprint 1 | 🟡 Open |
| 3.3 | Anonymous numbering | Product | Sprint 1 | 🟢 Open |
| 3.4 | Ticket sharing UX | Product | Sprint 1 | 🟡 Open |
| 3.5 | Onboarding tutorial | Design | Sprint 3 | 🟢 Open |
| 4.1 | Device fingerprint recovery | Product | Sprint 2 | 🟡 Open |
| 4.2 | IP logging duration | Legal/Ops | Before launch | 🟢 Open |
| 4.3 | Data breach plan | Legal | Before launch | 🟡 Open |
| 5.1 | App name trademark | Legal | Month 1 | 🔴 Open |
| 5.2 | Visual identity | Designer | Month 1 | 🟡 Open |
| 5.3 | App icon design | Designer | Month 1 | 🟡 Open |
| 6.1 | ToS drafting | Legal | Before launch | 🔴 Open |
| 6.2 | DPO requirement | Legal | Before launch | 🔴 Open |
| 6.3 | Content moderation | Product | Sprint 2 | 🟡 Open |
| 7.1 | Customer support plan | Ops | Before launch | 🟡 Open |
| 7.2 | On-call rotation | Ops | Before launch | 🟢 Open |
| 7.3 | Backup testing | Ops | Month 1 | 🟡 Open |

---

## 9. Decision-Making Process

**For Blocker Questions (🔴):**
1. Schedule decision meeting with stakeholders
2. Present options with pros/cons
3. Make decision and document here
4. Update affected documentation (API spec, user flows, etc.)

**For Important Questions (🟡):**
1. Discuss during sprint planning
2. Product owner makes final call
3. Document decision

**For Nice-to-Know Questions (🟢):**
1. Tech lead or designer decides
2. Document in code comments or design files
3. Optional: Note in this doc

---

## 10. How to Use This Document

**Adding New Questions:**
1. Use template:
   ```markdown
   ### X.X Question Title 🔴/🟡/🟢
   **Question:** Clear question statement
   **Options:**
   1. Option A - pros/cons
   2. Option B - pros/cons
   **Recommendation:** Suggested approach
   **Decision:** ⏳ Pending / ✅ Decided: [outcome]
   ```

2. Add to tracking table (Section 8)

**Resolving Questions:**
1. Update **Decision:** field with outcome and date
2. Update status in tracking table
3. Update related docs (API spec, user flows, etc.)

**Reviewing:**
- Review weekly during sprint planning
- Prioritize blockers first
- Assign owners for open questions

---

**Document Version:** 1.0
**Last Updated:** 2025-10-08
**Next Review:** Sprint planning / kickoff meeting
