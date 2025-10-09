package com.thechain.repository;

import com.thechain.entity.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.TestPropertySource;

import java.time.Instant;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest(excludeAutoConfiguration = {
        org.springframework.boot.autoconfigure.flyway.FlywayAutoConfiguration.class
})
@TestPropertySource(locations = "classpath:application-test.yml")
class UserRepositoryTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private UserRepository userRepository;

    private User testUser1;
    private User testUser2;
    private User testUser3;

    @BeforeEach
    void setUp() {
        // Create test users with different properties
        testUser1 = User.builder()
                .chainKey("TEST00000001")
                .displayName("Test User 1")
                .position(1)
                .username("testuser1")
                .passwordHash("$2a$10$hashedPassword1")
                .status("active")
                .createdAt(Instant.now())
                .build();

        testUser1 = entityManager.persistAndFlush(testUser1);

        testUser2 = User.builder()
                .chainKey("TEST00000002")
                .displayName("Test User 2")
                .position(2)
                .username("testuser2")
                .passwordHash("$2a$10$hashedPassword2")
                .status("active")
                .createdAt(Instant.now())
                .parentId(testUser1.getId())
                .associatedWith("US")
                .build();

        testUser2 = entityManager.persistAndFlush(testUser2);

        testUser3 = User.builder()
                .chainKey("TEST00000003")
                .displayName("Test User 3")
                .position(3)
                .username("testuser3")
                .appleUserId("apple-user-123")
                .googleUserId("google-user-456")
                .status("seed")
                .createdAt(Instant.now())
                .deletedAt(null)
                .associatedWith("CA")
                .build();

        testUser3 = entityManager.persistAndFlush(testUser3);
    }

    @Test
    void findByChainKey_Success() {
        // When
        Optional<User> found = userRepository.findByChainKey("TEST00000001");

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getDisplayName()).isEqualTo("Test User 1");
    }

    @Test
    void findByChainKey_NotFound() {
        // When
        Optional<User> found = userRepository.findByChainKey("NONEXISTENT");

        // Then
        assertThat(found).isEmpty();
    }


    @Test
    void findByPosition_Success() {
        // When
        Optional<User> found = userRepository.findByPosition(2);

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getChainKey()).isEqualTo("TEST00000002");
    }

    @Test
    void findByUsername_Success() {
        // When
        Optional<User> found = userRepository.findByUsername("testuser1");

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getChainKey()).isEqualTo("TEST00000001");
        assertThat(found.get().getPasswordHash()).isNotNull();
    }

    @Test
    void findByUsername_NotFound() {
        // When
        Optional<User> found = userRepository.findByUsername("nonexistent");

        // Then
        assertThat(found).isEmpty();
    }

    @Test
    void findByAppleUserId_Success() {
        // When
        Optional<User> found = userRepository.findByAppleUserId("apple-user-123");

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getChainKey()).isEqualTo("TEST00000003");
    }

    @Test
    void findByGoogleUserId_Success() {
        // When
        Optional<User> found = userRepository.findByGoogleUserId("google-user-456");

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getChainKey()).isEqualTo("TEST00000003");
    }


    @Test
    void existsByUsername_ExistsReturnsTrue() {
        // When
        boolean exists = userRepository.existsByUsername("testuser2");

        // Then
        assertThat(exists).isTrue();
    }

    @Test
    void existsByUsername_NotExistsReturnsFalse() {
        // When
        boolean exists = userRepository.existsByUsername("nonexistent");

        // Then
        assertThat(exists).isFalse();
    }

    @Test
    void existsByDisplayNameIgnoreCase_ExistsReturnsTrue() {
        // When
        boolean exists = userRepository.existsByDisplayNameIgnoreCase("test user 1");

        // Then
        assertThat(exists).isTrue();
    }

    @Test
    void existsByDisplayNameIgnoreCase_DifferentCaseReturnsTrue() {
        // When
        boolean exists = userRepository.existsByDisplayNameIgnoreCase("TEST USER 2");

        // Then
        assertThat(exists).isTrue();
    }

    @Test
    void findMaxPosition_ReturnsHighestPosition() {
        // When
        Integer maxPosition = userRepository.findMaxPosition();

        // Then
        assertThat(maxPosition).isEqualTo(3);
    }

    @Test
    void countByDeletedAtIsNull_ReturnsActiveUserCount() {
        // When
        long count = userRepository.countByDeletedAtIsNull();

        // Then
        assertThat(count).isEqualTo(3); // All 3 users are not deleted
    }

    @Test
    void countByStatus_Active_ReturnsCorrectCount() {
        // When
        long count = userRepository.countByStatus("active");

        // Then
        assertThat(count).isEqualTo(2); // testUser1 and testUser2
    }

    @Test
    void countByStatus_Seed_ReturnsCorrectCount() {
        // When
        long count = userRepository.countByStatus("seed");

        // Then
        assertThat(count).isEqualTo(1); // testUser3
    }

    @Test
    void countDistinctCountries_ReturnsCorrectCount() {
        // When
        long count = userRepository.countDistinctCountries();

        // Then
        assertThat(count).isEqualTo(2); // US and CA
    }

    @Test
    void findCurrentTip_ReturnsUserWithHighestPosition() {
        // When
        Optional<User> tip = userRepository.findCurrentTip();

        // Then
        assertThat(tip).isPresent();
        assertThat(tip.get().getPosition()).isEqualTo(3);
        assertThat(tip.get().getChainKey()).isEqualTo("TEST00000003");
    }

    @Test
    void findCurrentTip_OnlyConsidersActiveSeedStatus() {
        // Given - Create a deleted user with higher position
        User deletedUser = User.builder()
                .chainKey("TEST00000004")
                .displayName("Deleted User")
                .position(4)
                .status("removed")
                .createdAt(Instant.now())
                .deletedAt(Instant.now())
                .build();
        entityManager.persistAndFlush(deletedUser);

        // When
        Optional<User> tip = userRepository.findCurrentTip();

        // Then - Should still return position 3, not the deleted user
        assertThat(tip).isPresent();
        assertThat(tip.get().getPosition()).isEqualTo(3);
        assertThat(tip.get().getStatus()).isIn("active", "seed");
    }
}
