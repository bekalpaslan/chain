package com.thechain.service;

import com.thechain.entity.Badge;
import com.thechain.entity.Ticket;
import com.thechain.entity.User;
import jakarta.mail.internet.MimeMessage;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.test.util.ReflectionTestUtils;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.mockito.Mockito.lenient;

/**
 * Comprehensive tests for EmailService
 * Tests all 5 email notification methods and error handling
 */
@ExtendWith(MockitoExtension.class)
class EmailServiceTest {

    @Mock
    private JavaMailSender mailSender;

    @Mock
    private TemplateEngine templateEngine;

    @Mock
    private MimeMessage mimeMessage;

    @InjectMocks
    private EmailService emailService;

    private User testUser;
    private Ticket testTicket;
    private Badge testBadge;

    @BeforeEach
    void setUp() {
        // Set up test configuration values
        ReflectionTestUtils.setField(emailService, "fromAddress", "noreply@thechain.app");
        ReflectionTestUtils.setField(emailService, "fromName", "The Chain");
        ReflectionTestUtils.setField(emailService, "ticketExpirationEnabled", true);
        ReflectionTestUtils.setField(emailService, "badgeEarnedEnabled", true);
        ReflectionTestUtils.setField(emailService, "ticketUsedEnabled", true);

        // Create test user
        testUser = User.builder()
                .id(UUID.randomUUID())
                .username("testuser")
                .displayName("Test User")
                .email("test@example.com")
                .position(100)
                .chainKey("TEST123")
                .build();

        // Create test ticket
        testTicket = Ticket.builder()
                .id(UUID.randomUUID())
                .ownerId(testUser.getId())
                .ticketCode("TICKET123")
                .nextPosition(101)
                .attemptNumber(1)
                .durationHours(24)
                .issuedAt(Instant.now())
                .expiresAt(Instant.now().plus(12, ChronoUnit.HOURS))
                .status(Ticket.TicketStatus.ACTIVE)
                .signature("test-signature")
                .payload("test-payload")
                .build();

        // Create test badge
        testBadge = Badge.builder()
                .id(UUID.randomUUID())
                .badgeType(Badge.CHAIN_SAVIOR)
                .name("Chain Savior")
                .icon("🏆")
                .description("You saved The Chain from breaking")
                .build();

        // Mock JavaMailSender (lenient for tests that don't use it)
        lenient().when(mailSender.createMimeMessage()).thenReturn(mimeMessage);
        lenient().when(templateEngine.process(anyString(), any(Context.class))).thenReturn("<html>Test Email</html>");
    }

    @Test
    void testSendTicketExpiring12Hours_Success() throws Exception {
        // Arrange
        doNothing().when(mailSender).send(any(MimeMessage.class));

        // Act
        emailService.sendTicketExpiring12Hours(testUser, testTicket);

        // Assert
        verify(mailSender, times(1)).createMimeMessage();
        verify(mailSender, times(1)).send(any(MimeMessage.class));
        verify(templateEngine, times(1)).process(eq("email/ticket-expiring-12h"), any(Context.class));

        // Verify template context
        ArgumentCaptor<Context> contextCaptor = ArgumentCaptor.forClass(Context.class);
        verify(templateEngine).process(anyString(), contextCaptor.capture());
        Context context = contextCaptor.getValue();
        assertThat(context.getVariable("username")).isEqualTo("testuser");
        assertThat(context.getVariable("displayName")).isEqualTo("Test User");
        assertThat(context.getVariable("ticketCode")).isEqualTo("TICKET123");
        assertThat(context.getVariable("hoursRemaining")).isEqualTo(12);
        assertThat(context.getVariable("nextPosition")).isEqualTo(101);
    }

    @Test
    void testSendTicketExpiring1Hour_Success() throws Exception {
        // Arrange
        testTicket.setExpiresAt(Instant.now().plus(1, ChronoUnit.HOURS));
        doNothing().when(mailSender).send(any(MimeMessage.class));

        // Act
        emailService.sendTicketExpiring1Hour(testUser, testTicket);

        // Assert
        verify(mailSender, times(1)).createMimeMessage();
        verify(mailSender, times(1)).send(any(MimeMessage.class));
        verify(templateEngine, times(1)).process(eq("email/ticket-expiring-1h"), any(Context.class));

        // Verify template context
        ArgumentCaptor<Context> contextCaptor = ArgumentCaptor.forClass(Context.class);
        verify(templateEngine).process(anyString(), contextCaptor.capture());
        Context context = contextCaptor.getValue();
        assertThat(context.getVariable("username")).isEqualTo("testuser");
        assertThat(context.getVariable("hoursRemaining")).isEqualTo(1);
    }

