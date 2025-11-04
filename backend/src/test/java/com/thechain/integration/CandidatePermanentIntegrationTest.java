package com.thechain.integration;

import com.thechain.entity.Invitation;
import com.thechain.entity.Ticket;
import com.thechain.entity.User;
import com.thechain.repository.InvitationRepository;
import com.thechain.repository.TicketRepository;
import com.thechain.repository.UserRepository;
import com.thechain.service.ChainService;
import com.thechain.service.TicketService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Integration tests for the Candidate/Permanent member system.
 * Tests the core mechanics of the probation period model.
 */
@SpringBootTest
@ActiveProfiles("test")
@Transactional
class CandidatePermanentIntegrationTest {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TicketRepository ticketRepository;

    @Autowired
    private InvitationRepository invitationRepository;

    @Autowired
    private ChainService chainService;

    @Autowired
    private TicketService ticketService;

    private User seedUser;

    @BeforeEach
    void setUp() {
        // Clean up
        ticketRepository.deleteAll();
        invitationRepository.deleteAll();
        userRepository.deleteAll();

        // Create seed user (always permanent)
        seedUser = User.builder()
                .chainKey("SEED00000001")
                .displayName("Seed User")
                .position(1)
                .username("seed")
                .passwordHash("hashed")
                .status("seed")
                .membershipTier("permanent")
                .promotedToPermanentAt(Instant.now())
                .inviteeDepth(2)
                .build();
        seedUser = userRepository.save(seedUser);
    }

    @Test
    void newUser_StartsAsCandidate() {
        // When: User registers
        User bob = createTestUser("Bob", 2, seedUser.getId());

        // Then: User is candidate by default
        assertThat(bob.getMembershipTier()).isEqualTo("candidate");
        assertThat(bob.getPromotedToPermanentAt()).isNull();
        assertThat(bob.getInviteeDepth()).isEqualTo(0);
    }

    @Test
    void candidate_InvitesSomeone_StaysCandidate() {
        // Given: Candidate Bob invites Charlie
        User bob = createCandidate("Bob", 2, seedUser.getId());
        User charlie = createCandidate("Charlie", 3, bob.getId());

        // Create invitation to establish relationship
        createCompletedInvitation(bob.getId(), charlie.getId());

        // When: Check promotion
        boolean promoted = chainService.checkAndPromoteToPermament(bob.getId());

        // Then: Bob is still candidate (depth-1, needs depth-2)
        assertThat(promoted).isFalse();
        User updatedBob = userRepository.findById(bob.getId()).get();
        assertThat(updatedBob.getMembershipTier()).isEqualTo("candidate");
    }

    @Test
    void candidate_InviteeInvitesSomeone_BecomesPermament() {
        // Given: Bob → Charlie → Diana (depth-2)
        User bob = createCandidate("Bob", 2, seedUser.getId());
        User charlie = createCandidate("Charlie", 3, bob.getId());
        User diana = createCandidate("Diana", 4, charlie.getId());

        // Create invitations to establish relationships
        createCompletedInvitation(bob.getId(), charlie.getId());
        createCompletedInvitation(charlie.getId(), diana.getId());

        // When: Check Bob's promotion
        boolean promoted = chainService.checkAndPromoteToPermament(bob.getId());

        // Then: Bob becomes permanent!
        assertThat(promoted).isTrue();
        User updatedBob = userRepository.findById(bob.getId()).get();
        assertThat(updatedBob.getMembershipTier()).isEqualTo("permanent");
        assertThat(updatedBob.getPromotedToPermanentAt()).isNotNull();
        assertThat(updatedBob.getInviteeDepth()).isEqualTo(2);
    }

