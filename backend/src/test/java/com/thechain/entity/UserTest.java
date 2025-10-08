package com.thechain.entity;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.TestPropertySource;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@TestPropertySource(properties = {
    "spring.sql.init.mode=never",
    "spring.jpa.hibernate.ddl-auto=create-drop"
})
class UserTest {

    @Autowired
    private TestEntityManager entityManager;

    private User user;

    @BeforeEach
    void setUp() {
        user = User.builder()
                .displayName("Test User")
                .position(1)
                .deviceId("device-123")
                .deviceFingerprint("fingerprint-123")
                .shareLocation(false)
                .build();
    }

    @Test
    void createUser_WithRequiredFields_Success() {
        // When
        User savedUser = entityManager.persistAndFlush(user);

        // Then
        assertThat(savedUser.getId()).isNotNull();
        assertThat(savedUser.getDisplayName()).isEqualTo("Test User");
        assertThat(savedUser.getPosition()).isEqualTo(1);
        assertThat(savedUser.getDeviceId()).isEqualTo("device-123");
        assertThat(savedUser.getDeviceFingerprint()).isEqualTo("fingerprint-123");
        assertThat(savedUser.getShareLocation()).isFalse();
    }

    @Test
    void createUser_AutoGeneratesChainKey() {
        // When
        User savedUser = entityManager.persistAndFlush(user);

        // Then
        assertThat(savedUser.getChainKey()).isNotNull();
        assertThat(savedUser.getChainKey()).hasSize(12);
        assertThat(savedUser.getChainKey()).matches("[A-Z0-9]{12}");
    }

    @Test
    void createUser_WithChainKey_UsesProvidedKey() {
        // Given
        user.setChainKey("CUSTOM123456");

        // When
        User savedUser = entityManager.persistAndFlush(user);

        // Then
        assertThat(savedUser.getChainKey()).isEqualTo("CUSTOM123456");
    }

    @Test
    void createUser_SetsAuditingTimestamps() {
        // When
        User savedUser = entityManager.persistAndFlush(user);

        // Then
        assertThat(savedUser.getCreatedAt()).isNotNull();
        assertThat(savedUser.getUpdatedAt()).isNotNull();
        assertThat(savedUser.getCreatedAt()).isBeforeOrEqualTo(Instant.now());
        assertThat(savedUser.getUpdatedAt()).isBeforeOrEqualTo(Instant.now());
    }

    @Test
    void updateUser_UpdatesModifiedDate() throws InterruptedException {
        // Given
        User savedUser = entityManager.persistAndFlush(user);
        Instant originalUpdatedAt = savedUser.getUpdatedAt();

        // Wait a moment to ensure timestamp difference
        Thread.sleep(10);

        // When
        savedUser.setDisplayName("Updated Name");
        User updatedUser = entityManager.persistAndFlush(savedUser);

        // Then
        assertThat(updatedUser.getUpdatedAt()).isAfter(originalUpdatedAt);
        assertThat(updatedUser.getCreatedAt()).isEqualTo(savedUser.getCreatedAt());
    }

    @Test
    void createUser_WithLocation_Success() {
        // Given
        user.setShareLocation(true);
        user.setLocationLat(new BigDecimal("40.712800"));
        user.setLocationLon(new BigDecimal("-74.006000"));
        user.setLocationCountry("US");
        user.setLocationCity("New York");

        // When
        User savedUser = entityManager.persistAndFlush(user);

        // Then
        assertThat(savedUser.getShareLocation()).isTrue();
        assertThat(savedUser.getLocationLat()).isEqualByComparingTo(new BigDecimal("40.712800"));
        assertThat(savedUser.getLocationLon()).isEqualByComparingTo(new BigDecimal("-74.006000"));
        assertThat(savedUser.getLocationCountry()).isEqualTo("US");
        assertThat(savedUser.getLocationCity()).isEqualTo("New York");
    }

    @Test
    void createUser_WithParentAndChild_Success() {
        // Given
        UUID parentId = UUID.randomUUID();
        UUID childId = UUID.randomUUID();
        user.setParentId(parentId);
        user.setChildId(childId);

        // When
        User savedUser = entityManager.persistAndFlush(user);

        // Then
        assertThat(savedUser.getParentId()).isEqualTo(parentId);
        assertThat(savedUser.getChildId()).isEqualTo(childId);
    }

    @Test
    void createUser_WithDeletedAt_Success() {
        // Given
        Instant deletedTime = Instant.now();
        user.setDeletedAt(deletedTime);

        // When
        User savedUser = entityManager.persistAndFlush(user);

        // Then
        assertThat(savedUser.getDeletedAt()).isNotNull();
        assertThat(savedUser.getDeletedAt()).isEqualTo(deletedTime);
    }

