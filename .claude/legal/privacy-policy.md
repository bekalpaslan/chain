# Privacy Policy - The Chain

**Effective Date**: [Insert Date]
**Last Updated**: 2025-10-10 (DRAFT)

---

## Introduction

Welcome to **The Chain**. We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, share, and protect your information when you use our service at [domain.com] ("Service").

**Data Controller**: [Your Company Name], [Address]
**Contact**: [privacy@yourdomain.com]

By using The Chain, you agree to the collection and use of information in accordance with this policy.

---

## 1. Information We Collect

### 1.1 Information You Provide to Us

When you create an account, we collect:

| Data Field | Purpose | Required? |
|------------|---------|-----------|
| **Username** | Account identification, display name in chain | ✅ Yes |
| **Email address** | Account verification, notifications, password recovery | ✅ Yes |
| **Password** | Account authentication (stored as bcrypt hash, never plaintext) | ✅ Yes |
| **Display name** | Public profile display | ✅ Yes |
| **Country** | Chain statistics, analytics (ISO 2-letter code) | ⚠️ Optional |

### 1.2 Information We Collect Automatically

When you use the Service, we automatically collect:

| Data Field | Purpose |
|------------|---------|
| **IP address** | Fraud prevention, rate limiting, approximate geolocation |
| **Device information** | Browser type, operating system, device ID |
| **Usage data** | Pages visited, features used, time spent |
| **Log data** | API requests, errors, performance metrics |
| **Cookies** | Session authentication, preferences (see Section 7) |

### 1.3 Information We Derive

Based on your activity, we create:

| Data Field | Purpose |
|------------|---------|
| **Chain key** | Unique identifier in the invitation chain (e.g., "SEED00000001") |
| **Position** | Your numerical position in the global chain (e.g., 12,453) |
| **Parent/child relationships** | Your lineage in the chain (who invited you, who you invited) |
| **Ticket statistics** | Number of tickets generated, used, wasted |

### 1.4 Information We Do NOT Collect

