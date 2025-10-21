package com.thechain.repository;

import com.thechain.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {

    Optional<User> findByChainKey(String chainKey);

    Optional<User> findByPosition(Integer position);

    Optional<User> findByUsername(String username);

    Optional<User> findByEmail(String email);

    Optional<User> findByAppleUserId(String appleUserId);

    Optional<User> findByGoogleUserId(String googleUserId);

    boolean existsByUsername(String username);

    boolean existsByEmail(String email);

    boolean existsByDisplayNameIgnoreCase(String displayName);

    @Query("SELECT MAX(u.position) FROM User u")
    Integer findMaxPosition();

    long countByDeletedAtIsNull();

    long countByStatus(String status);

    @Query("SELECT COUNT(DISTINCT u.associatedWith) FROM User u WHERE u.associatedWith IS NOT NULL")
    long countDistinctCountries();

    /**
     * OPTIMIZED: Find current tip without loading all users
     * The tip is the highest-position active/seed user who either:
     * 1. Has no active child attachment (hasn't invited anyone yet), OR
     * 2. Their child's invitation is not ACTIVE (child was removed/wasted)
     *
     * This replaces the inefficient findAll().stream() approach
     * Note: Since activeChildId is transient, we check the attachments table directly
     */
    @Query("""
        SELECT u FROM User u
        WHERE u.status IN ('active', 'seed')
        AND (
            NOT EXISTS (
                SELECT 1 FROM Attachment a
                WHERE a.parentId = u.id
            )
            OR NOT EXISTS (
                SELECT 1 FROM Attachment a
                JOIN Invitation i ON i.childId = a.childId
                WHERE a.parentId = u.id
                AND i.status = 'ACTIVE'
            )
        )
        ORDER BY u.position DESC
        LIMIT 1
        """)
    Optional<User> findCurrentTipOptimized();

    /**
     * @deprecated Use findCurrentTipOptimized() instead. This method loads all users into memory.
     */
    @Deprecated
    @Query("SELECT u FROM User u WHERE u.status IN ('active', 'seed') ORDER BY u.position DESC LIMIT 1")
    Optional<User> findCurrentTip();

    /**
     * Find the user with the highest position (current tip)
     */
    Optional<User> findTopByOrderByPositionDesc();

    /**
     * Count active children of a parent user
     */
    Integer countByParentIdAndStatus(UUID parentId, String status);

    /**
     * Find users within a position range for pagination
     */
    List<User> findByPositionBetweenOrderByPositionAsc(Integer startPosition, Integer endPosition);
}