    @Test
    void testSendTicketExpired_Success() throws Exception {
        // Arrange
        testTicket.setExpiresAt(Instant.now().minus(1, ChronoUnit.HOURS));
        testTicket.setStatus(Ticket.TicketStatus.EXPIRED);
        doNothing().when(mailSender).send(any(MimeMessage.class));

        // Act
        emailService.sendTicketExpired(testUser, testTicket);

        // Assert
        verify(mailSender, times(1)).createMimeMessage();
        verify(mailSender, times(1)).send(any(MimeMessage.class));
        verify(templateEngine, times(1)).process(eq("email/ticket-expired"), any(Context.class));

        // Verify template context
        ArgumentCaptor<Context> contextCaptor = ArgumentCaptor.forClass(Context.class);
        verify(templateEngine).process(anyString(), contextCaptor.capture());
        Context context = contextCaptor.getValue();
        assertThat(context.getVariable("attemptNumber")).isEqualTo(1);
        assertThat(context.getVariable("canGenerateNewTicket")).isEqualTo(true);
    }

    @Test
    void testSendTicketExpired_AllAttemptsUsed() throws Exception {
        // Arrange
        testTicket.setAttemptNumber(3);
        testTicket.setStatus(Ticket.TicketStatus.EXPIRED);
        doNothing().when(mailSender).send(any(MimeMessage.class));

        // Act
        emailService.sendTicketExpired(testUser, testTicket);

        // Assert
        ArgumentCaptor<Context> contextCaptor = ArgumentCaptor.forClass(Context.class);
        verify(templateEngine).process(anyString(), contextCaptor.capture());
        Context context = contextCaptor.getValue();
        assertThat(context.getVariable("attemptNumber")).isEqualTo(3);
        assertThat(context.getVariable("canGenerateNewTicket")).isEqualTo(false);
    }

    @Test
    void testSendBadgeEarned_Success() throws Exception {
        // Arrange
        doNothing().when(mailSender).send(any(MimeMessage.class));

        // Act
        emailService.sendBadgeEarned(testUser, testBadge);

        // Assert
        verify(mailSender, times(1)).createMimeMessage();
        verify(mailSender, times(1)).send(any(MimeMessage.class));
        verify(templateEngine, times(1)).process(eq("email/badge-earned"), any(Context.class));

        // Verify template context
        ArgumentCaptor<Context> contextCaptor = ArgumentCaptor.forClass(Context.class);
        verify(templateEngine).process(anyString(), contextCaptor.capture());
        Context context = contextCaptor.getValue();
        assertThat(context.getVariable("badgeName")).isEqualTo("Chain Savior");
        assertThat(context.getVariable("badgeIcon")).isEqualTo("🏆");
        assertThat(context.getVariable("badgeDescription")).isEqualTo("You saved The Chain from breaking");
    }

    @Test
    void testSendTicketUsed_Success() throws Exception {
        // Arrange
        User inviter = testUser;
        User invitee = User.builder()
                .id(UUID.randomUUID())
                .username("invitee")
                .displayName("Invitee User")
                .email("invitee@example.com")
                .position(101)
                .chainKey("INVITEE123")
                .build();

        testTicket.setClaimedBy(invitee.getId());
        testTicket.setUsedAt(Instant.now());
        testTicket.setStatus(Ticket.TicketStatus.USED);

        doNothing().when(mailSender).send(any(MimeMessage.class));

        // Act
        emailService.sendTicketUsed(inviter, invitee, testTicket);

        // Assert
        verify(mailSender, times(1)).createMimeMessage();
        verify(mailSender, times(1)).send(any(MimeMessage.class));
        verify(templateEngine, times(1)).process(eq("email/ticket-used"), any(Context.class));

        // Verify template context
        ArgumentCaptor<Context> contextCaptor = ArgumentCaptor.forClass(Context.class);
        verify(templateEngine).process(anyString(), contextCaptor.capture());
        Context context = contextCaptor.getValue();
        assertThat(context.getVariable("username")).isEqualTo("testuser");
        assertThat(context.getVariable("inviteeUsername")).isEqualTo("invitee");
        assertThat(context.getVariable("inviteeDisplayName")).isEqualTo("Invitee User");
        assertThat(context.getVariable("inviteePosition")).isEqualTo(101);
    }

    @Test
    void testSendEmail_MailSenderThrowsException() {
        // Arrange
        doThrow(new org.springframework.mail.MailSendException("SMTP server error"))
                .when(mailSender).send(any(MimeMessage.class));

        // Act & Assert
        assertThatThrownBy(() -> emailService.sendTicketExpiring12Hours(testUser, testTicket))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Failed to send email");

        verify(mailSender, times(1)).send(any(MimeMessage.class));
    }

