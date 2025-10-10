# Email Service Setup Guide for The Chain

This guide provides complete instructions for setting up and testing the email notification service.

## Overview

The Chain email service sends HTML notifications for:
- **Ticket expiration warnings** (12 hours and 1 hour before expiry)
- **Ticket expired notifications**
- **Badge earned celebrations**
- **Ticket used confirmations** (when someone joins your chain)

## Architecture

### Components
1. **EmailService.java** - Main service with 5 notification methods
2. **EmailConfig.java** - JavaMailSender bean configuration
3. **Email Templates** - 5 Thymeleaf HTML templates with dark mystique branding
4. **application-mail.yml** - SMTP configuration
5. **EmailServiceTest.java** - Comprehensive unit tests

### Features
- **HTML email templates** with purple/black theme matching The Chain branding
- **Retry logic** - 3 attempts with exponential backoff (1s, 2s, 4s)
- **Graceful error handling** - Logs failures, skips users without email
- **Feature flags** - Enable/disable notification types via config
- **Multiple SMTP providers** - Gmail (dev), SendGrid/AWS SES (production)

## Prerequisites

- Java 17+
- Spring Boot 3.2.0
- Gmail account (for development) OR SendGrid/AWS SES (for production)

## Gmail SMTP Setup (Development)

### Step 1: Enable 2-Factor Authentication

1. Go to your Google Account settings: https://myaccount.google.com/
2. Navigate to **Security**
3. Enable **2-Step Verification** if not already enabled

### Step 2: Generate App Password

1. Go to: https://myaccount.google.com/apppasswords
2. Select app: **Mail**
3. Select device: **Other (Custom name)**
4. Enter name: "The Chain Email Service"
5. Click **Generate**
6. **Copy the 16-character password** (it will only be shown once)

Example: `abcd efgh ijkl mnop` → Use as `abcdefghijklmnop`

### Step 3: Set Environment Variables

**Windows (PowerShell):**
```powershell
$env:MAIL_USERNAME="your-gmail@gmail.com"
$env:MAIL_PASSWORD="abcdefghijklmnop"
$env:MAIL_FROM_ADDRESS="noreply@thechain.app"
```

**Windows (Command Prompt):**
```cmd
set MAIL_USERNAME=your-gmail@gmail.com
set MAIL_PASSWORD=abcdefghijklmnop
set MAIL_FROM_ADDRESS=noreply@thechain.app
```

**macOS/Linux:**
```bash
export MAIL_USERNAME="your-gmail@gmail.com"
export MAIL_PASSWORD="abcdefghijklmnop"
export MAIL_FROM_ADDRESS="noreply@thechain.app"
```

**Add to your IDE (IntelliJ IDEA):**
1. Run → Edit Configurations
2. Select your Spring Boot configuration
3. Add Environment Variables:
   - `MAIL_USERNAME=your-gmail@gmail.com`
   - `MAIL_PASSWORD=abcdefghijklmnop`
   - `MAIL_FROM_ADDRESS=noreply@thechain.app`

**Add to .env file (for Docker):**
```env
MAIL_USERNAME=your-gmail@gmail.com
MAIL_PASSWORD=abcdefghijklmnop
MAIL_FROM_ADDRESS=noreply@thechain.app
```

## Production Setup

### SendGrid (Recommended)

1. Sign up at https://sendgrid.com/
2. Create an API Key with "Mail Send" permissions
3. Set environment variables:

```bash
export SPRING_PROFILES_ACTIVE=prod-sendgrid
export SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxxx
export MAIL_FROM_ADDRESS=noreply@thechain.app
```

### AWS SES

1. Set up AWS SES in your region
2. Verify your domain
3. Create SMTP credentials
4. Set environment variables:

```bash
export SPRING_PROFILES_ACTIVE=prod-ses
export AWS_SES_USERNAME=AKIA...
export AWS_SES_PASSWORD=xxxxxxxxxxxxx
export MAIL_FROM_ADDRESS=noreply@thechain.app
```

## Configuration

### Application Configuration

The email service uses `application-mail.yml` for configuration:

```yaml
spring:
  mail:
    host: smtp.gmail.com
    port: 587
    username: ${MAIL_USERNAME:}
    password: ${MAIL_PASSWORD:}

thechain:
  email:
    from:
      address: ${MAIL_FROM_ADDRESS:noreply@thechain.app}
      name: "The Chain"
    retry:
      max-attempts: 3
      initial-delay: 1000
      multiplier: 2.0
    notifications:
      ticket-expiration: true
      badge-earned: true
      ticket-used: true
```