We do NOT collect:
- ❌ Government-issued ID numbers (Social Security, passport, driver's license)
- ❌ Financial information (credit cards, bank accounts)
- ❌ Biometric data (fingerprints, facial recognition)
- ❌ Health information
- ❌ Precise geolocation (GPS coordinates)
- ❌ Racial, ethnic, religious, or political affiliation
- ❌ Phone numbers (unless you voluntarily provide)

---

## 2. How We Use Your Information

### 2.1 Legal Basis for Processing (GDPR)

| Purpose | Legal Basis | Can You Opt-Out? |
|---------|-------------|------------------|
| Account creation and authentication | Contractual necessity | ❌ No (required for service) |
| Email notifications (password reset, security alerts) | Contractual necessity | ❌ No (essential) |
| Chain lineage tracking | Contractual necessity | ❌ No (core feature) |
| Fraud prevention, rate limiting | Legitimate interest | ⚠️ Partial (limited without service impact) |
| Product improvement, analytics | Legitimate interest | ✅ Yes (opt-out in settings) |
| Marketing emails (newsletters, updates) | Consent | ✅ Yes (opt-in only) |

### 2.2 Specific Uses

We use your information to:

✅ **Provide the Service**:
- Create and manage your account
- Generate and validate invitation tickets
- Display your position in the chain
- Authenticate your login sessions

✅ **Communicate with You**:
- Send account-related emails (verification, password reset)
- Notify you about your tickets (expiration warnings)
- Respond to your support requests
- Send marketing emails (ONLY if you opt-in)

✅ **Improve the Service**:
- Analyze usage patterns to improve features
- Monitor performance and fix bugs
- Conduct A/B testing for new features
- Generate anonymized aggregate statistics

✅ **Ensure Security**:
- Detect and prevent fraud, abuse, or violations of Terms of Service
- Enforce rate limits to prevent brute-force attacks
- Investigate security incidents
- Comply with legal obligations

---

## 3. How We Share Your Information

### 3.1 We Do NOT Sell Your Data

**We do NOT sell, rent, or trade your personal information to third parties for marketing purposes.**

### 3.2 Sharing with Third Parties

We may share your data with:

| Third Party | Data Shared | Purpose | Legal Basis |
|-------------|-------------|---------|-------------|
| **Email Service Provider** (e.g., SendGrid, AWS SES) | Email address, message content | Send transactional and marketing emails | Data Processing Agreement (DPA) |
| **Cloud Hosting Provider** (e.g., AWS, DigitalOcean) | All data (servers, databases) | Infrastructure hosting | DPA with GDPR-compliant provider |
| **Analytics Service** (if used) | IP address (anonymized), usage data | Product analytics | DPA OR privacy-friendly alternative (Plausible) |

**All third-party service providers**:
- ✅ Are contractually required to protect your data (Data Processing Agreements)
- ✅ May only use your data to provide services to us
- ✅ Are GDPR/CCPA compliant (if applicable)

### 3.3 Legal Disclosures

We may disclose your information if required by law to:
- ✅ Comply with a court order, subpoena, or legal process
- ✅ Protect the rights, property, or safety of [Your Company Name], users, or the public
- ✅ Investigate fraud, security incidents, or Terms of Service violations
- ✅ Enforce our Terms of Service

### 3.4 Business Transfers

If we are acquired by or merged with another company, your data may be transferred. We will notify you via email and update this Privacy Policy.

---

## 4. How Long We Keep Your Data

### 4.1 Retention Periods

| Data Type | Retention Period | Reason |
|-----------|------------------|--------|
| **Active account data** | Account lifetime | Provide the Service |
| **Deleted account (personal data)** | **30 days** after deletion | Grace period for recovery |
| **Deleted account (chain data)** | **Permanent** (anonymized) | Preserve chain integrity for other users |
| **Email logs** | 30 days | Debugging, deliverability |
| **API access logs** | 30 days | Security, debugging |
| **Session tokens** | 24 hours | Auto-expire |
| **Password reset tokens** | 1 hour | Auto-expire |

### 4.2 Anonymization of Deleted Accounts

When you delete your account:
1. **Personal data is permanently deleted**: Username, email, password, display name
2. **Chain data is anonymized**: Your chain key, position, and parent/child relationships are retained as "Deleted User" to preserve the integrity of the chain for other users
3. **Justification**: Contractual necessity for other users' chain accuracy

**Privacy Policy Language**:
> "Your anonymized position in the chain is retained as 'Deleted User #[UUID]' to ensure other users can still view their complete chain lineage."

---

## 5. Your Rights (GDPR & CCPA)

### 5.1 European Users (GDPR)

If you are in the EU/EEA/UK, you have the following rights:

| Right | What You Can Do | How to Exercise |
|-------|-----------------|-----------------|
| **Access** (Article 15) | Request a copy of your personal data | Account Settings → "Download My Data" |
| **Rectification** (Article 16) | Correct inaccurate data | Account Settings → Edit profile |
| **Erasure** (Article 17) | Request deletion of your account | Account Settings → "Delete Account" |
| **Restriction** (Article 18) | Request temporary suspension of processing | Email privacy@yourdomain.com |
| **Data Portability** (Article 20) | Export your data in JSON format | Account Settings → "Download My Data" |
| **Object** (Article 21) | Opt-out of analytics, marketing | Account Settings → Privacy Preferences |
| **Withdraw Consent** | Revoke consent for marketing emails | Click "Unsubscribe" in any email |

**Response Time**: We will respond to requests within **30 days**.

### 5.2 California Users (CCPA)

If you are a California resident, you have the right to:

| Right | What You Can Do |
|-------|-----------------|
| **Know** | Request disclosure of personal data collected |
| **Delete** | Request deletion of personal data |
| **Opt-Out** | Opt-out of data "sale" (we don't sell data - N/A) |
| **Non-Discrimination** | No penalty for exercising your rights |

**How to Exercise**: Email privacy@yourdomain.com with subject "CCPA Request"

### 5.3 How to Exercise Your Rights

**Email**: privacy@yourdomain.com
**Subject**: "Data Request - [Your Request Type]"
**Include**: Your username, email, and request details

We may ask for identity verification (e.g., confirm email ownership) before fulfilling requests.

---

## 6. Data Security

We implement industry-standard security measures to protect your data:

### 6.1 Technical Safeguards
- ✅ **Password hashing**: Bcrypt with 10+ rounds (passwords never stored in plaintext)
- ✅ **HTTPS/TLS encryption**: All data in transit is encrypted
- ✅ **Database encryption**: Data at rest is encrypted using PostgreSQL pgcrypto
- ✅ **Secure session management**: HttpOnly, Secure, SameSite cookies
- ✅ **Rate limiting**: Prevents brute-force attacks
- ✅ **SQL injection prevention**: Parameterized queries via JPA
- ✅ **CSRF protection**: Enabled by default (Spring Security)
- ✅ **Input validation**: Sanitized to prevent XSS attacks

### 6.2 Organizational Safeguards
- ✅ **Access control**: Role-based access, principle of least privilege
- ✅ **Regular security audits**: Penetration testing, vulnerability scanning
- ✅ **Incident response plan**: Documented breach notification procedure
- ✅ **Data minimization**: We only collect data necessary for the Service

### 6.3 Data Breach Notification

In the event of a data breach:
- We will notify affected users within **72 hours** (GDPR requirement)
- Notification will include: Nature of breach, data affected, steps taken, how to protect yourself
- We will report to relevant authorities (GDPR Supervisory Authority, CCPA Attorney General)

**No security is perfect**: While we use industry-standard measures, we cannot guarantee 100% security. You are responsible for keeping your password secure.

---

## 7. Cookies and Tracking

### 7.1 What Are Cookies?

Cookies are small text files stored on your device to enable functionality and track usage.

### 7.2 Cookies We Use

| Cookie Name | Type | Purpose | Expiration | Required? |
|-------------|------|---------|------------|-----------|
| `session_token` | Strictly Necessary | Authentication | 24 hours | ✅ Yes |
| `csrf_token` | Strictly Necessary | Security (prevent CSRF attacks) | Session | ✅ Yes |
| `preferences` | Functional | Remember your settings (theme, language) | 1 year | ⚠️ No |
| `analytics_id` | Analytics | Track usage (if enabled) | 1 year | ❌ No (opt-out available) |

### 7.3 Third-Party Cookies

We do NOT use third-party advertising cookies (e.g., Google Ads, Facebook Pixel).

If we use analytics (e.g., Google Analytics), we:
- ✅ Anonymize IP addresses
- ✅ Obtain your consent via cookie banner
- ✅ Allow opt-out in settings

### 7.4 How to Manage Cookies

**Browser Settings**: Most browsers allow you to block cookies. However, blocking strictly necessary cookies may prevent you from using the Service.

**Opt-Out**: Account Settings → Privacy Preferences → Analytics Cookies (Disable)

**Do Not Track (DNT)**: We respect DNT signals from your browser.

---

## 8. Children's Privacy

### 8.1 Age Restriction

The Service is **NOT intended for children under 16**. We do not knowingly collect data from children under 16.

### 8.2 Parental Consent

If you are under 18, you confirm you have parental or guardian consent to use the Service.

### 8.3 If We Discover Child Data

If we learn we have collected data from a child under 16 without parental consent, we will delete it immediately. Parents may contact privacy@yourdomain.com to request deletion.

**Compliance**:
- ✅ COPPA (US): Age 13+ required
- ✅ GDPR (EU): Age 16+ required (or 13-15 with parental consent)
- ✅ Our policy: **16+ globally** to simplify compliance

---

## 9. International Data Transfers

### 9.1 Where We Store Data

Your data is stored on servers located in **[Specify: EU, US, etc.]**.

### 9.2 EU-US Data Transfers

If we transfer data from the EU to the US, we ensure adequate protection through:
- ✅ **Standard Contractual Clauses (SCCs)**: Approved by the European Commission
- ✅ **Data Processing Agreements (DPAs)**: With GDPR-compliant cloud providers (e.g., AWS, Google Cloud)
- ✅ **Encryption**: Data is encrypted in transit and at rest

### 9.3 Your Rights

You have the right to object to international data transfers. Contact privacy@yourdomain.com for more information.

---

## 10. Changes to This Privacy Policy

We may update this Privacy Policy from time to time. If we make **material changes**:
- ✅ We will notify you via email or in-app notification
- ✅ Changes become effective **30 days** after notice
- ✅ Continued use after changes = acceptance of new policy

We encourage you to review this policy periodically.

**Version History**:
- 2025-10-10: Initial draft

---

## 11. Contact Us

If you have questions, concerns, or requests regarding this Privacy Policy or your data, please contact us:

**[Your Company Name]**
**Data Protection Officer (DPO)**: [Name, if applicable]
**Email**: privacy@yourdomain.com
**Address**: [Your Physical Address]

**EU Representative** (if applicable): [Name, Address]

**Response Time**: We aim to respond to all inquiries within **7 business days**.

---

## 12. Supervisory Authority (EU/EEA/UK)

If you are in the EU/EEA/UK, you have the right to lodge a complaint with your local data protection authority:

- **EU**: [Find your authority](https://edpb.europa.eu/about-edpb/board/members_en)
- **UK**: [Information Commissioner's Office (ICO)](https://ico.org.uk/)
- **Germany**: [Federal Commissioner for Data Protection and Freedom of Information](https://www.bfdi.bund.de/)

---

**By using The Chain, you acknowledge that you have read and understood this Privacy Policy.**

---

## Drafting Notes (Remove before publication)

⚠️ **IMPORTANT: This is a TEMPLATE. You MUST:**
1. Replace all placeholders in [brackets] with your actual information
2. Specify data storage location (Section 9.1)
3. Add Data Protection Officer contact (if required)
4. Review with a qualified privacy attorney before publication
5. Ensure compliance with local laws in your jurisdiction
6. Test "Download My Data" and "Delete Account" features
7. Sign Data Processing Agreements with third-party services

**Customization Checklist**:
- [ ] Company name and contact information
- [ ] Effective date
- [ ] Data storage location (EU, US, etc.)
- [ ] Third-party services used (email, hosting, analytics)
- [ ] Cookie consent banner implementation
- [ ] "Download My Data" feature
- [ ] "Delete Account" feature with anonymization
- [ ] Legal review by privacy attorney
- [ ] GDPR compliance verification (if serving EU)
- [ ] CCPA compliance verification (if serving CA)

**Additional Sections to Consider**:
- User-generated content (if allowing posts, comments)
- Payment processing (if monetizing - PCI DSS compliance)
- Social media integration (if connecting to Facebook, Google)
- Location services (if using GPS)
- Push notifications (mobile apps)
- Affiliate marketing disclosure (if applicable)

**Tools for Compliance**:
- [TermsFeed Privacy Policy Generator](https://www.termsfeed.com/privacy-policy-generator/)
- [GDPR Checklist (ICO)](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/checklist/)
- [OneTrust Cookie Consent](https://www.onetrust.com/products/cookie-consent/)

---

**Status**: 🚧 DRAFT - Legal review required before publication
**Priority**: **HIGH** - Must publish before collecting user data