    @Test
    void testSendEmail_UserHasNoEmail() {
        // Arrange
        testUser.setEmail(null);

        // Act
        emailService.sendTicketExpiring12Hours(testUser, testTicket);

        // Assert - should not attempt to send email
        verify(mailSender, never()).createMimeMessage();
        verify(mailSender, never()).send(any(MimeMessage.class));
    }

    @Test
    void testSendEmail_EmptyEmail() {
        // Arrange
        testUser.setEmail("");

        // Act
        emailService.sendBadgeEarned(testUser, testBadge);

        // Assert - should not attempt to send email
        verify(mailSender, never()).createMimeMessage();
        verify(mailSender, never()).send(any(MimeMessage.class));
    }

    @Test
    void testSendEmail_InvalidEmailAddress() throws Exception {
        // Arrange
        testUser.setEmail("invalid-email");
        doThrow(new org.springframework.mail.MailSendException("Invalid address"))
                .when(mailSender).send(any(MimeMessage.class));

        // Act & Assert
        assertThatThrownBy(() -> emailService.sendBadgeEarned(testUser, testBadge))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Failed to send email");
    }

    @Test
    void testNotificationsDisabled_TicketExpiration() {
        // Arrange
        ReflectionTestUtils.setField(emailService, "ticketExpirationEnabled", false);

        // Act
        emailService.sendTicketExpiring12Hours(testUser, testTicket);

        // Assert
        verify(mailSender, never()).send(any(MimeMessage.class));
    }

    @Test
    void testNotificationsDisabled_BadgeEarned() {
        // Arrange
        ReflectionTestUtils.setField(emailService, "badgeEarnedEnabled", false);

        // Act
        emailService.sendBadgeEarned(testUser, testBadge);

        // Assert
        verify(mailSender, never()).send(any(MimeMessage.class));
    }

    @Test
    void testNotificationsDisabled_TicketUsed() {
        // Arrange
        ReflectionTestUtils.setField(emailService, "ticketUsedEnabled", false);
        User invitee = User.builder()
                .id(UUID.randomUUID())
                .username("invitee")
                .displayName("Invitee User")
                .email("invitee@example.com")
                .position(101)
                .build();

        // Act
        emailService.sendTicketUsed(testUser, invitee, testTicket);

        // Assert
        verify(mailSender, never()).send(any(MimeMessage.class));
    }

    @Test
    void testTemplateProcessing_IncludesAllRequiredFields() throws Exception {
        // Arrange
        doNothing().when(mailSender).send(any(MimeMessage.class));

        // Act
        emailService.sendTicketExpiring12Hours(testUser, testTicket);

        // Assert - verify all required template variables are set
        ArgumentCaptor<Context> contextCaptor = ArgumentCaptor.forClass(Context.class);
        verify(templateEngine).process(eq("email/ticket-expiring-12h"), contextCaptor.capture());
        Context context = contextCaptor.getValue();

        assertThat(context.getVariable("username")).isNotNull();
        assertThat(context.getVariable("displayName")).isNotNull();
        assertThat(context.getVariable("ticketCode")).isNotNull();
        assertThat(context.getVariable("expiresAt")).isNotNull();
        assertThat(context.getVariable("hoursRemaining")).isNotNull();
        assertThat(context.getVariable("nextPosition")).isNotNull();
    }

    @Test
    void testMultipleEmailsSent_AllSucceed() throws Exception {
        // Arrange
        doNothing().when(mailSender).send(any(MimeMessage.class));

        // Act - send multiple different email types
        emailService.sendTicketExpiring12Hours(testUser, testTicket);
        emailService.sendTicketExpiring1Hour(testUser, testTicket);
        emailService.sendBadgeEarned(testUser, testBadge);

        // Assert
        verify(mailSender, times(3)).createMimeMessage();
        verify(mailSender, times(3)).send(any(MimeMessage.class));
    }

    @Test
    void testDateTimeFormatting() throws Exception {
        // Arrange
        Instant testTime = Instant.parse("2025-01-15T15:30:00Z");
        testTicket.setExpiresAt(testTime);
        doNothing().when(mailSender).send(any(MimeMessage.class));

        // Act
        emailService.sendTicketExpiring12Hours(testUser, testTicket);

        // Assert - verify date is formatted (exact format may vary by timezone)
        ArgumentCaptor<Context> contextCaptor = ArgumentCaptor.forClass(Context.class);
        verify(templateEngine).process(anyString(), contextCaptor.capture());
        Context context = contextCaptor.getValue();
        String formattedDate = (String) context.getVariable("expiresAt");
        assertThat(formattedDate).isNotNull();
        assertThat(formattedDate).isNotEqualTo("N/A");
    }
}