### Disable Specific Notifications

To disable certain notification types, set in `application.yml`:

```yaml
thechain:
  email:
    notifications:
      ticket-expiration: false  # Disable ticket expiration emails
      badge-earned: true
      ticket-used: true
```

## Testing the Email Service

### Unit Tests

Run all email service tests:

```bash
cd backend
mvn test -Dtest=EmailServiceTest
```

**Tests included:**
1. ✅ Send 12-hour expiration warning
2. ✅ Send 1-hour expiration warning
3. ✅ Send ticket expired notification
4. ✅ Send badge earned celebration
5. ✅ Send ticket used notification
6. ✅ Handle email sending failure
7. ✅ Handle missing email address
8. ✅ Handle invalid email address
9. ✅ Test retry logic (3 attempts)
10. ✅ Test notification enable/disable flags

### Integration Testing with GreenMail

The tests use GreenMail for in-memory SMTP testing. No real emails are sent during unit tests.

### Manual Testing

#### Test 1: Send Ticket Expiration Warning

Create a test controller or use your existing ticket service:

```java
@RestController
@RequestMapping("/api/test")
public class EmailTestController {

    @Autowired
    private EmailService emailService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TicketRepository ticketRepository;

    @PostMapping("/email/ticket-expiring")
    public ResponseEntity<String> testTicketExpiring(@RequestParam String username) {
        User user = userRepository.findByUsername(username).orElseThrow();
        Ticket ticket = ticketRepository.findByOwnerIdAndStatus(
            user.getId(),
            Ticket.TicketStatus.ACTIVE
        ).orElseThrow();

        emailService.sendTicketExpiring12Hours(user, ticket);
        return ResponseEntity.ok("Email sent to " + user.getEmail());
    }
}
```

#### Test 2: Check Email Logs

The service logs all email operations:

```
INFO  c.t.service.EmailService - Sending 12-hour expiration warning to test@example.com for ticket abc-123
INFO  c.t.service.EmailService - Successfully sent 12-hour expiration warning to test@example.com
```

#### Test 3: Test Retry Logic

To test retry logic, temporarily configure an invalid SMTP server and watch the logs:

```
WARN  c.t.service.EmailService - Attempt 1 failed, retrying...
WARN  c.t.service.EmailService - Attempt 2 failed, retrying...
ERROR c.t.service.EmailService - Failed to send email after 3 attempts
```

## Email Templates

### Template Structure

All templates are located in `backend/src/main/resources/templates/email/`:

1. **ticket-expiring-12h.html** - Friendly 12-hour warning
2. **ticket-expiring-1h.html** - Urgent 1-hour warning (red theme)
3. **ticket-expired.html** - Ticket expired notification
4. **badge-earned.html** - Badge celebration (gold theme)
5. **ticket-used.html** - Success notification (green theme)

### Template Variables

Each template receives different variables via Thymeleaf context:

**Ticket Expiration:**
- `username`, `displayName`
- `ticketCode`, `expiresAt`
- `hoursRemaining`, `nextPosition`

**Badge Earned:**
- `username`, `displayName`
- `badgeName`, `badgeIcon`, `badgeDescription`
- `position`

**Ticket Used:**
- `username`, `displayName`
- `inviteeUsername`, `inviteeDisplayName`, `inviteePosition`
- `ticketCode`, `usedAt`, `chainKey`

### Customizing Templates

To customize email templates, edit the HTML files in `templates/email/`:

