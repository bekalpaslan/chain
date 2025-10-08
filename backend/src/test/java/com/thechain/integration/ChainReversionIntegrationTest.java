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
        user1 = createUser(1, "USER00000001", seed.getId());
        user2 = createUser(2, "USER00000002", user1.getId());
        user3 = createUser(3, "USER00000003", user2.getId());

        // Set up parent-child relationships using activeChildId
        seed.setActiveChildId(user1.getId());
        user1.setActiveChildId(user2.getId());
        user2.setActiveChildId(user3.getId());

        userRepository.save(seed);
        userRepository.save(user1);
        userRepository.save(user2);
        userRepository.save(user3);
    }

    @Test
    void removeUser_RevertsChainToInviter() {
        // Given: Chain is SEED → User1 → User2 → User3
        assertThat(user1.getActiveChildId()).isEqualTo(user2.getId());
        assertThat(user2.getParentId()).isEqualTo(user1.getId());

        // When: User2 is removed
        chainService.removeUserFromChain(user2.getId(), "test_removal");

        // Then: User1 loses reference to User2
        User updatedUser1 = userRepository.findById(user1.getId()).orElseThrow();
        assertThat(updatedUser1.getActiveChildId()).isNull();

        User updatedUser2 = userRepository.findById(user2.getId()).orElseThrow();
        assertThat(updatedUser2.getStatus()).isEqualTo("removed");
        assertThat(updatedUser2.getRemovalReason()).isEqualTo("test_removal");
        assertThat(updatedUser2.getRemovedAt()).isNotNull();
    }

    @Test
    void removeUser_UpdatesInvitationStatus() {
        // Given: Create invitation record with required ticket_id
        Invitation invitation = Invitation.builder()
                .parentId(user1.getId())
                .childId(user2.getId())
                .ticketId(UUID.randomUUID())  // Required field
                .status(Invitation.InvitationStatus.ACTIVE)
                .acceptedAt(Instant.now())
                .build();
        invitationRepository.save(invitation);

        // When: User2 is removed
        chainService.removeUserFromChain(user2.getId(), "test_removal");

        // Then: Invitation status updated
        Invitation updatedInvitation = invitationRepository
                .findByChildId(user2.getId())
                .orElseThrow();
        assertThat(updatedInvitation.getStatus()).isEqualTo(Invitation.InvitationStatus.REMOVED);
    }

    @Test
    void removeUser_ClearsParentActiveChildReference() {
        // Given: User2 has both parent and child
        assertThat(user2.getParentId()).isEqualTo(user1.getId());
        assertThat(user2.getActiveChildId()).isEqualTo(user3.getId());

        // When: User2 is removed
        chainService.removeUserFromChain(user2.getId(), "test_removal");

        // Then: User2 is marked as removed
        User updatedUser2 = userRepository.findById(user2.getId()).orElseThrow();
        assertThat(updatedUser2.getStatus()).isEqualTo("removed");

        // Parent (User1) has activeChildId cleared
        User updatedUser1 = userRepository.findById(user1.getId()).orElseThrow();
        assertThat(updatedUser1.getActiveChildId()).isNull();

        // User3 still references User2 as parent (historical data preserved)
        User updatedUser3 = userRepository.findById(user3.getId()).orElseThrow();
        assertThat(updatedUser3.getParentId()).isEqualTo(user2.getId());
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
        // Given: User3 is current tip (no active child)
        User currentTip = chainService.getCurrentTip();
        assertThat(currentTip.getPosition()).isEqualTo(3);

        // When: User3 is removed
        chainService.removeUserFromChain(user3.getId(), "test_removal");

        // Then: User2 becomes new tip
        User newTip = chainService.getCurrentTip();
        assertThat(newTip.getPosition()).isEqualTo(2);
        assertThat(newTip.getActiveChildId()).isNull();
    }

    @Test
    void chainReversion_PreservesChainBeforeRemovedUser() {
        // Given: Full chain SEED → User1 → User2 → User3

        // When: User2 is removed
        chainService.removeUserFromChain(user2.getId(), "test_removal");

        // Then: Chain before User2 is intact
        User updatedSeed = userRepository.findById(seed.getId()).orElseThrow();
        assertThat(updatedSeed.getStatus()).isEqualTo("active");
        assertThat(updatedSeed.getActiveChildId()).isEqualTo(user1.getId());

        User updatedUser1 = userRepository.findById(user1.getId()).orElseThrow();
        assertThat(updatedUser1.getStatus()).isEqualTo("active");
        assertThat(updatedUser1.getParentId()).isEqualTo(seed.getId());
    }

    @Test
    void threeStrikeRule_ParentRemovedAfterThreeChildrenFail() {
        // Given: User1 has had 2 children removed already
        User child1 = createUser(10, "CHILD0000001", user1.getId());
        User child2 = createUser(11, "CHILD0000002", user1.getId());
        User child3 = createUser(12, "CHILD0000003", user1.getId());

        // Create invitations and mark first two as REMOVED
        invitationRepository.save(Invitation.builder()
                .parentId(user1.getId())
                .childId(child1.getId())
                .ticketId(UUID.randomUUID())
                .status(Invitation.InvitationStatus.REMOVED)
                .acceptedAt(Instant.now())
                .build());

        invitationRepository.save(Invitation.builder()
                .parentId(user1.getId())
                .childId(child2.getId())
                .ticketId(UUID.randomUUID())
                .status(Invitation.InvitationStatus.REMOVED)
                .acceptedAt(Instant.now())
                .build());

        // Third child is currently active
        invitationRepository.save(Invitation.builder()
                .parentId(user1.getId())
                .childId(child3.getId())
                .ticketId(UUID.randomUUID())
                .status(Invitation.InvitationStatus.ACTIVE)
                .acceptedAt(Instant.now())
                .build());

        user1.setActiveChildId(child3.getId());
        userRepository.save(user1);

        // When: Third child is removed (3rd strike!)
        chainService.checkParentRemovalFor3Strikes(child3.getId());

        // Then: User1 should be removed due to 3-strike rule
        User updatedUser1 = userRepository.findById(user1.getId()).orElseThrow();
        assertThat(updatedUser1.getStatus()).isEqualTo("removed");
        assertThat(updatedUser1.getRemovalReason()).contains("WASTED");

        // Parent (seed) should have activeChildId cleared
        User updatedSeed = userRepository.findById(seed.getId()).orElseThrow();
        assertThat(updatedSeed.getActiveChildId()).isNull();
    }

    @Test
    void threeStrikeRule_ParentNotRemovedWithTwoStrikes() {
        // Given: User1 has had only 2 children removed
        User child1 = createUser(10, "CHILD0000001", user1.getId());
        User child2 = createUser(11, "CHILD0000002", user1.getId());

        invitationRepository.save(Invitation.builder()
                .parentId(user1.getId())
                .childId(child1.getId())
                .ticketId(UUID.randomUUID())
                .status(Invitation.InvitationStatus.REMOVED)
                .acceptedAt(Instant.now())
                .build());

        invitationRepository.save(Invitation.builder()
                .parentId(user1.getId())
                .childId(child2.getId())
                .ticketId(UUID.randomUUID())
                .status(Invitation.InvitationStatus.REMOVED)
                .acceptedAt(Instant.now())
                .build());

        // When: Check parent removal with only 2 strikes
        chainService.checkParentRemovalFor3Strikes(child2.getId());

        // Then: User1 should still be active (only 2 strikes)
        User updatedUser1 = userRepository.findById(user1.getId()).orElseThrow();
        assertThat(updatedUser1.getStatus()).isEqualTo("active");
    }

    @Test
    void threeStrikeRule_SeedImmuneToRemoval() {
        // Given: Seed has had 3 children removed
        User child1 = createUser(10, "CHILD0000001", seed.getId());
        User child2 = createUser(11, "CHILD0000002", seed.getId());
        User child3 = createUser(12, "CHILD0000003", seed.getId());

        seed.setStatus("seed");
        userRepository.save(seed);

        for (User child : new User[]{child1, child2, child3}) {
            invitationRepository.save(Invitation.builder()
                    .parentId(seed.getId())
                    .childId(child.getId())
                    .ticketId(UUID.randomUUID())
                    .status(Invitation.InvitationStatus.REMOVED)
                    .acceptedAt(Instant.now())
                    .build());
        }

        // When: Check parent removal for seed
        chainService.checkParentRemovalFor3Strikes(child3.getId());

        // Then: Seed should remain active (immune to removal)
        User updatedSeed = userRepository.findById(seed.getId()).orElseThrow();
        assertThat(updatedSeed.getStatus()).isEqualTo("seed");
    }

    /**
     * Helper method to create a user
     */
    private User createUser(Integer position, String chainKey, UUID parentId) {
        return userRepository.save(User.builder()
                .position(position)
                .chainKey(chainKey)
                .displayName("User " + position)
                .deviceId("device-" + position)
                .deviceFingerprint("fingerprint-" + position)
                .parentId(parentId)
                .status("active")
                .wastedTicketsCount(0)
                .build());
    }
}