    @Test
    void ticket_HalvingRule_24h_12h_6h() {
        // Given: Candidate with 0 strikes
        User alice = createCandidate("Alice", 2, seedUser.getId());

        // First ticket: 24 hours
        Ticket ticket1 = ticketService.createTicketForUser(alice.getId());
        long duration1 = (ticket1.getExpiresAt().toEpochMilli() - Instant.now().toEpochMilli()) / 1000;
        assertThat(duration1).isBetween(24 * 3600L - 10, 24 * 3600L + 10); // 24 hours ± 10 seconds

        // Expire first ticket
        ticketService.expireTicket(ticket1.getId());
        alice = userRepository.findById(alice.getId()).get();
        assertThat(alice.getWastedTicketsCount()).isEqualTo(1);

        // Second ticket: 12 hours (auto-created)
        Optional<Ticket> ticket2Opt = ticketRepository.findByOwnerIdAndStatus(
            alice.getId(), Ticket.TicketStatus.ACTIVE);
        assertThat(ticket2Opt).isPresent();
        Ticket ticket2 = ticket2Opt.get();
        long duration2 = (ticket2.getExpiresAt().toEpochMilli() - Instant.now().toEpochMilli()) / 1000;
        assertThat(duration2).isBetween(12 * 3600L - 10, 12 * 3600L + 10); // 12 hours ± 10 seconds

        // Expire second ticket
        ticketService.expireTicket(ticket2.getId());
        alice = userRepository.findById(alice.getId()).get();
        assertThat(alice.getWastedTicketsCount()).isEqualTo(2);

        // Third ticket: 6 hours (auto-created)
        Optional<Ticket> ticket3Opt = ticketRepository.findByOwnerIdAndStatus(
            alice.getId(), Ticket.TicketStatus.ACTIVE);
        assertThat(ticket3Opt).isPresent();
        Ticket ticket3 = ticket3Opt.get();
        long duration3 = (ticket3.getExpiresAt().toEpochMilli() - Instant.now().toEpochMilli()) / 1000;
        assertThat(duration3).isBetween(6 * 3600L - 10, 6 * 3600L + 10); // 6 hours ± 10 seconds
    }

    @Test
    void candidate_Fails_TicketGoesToLastPermanent() {
        // Given: Seed (P) → Alice (P) → Bob (C) → Charlie (C)
        User alice = createPermanent("Alice", 2, seedUser.getId());
        User bob = createCandidate("Bob", 3, alice.getId());
        User charlie = createCandidate("Charlie", 4, bob.getId());

        // Create invitations
        createCompletedInvitation(alice.getId(), bob.getId());
        createCompletedInvitation(bob.getId(), charlie.getId());

        // Charlie wastes 2 tickets first
        charlie.setWastedTicketsCount(2);
        userRepository.save(charlie);

        // Create Charlie's third ticket
        Ticket charlieTicket = ticketService.createTicketForUser(charlie.getId());

        // When: Charlie's ticket expires (3rd strike)
        ticketService.expireTicket(charlieTicket.getId());

        // Then: Charlie is removed
        User updatedCharlie = userRepository.findById(charlie.getId()).get();
        assertThat(updatedCharlie.getStatus()).isEqualTo("removed");

        // And: Alice (last permanent) gets the ticket
        Optional<Ticket> aliceTicket = ticketRepository.findByOwnerIdAndStatus(
            alice.getId(), Ticket.TicketStatus.ACTIVE);
        assertThat(aliceTicket).isPresent();
        assertThat(aliceTicket.get().getOwnerId()).isEqualTo(alice.getId());
    }

    @Test
    void findLastPermanent_SkipsMultipleCandidates() {
        // Given: Seed (P) → Alice (P) → Bob (C) → Charlie (C) → Diana (C)
        User alice = createPermanent("Alice", 2, seedUser.getId());
        User bob = createCandidate("Bob", 3, alice.getId());
        User charlie = createCandidate("Charlie", 4, bob.getId());
        User diana = createCandidate("Diana", 5, charlie.getId());

        // When: Find last permanent from Diana
        User lastPermanent = chainService.findLastPermanentMember(diana.getId());

        // Then: Should find Alice (skip Diana, Charlie, Bob)
        assertThat(lastPermanent.getId()).isEqualTo(alice.getId());
        assertThat(lastPermanent.getMembershipTier()).isEqualTo("permanent");
    }

