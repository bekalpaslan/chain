package com.thechain.service;

import com.thechain.entity.Badge;
import com.thechain.entity.Ticket;
import com.thechain.entity.User;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

/**
 * Email service for The Chain
 * Handles all email notifications with retry logic and template support
 */
@Service
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;
    private final TemplateEngine templateEngine;

    @Value("${thechain.email.from.address:noreply@thechain.app}")
    private String fromAddress;

    @Value("${thechain.email.from.name:The Chain}")
    private String fromName;

    @Value("${thechain.email.notifications.ticket-expiration:true}")
    private boolean ticketExpirationEnabled;

    @Value("${thechain.email.notifications.badge-earned:true}")
    private boolean badgeEarnedEnabled;

    @Value("${thechain.email.notifications.ticket-used:true}")
    private boolean ticketUsedEnabled;

    private static final String CHARSET = "UTF-8";
    private static final DateTimeFormatter DATE_TIME_FORMATTER =
        DateTimeFormatter.ofPattern("MMM dd, yyyy 'at' hh:mm a").withZone(ZoneId.systemDefault());

    public EmailService(JavaMailSender mailSender, TemplateEngine templateEngine) {
        this.mailSender = mailSender;
        this.templateEngine = templateEngine;
    }

    /**
     * Send 12-hour ticket expiration warning
     */
    @Retryable(
        retryFor = {MessagingException.class},
        maxAttempts = 3,
        backoff = @Backoff(delay = 1000, multiplier = 2.0, maxDelay = 10000)
    )
    public void sendTicketExpiring12Hours(User user, Ticket ticket) {
        if (!ticketExpirationEnabled) {
            log.info("Ticket expiration notifications are disabled");
            return;
        }

        if (user.getEmail() == null || user.getEmail().isEmpty()) {
            log.warn("User {} has no email address, skipping notification", user.getUsername());
            return;
        }

        try {
            log.info("Sending 12-hour expiration warning to {} for ticket {}", user.getEmail(), ticket.getId());

            Context context = new Context();
            context.setVariable("username", user.getUsername());
            context.setVariable("displayName", user.getDisplayName());
            context.setVariable("ticketCode", ticket.getTicketCode());
            context.setVariable("expiresAt", formatDateTime(ticket.getExpiresAt()));
            context.setVariable("hoursRemaining", 12);
            context.setVariable("nextPosition", ticket.getNextPosition());

            String htmlContent = templateEngine.process("email/ticket-expiring-12h", context);

            sendHtmlEmail(
                user.getEmail(),
                "Your Chain Ticket Expires in 12 Hours",
                htmlContent,
                "Your ticket (code: " + ticket.getTicketCode() + ") expires in 12 hours at " +
                    formatDateTime(ticket.getExpiresAt())
            );

            log.info("Successfully sent 12-hour expiration warning to {}", user.getEmail());
        } catch (Exception e) {
            log.error("Failed to send 12-hour expiration warning to {}: {}", user.getEmail(), e.getMessage(), e);
            throw new RuntimeException("Failed to send email", e);
        }
    }

    /**
     * Send 1-hour ticket expiration warning (urgent)
     */
    @Retryable(
        retryFor = {MessagingException.class},
        maxAttempts = 3,
        backoff = @Backoff(delay = 1000, multiplier = 2.0, maxDelay = 10000)
    )
    public void sendTicketExpiring1Hour(User user, Ticket ticket) {
        if (!ticketExpirationEnabled) {
            log.info("Ticket expiration notifications are disabled");
            return;
        }

        if (user.getEmail() == null || user.getEmail().isEmpty()) {
            log.warn("User {} has no email address, skipping notification", user.getUsername());
            return;
        }

        try {
            log.info("Sending 1-hour expiration warning to {} for ticket {}", user.getEmail(), ticket.getId());

            Context context = new Context();
            context.setVariable("username", user.getUsername());
            context.setVariable("displayName", user.getDisplayName());
            context.setVariable("ticketCode", ticket.getTicketCode());
            context.setVariable("expiresAt", formatDateTime(ticket.getExpiresAt()));
            context.setVariable("hoursRemaining", 1);
            context.setVariable("nextPosition", ticket.getNextPosition());

            String htmlContent = templateEngine.process("email/ticket-expiring-1h", context);

            sendHtmlEmail(
                user.getEmail(),
                "URGENT: Your Chain Ticket Expires in 1 Hour!",
                htmlContent,
                "URGENT: Your ticket (code: " + ticket.getTicketCode() + ") expires in 1 hour at " +
                    formatDateTime(ticket.getExpiresAt())
            );

            log.info("Successfully sent 1-hour expiration warning to {}", user.getEmail());
        } catch (Exception e) {
            log.error("Failed to send 1-hour expiration warning to {}: {}", user.getEmail(), e.getMessage(), e);
            throw new RuntimeException("Failed to send email", e);
        }
    }

    /**
     * Send ticket expired notification
     */
    @Retryable(
        retryFor = {MessagingException.class},
        maxAttempts = 3,
        backoff = @Backoff(delay = 1000, multiplier = 2.0, maxDelay = 10000)
    )
    public void sendTicketExpired(User user, Ticket ticket) {
        if (!ticketExpirationEnabled) {
            log.info("Ticket expiration notifications are disabled");
            return;
        }

        if (user.getEmail() == null || user.getEmail().isEmpty()) {
            log.warn("User {} has no email address, skipping notification", user.getUsername());
            return;
        }

        try {
            log.info("Sending ticket expired notification to {} for ticket {}", user.getEmail(), ticket.getId());

            Context context = new Context();
            context.setVariable("username", user.getUsername());
            context.setVariable("displayName", user.getDisplayName());
            context.setVariable("ticketCode", ticket.getTicketCode());
            context.setVariable("expiredAt", formatDateTime(ticket.getExpiresAt()));
            context.setVariable("attemptNumber", ticket.getAttemptNumber());
            context.setVariable("canGenerateNewTicket", ticket.getAttemptNumber() < 3);

            String htmlContent = templateEngine.process("email/ticket-expired", context);

            sendHtmlEmail(
                user.getEmail(),
                "Your Chain Ticket Has Expired",
                htmlContent,
                "Your ticket (code: " + ticket.getTicketCode() + ") has expired. " +
                    (ticket.getAttemptNumber() < 3 ? "You can generate a new ticket." : "")
            );

            log.info("Successfully sent ticket expired notification to {}", user.getEmail());
        } catch (Exception e) {
            log.error("Failed to send ticket expired notification to {}: {}", user.getEmail(), e.getMessage(), e);
            throw new RuntimeException("Failed to send email", e);
        }
    }

    /**
     * Send badge earned celebration email
     */
    @Retryable(
        retryFor = {MessagingException.class},
        maxAttempts = 3,
        backoff = @Backoff(delay = 1000, multiplier = 2.0, maxDelay = 10000)
    )
    public void sendBadgeEarned(User user, Badge badge) {
        if (!badgeEarnedEnabled) {
            log.info("Badge earned notifications are disabled");
            return;
        }

        if (user.getEmail() == null || user.getEmail().isEmpty()) {
            log.warn("User {} has no email address, skipping notification", user.getUsername());
            return;
        }

        try {
            log.info("Sending badge earned notification to {} for badge {}", user.getEmail(), badge.getName());

            Context context = new Context();
            context.setVariable("username", user.getUsername());
            context.setVariable("displayName", user.getDisplayName());
            context.setVariable("badgeName", badge.getName());
            context.setVariable("badgeIcon", badge.getIcon());
            context.setVariable("badgeDescription", badge.getDescription());
            context.setVariable("position", user.getPosition());

            String htmlContent = templateEngine.process("email/badge-earned", context);

            sendHtmlEmail(
                user.getEmail(),
                "You Earned a Badge: " + badge.getName(),
                htmlContent,
                "Congratulations! You've earned the " + badge.getName() + " badge: " + badge.getDescription()
            );

            log.info("Successfully sent badge earned notification to {}", user.getEmail());
        } catch (Exception e) {
            log.error("Failed to send badge earned notification to {}: {}", user.getEmail(), e.getMessage(), e);
            throw new RuntimeException("Failed to send email", e);
        }
    }

    /**
     * Send ticket used notification to inviter (someone joined your chain)
     */
    @Retryable(
        retryFor = {MessagingException.class},
        maxAttempts = 3,
        backoff = @Backoff(delay = 1000, multiplier = 2.0, maxDelay = 10000)
    )
    public void sendTicketUsed(User inviter, User invitee, Ticket ticket) {
        if (!ticketUsedEnabled) {
            log.info("Ticket used notifications are disabled");
            return;
        }

        if (inviter.getEmail() == null || inviter.getEmail().isEmpty()) {
            log.warn("User {} has no email address, skipping notification", inviter.getUsername());
            return;
        }

        try {
            log.info("Sending ticket used notification to {} for ticket {}", inviter.getEmail(), ticket.getId());

            Context context = new Context();
            context.setVariable("username", inviter.getUsername());
            context.setVariable("displayName", inviter.getDisplayName());
            context.setVariable("inviteeUsername", invitee.getUsername());
            context.setVariable("inviteeDisplayName", invitee.getDisplayName());
            context.setVariable("inviteePosition", invitee.getPosition());
            context.setVariable("ticketCode", ticket.getTicketCode());
            context.setVariable("usedAt", formatDateTime(ticket.getUsedAt()));
            context.setVariable("chainKey", invitee.getChainKey());

            String htmlContent = templateEngine.process("email/ticket-used", context);

            sendHtmlEmail(
                inviter.getEmail(),
                "Someone Joined Your Chain!",
                htmlContent,
                invitee.getDisplayName() + " (@" + invitee.getUsername() + ") has joined The Chain using your ticket!"
            );

            log.info("Successfully sent ticket used notification to {}", inviter.getEmail());
        } catch (Exception e) {
            log.error("Failed to send ticket used notification to {}: {}", inviter.getEmail(), e.getMessage(), e);
            throw new RuntimeException("Failed to send email", e);
        }
    }

    /**
     * Send HTML email with fallback to plain text
     */
    private void sendHtmlEmail(String to, String subject, String htmlContent, String plainTextFallback)
            throws MessagingException {

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, CHARSET);

            helper.setFrom(fromAddress, fromName);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(plainTextFallback, htmlContent);

            mailSender.send(message);
        } catch (jakarta.mail.MessagingException e) {
            throw new MessagingException("Failed to send email to " + to, e);
        } catch (Exception e) {
            throw new MessagingException("Unexpected error sending email to " + to, e);
        }
    }

    /**
     * Format Instant to readable date/time string
     */
    private String formatDateTime(Instant instant) {
        if (instant == null) {
            return "N/A";
        }
        return DATE_TIME_FORMATTER.format(instant);
    }

}