    @Test
    void findUser_ById_Success() {
        // Given
        User savedUser = entityManager.persistAndFlush(user);
        entityManager.clear();

        // When
        User foundUser = entityManager.find(User.class, savedUser.getId());

        // Then
        assertThat(foundUser).isNotNull();
        assertThat(foundUser.getId()).isEqualTo(savedUser.getId());
        assertThat(foundUser.getDisplayName()).isEqualTo("Test User");
    }

    @Test
    void createUser_ChainKeyIsUnique() {
        // Given
        User user1 = User.builder()
                .chainKey("UNIQUE123456")
                .displayName("User 1")
                .position(1)
                .deviceId("device-1")
                .deviceFingerprint("fingerprint-1")
                .build();

        User user2 = User.builder()
                .chainKey("UNIQUE123456") // Same chain key
                .displayName("User 2")
                .position(2)
                .deviceId("device-2")
                .deviceFingerprint("fingerprint-2")
                .build();

        // When
        entityManager.persistAndFlush(user1);

        // Then - attempting to save second user with same chain key should fail
        try {
            entityManager.persistAndFlush(user2);
            assertThat(false).as("Should have thrown exception for duplicate chain key").isTrue();
        } catch (Exception e) {
            assertThat(e).isNotNull();
        }
    }

    @Test
    void createUser_PositionIsUnique() {
        // Given
        User user1 = User.builder()
                .displayName("User 1")
                .position(1)
                .deviceId("device-1")
                .deviceFingerprint("fingerprint-1")
                .build();

        User user2 = User.builder()
                .displayName("User 2")
                .position(1) // Same position
                .deviceId("device-2")
                .deviceFingerprint("fingerprint-2")
                .build();

        // When
        entityManager.persistAndFlush(user1);

        // Then - attempting to save second user with same position should fail
        try {
            entityManager.persistAndFlush(user2);
            assertThat(false).as("Should have thrown exception for duplicate position").isTrue();
        } catch (Exception e) {
            assertThat(e).isNotNull();
        }
    }

    @Test
    void userBuilder_CreatesUserWithDefaultValues() {
        // When
        User newUser = User.builder()
                .displayName("Builder User")
                .position(10)
                .deviceId("device-builder")
                .deviceFingerprint("fingerprint-builder")
                .build();

        // Then
        assertThat(newUser.getShareLocation()).isFalse();
        assertThat(newUser.getId()).isNull(); // Not persisted yet
        assertThat(newUser.getCreatedAt()).isNull(); // Not persisted yet
    }

    @Test
    void userEntity_SupportsLongDisplayNames() {
        // Given
        String longName = "A".repeat(50); // Max length is 50
        user.setDisplayName(longName);

        // When
        User savedUser = entityManager.persistAndFlush(user);

        // Then
        assertThat(savedUser.getDisplayName()).hasSize(50);
        assertThat(savedUser.getDisplayName()).isEqualTo(longName);
    }

    @Test
    void userEntity_LocationCountryIsTwoCharacters() {
        // Given
        user.setLocationCountry("CA");

        // When
        User savedUser = entityManager.persistAndFlush(user);

        // Then
        assertThat(savedUser.getLocationCountry()).isEqualTo("CA");
        assertThat(savedUser.getLocationCountry()).hasSize(2);
    }

    @Test
    void userEntity_SupportsNullParentAndChild() {
        // Given - user with no parent or child (root user)
        user.setParentId(null);
        user.setChildId(null);

        // When
        User savedUser = entityManager.persistAndFlush(user);

        // Then
        assertThat(savedUser.getParentId()).isNull();
        assertThat(savedUser.getChildId()).isNull();
    }

    @Test
    void userEntity_SupportsLocationWithoutCity() {
        // Given
        user.setShareLocation(true);
        user.setLocationLat(new BigDecimal("51.507400"));
        user.setLocationLon(new BigDecimal("-0.127800"));
        user.setLocationCountry("GB");
        user.setLocationCity(null);

        // When
        User savedUser = entityManager.persistAndFlush(user);

        // Then
        assertThat(savedUser.getLocationLat()).isNotNull();
        assertThat(savedUser.getLocationLon()).isNotNull();
        assertThat(savedUser.getLocationCountry()).isEqualTo("GB");
        assertThat(savedUser.getLocationCity()).isNull();
    }

    @Test
    void userEntity_ChainKeyGenerationIsUpperCase() {
        // When
        User savedUser = entityManager.persistAndFlush(user);

        // Then
        assertThat(savedUser.getChainKey()).isUpperCase();
    }

    @Test
    void userEntity_ChainKeyDoesNotContainHyphens() {
        // When
        User savedUser = entityManager.persistAndFlush(user);

        // Then
        assertThat(savedUser.getChainKey()).doesNotContain("-");
    }
}
