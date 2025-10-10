package com.thechain.service;

import com.thechain.dto.UserChainResponse;
import com.thechain.dto.UserProfileResponse;
import com.thechain.entity.Invitation;
import com.thechain.entity.User;
import com.thechain.exception.BusinessException;
import com.thechain.fixtures.TestDataBuilder;
import com.thechain.repository.InvitationRepository;
import com.thechain.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Unit tests for UserService
 * Tests user profile retrieval, chain management, and related operations
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("UserService Unit Tests")
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private InvitationRepository invitationRepository;

    @InjectMocks
    private UserService userService;

    private User testUser;
    private User seedUser;
    private UUID testUserId;

    @BeforeEach
    void setUp() {
        testUserId = UUID.randomUUID();

        // Create seed user using TestDataBuilder
        seedUser = TestDataBuilder.user()
                .asSeedUser()
                .build();

        // Create test user
        testUser = TestDataBuilder.user()
                .withId(testUserId)
                .withUsername("testuser")
                .withDisplayName("Test User")
                .withPosition(100)
                .withParentId(seedUser.getId())
                .build();
    }

    // ==================== getUserProfile Tests ====================

    @Test
    @DisplayName("Get user profile - Success with valid user ID")
    void whenGetUserProfile_withValidUserId_thenReturnsProfile() {
        // Arrange
        when(userRepository.findById(testUserId)).thenReturn(Optional.of(testUser));

        // Act
        UserProfileResponse response = userService.getUserProfile(testUserId);

        // Assert
        assertThat(response).isNotNull();
        assertThat(response.getUserId()).isEqualTo(testUserId);
        assertThat(response.getChainKey()).isEqualTo(testUser.getChainKey());
        assertThat(response.getDisplayName()).isEqualTo("Test User");
        assertThat(response.getPosition()).isEqualTo(100);
        assertThat(response.getParentId()).isEqualTo(seedUser.getId());
        assertThat(response.getStatus()).isEqualTo("active");

        verify(userRepository).findById(testUserId);
    }

    @Test
    @DisplayName("Get user profile - Throws exception when user not found")
    void whenGetUserProfile_withInvalidUserId_thenThrowsException() {
        // Arrange
        UUID nonExistentId = UUID.randomUUID();
        when(userRepository.findById(nonExistentId)).thenReturn(Optional.empty());

        // Act & Assert
        assertThatThrownBy(() -> userService.getUserProfile(nonExistentId))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("User not found");

        verify(userRepository).findById(nonExistentId);
    }

    @Test
    @DisplayName("Get user profile - Returns profile with active child")
    void whenGetUserProfile_withActiveChild_thenReturnsProfileWithChildId() {
        // Arrange
        UUID activeChildId = UUID.randomUUID();
        testUser.setActiveChildId(activeChildId);
        when(userRepository.findById(testUserId)).thenReturn(Optional.of(testUser));

        // Act
        UserProfileResponse response = userService.getUserProfile(testUserId);

        // Assert
        assertThat(response).isNotNull();
        assertThat(response.getActiveChildId()).isEqualTo(activeChildId);

        verify(userRepository).findById(testUserId);
    }

    @Test
    @DisplayName("Get user profile - Returns profile with wasted tickets count")
    void whenGetUserProfile_withWastedTickets_thenReturnsCount() {
        // Arrange
        testUser.setWastedTicketsCount(3);
        when(userRepository.findById(testUserId)).thenReturn(Optional.of(testUser));

        // Act
        UserProfileResponse response = userService.getUserProfile(testUserId);

        // Assert
        assertThat(response).isNotNull();
        assertThat(response.getWastedTicketsCount()).isEqualTo(3);

        verify(userRepository).findById(testUserId);
    }

    @Test
    @DisplayName("Get user profile - Returns seed user profile")
    void whenGetUserProfile_forSeedUser_thenReturnsProfileWithoutParent() {
        // Arrange
        when(userRepository.findById(seedUser.getId())).thenReturn(Optional.of(seedUser));

        // Act
        UserProfileResponse response = userService.getUserProfile(seedUser.getId());

        // Assert
        assertThat(response).isNotNull();
        assertThat(response.getUserId()).isEqualTo(seedUser.getId());
        assertThat(response.getChainKey()).isEqualTo("SEED00000001");
        assertThat(response.getPosition()).isEqualTo(0);
        assertThat(response.getParentId()).isNull();

        verify(userRepository).findById(seedUser.getId());
    }

    // ==================== getUserChain Tests ====================

    @Test
    @DisplayName("Get user chain - Success with multiple children")
    void whenGetUserChain_withMultipleChildren_thenReturnsAllChildren() {
        // Arrange
        User child1 = TestDataBuilder.user()
                .withId(UUID.randomUUID())
                .withUsername("child1")
                .withDisplayName("Child One")
                .withPosition(1)
                .withParentId(testUserId)
                .build();

        User child2 = TestDataBuilder.user()
                .withId(UUID.randomUUID())
                .withUsername("child2")
                .withDisplayName("Child Two")
                .withPosition(2)
                .withParentId(testUserId)
                .build();

        Invitation invitation1 = createInvitation(testUserId, child1.getId());
        Invitation invitation2 = createInvitation(testUserId, child2.getId());

        when(invitationRepository.findAllByParentId(testUserId))
                .thenReturn(Arrays.asList(invitation1, invitation2));
        when(userRepository.findById(child1.getId())).thenReturn(Optional.of(child1));
        when(userRepository.findById(child2.getId())).thenReturn(Optional.of(child2));

        // Act
        List<UserChainResponse> chain = userService.getUserChain(testUserId);

        // Assert
        assertThat(chain).isNotNull();
        assertThat(chain).hasSize(2);

        assertThat(chain.get(0).getUserId()).isEqualTo(child1.getId());
        assertThat(chain.get(0).getDisplayName()).isEqualTo("Child One");
        assertThat(chain.get(0).getPosition()).isEqualTo(1);

        assertThat(chain.get(1).getUserId()).isEqualTo(child2.getId());
        assertThat(chain.get(1).getDisplayName()).isEqualTo("Child Two");
        assertThat(chain.get(1).getPosition()).isEqualTo(2);

        verify(invitationRepository).findAllByParentId(testUserId);
        verify(userRepository, times(2)).findById(any(UUID.class));
    }

    @Test
    @DisplayName("Get user chain - Returns empty list when no children")
    void whenGetUserChain_withNoChildren_thenReturnsEmptyList() {
        // Arrange
        when(invitationRepository.findAllByParentId(testUserId))
                .thenReturn(Collections.emptyList());

        // Act
        List<UserChainResponse> chain = userService.getUserChain(testUserId);

        // Assert
        assertThat(chain).isNotNull();
        assertThat(chain).isEmpty();

        verify(invitationRepository).findAllByParentId(testUserId);
        verify(userRepository, never()).findById(any());
    }

    @Test
    @DisplayName("Get user chain - Filters out children with missing user records")
    void whenGetUserChain_withMissingChildUser_thenFiltersOutMissing() {
        // Arrange
        UUID validChildId = UUID.randomUUID();
        UUID missingChildId = UUID.randomUUID();

        User validChild = TestDataBuilder.user()
                .withId(validChildId)
                .withDisplayName("Valid Child")
                .build();

        Invitation validInvitation = createInvitation(testUserId, validChildId);
        Invitation invalidInvitation = createInvitation(testUserId, missingChildId);

        when(invitationRepository.findAllByParentId(testUserId))
                .thenReturn(Arrays.asList(validInvitation, invalidInvitation));
        when(userRepository.findById(validChildId)).thenReturn(Optional.of(validChild));
        when(userRepository.findById(missingChildId)).thenReturn(Optional.empty());

        // Act
        List<UserChainResponse> chain = userService.getUserChain(testUserId);

        // Assert
        assertThat(chain).isNotNull();
        assertThat(chain).hasSize(1);
        assertThat(chain.get(0).getUserId()).isEqualTo(validChildId);

        verify(invitationRepository).findAllByParentId(testUserId);
        verify(userRepository).findById(validChildId);
        verify(userRepository).findById(missingChildId);
    }

    @Test
    @DisplayName("Get user chain - Includes invitation status")
    void whenGetUserChain_thenIncludesInvitationStatus() {
        // Arrange
        User child = TestDataBuilder.user()
                .withId(UUID.randomUUID())
                .withDisplayName("Test Child")
                .build();

        Invitation invitation = createInvitation(testUserId, child.getId());
        invitation.setStatus(Invitation.InvitationStatus.ACTIVE);

        when(invitationRepository.findAllByParentId(testUserId))
                .thenReturn(Collections.singletonList(invitation));
        when(userRepository.findById(child.getId())).thenReturn(Optional.of(child));

        // Act
        List<UserChainResponse> chain = userService.getUserChain(testUserId);

        // Assert
        assertThat(chain).isNotNull();
        assertThat(chain).hasSize(1);
        assertThat(chain.get(0).getInvitationStatus()).isEqualTo("ACTIVE");
    }

    @Test
    @DisplayName("Get user chain - Includes joined at timestamp")
    void whenGetUserChain_thenIncludesJoinedAt() {
        // Arrange
        User child = TestDataBuilder.user()
                .withId(UUID.randomUUID())
                .build();

        Instant joinedAt = Instant.now().minusSeconds(3600);
        Invitation invitation = createInvitation(testUserId, child.getId());
        invitation.setAcceptedAt(joinedAt);

        when(invitationRepository.findAllByParentId(testUserId))
                .thenReturn(Collections.singletonList(invitation));
        when(userRepository.findById(child.getId())).thenReturn(Optional.of(child));

        // Act
        List<UserChainResponse> chain = userService.getUserChain(testUserId);

        // Assert
        assertThat(chain).isNotNull();
        assertThat(chain).hasSize(1);
        assertThat(chain.get(0).getJoinedAt()).isEqualTo(joinedAt);
    }

    @Test
    @DisplayName("Get user chain - Returns correct chain keys")
    void whenGetUserChain_thenIncludesChainKeys() {
        // Arrange
        User child = TestDataBuilder.user()
                .withId(UUID.randomUUID())
                .withChainKey("CHAIN12345678")
                .build();

        Invitation invitation = createInvitation(testUserId, child.getId());

        when(invitationRepository.findAllByParentId(testUserId))
                .thenReturn(Collections.singletonList(invitation));
        when(userRepository.findById(child.getId())).thenReturn(Optional.of(child));

        // Act
        List<UserChainResponse> chain = userService.getUserChain(testUserId);

        // Assert
        assertThat(chain).isNotNull();
        assertThat(chain).hasSize(1);
        assertThat(chain.get(0).getChainKey()).isEqualTo("CHAIN12345678");
    }

    @Test
    @DisplayName("Get user chain - Handles large number of children")
    void whenGetUserChain_withManyChildren_thenReturnsAll() {
        // Arrange
        int childCount = 10;
        List<Invitation> invitations = new java.util.ArrayList<>();

        for (int i = 0; i < childCount; i++) {
            UUID childId = UUID.randomUUID();
            User child = TestDataBuilder.user()
                    .withId(childId)
                    .withDisplayName("Child " + i)
                    .withPosition(i + 1)
                    .build();

            Invitation invitation = createInvitation(testUserId, childId);
            invitations.add(invitation);

            when(userRepository.findById(childId)).thenReturn(Optional.of(child));
        }

        when(invitationRepository.findAllByParentId(testUserId))
                .thenReturn(invitations);

        // Act
        List<UserChainResponse> chain = userService.getUserChain(testUserId);

        // Assert
        assertThat(chain).isNotNull();
        assertThat(chain).hasSize(childCount);

        verify(invitationRepository).findAllByParentId(testUserId);
        verify(userRepository, times(childCount)).findById(any(UUID.class));
    }

    @Test
    @DisplayName("Get user chain - Returns empty for seed user with no children")
    void whenGetUserChain_forSeedUserWithNoChildren_thenReturnsEmpty() {
        // Arrange
        when(invitationRepository.findAllByParentId(seedUser.getId()))
                .thenReturn(Collections.emptyList());

        // Act
        List<UserChainResponse> chain = userService.getUserChain(seedUser.getId());

        // Assert
        assertThat(chain).isNotNull();
        assertThat(chain).isEmpty();
    }

    @Test
    @DisplayName("Get user chain - Preserves order of invitations")
    void whenGetUserChain_thenPreservesInvitationOrder() {
        // Arrange
        User child1 = TestDataBuilder.user()
                .withId(UUID.randomUUID())
                .withDisplayName("First Child")
                .build();

        User child2 = TestDataBuilder.user()
                .withId(UUID.randomUUID())
                .withDisplayName("Second Child")
                .build();

        User child3 = TestDataBuilder.user()
                .withId(UUID.randomUUID())
                .withDisplayName("Third Child")
                .build();

        Invitation inv1 = createInvitation(testUserId, child1.getId());
        Invitation inv2 = createInvitation(testUserId, child2.getId());
        Invitation inv3 = createInvitation(testUserId, child3.getId());

        when(invitationRepository.findAllByParentId(testUserId))
                .thenReturn(Arrays.asList(inv1, inv2, inv3));
        when(userRepository.findById(child1.getId())).thenReturn(Optional.of(child1));
        when(userRepository.findById(child2.getId())).thenReturn(Optional.of(child2));
        when(userRepository.findById(child3.getId())).thenReturn(Optional.of(child3));

        // Act
        List<UserChainResponse> chain = userService.getUserChain(testUserId);

        // Assert
        assertThat(chain).isNotNull();
        assertThat(chain).hasSize(3);
        assertThat(chain.get(0).getDisplayName()).isEqualTo("First Child");
        assertThat(chain.get(1).getDisplayName()).isEqualTo("Second Child");
        assertThat(chain.get(2).getDisplayName()).isEqualTo("Third Child");
    }

    // ==================== Helper Methods ====================

    private Invitation createInvitation(UUID parentId, UUID childId) {
        return Invitation.builder()
                .id(UUID.randomUUID())
                .parentId(parentId)
                .childId(childId)
                .status(Invitation.InvitationStatus.ACTIVE)
                .acceptedAt(Instant.now())
                .build();
    }
}
