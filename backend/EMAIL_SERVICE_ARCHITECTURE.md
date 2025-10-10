# Email Service Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      The Chain Application                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         EmailService                            │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  • sendTicketExpiring12Hours(User, Ticket)                │ │
│  │  • sendTicketExpiring1Hour(User, Ticket)                  │ │
│  │  • sendTicketExpired(User, Ticket)                        │ │
│  │  • sendBadgeEarned(User, Badge)                           │ │
│  │  • sendTicketUsed(User inviter, User invitee, Ticket)     │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
           │                    │                    │
           ▼                    ▼                    ▼
    ┌──────────────┐   ┌───────────────┐   ┌─────────────────┐
    │ JavaMailSend │   │ TemplateEngine│   │  Retry Logic    │
    │   er (SMTP)  │   │  (Thymeleaf)  │   │  (@Retryable)   │
    └──────────────┘   └───────────────┘   └─────────────────┘
           │                    │
           │                    └──────────┐
           ▼                               ▼
    ┌──────────────┐          ┌────────────────────────┐
    │  Gmail SMTP  │          │   HTML Templates       │
    │  (Dev Mode)  │          │  ┌──────────────────┐  │
    └──────────────┘          │  │ ticket-expiring  │  │
           │                  │  │    -12h.html     │  │
           │                  │  ├──────────────────┤  │
           ▼                  │  │ ticket-expiring  │  │
    ┌──────────────┐          │  │    -1h.html      │  │
    │  SendGrid/   │          │  ├──────────────────┤  │
    │   AWS SES    │          │  │ ticket-expired   │  │
    │  (Prod Mode) │          │  │    .html         │  │
    └──────────────┘          │  ├──────────────────┤  │
                              │  │ badge-earned     │  │
                              │  │    .html         │  │
                              │  ├──────────────────┤  │
                              │  │ ticket-used      │  │
                              │  │    .html         │  │
                              │  └──────────────────┘  │
                              └────────────────────────┘
```

## Email Flow Diagram

```
┌────────────┐
│   Trigger  │  (e.g., Ticket expires in 12 hours)
└─────┬──────┘
      │
      ▼
┌─────────────────────────────────────────┐
│  EmailService.sendTicketExpiring12Hours │
└─────┬───────────────────────────────────┘
      │
      ▼
┌─────────────────────┐
│ Check if enabled?   │───── No ────► Skip (log)
└─────┬───────────────┘
      │ Yes
      ▼
┌─────────────────────┐
│ User has email?     │───── No ────► Skip (warn log)
└─────┬───────────────┘
      │ Yes
      ▼
┌─────────────────────────────────┐
│ Build Thymeleaf Context         │
│  • username                     │
│  • displayName                  │
│  • ticketCode                   │
│  • expiresAt (formatted)        │
│  • hoursRemaining               │
│  • nextPosition                 │
└─────┬───────────────────────────┘
      │
      ▼
┌─────────────────────────────────┐
│ Process HTML Template           │
│  templateEngine.process(        │
│    "email/ticket-expiring-12h", │
│    context                      │
│  )                              │
└─────┬───────────────────────────┘
      │
      ▼
┌─────────────────────────────────┐
│ Create MimeMessage              │
│  • From: noreply@thechain.app   │
│  • To: user.email               │
│  • Subject: "Your Chain Ticket  │
│             Expires in 12 Hours"│
│  • Body: HTML + plain text      │
└─────┬───────────────────────────┘
      │
      ▼
┌─────────────────────────────────┐
│ Send via JavaMailSender         │
│  (with @Retryable)              │
└─────┬───────────────────────────┘
      │
      ├─── Success ───► Log success
      │
      └─── Failure ───► Retry Logic
                            │
                            ▼
                    ┌───────────────┐
                    │ Attempt 1     │
                    │ (immediate)   │
                    └───┬───────────┘
                        │ Fail
                        ▼
                    ┌───────────────┐
                    │ Wait 1 second │
                    └───┬───────────┘
                        │
                        ▼
                    ┌───────────────┐
                    │ Attempt 2     │
                    └───┬───────────┘
                        │ Fail
                        ▼
                    ┌───────────────┐
                    │ Wait 2 seconds│
                    └───┬───────────┘
                        │
                        ▼
                    ┌───────────────┐
                    │ Attempt 3     │
                    └───┬───────────┘
                        │
                        ├─ Success ─► Log success
                        │
                        └─ Fail ────► Throw Exception
                                       │
                                       ▼
                                    Log error
