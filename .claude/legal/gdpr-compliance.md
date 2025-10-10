# The Chain - GDPR/CCPA Compliance Checklist

**Project**: The Chain Social Network
**Legal Advisor**: legal-software-advisor agent
**Task ID**: TASK-LEGAL-001
**Last Updated**: 2025-10-10

---

## Executive Summary

The Chain is an invite-only social network that processes **Personally Identifiable Information (PII)** and must comply with:
- **GDPR** (EU General Data Protection Regulation) - if serving EU users
- **CCPA** (California Consumer Privacy Act) - if serving California residents
- **UK GDPR** - if serving UK users

**Data Controller**: [Your Company Name] (to be determined)
**Data Processors**: PostgreSQL (self-hosted), Redis (self-hosted), Email service provider (if using external SMTP)

---

## 1. Personal Data Collected

### 1.1 Directly Collected (User-Provided)

| Data Field | Purpose | Legal Basis (GDPR) | Retention Period |
|------------|---------|-------------------|------------------|
| Username | Account identification | Contractual necessity | Account lifetime + 30 days |
| Email address | Authentication, notifications | Contractual necessity | Account lifetime + 30 days |
| Password (hashed) | Authentication | Contractual necessity | Account lifetime |
| Display name | User profile | Contractual necessity | Account lifetime |
| Associated country | Chain statistics, analytics | Legitimate interest | Account lifetime |

### 1.2 Automatically Collected

| Data Field | Purpose | Legal Basis (GDPR) | Retention Period |
|------------|---------|-------------------|------------------|
| IP address | Rate limiting, fraud prevention | Legitimate interest | 90 days (logs) |
| Session tokens | Authentication | Contractual necessity | 24 hours (expires) |
| API request logs | Debugging, performance | Legitimate interest | 30 days |
| WebSocket connection metadata | Real-time features | Contractual necessity | Session duration |

### 1.3 Derived Data

| Data Field | Purpose | Legal Basis (GDPR) | Retention Period |
|------------|---------|-------------------|------------------|
| Chain key | Unique identifier in chain | Contractual necessity | Permanent (chain integrity) |
| Position in chain | Chain visualization | Contractual necessity | Permanent (chain integrity) |
| Parent/child relationships | Chain lineage | Contractual necessity | Permanent (chain integrity) |
| Ticket generation history | Anti-abuse, statistics | Legitimate interest | Account lifetime |
| Wasted tickets count | Performance tracking | Legitimate interest | Account lifetime |

### 1.4 Special Categories (Sensitive Data)

❌ **None** - The Chain does NOT collect:
- Racial or ethnic origin
- Political opinions
- Religious or philosophical beliefs
- Trade union membership
- Genetic or biometric data
- Health data
- Sexual orientation

---

## 2. GDPR Compliance Requirements

### 2.1 Lawful Basis (Article 6)

Each data processing activity must have one of these legal bases:

| Data Processing | Legal Basis |
|----------------|-------------|
| Account creation | Contractual necessity |
| Email notifications | Contractual necessity |
| Chain lineage tracking | Contractual necessity |
| Anti-fraud measures | Legitimate interest |
| Performance analytics | Legitimate interest (with opt-out) |
| Marketing emails | Consent (opt-in required) |

**Action Items**:
- [ ] Clearly state legal basis in Privacy Policy
- [ ] Conduct Legitimate Interest Assessment (LIA) for analytics
- [ ] Implement opt-out for non-essential processing

### 2.2 User Consent (Article 7)

**Requirements**:
- ✅ Must be freely given (no forced bundling)
- ✅ Must be specific (granular checkboxes)
- ✅ Must be informed (clear language)
- ✅ Must be unambiguous (affirmative action)
- ✅ Easy to withdraw

**Implementation**:
```
□ I agree to receive email notifications about my account (required)
□ I agree to receive marketing emails (optional)
□ I agree to analytics tracking (optional - legitimate interest)
```

