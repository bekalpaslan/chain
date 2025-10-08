package com.thechain.repository;

import com.thechain.entity.UserBadge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface UserBadgeRepository extends JpaRepository<UserBadge, UUID> {

    List<UserBadge> findAllByUserPosition(Integer userPosition);

    boolean existsByUserPositionAndBadgeType(Integer userPosition, String badgeType);

    @Query("SELECT ub FROM UserBadge ub WHERE ub.userPosition = :position ORDER BY ub.earnedAt DESC")
    List<UserBadge> findBadgesByPosition(@Param("position") Integer position);

    @Query("SELECT COUNT(ub) FROM UserBadge ub WHERE ub.badgeType = :badgeType")
    long countByBadgeType(@Param("badgeType") String badgeType);
}