    @Test
    void grandfatheredUsers_ArePermanent() {
        // Given: An existing user marked as "active" (simulating pre-migration user)
        User existingUser = User.builder()
                .chainKey("USER00000099")
                .displayName("Old Timer")
                .position(99)
                .username("oldtimer")
                .passwordHash("hashed")
                .status("active")
                .membershipTier("permanent")  // Would be set by migration
                .promotedToPermanentAt(Instant.now())  // Would be set by migration
                .build();
        existingUser = userRepository.save(existingUser);

        // Then: User is permanent
        assertThat(existingUser.getMembershipTier()).isEqualTo("permanent");
        assertThat(existingUser.getPromotedToPermanentAt()).isNotNull();
    }

    @Test
    void permanentMember_DoesNotGetTicketAfterStrike() {
        // Given: A permanent member with a ticket
        User permanent = createPermanent("Permanent", 2, seedUser.getId());
        Ticket ticket = ticketService.createTicketForUser(permanent.getId());

        // When: Ticket expires (but not 3rd strike)
        ticketService.expireTicket(ticket.getId());

        // Then: Permanent member doesn't get auto-ticket
        permanent = userRepository.findById(permanent.getId()).get();
        assertThat(permanent.getWastedTicketsCount()).isEqualTo(1);

        // No new ticket should be created
        Optional<Ticket> newTicket = ticketRepository.findByOwnerIdAndStatus(
            permanent.getId(), Ticket.TicketStatus.ACTIVE);
        assertThat(newTicket).isEmpty();
    }

    @Test
    void chainReversion_CascadesCorrectly() {
        // Given: Complex chain with multiple candidates
        User alice = createPermanent("Alice", 2, seedUser.getId());
        User bob = createCandidate("Bob", 3, alice.getId());
        User charlie = createCandidate("Charlie", 4, bob.getId());
        User diana = createCandidate("Diana", 5, charlie.getId());
        User eve = createCandidate("Eve", 6, diana.getId());

        // Create invitations
        createCompletedInvitation(alice.getId(), bob.getId());
        createCompletedInvitation(bob.getId(), charlie.getId());
        createCompletedInvitation(charlie.getId(), diana.getId());
        createCompletedInvitation(diana.getId(), eve.getId());

        // Eve wastes 3 tickets
        eve.setWastedTicketsCount(2);
        userRepository.save(eve);
        Ticket eveTicket = ticketService.createTicketForUser(eve.getId());
        ticketService.expireTicket(eveTicket.getId());

        // Then: Eve is removed, ticket goes to Alice (last permanent)
        eve = userRepository.findById(eve.getId()).get();
        assertThat(eve.getStatus()).isEqualTo("removed");

        Optional<Ticket> aliceTicket = ticketRepository.findByOwnerIdAndStatus(
            alice.getId(), Ticket.TicketStatus.ACTIVE);
        assertThat(aliceTicket).isPresent();
    }

    // Helper methods
    private User createTestUser(String name, int position, UUID parentId) {
        User user = User.builder()
                .chainKey("USER" + String.format("%08d", position))
                .displayName(name)
                .position(position)
                .parentId(parentId)
                .username(name.toLowerCase())
                .passwordHash("hashed")
                .status("active")
                .membershipTier("candidate")
                .inviteeDepth(0)
                .wastedTicketsCount(0)
                .build();
        return userRepository.save(user);
    }

    private User createCandidate(String name, int position, UUID parentId) {
        return createTestUser(name, position, parentId);
    }

    private User createPermanent(String name, int position, UUID parentId) {
        User user = createTestUser(name, position, parentId);
        user.setMembershipTier("permanent");
        user.setPromotedToPermanentAt(Instant.now());
        user.setInviteeDepth(2);
        return userRepository.save(user);
    }

    private Invitation createCompletedInvitation(UUID parentId, UUID childId) {
        Invitation invitation = Invitation.builder()
                .parentId(parentId)
                .childId(childId)
                .status(Invitation.InvitationStatus.ACTIVE)
                .acceptedAt(Instant.now())
                .build();
        return invitationRepository.save(invitation);
    }
}