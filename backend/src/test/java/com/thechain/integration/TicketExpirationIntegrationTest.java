package com.thechain.integration;

import com.thechain.entity.Ticket;
import com.thechain.entity.User;
import com.thechain.repository.TicketRepository;
import com.thechain.repository.UserRepository;
import com.thechain.service.TicketService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Integration test for ticket expiration flow.
 * Tests the complete lifecycle from ticket creation to expiration and user removal.
 */
@SpringBootTest
@ActiveProfiles("test")
@TestPropertySource(properties = {
    "spring.flyway.enabled=false",
    "spring.jpa.hibernate.ddl-auto=create-drop"
})
@Transactional
class TicketExpirationIntegrationTest {

    @Autowired
    private TicketService ticketService;

    @Autowired
    private TicketRepository ticketRepository;

    @Autowired
    private UserRepository userRepository;

    private User testUser;

    @BeforeEach
    void setUp() {
        // Create a test user at position 1
        testUser = User.builder()
                .chainKey("TEST00000001")
                .displayName("Test User")
                .position(1)
                .deviceId("test-device")
                .deviceFingerprint("test-fingerprint")
                .wastedTicketsCount(0)
                .status("active")
                .build();
        testUser = userRepository.save(testUser);
    }

    @Test
    void ticketExpiration_FirstAttempt_IncrementsWastedCount() {
        // Given: User generates a ticket
        Ticket ticket = createExpiredTicket(testUser);

        // When: Ticket expires
        ticketService.expireTicket(ticket.getId());

        // Then: User's wasted count increments, user stays active
        User updatedUser = userRepository.findById(testUser.getId()).orElseThrow();
        assertThat(updatedUser.getWastedTicketsCount()).isEqualTo(1);
        assertThat(updatedUser.getStatus()).isEqualTo("active");

        Ticket updatedTicket = ticketRepository.findById(ticket.getId()).orElseThrow();
        assertThat(updatedTicket.getStatus()).isEqualTo(Ticket.TicketStatus.EXPIRED);
    }

    @Test
    void ticketExpiration_SecondAttempt_IncrementsWastedCount() {
        // Given: User already wasted 1 ticket
        testUser.setWastedTicketsCount(1);
        testUser = userRepository.save(testUser);

        Ticket ticket = createExpiredTicket(testUser);

        // When: Ticket expires
        ticketService.expireTicket(ticket.getId());

        // Then: User's wasted count increments to 2, still active
        User updatedUser = userRepository.findById(testUser.getId()).orElseThrow();
        assertThat(updatedUser.getWastedTicketsCount()).isEqualTo(2);
        assertThat(updatedUser.getStatus()).isEqualTo("active");
    }

    @Test
    void ticketExpiration_ThirdAttempt_RemovesUserFromChain() {
        // Given: User already wasted 2 tickets
        testUser.setWastedTicketsCount(2);
        testUser = userRepository.save(testUser);

        Ticket ticket = createExpiredTicket(testUser);

        // When: Third ticket expires
        ticketService.expireTicket(ticket.getId());

        // Then: User is removed from chain
        User updatedUser = userRepository.findById(testUser.getId()).orElseThrow();
        assertThat(updatedUser.getWastedTicketsCount()).isEqualTo(0);  // Reset after removal
        assertThat(updatedUser.getStatus()).isEqualTo("removed");
        assertThat(updatedUser.getRemovalReason()).isEqualTo("3_wasted_tickets");
        assertThat(updatedUser.getRemovedAt()).isNotNull();
        assertThat(updatedUser.getInviterPosition()).isNull();
        assertThat(updatedUser.getInviteePosition()).isNull();
    }

    @Test
    void ticketExpiration_WithInviter_RevertsChain() {
        // Given: Create an inviter and set up relationship
        User inviter = User.builder()
                .chainKey("INVITER000001")
                .displayName("Inviter")
                .position(0)
                .deviceId("inviter-device")
                .deviceFingerprint("inviter-fingerprint")
                .inviteePosition(1)  // Points to testUser
                .wastedTicketsCount(0)
                .status("active")
                .build();
        inviter = userRepository.save(inviter);

        testUser.setInviterPosition(0);  // Points back to inviter
        testUser.setWastedTicketsCount(2);  // On third strike
        testUser = userRepository.save(testUser);

        Ticket ticket = createExpiredTicket(testUser);

        // When: Third ticket expires
        ticketService.expireTicket(ticket.getId());

        // Then: Chain reverts - inviter loses reference to testUser
        User updatedInviter = userRepository.findById(inviter.getId()).orElseThrow();
        assertThat(updatedInviter.getInviteePosition()).isNull();

        User updatedUser = userRepository.findById(testUser.getId()).orElseThrow();
        assertThat(updatedUser.getStatus()).isEqualTo("removed");
        assertThat(updatedUser.getInviterPosition()).isNull();
    }

    @Test
    void ticketExpiration_NonActiveTicket_DoesNothing() {
        // Given: An already expired ticket
        Ticket ticket = createExpiredTicket(testUser);
        ticket.setStatus(Ticket.TicketStatus.EXPIRED);
        ticket = ticketRepository.save(ticket);

        int initialWastedCount = testUser.getWastedTicketsCount();

        // When: Try to expire again
        ticketService.expireTicket(ticket.getId());

        // Then: Nothing changes
        User updatedUser = userRepository.findById(testUser.getId()).orElseThrow();
        assertThat(updatedUser.getWastedTicketsCount()).isEqualTo(initialWastedCount);
    }

    @Test
    void ticketExpiration_CompleteFlow_ThreeStrikesAndOut() {
        // Test the complete flow: 3 tickets expire, user removed

        // Strike 1
        Ticket ticket1 = createExpiredTicket(testUser);
        ticketService.expireTicket(ticket1.getId());

        User afterStrike1 = userRepository.findById(testUser.getId()).orElseThrow();
        assertThat(afterStrike1.getWastedTicketsCount()).isEqualTo(1);
        assertThat(afterStrike1.getStatus()).isEqualTo("active");

        // Strike 2
        Ticket ticket2 = createExpiredTicket(testUser);
        ticketService.expireTicket(ticket2.getId());

        User afterStrike2 = userRepository.findById(testUser.getId()).orElseThrow();
        assertThat(afterStrike2.getWastedTicketsCount()).isEqualTo(2);
        assertThat(afterStrike2.getStatus()).isEqualTo("active");

        // Strike 3 - Out!
        Ticket ticket3 = createExpiredTicket(testUser);
        ticketService.expireTicket(ticket3.getId());

        User afterStrike3 = userRepository.findById(testUser.getId()).orElseThrow();
        assertThat(afterStrike3.getWastedTicketsCount()).isEqualTo(0);  // Reset
        assertThat(afterStrike3.getStatus()).isEqualTo("removed");
        assertThat(afterStrike3.getRemovalReason()).isEqualTo("3_wasted_tickets");
        assertThat(afterStrike3.getRemovedAt()).isNotNull();
    }

    /**
     * Helper method to create an expired ticket
     */
    private Ticket createExpiredTicket(User owner) {
        Instant past = Instant.now().minus(25, ChronoUnit.HOURS);

        Ticket ticket = Ticket.builder()
                .ownerId(owner.getId())
                .status(Ticket.TicketStatus.ACTIVE)
                .issuedAt(past)
                .expiresAt(past.plus(24, ChronoUnit.HOURS))  // Expired 1 hour ago
                .attemptNumber(1)
                .ruleVersion(1)
                .durationHours(24)
                .signature("test-signature")
                .payload("test-payload")
                .build();

        return ticketRepository.save(ticket);
    }
}