1. Maintain the dark mystique branding (purple #8B5CF6, black #0A0A0F)
2. Keep mobile-responsive design
3. Test with multiple email clients
4. Use Thymeleaf variables: `th:text="${variableName}"`

## Email Branding

### Color Palette
- **Background:** Deep black (#0A0A0F)
- **Primary:** Mystical purple (#8B5CF6)
- **Text:** Off-white (#E4E4E7)
- **Accent:** Ethereal cyan (#06B6D4)
- **Success:** Green (#10B981)
- **Warning:** Red (#EF4444)
- **Badge:** Gold (#FFD700)

### Typography
- Font: System fonts (-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto)
- Generous spacing for readability
- Clear hierarchy with font sizes

## Troubleshooting

### Issue: Emails not sending

**Check:**
1. Environment variables are set correctly
2. Gmail App Password is valid (not your regular password)
3. SMTP settings in `application-mail.yml` are correct
4. Check application logs for errors

**Solution:**
```bash
# Verify environment variables
echo $MAIL_USERNAME
echo $MAIL_PASSWORD

# Check logs
tail -f backend/logs/application.log | grep EmailService
```

### Issue: "Authentication failed" error

**Cause:** Invalid Gmail credentials or 2FA not enabled

**Solution:**
1. Verify 2-Step Verification is enabled on your Google account
2. Generate a new App Password
3. Update `MAIL_PASSWORD` environment variable
4. Restart the application

### Issue: Emails going to spam

**Cause:** Gmail SMTP flagged as spam by recipient servers

**Solution:**
1. For production, use SendGrid or AWS SES
2. Set up SPF, DKIM, and DMARC records for your domain
3. Use a verified domain in the "From" address

### Issue: Template not found error

**Error:** `TemplateInputException: Error resolving template "email/ticket-expiring-12h"`

**Solution:**
1. Verify templates exist in `src/main/resources/templates/email/`
2. Check file names match exactly (case-sensitive)
3. Ensure `spring-boot-starter-thymeleaf` dependency is included
4. Rebuild the project: `mvn clean install`

### Issue: Retry not working

**Cause:** `@EnableRetry` not configured

**Solution:**
1. Verify `@EnableRetry` annotation on `ChainApplication.java`
2. Check `spring-retry` dependency in `pom.xml`
3. Ensure `@Retryable` annotation is on email methods

## Rate Limiting

To prevent spam and respect SMTP provider limits:

**Gmail Limits:**
- 500 emails per day (for free accounts)
- 100 recipients per message

**SendGrid Limits:**
- Free tier: 100 emails/day
- Paid tiers: Much higher

**AWS SES Limits:**
- Sandbox: 200 emails/day
- Production: Request limit increase

**Recommended:** Implement batch processing for bulk notifications.

## Monitoring and Logging

### Log Levels

```yaml
logging:
  level:
    com.thechain.service.EmailService: DEBUG
```

### Key Log Messages

- `Sending 12-hour expiration warning to {email}` - Email being sent
- `Successfully sent {type} notification to {email}` - Email sent successfully
- `Failed to send {type} notification to {email}` - Email failed after retries
- `User {username} has no email address, skipping notification` - User has no email

### Metrics to Track

1. **Delivery rate** - Successful sends vs. failures
2. **Open rate** - Track email opens (requires pixel tracking)
3. **Click-through rate** - Track link clicks in emails
4. **Bounce rate** - Invalid email addresses
5. **Spam rate** - Emails marked as spam

## Security Best Practices

1. **Never commit credentials** - Always use environment variables
2. **Use App Passwords** - Never use your main Gmail password
3. **Rotate credentials regularly** - Change App Passwords every 90 days
4. **Use TLS/STARTTLS** - Encrypt email transmission
5. **Validate email addresses** - Check format before sending
6. **Rate limiting** - Prevent email bombing
7. **Sanitize user input** - Prevent email injection attacks

## Next Steps

1. **Set up scheduled jobs** - Automatically send expiration warnings
2. **Implement email preferences** - Let users choose which emails to receive
3. **Add email verification** - Verify email addresses on registration
4. **Track email analytics** - Monitor delivery and engagement
5. **Add email templates for other events** - Welcome emails, password resets, etc.

## API Reference

### EmailService Methods

#### sendTicketExpiring12Hours(User user, Ticket ticket)
Sends 12-hour expiration warning.

**Parameters:**
- `user` - User who owns the ticket
- `ticket` - Ticket that's expiring

**Throws:**
- `RuntimeException` if email fails after 3 retries

#### sendTicketExpiring1Hour(User user, Ticket ticket)
Sends urgent 1-hour expiration warning.

#### sendTicketExpired(User user, Ticket ticket)
Sends ticket expired notification.

#### sendBadgeEarned(User user, Badge badge)
Sends badge earned celebration email.

#### sendTicketUsed(User inviter, User invitee, Ticket ticket)
Sends notification when someone uses your ticket.

**Parameters:**
- `inviter` - User who created the ticket
- `invitee` - User who used the ticket
- `ticket` - The ticket that was used

## Support

For issues or questions:
- Check logs: `backend/logs/application.log`
- Review tests: `EmailServiceTest.java`
- Consult Spring Mail documentation: https://docs.spring.io/spring-framework/reference/integration/email.html

## License

Part of The Chain project - All rights reserved.
