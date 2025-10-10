# Email Service Quick Start Guide

## 5-Minute Setup (Development)

### 1. Generate Gmail App Password

1. Visit: https://myaccount.google.com/apppasswords
2. Create app password named "The Chain"
3. Copy the 16-character password

### 2. Set Environment Variables

**Windows (PowerShell):**
```powershell
$env:MAIL_USERNAME="your-email@gmail.com"
$env:MAIL_PASSWORD="your-app-password"
$env:MAIL_FROM_ADDRESS="noreply@thechain.app"
```

**Mac/Linux:**
```bash
export MAIL_USERNAME="your-email@gmail.com"
export MAIL_PASSWORD="your-app-password"
export MAIL_FROM_ADDRESS="noreply@thechain.app"
```

### 3. Start the Application

```bash
cd backend
mvn spring-boot:run
```

### 4. Test Email Sending

Use the service in your code:

```java
@Autowired
private EmailService emailService;

// Send ticket expiring email
emailService.sendTicketExpiring12Hours(user, ticket);

// Send badge earned email
emailService.sendBadgeEarned(user, badge);

// Send ticket used email
emailService.sendTicketUsed(inviter, invitee, ticket);
```

## What Was Created

### Files Created

1. **Service Layer:**
   - `EmailService.java` - Main email service with 5 methods
   - `EmailConfig.java` - JavaMailSender configuration

2. **Templates (Dark Mystique Theme):**
   - `ticket-expiring-12h.html` - 12-hour warning (purple)
   - `ticket-expiring-1h.html` - 1-hour urgent warning (red)
   - `ticket-expired.html` - Expired notification (gray)
   - `badge-earned.html` - Badge celebration (gold)
   - `ticket-used.html` - Success notification (green)

3. **Configuration:**
   - `application-mail.yml` - SMTP settings
   - Updated `pom.xml` with dependencies
   - Updated `ChainApplication.java` with `@EnableRetry`

4. **Tests:**
   - `EmailServiceTest.java` - 16 comprehensive unit tests

5. **Documentation:**
   - `EMAIL_SERVICE_SETUP.md` - Complete setup guide
   - `EMAIL_SERVICE_QUICK_START.md` - This file

### Dependencies Added

```xml
<!-- Email -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-mail</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>

<!-- Spring Retry -->
<dependency>
    <groupId>org.springframework.retry</groupId>
    <artifactId>spring-retry</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-aspects</artifactId>
</dependency>

<!-- Testing -->
<dependency>
    <groupId>com.icegreen</groupId>
    <artifactId>greenmail-spring</artifactId>
    <version>2.0.1</version>
    <scope>test</scope>
</dependency>
```

## Email Service API

### Method 1: Ticket Expiring 12 Hours
```java
emailService.sendTicketExpiring12Hours(user, ticket);
```
Sends friendly warning 12 hours before ticket expires.

### Method 2: Ticket Expiring 1 Hour
```java
emailService.sendTicketExpiring1Hour(user, ticket);
```
Sends urgent warning 1 hour before ticket expires.

### Method 3: Ticket Expired
```java
emailService.sendTicketExpired(user, ticket);
```
Notifies user their ticket has expired.

### Method 4: Badge Earned
```java
emailService.sendBadgeEarned(user, badge);
```
Celebrates when user earns a badge.

### Method 5: Ticket Used
```java
emailService.sendTicketUsed(inviter, invitee, ticket);
```
Notifies inviter when someone uses their ticket.

## Features

✅ **HTML Email Templates** - Beautiful dark theme matching The Chain branding
✅ **Retry Logic** - 3 automatic retries with exponential backoff
✅ **Error Handling** - Graceful failures, detailed logging
✅ **Feature Flags** - Enable/disable notification types
✅ **Mobile Responsive** - Works on all email clients
✅ **Production Ready** - Support for SendGrid and AWS SES
✅ **Comprehensive Tests** - 16 unit tests with GreenMail

## Configuration Options

### Disable Specific Notifications

In `application.yml`:

```yaml
thechain:
  email:
    notifications:
      ticket-expiration: false  # Disable ticket emails
      badge-earned: true
      ticket-used: true
```

### Change Retry Behavior

In `application-mail.yml`:

```yaml
thechain:
  email:
    retry:
      max-attempts: 5        # Change from 3 to 5 attempts
      initial-delay: 2000    # Wait 2 seconds initially
      multiplier: 2.0        # Double delay each time
```

## Testing

### Run All Email Tests
```bash
mvn test -Dtest=EmailServiceTest
```

### Run Specific Test
```bash
mvn test -Dtest=EmailServiceTest#testSendTicketExpiring12Hours_Success
```

### Check Logs
```bash
tail -f backend/logs/application.log | grep EmailService
```

## Troubleshooting

### "Authentication failed"
- Verify you're using an App Password, not your regular Gmail password
- Check 2-Step Verification is enabled on your Google account

### "Template not found"
- Verify files exist in `src/main/resources/templates/email/`
- Rebuild project: `mvn clean install`

### Emails not sending
- Check environment variables are set: `echo $MAIL_USERNAME`
- Review logs for errors
- Verify SMTP settings in `application-mail.yml`

## Production Deployment

### Switch to SendGrid

```bash
export SPRING_PROFILES_ACTIVE=prod-sendgrid
export SENDGRID_API_KEY=SG.xxxxxxxx
export MAIL_FROM_ADDRESS=noreply@thechain.app
```

### Switch to AWS SES

```bash
export SPRING_PROFILES_ACTIVE=prod-ses
export AWS_SES_USERNAME=AKIA...
export AWS_SES_PASSWORD=xxxxx
export MAIL_FROM_ADDRESS=noreply@thechain.app
```

## Next Steps

1. **Integrate with Scheduler** - Automatically send expiration warnings
2. **Add Email Preferences** - Let users opt-in/out of notifications
3. **Track Analytics** - Monitor open rates and clicks
4. **Verify Domain** - Set up SPF/DKIM for production
5. **Add More Templates** - Welcome emails, password resets, etc.

## Support

For detailed documentation, see `EMAIL_SERVICE_SETUP.md`

For issues:
- Check application logs
- Review test cases in `EmailServiceTest.java`
- Consult Spring Mail docs: https://docs.spring.io/spring-boot/docs/current/reference/html/io.html#io.email
