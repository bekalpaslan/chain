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

    boolean existsByDeviceFingerprint(String deviceFingerprint);

    @Query("SELECT MAX(u.position) FROM User u")
    Integer findMaxPosition();

    long countByDeletedAtIsNull();
}