**Action Items**:
- [ ] Implement consent checkboxes during registration
- [ ] Store consent records in database (timestamp, IP, version)
- [ ] Allow users to withdraw consent in account settings
- [ ] Do NOT pre-check optional boxes

### 2.3 Data Subject Rights (Articles 15-22)

Users have the right to:

| Right | GDPR Article | Implementation |
|-------|-------------|----------------|
| **Access** | Art. 15 | Download all personal data (JSON export) |
| **Rectification** | Art. 16 | Edit username, email, display name in settings |
| **Erasure** | Art. 17 | Delete account (with chain integrity preservation) |
| **Restriction** | Art. 18 | Freeze account (no deletion) |
| **Data Portability** | Art. 20 | Export data in JSON format |
| **Object** | Art. 21 | Opt-out of analytics, marketing |
| **Automated Decision-Making** | Art. 22 | N/A - no automated profiling/decisions |

**Action Items**:
- [ ] Implement "Download My Data" feature (JSON export)
- [ ] Implement "Delete Account" with confirmation
- [ ] Handle erasure requests within 30 days
- [ ] Document process for handling rights requests

#### Right to Erasure (Special Case)

**Challenge**: Chain integrity vs. data deletion

**Solution**: **Pseudonymization**
- Delete PII (username, email, password, display name)
- Replace with: "Deleted User #[UUID]"
- Retain chain key, position, parent/child IDs (anonymized)
- Justification: Contractual necessity for other users' chain accuracy

**Privacy Policy Language**:
> "When you delete your account, we will permanently remove your personal information (username, email, display name). However, to preserve the integrity of The Chain for other users, your anonymized position in the chain (chain key and lineage connections) will be retained as 'Deleted User'."

### 2.4 Data Breach Notification (Article 33-34)

**Obligation**: Notify supervisory authority within **72 hours** of breach discovery

**Breach Definition**:
- Unauthorized access to database
- Data exfiltration (e.g., SQL injection)
- Accidental disclosure (e.g., public S3 bucket)
- Ransomware encryption of user data

**Action Items**:
- [ ] Appoint Data Protection Officer (DPO) or contact person
- [ ] Document breach response plan
- [ ] Implement database encryption at rest
- [ ] Implement HTTPS/TLS for data in transit
- [ ] Log all database access for audit trail
- [ ] Prepare breach notification templates

### 2.5 Privacy by Design & Default (Article 25)