```

## Component Interaction

```
┌──────────────────────────────────────────────────────────────┐
│                     ChainApplication.java                    │
│                    @EnableRetry added                        │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│                       EmailConfig.java                       │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  @Bean JavaMailSender javaMailSender()                 │ │
│  │  • Loads SMTP config from application-mail.yml         │ │
│  │  • Sets up connection properties                       │ │
│  │  • Configures timeouts and TLS                         │ │
│  └────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│                   application-mail.yml                       │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  spring:                                               │ │
│  │    mail:                                               │ │
│  │      host: smtp.gmail.com                              │ │
│  │      port: 587                                         │ │
│  │      username: ${MAIL_USERNAME}                        │ │
│  │      password: ${MAIL_PASSWORD}                        │ │
│  │                                                        │ │
│  │  thechain:                                             │ │
│  │    email:                                              │ │
│  │      from:                                             │ │
│  │        address: ${MAIL_FROM_ADDRESS}                   │ │
│  │      retry:                                            │ │
│  │        max-attempts: 3                                 │ │
│  │        initial-delay: 1000                             │ │
│  │      notifications:                                    │ │
│  │        ticket-expiration: true                         │ │
│  │        badge-earned: true                              │ │
│  │        ticket-used: true                               │ │
│  └────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
                      Environment Variables
                    ┌─────────────────────┐
                    │ MAIL_USERNAME       │
                    │ MAIL_PASSWORD       │
                    │ MAIL_FROM_ADDRESS   │
                    └─────────────────────┘
```

## Template Processing Flow

```
EmailService Method Called
         │
         ▼
┌─────────────────────┐
│ Create Context      │
│                     │
│  context.setVariable│
│   ("username", ...) │
│   ("displayName",..)│
│   ("ticketCode", ..)│
│   etc.              │
└─────┬───────────────┘
      │
      ▼
