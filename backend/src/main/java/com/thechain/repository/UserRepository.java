package com.thechain.repository;

import com.thechain.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {

    Optional<User> findByChainKey(String chainKey);

    Optional<User> findByDeviceId(String deviceId);

    Optional<User> findByPosition(Integer position);

    Optional<User> findByEmail(String email);

    Optional<User> findByAppleUserId(String appleUserId);

    Optional<User> findByGoogleUserId(String googleUserId);

    boolean existsByDeviceFingerprint(String deviceFingerprint);

    boolean existsByEmail(String email);

    boolean existsByDisplayNameIgnoreCase(String displayName);

    @Query("SELECT MAX(u.position) FROM User u")
    Integer findMaxPosition();

    long countByDeletedAtIsNull();

    long countByStatus(String status);

    @Query("SELECT COUNT(DISTINCT u.belongsTo) FROM User u WHERE u.belongsTo IS NOT NULL")
    long countDistinctCountries();

    @Query("SELECT u FROM User u WHERE u.status IN ('active', 'seed') ORDER BY u.position DESC LIMIT 1")
    Optional<User> findCurrentTip();
}
