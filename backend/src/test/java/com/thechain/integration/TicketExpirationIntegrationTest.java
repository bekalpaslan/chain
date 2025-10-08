package com.thechain.integration;

import com.thechain.entity.Invitation;
import com.thechain.entity.Ticket;
import com.thechain.entity.User;
import com.thechain.repository.InvitationRepository;
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

    @Autowired
    private InvitationRepository invitationRepository;

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
        assertThat(updatedUser.getRemovalReason()).isEqualTo("WASTED");
        assertThat(updatedUser.getRemovedAt()).isNotNull();
        // parentId and activeChildId are preserved for historical data
    }

    @Test
    void ticketExpiration_WithParent_RevertsChain() {
        // Given: Create a parent and set up relationship
        User parent = User.builder()
                .chainKey("PARENT0000001")
                .displayName("Parent")
                .position(0)
                .deviceId("parent-device")
                .deviceFingerprint("parent-fingerprint")
                .activeChildId(testUser.getId())  // Points to testUser
                .wastedTicketsCount(0)
                .status("active")
                .build();
        parent = userRepository.save(parent);

        testUser.setParentId(parent.getId());  // Points back to parent
        testUser.setWastedTicketsCount(2);  // On third strike
        testUser = userRepository.save(testUser);

        Ticket ticket = createExpiredTicket(testUser);

        // When: Third ticket expires
        ticketService.expireTicket(ticket.getId());

        // Then: Chain reverts - parent loses reference to testUser
        User updatedParent = userRepository.findById(parent.getId()).orElseThrow();
        assertThat(updatedParent.getActiveChildId()).isNull();

        User updatedUser = userRepository.findById(testUser.getId()).orElseThrow();
        assertThat(updatedUser.getStatus()).isEqualTo("removed");
        // parentId is preserved for historical data
        assertThat(updatedUser.getParentId()).isEqualTo(parent.getId());
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
        assertThat(afterStrike3.getRemovalReason()).isEqualTo("WASTED");
        assertThat(afterStrike3.getRemovedAt()).isNotNull();
    }

    @Test
    void parentThreeStrike_ThreeChildrenWasteTickets_ParentRemoved() {
        // Given: Parent with activeChildId pointing to first child
        User parent = User.builder()
                .chainKey("PARENT0000001")
                .displayName("Parent User")
                .position(10)
                .deviceId("parent-device")
                .deviceFingerprint("parent-fingerprint")
                .wastedTicketsCount(0)
                .status("active")
                .build();
        parent = userRepository.save(parent);

        // Create and remove 3 children (simulating 3 strikes for parent)
        for (int i = 1; i <= 3; i++) {
            User child = User.builder()
                    .chainKey("CHILD000000" + i)
                    .displayName("Child " + i)
                    .position(10 + i)
                    .deviceId("child-device-" + i)
                    .deviceFingerprint("child-fingerprint-" + i)
                    .parentId(parent.getId())
                    .wastedTicketsCount(2)  // Already on 2nd strike
                    .status("active")
                    .build();
            child = userRepository.save(child);

            // Create invitation record
            invitationRepository.save(Invitation.builder()
                    .parentId(parent.getId())
                    .childId(child.getId())
                    .ticketId(UUID.randomUUID())
                    .status(Invitation.InvitationStatus.ACTIVE)
                    .acceptedAt(Instant.now())
                    .build());

            parent.setActiveChildId(child.getId());
            parent = userRepository.save(parent);

            // Child wastes 3rd ticket - child removed
            Ticket ticket = createExpiredTicket(child);
            ticketService.expireTicket(ticket.getId());

            // Verify child is removed
            User removedChild = userRepository.findById(child.getId()).orElseThrow();
            assertThat(removedChild.getStatus()).isEqualTo("removed");

            // Verify invitation is marked as REMOVED
            Invitation invitation = invitationRepository.findByChildId(child.getId()).orElseThrow();
            assertThat(invitation.getStatus()).isEqualTo(Invitation.InvitationStatus.REMOVED);
        }

        // Then: After 3 children fail, parent should be removed
        User updatedParent = userRepository.findById(parent.getId()).orElseThrow();
        assertThat(updatedParent.getStatus()).isEqualTo("removed");
        assertThat(updatedParent.getRemovalReason()).isEqualTo("WASTED");
        assertThat(updatedParent.getRemovedAt()).isNotNull();
    }

    @Test
    void parentThreeStrike_TwoChildrenFail_ParentStaysActive() {
        // Given: Parent with 2 failed children (not yet 3 strikes)
        User parent = User.builder()
                .chainKey("PARENT0000002")
                .displayName("Parent User 2")
                .position(20)
                .deviceId("parent-device-2")
                .deviceFingerprint("parent-fingerprint-2")
                .wastedTicketsCount(0)
                .status("active")
                .build();
        parent = userRepository.save(parent);

        // Create and remove only 2 children
        for (int i = 1; i <= 2; i++) {
            User child = User.builder()
                    .chainKey("CHILD000002" + i)
                    .displayName("Child " + i)
                    .position(20 + i)
                    .deviceId("child-device-2-" + i)
                    .deviceFingerprint("child-fingerprint-2-" + i)
                    .parentId(parent.getId())
                    .wastedTicketsCount(2)
                    .status("active")
                    .build();
            child = userRepository.save(child);

            invitationRepository.save(Invitation.builder()
                    .parentId(parent.getId())
                    .childId(child.getId())
                    .ticketId(UUID.randomUUID())
                    .status(Invitation.InvitationStatus.ACTIVE)
                    .acceptedAt(Instant.now())
                    .build());

            parent.setActiveChildId(child.getId());
            parent = userRepository.save(parent);

            // Child wastes 3rd ticket
            Ticket ticket = createExpiredTicket(child);
            ticketService.expireTicket(ticket.getId());
        }

        // Then: Parent should still be active (only 2 strikes)
        User updatedParent = userRepository.findById(parent.getId()).orElseThrow();
        assertThat(updatedParent.getStatus()).isEqualTo("active");
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