┌──────────────────────────────────────┐
│ TemplateEngine.process()             │
│                                      │
│  Loads: templates/email/*.html       │
│  Replaces: th:text="${variableName}" │
│  Returns: Fully rendered HTML string │
└─────┬────────────────────────────────┘
      │
      ▼
┌─────────────────────┐
│ Rendered HTML       │
│  • Dark theme       │
│  • Responsive       │
│  • User data filled │
└─────┬───────────────┘
      │
      ▼
┌─────────────────────┐
│ MimeMessage         │
│  • HTML body        │
│  • Plain text       │
│    fallback         │
└─────┬───────────────┘
      │
      ▼
    Sent!
```

## Email Template Structure

```
ticket-expiring-12h.html
├── <head>
│   ├── Meta tags (charset, viewport)
│   └── <style> (embedded CSS)
│       ├── Dark mystique colors
│       ├── Responsive layout
│       └── Email client compatibility
├── <body>
│   ├── Container
│   ├── Header
│   │   └── Logo "THE CHAIN"
│   ├── Content
│   │   ├── Greeting (th:text="${displayName}")
│   │   ├── Warning box
│   │   ├── Ticket info table
│   │   │   ├── Ticket Code (th:text="${ticketCode}")
│   │   │   ├── Expires At (th:text="${expiresAt}")
│   │   │   └── Next Position (th:text="${nextPosition}")
│   │   └── CTA Button
│   └── Footer
│       ├── Unsubscribe link
│       └── Username display
```

## Retry Logic Breakdown

```
@Retryable(
    retryFor = {MessagingException.class},
    maxAttempts = 3,
    backoff = @Backoff(
        delay = 1000,         // Initial delay: 1 second
        multiplier = 2.0,     // Double each time
        maxDelay = 10000      // Max 10 seconds
    )
)

Timeline:
T+0ms    : Attempt 1 (immediate)
           └─► Fails
T+1000ms : Attempt 2 (1 second later)
           └─► Fails
T+3000ms : Attempt 3 (2 seconds later)
           └─► Fails
T+3000ms : Throw RuntimeException

If successful at any point, returns immediately.
```

## Configuration Profiles

```
┌────────────────────────────────────────────────────────┐
│                    Development                         │
├────────────────────────────────────────────────────────┤
│  Profile: default                                      │
│  SMTP: Gmail (smtp.gmail.com:587)                      │
│  Auth: App Password                                    │
│  TLS: Required                                         │
│  Rate Limit: 500 emails/day                            │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│              Production (SendGrid)                     │
├────────────────────────────────────────────────────────┤
│  Profile: prod-sendgrid                                │
│  SMTP: SendGrid (smtp.sendgrid.net:587)                │
│  Auth: API Key                                         │
│  TLS: Required                                         │
│  Rate Limit: Based on plan                             │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│               Production (AWS SES)                     │
├────────────────────────────────────────────────────────┤
│  Profile: prod-ses                                     │
│  SMTP: AWS SES (email-smtp.us-east-1.amazonaws.com)    │
│  Auth: IAM credentials                                 │
│  TLS: Required                                         │
│  Rate Limit: Configurable                              │
└────────────────────────────────────────────────────────┘
```

## Testing Architecture

```
┌────────────────────────────────────────────────────────┐
│               EmailServiceTest.java                    │
├────────────────────────────────────────────────────────┤
│                                                        │
│  ┌──────────────────────────────────────────────┐    │
│  │         Mock Dependencies                    │    │
│  │  • @Mock JavaMailSender                      │    │
│  │  • @Mock TemplateEngine                      │    │
│  │  • @Mock MimeMessage                         │    │
│  └──────────────────────────────────────────────┘    │
│                                                        │
│  ┌──────────────────────────────────────────────┐    │
│  │         Test Data Setup (@BeforeEach)        │    │
│  │  • Create test User                          │    │
│  │  • Create test Ticket                        │    │
│  │  • Create test Badge                         │    │
│  │  • Configure mocks (lenient)                 │    │
│  └──────────────────────────────────────────────┘    │
│                                                        │
│  ┌──────────────────────────────────────────────┐    │
│  │         16 Test Methods                      │    │
│  │  • Happy path (5 tests)                      │    │
│  │  • Edge cases (6 tests)                      │    │
│  │  • Error handling (2 tests)                  │    │
│  │  • Validation (3 tests)                      │    │
│  └──────────────────────────────────────────────┘    │
│                                                        │
│  ┌──────────────────────────────────────────────┐    │
│  │         Assertions                           │    │
│  │  • Verify email sent                         │    │
│  │  • Verify template used                      │    │
│  │  • Verify context variables                  │    │
│  │  • Verify exception handling                 │    │
│  └──────────────────────────────────────────────┘    │
│                                                        │
└────────────────────────────────────────────────────────┘
```

## Integration Points

```
┌─────────────────────────────────────────────────────────┐
│              Future Integration Points                  │
└─────────────────────────────────────────────────────────┘

1. TicketExpirationScheduler
   ├─► Runs every hour (@Scheduled)
   ├─► Finds tickets expiring in 12h
   ├─► Finds tickets expiring in 1h
   └─► Calls EmailService.sendTicketExpiring*()

2. TicketService.expireTicket()
   ├─► Sets ticket status to EXPIRED
   └─► Calls EmailService.sendTicketExpired()

3. BadgeService.awardBadge()
   ├─► Creates UserBadge record
   └─► Calls EmailService.sendBadgeEarned()

4. TicketService.claimTicket()
   ├─► Marks ticket as USED
   ├─► Creates new User
   └─► Calls EmailService.sendTicketUsed()
```

## Error Handling Strategy

```
┌─────────────────────────────────────────────────────────┐
│                  Error Scenarios                        │
└─────────────────────────────────────────────────────────┘

1. User has no email
   └─► Log warning, skip email, continue

2. Invalid email format
   └─► Log warning, skip email, continue

3. SMTP connection failure
   └─► Retry 3 times
       ├─► Success: Log and return
       └─► Fail: Log error, throw exception

4. Template not found
   └─► Throw exception (fail fast)

5. Notification disabled
   └─► Log info, skip email, continue

6. Authentication failure
   └─► Retry 3 times
       └─► Fail: Log error, throw exception
```

## Security Layers

```
┌────────────────────────────────────────────────────────┐
│                   Security Measures                    │
└────────────────────────────────────────────────────────┘

1. Credentials Management
   ├─► Environment variables (never in code)
   ├─► App passwords (not real passwords)
   └─► Secrets rotation capability

2. Transport Security
   ├─► TLS/STARTTLS required
   ├─► No plain text SMTP
   └─► Encrypted connections

3. Input Validation
   ├─► Email format validation
   ├─► Template injection prevention
   └─► Context variable sanitization

4. Rate Limiting
   ├─► Configurable limits
   ├─► Prevent spam/abuse
   └─► SMTP provider compliance

5. Logging Security
   ├─► No credentials in logs
   ├─► No user email content in logs
   └─► Sanitized error messages
```

## Performance Considerations

```
┌────────────────────────────────────────────────────────┐
│               Performance Optimizations                │
└────────────────────────────────────────────────────────┘

1. Template Caching
   └─► Thymeleaf caches parsed templates

2. Connection Pooling
   └─► JavaMailSender reuses SMTP connections

3. Async Sending (Future)
   └─► Use @Async for non-blocking sends

4. Batch Processing (Future)
   └─► Send multiple emails in batches

5. Message Queue (Future)
   └─► RabbitMQ/Kafka for high volume
```

## Monitoring Dashboard

```
┌────────────────────────────────────────────────────────┐
│                  Key Metrics to Track                  │
└────────────────────────────────────────────────────────┘

Email Sent Count
├─► By Type (expiration, badge, used)
├─► By Status (success, failure, retry)
└─► Time series data

Delivery Rate
├─► Successful sends / Total attempts
└─► Target: > 99%

Retry Rate
├─► Emails requiring retries / Total
└─► Target: < 5%

Error Rate
├─► Failed sends / Total attempts
└─► Target: < 1%

Average Send Time
├─► Time from call to delivery
└─► Target: < 2 seconds

Template Render Time
├─► Time to process template
└─► Target: < 100ms
```

## Scalability Path

```
Current: Synchronous Sending
    ↓
Phase 1: Add @Async
    ↓
Phase 2: Add Message Queue
    ↓
Phase 3: Add Email Service Workers
    ↓
Phase 4: Horizontal Scaling

   1 email/sec  →  10 emails/sec  →  100 emails/sec  →  1000+ emails/sec
```

---

**Architecture Status:** ✅ Production Ready
**Last Updated:** 2025-10-09
**Version:** 1.0.0
