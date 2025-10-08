package com.thechain.repository;

import com.thechain.entity.ChainRule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ChainRuleRepository extends JpaRepository<ChainRule, UUID> {

    Optional<ChainRule> findByVersion(Integer version);

    @Query("SELECT cr FROM ChainRule cr WHERE cr.appliedAt IS NOT NULL AND cr.effectiveFrom <= :now ORDER BY cr.version DESC LIMIT 1")
    Optional<ChainRule> findCurrentActiveRule(Instant now);

    @Query("SELECT cr FROM ChainRule cr WHERE cr.appliedAt IS NULL AND cr.effectiveFrom > :now ORDER BY cr.effectiveFrom ASC")
    List<ChainRule> findUpcomingRules(Instant now);

    @Query("SELECT MAX(cr.version) FROM ChainRule cr")
    Optional<Integer> findMaxVersion();

    List<ChainRule> findAllByOrderByVersionDesc();

    @Query("SELECT cr FROM ChainRule cr WHERE cr.deploymentMode = 'SCHEDULED' AND cr.appliedAt IS NULL AND cr.effectiveFrom <= :now")
    List<ChainRule> findScheduledRulesDueForApplication(Instant now);
}