**Requirements**:
- ✅ Minimize data collection (only what's necessary)
- ✅ Pseudonymize data where possible (chain keys vs. email in public views)
- ✅ Encrypt data at rest and in transit
- ✅ Default to most privacy-protective settings

**Action Items**:
- [ ] Enable PostgreSQL encryption (pgcrypto for sensitive fields)
- [ ] Use HTTPS-only (no HTTP fallback)
- [ ] Default to email notifications OFF (user opt-in)
- [ ] Hash passwords with bcrypt (minimum 10 rounds)
- [ ] Never log passwords or tokens in plaintext

### 2.6 Data Processing Agreements (Article 28)

**Required if using third-party services**:

| Service | Data Shared | DPA Required? | Status |
|---------|------------|---------------|--------|
| PostgreSQL | All data | ❌ No (self-hosted) | N/A |
| Redis | Session tokens | ❌ No (self-hosted) | N/A |
| Email provider (e.g., SendGrid, AWS SES) | Email addresses, messages | ✅ **YES** | ⚠️ TODO |
| Cloud hosting (e.g., AWS, DigitalOcean) | All data (servers) | ✅ **YES** | ⚠️ TODO |
| Analytics (e.g., Google Analytics) | IP, usage data | ✅ **YES** | ⚠️ TODO (or avoid) |

**Action Items**:
- [ ] Sign Data Processing Agreement (DPA) with email provider
- [ ] Use hosting providers with GDPR-compliant DPAs (AWS, Google Cloud, Azure)
- [ ] Avoid analytics services OR use privacy-friendly alternatives (Plausible, Fathom)
- [ ] Document all data processors in Privacy Policy

### 2.7 International Data Transfers (Chapter V)

**Issue**: If hosting in US but serving EU users

**Solutions**:
1. **EU Standard Contractual Clauses (SCCs)** - Legal mechanism for US → EU transfers
2. **Data Processing Agreement** with cloud provider
3. **Encrypt data** end-to-end
4. **Host in EU** (easiest solution - use AWS eu-west-1, Google europe-west1)

**Action Items**:
- [ ] Determine primary user base geography
- [ ] If serving EU: Host in EU region OR sign SCCs with US cloud provider
- [ ] Disclose data transfer details in Privacy Policy

---

## 3. CCPA Compliance (California)

**Applies if**:
- Annual gross revenue > $25M OR
- Buy/sell personal data of 50,000+ CA residents OR
- Derive 50% of revenue from selling personal data

**User Rights under CCPA**:
1. **Right to Know**: What personal data is collected
2. **Right to Delete**: Request deletion of personal data
3. **Right to Opt-Out**: Opt-out of data "sale" (we don't sell data - ✅ compliant)
4. **Right to Non-Discrimination**: No penalty for exercising rights

**Implementation** (if applicable):
- [ ] Add "Do Not Sell My Personal Information" link (even if you don't sell - safe harbor)
- [ ] Respond to requests within 45 days
- [ ] Verify requestor identity (2-step verification)

**Good News**: The Chain does NOT sell user data → CCPA compliance is easier

---

## 4. Cookie Consent (ePrivacy Directive)

**Required for EU users**

**Cookies Used by The Chain**:

| Cookie Name | Purpose | Category | Consent Required? |
|-------------|---------|----------|-------------------|
| `session_token` | Authentication | Strictly Necessary | ❌ No |
| `csrf_token` | Security | Strictly Necessary | ❌ No |
| `preferences` | User settings | Functional | ⚠️ Yes (if not essential) |
| `analytics_id` | Usage tracking | Analytics | ✅ **YES** |
| `marketing_id` | Ad tracking | Marketing | ✅ **YES** |

**Action Items**:
- [ ] Implement cookie consent banner (on first visit)
- [ ] Allow granular consent (Analytics: Yes/No, Marketing: Yes/No)
- [ ] Do NOT load analytics/marketing scripts until consent given
- [ ] Store consent preferences (cookie or localStorage)
- [ ] Provide "Cookie Settings" page to change preferences

**Example Banner**:
```
We use cookies to improve your experience. You can choose which cookies to allow:

[✓] Necessary (always required)
[ ] Analytics (help us improve)
[ ] Marketing (personalized ads)

[Accept All] [Reject Non-Essential] [Customize]
```

---

## 5. Privacy Policy Requirements

Must include:

### 5.1 Required Sections

1. **Identity of Data Controller**
   - Company name, address, contact email
   - DPO contact (if applicable)

2. **What Data We Collect**
   - List all personal data (see Section 1)

3. **Why We Collect It** (Legal Basis)
   - Contractual necessity, legitimate interest, consent

4. **How Long We Keep It** (Retention)
   - Specify retention periods per data type

5. **Who We Share It With** (Third Parties)
   - Email providers, hosting providers, analytics

6. **Your Rights**
   - Access, rectification, erasure, portability, object

7. **How to Exercise Rights**
   - Email address for data requests

8. **Data Security Measures**
   - Encryption, access controls, security audits

9. **International Transfers** (if applicable)
   - SCCs, hosting location

10. **Cookies** (if applicable)
    - Types of cookies, purposes, how to opt-out

11. **Children's Privacy**
    - Age restriction (13+ or 16+ for EU)

12. **Changes to Policy**
    - Notification method, effective date

### 5.2 Language Requirements

- ✅ Clear, plain language (no legalese)
- ✅ Easy to find (link in footer)
- ✅ Easy to read (structured, headings)
- ✅ Available in user's language (if serving non-English markets)

**Action Items**:
- [ ] Draft Privacy Policy (see `privacy-policy.md`)
- [ ] Review by legal counsel
- [ ] Publish at `/privacy-policy` URL
- [ ] Link in footer, registration page, app settings
- [ ] Track version history (date, changes made)

---

## 6. Terms of Service Requirements

Must include:

1. **Acceptance of Terms**
   - Agreement by using the service

2. **Eligibility**
   - Age restriction (13+, or 16+ for EU without parental consent)

3. **Account Registration**
   - Accuracy of information, account security

4. **Acceptable Use Policy**
   - Prohibited activities (spam, abuse, illegal content)

5. **Ticket/Invitation Rules**
   - Expiration, limits, no transfer/sale

6. **Intellectual Property**
   - Ownership of content (user content vs. platform)

7. **Termination**
   - Right to suspend/delete accounts for violations

8. **Limitation of Liability**
   - No warranty, limited liability for damages

9. **Dispute Resolution**
   - Governing law, arbitration clause (if desired)

10. **Changes to Terms**
    - Notification method, continued use = acceptance

**Action Items**:
- [ ] Draft Terms of Service (see `terms-of-service.md`)
- [ ] Review by legal counsel
- [ ] Require acceptance during registration
- [ ] Publish at `/terms-of-service` URL
- [ ] Link in footer, registration page

---

## 7. Implementation Checklist

### Phase 1: Essential Compliance (Pre-Launch)
- [ ] Draft Privacy Policy
- [ ] Draft Terms of Service
- [ ] Implement password hashing (bcrypt, 10+ rounds)
- [ ] Implement HTTPS-only
- [ ] Age verification (13+) during registration
- [ ] Email verification flow
- [ ] "Download My Data" feature
- [ ] "Delete Account" feature
- [ ] Database encryption at rest (PostgreSQL pgcrypto)

### Phase 2: Advanced Compliance (Post-Launch)
- [ ] Cookie consent banner (if using analytics)
- [ ] Consent management (opt-in/opt-out toggles)
- [ ] Data breach response plan
- [ ] Sign DPAs with third-party services
- [ ] Regular security audits
- [ ] GDPR training for team members
- [ ] Appoint DPO (if required - 250+ employees or sensitive data)

### Phase 3: International (If Expanding)
- [ ] Translate Privacy Policy to EU languages
- [ ] Host in EU region (if serving EU primarily)
- [ ] Implement Standard Contractual Clauses (SCCs)
- [ ] Comply with local laws (German NetzDG, French data laws, etc.)

---

## 8. Data Retention Policy

| Data Type | Retention Period | Reason | Deletion Method |
|-----------|------------------|--------|-----------------|
| Active account data | Account lifetime | Contractual | Hard delete on request |
| Deleted account (chain data) | Permanent | Chain integrity | Pseudonymization |
| Email logs | 30 days | Debugging | Auto-purge cron job |
| API access logs | 30 days | Security, debugging | Auto-purge cron job |
| Session tokens | 24 hours | Expiration | Redis TTL |
| Password reset tokens | 1 hour | Expiration | Redis TTL |
| Wasted ticket history | Account lifetime | Anti-abuse | Delete with account |

**Action Items**:
- [ ] Implement cron job to purge old logs (30 days)
- [ ] Document retention policy in Privacy Policy
- [ ] Implement soft-delete with `deletedAt` timestamp (already in User entity ✓)

---

## 9. Security Measures (GDPR Article 32)

**Required**: Appropriate technical and organizational measures

### Technical Measures
- [x] Password hashing (bcrypt) - ✅ Implemented
- [ ] Database encryption at rest (PostgreSQL pgcrypto)
- [x] HTTPS/TLS for data in transit - ✅ Implemented (backend)
- [ ] Input validation (prevent SQL injection, XSS)
- [ ] Rate limiting (prevent brute force) - ✅ Implemented (RateLimitInterceptor)
- [ ] CSRF protection - ✅ Implemented (Spring Security default)
- [ ] Secure session management (HttpOnly, Secure, SameSite cookies)
- [ ] Regular dependency updates (security patches)
- [ ] SQL injection prevention (parameterized queries) - ✅ Implemented (JPA)

### Organizational Measures
- [ ] Access control (role-based, principle of least privilege)
- [ ] Security training for developers
- [ ] Incident response plan
- [ ] Regular security audits / penetration testing
- [ ] Secure development lifecycle (code review, static analysis)
- [ ] Data backup and disaster recovery plan

**Action Items**:
- [ ] Enable PostgreSQL SSL connections
- [ ] Implement Content Security Policy (CSP) headers
- [ ] Regular dependency scanning (Snyk, OWASP Dependency-Check)
- [ ] Penetration testing before public launch

---

## 10. Children's Privacy (COPPA / GDPR Article 8)

**COPPA (US)**: Age 13+ required
**GDPR (EU)**: Age 16+ required (or 13-15 with parental consent)

**Implementation**:
- [ ] Add age verification during registration
  - "I confirm I am at least 13 years old (or 16 if in the EU)"
- [ ] Reject registration if under minimum age
- [ ] Do NOT collect date of birth (just yes/no confirmation)
- [ ] If allowing 13-15 EU users: Implement parental consent mechanism

**Recommendation**: **Require 16+** globally to simplify compliance.

---

## 11. Email Marketing Compliance

**CAN-SPAM Act (US)**:
- ✅ Include physical mailing address in footer
- ✅ Clear "Unsubscribe" link (one-click)
- ✅ Honor opt-outs within 10 business days
- ✅ Accurate "From" name and subject line

**GDPR (EU)**:
- ✅ Opt-in consent required (no pre-checked boxes)
- ✅ Easy to withdraw consent

**Action Items**:
- [ ] Implement email unsubscribe link
- [ ] Add physical address to email templates
- [ ] Create "Email Preferences" page in account settings
- [ ] Track consent for marketing emails (separate from transactional)

---

## 12. Compliance Monitoring

### Regular Audits
- [ ] Quarterly privacy policy review
- [ ] Annual security audit
- [ ] Dependency license audit (see `dependency-audit.md`)
- [ ] Access log review (who accessed what data)

### Metrics to Track
- Number of data subject requests (access, erasure)
- Average response time to requests
- Number of data breaches (goal: 0)
- Consent rates (opt-in vs. opt-out)

### Tools
- **OneTrust / TrustArc**: GDPR compliance management platforms
- **Cookiebot**: Cookie consent management
- **Sentry / LogRocket**: Error tracking (privacy-safe)

---

## 13. Red Flags to Avoid

❌ **DO NOT**:
- Sell or rent user data to third parties
- Share data without DPAs
- Use dark patterns to trick users into consent
- Pre-check optional consent boxes
- Make privacy policy hard to find
- Ignore data subject requests
- Log passwords in plaintext
- Use unencrypted database backups
- Send marketing emails without opt-in

---

## 14. Next Steps

1. **Review with Legal Counsel** (CRITICAL)
   - This document is NOT legal advice
   - Hire privacy lawyer for final review

2. **Draft Privacy Policy** (see `privacy-policy.md`)

3. **Draft Terms of Service** (see `terms-of-service.md`)

4. **Implement Technical Measures**
   - Database encryption
   - Cookie consent
   - Data export/deletion features

5. **Test Data Subject Rights**
   - Request access to your own data
   - Delete test account and verify pseudonymization

6. **Train Team**
   - GDPR awareness
   - Data handling procedures
   - Breach response plan

---

## References

- [GDPR Full Text](https://gdpr-info.eu/)
- [GDPR Checklist (ICO)](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/)
- [CCPA Full Text](https://oag.ca.gov/privacy/ccpa)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

---

**Compliance Status**: ⚠️ **IN PROGRESS** - Legal review required before launch
**Priority**: **HIGH** - Must complete before serving EU/CA users
