package com.thechain.repository;

import com.thechain.entity.Badge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface BadgeRepository extends JpaRepository<Badge, UUID> {

    Optional<Badge> findByBadgeType(String badgeType);

    boolean existsByBadgeType(String badgeType);
}
