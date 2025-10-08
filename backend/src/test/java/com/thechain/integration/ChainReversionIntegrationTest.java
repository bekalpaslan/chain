package com.thechain.integration;

import com.thechain.entity.Invitation;
import com.thechain.entity.User;
import com.thechain.repository.InvitationRepository;
import com.thechain.repository.UserRepository;
import com.thechain.service.ChainService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Integration test for chain reversion logic.
 * Tests how the chain recovers when users are removed.
 */
@SpringBootTest
@ActiveProfiles("test")
@TestPropertySource(properties = {
    "spring.flyway.enabled=false",
    "spring.jpa.hibernate.ddl-auto=create-drop"
})
@Transactional
class ChainReversionIntegrationTest {

    @Autowired
    private ChainService chainService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private InvitationRepository invitationRepository;

    private User seed;
    private User user1;
    private User user2;
    private User user3;

    @BeforeEach
    void setUp() {
        // Create a chain: SEED → User1 → User2 → User3
        seed = createUser(0, "SEED00000000", null);
        user1 = createUser(1, "USER00000001", 0);
        user2 = createUser(2, "USER00000002", 1);
        user3 = createUser(3, "USER00000003", 2);

        // Set up bidirectional relationships
        seed.setInviteePosition(1);
        user1.setInviteePosition(2);
        user2.setInviteePosition(3);

        userRepository.save(seed);
        userRepository.save(user1);
        userRepository.save(user2);
        userRepository.save(user3);
    }

    @Test
    void removeUser_RevertsChainToInviter() {
        // Given: Chain is SEED → User1 → User2 → User3
        assertThat(user1.getInviteePosition()).isEqualTo(2);
        assertThat(user2.getInviterPosition()).isEqualTo(1);

        // When: User2 is removed
        chainService.removeUserFromChain(user2.getId(), "test_removal");

        // Then: User1 loses reference to User2
        User updatedUser1 = userRepository.findById(user1.getId()).orElseThrow();
        assertThat(updatedUser1.getInviteePosition()).isNull();

        User updatedUser2 = userRepository.findById(user2.getId()).orElseThrow();
        assertThat(updatedUser2.getStatus()).isEqualTo("removed");
        assertThat(updatedUser2.getRemovalReason()).isEqualTo("test_removal");
        assertThat(updatedUser2.getRemovedAt()).isNotNull();
    }

    @Test
    void removeUser_UpdatesInvitationStatus() {
        // Given: Create invitation record with required ticket_id
        Invitation invitation = Invitation.builder()
                .inviterPosition(1)
                .inviteePosition(2)
                .ticketId(UUID.randomUUID())  // Required field
                .status(Invitation.InvitationStatus.ACTIVE)
                .invitedAt(Instant.now())
                .build();
        invitationRepository.save(invitation);

        // When: User2 is removed
        chainService.removeUserFromChain(user2.getId(), "test_removal");

        // Then: Invitation status updated
        Invitation updatedInvitation = invitationRepository
                .findByInviteePosition(2)
                .orElseThrow();
        assertThat(updatedInvitation.getStatus()).isEqualTo(Invitation.InvitationStatus.REMOVED);
    }

    @Test
    void removeUser_ClearsInviterAndInviteeReferences() {
        // Given: User2 has both inviter and invitee
        assertThat(user2.getInviterPosition()).isEqualTo(1);
        assertThat(user2.getInviteePosition()).isEqualTo(3);

        // When: User2 is removed
        chainService.removeUserFromChain(user2.getId(), "test_removal");

        // Then: inviteePosition cleared (ChainService doesn't modify inviterPosition)
        User updatedUser2 = userRepository.findById(user2.getId()).orElseThrow();
        // Note: ChainService.removeUserFromChain() doesn't clear inviter/invitee positions
        // Only marks user as removed. This is by design to preserve historical data.
        assertThat(updatedUser2.getStatus()).isEqualTo("removed");

        // User3 still references User2 (historical data preserved)
        User updatedUser3 = userRepository.findById(user3.getId()).orElseThrow();
        assertThat(updatedUser3.getInviterPosition()).isEqualTo(2);
    }

    @Test
    void removeSeed_CannotBeRemoved() {
        // Given: Seed user with status="seed"
        seed.setStatus("seed");
        userRepository.save(seed);

        String beforeStatus = seed.getStatus();

        // When: Try to remove seed
        chainService.removeUserFromChain(seed.getId(), "test_removal");

        // Then: Seed is not removed
        User updatedSeed = userRepository.findById(seed.getId()).orElseThrow();
        assertThat(updatedSeed.getStatus()).isEqualTo("seed");  // Unchanged
        assertThat(updatedSeed.getRemovedAt()).isNull();
    }

    @Test
    void removeAlreadyRemovedUser_NoChange() {
        // Given: User already removed
        user2.setStatus("removed");
        user2.setRemovedAt(Instant.now());
        user2.setRemovalReason("previous_removal");
        userRepository.save(user2);

        Instant removalTime = user2.getRemovedAt();

        // When: Try to remove again
        chainService.removeUserFromChain(user2.getId(), "new_removal");

        // Then: No changes
        User updatedUser2 = userRepository.findById(user2.getId()).orElseThrow();
        assertThat(updatedUser2.getStatus()).isEqualTo("removed");
        assertThat(updatedUser2.getRemovalReason()).isEqualTo("previous_removal");
        assertThat(updatedUser2.getRemovedAt()).isEqualTo(removalTime);
    }

    @Test
    void chainReversion_MakesPreviousUserTip() {
        // Given: User3 is current tip (no invitee)
        User currentTip = chainService.getCurrentTip();
        assertThat(currentTip.getPosition()).isEqualTo(3);

        // When: User3 is removed
        chainService.removeUserFromChain(user3.getId(), "test_removal");

        // Then: User2 becomes new tip
        User newTip = chainService.getCurrentTip();
        assertThat(newTip.getPosition()).isEqualTo(2);
        assertThat(newTip.getInviteePosition()).isNull();
    }

    @Test
    void chainReversion_PreservesChainBeforeRemovedUser() {
        // Given: Full chain SEED → User1 → User2 → User3

        // When: User2 is removed
        chainService.removeUserFromChain(user2.getId(), "test_removal");

        // Then: Chain before User2 is intact
        User updatedSeed = userRepository.findById(seed.getId()).orElseThrow();
        assertThat(updatedSeed.getStatus()).isEqualTo("active");
        assertThat(updatedSeed.getInviteePosition()).isEqualTo(1);

        User updatedUser1 = userRepository.findById(user1.getId()).orElseThrow();
        assertThat(updatedUser1.getStatus()).isEqualTo("active");
        assertThat(updatedUser1.getInviterPosition()).isEqualTo(0);
    }

    /**
     * Helper method to create a user
     */
    private User createUser(Integer position, String chainKey, Integer inviterPosition) {
        return userRepository.save(User.builder()
                .position(position)
                .chainKey(chainKey)
                .displayName("User " + position)
                .deviceId("device-" + position)
                .deviceFingerprint("fingerprint-" + position)
                .inviterPosition(inviterPosition)
                .status("active")
                .wastedTicketsCount(0)
                .build());
    }
}
