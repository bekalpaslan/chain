package com.thechain.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

/**
 * ChainRule entity - dynamic rule management for The Chain
 * Allows admins to change game rules over time
 */
@Entity
@Table(name = "chain_rules", indexes = {
    @Index(name = "idx_chain_rules_version", columnList = "version"),
    @Index(name = "idx_chain_rules_effective_from", columnList = "effectiveFrom"),
    @Index(name = "idx_chain_rules_applied_at", columnList = "appliedAt")
})
@EntityListeners(AuditingEntityListener.class)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChainRule {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true)
    private Integer version;

    // Core rule parameters
    @Column(nullable = false, name = "ticket_duration_hours")
    @Builder.Default
    private Integer ticketDurationHours = 24;

    @Column(nullable = false, name = "max_attempts")
    @Builder.Default
    private Integer maxAttempts = 3;

    @Column(nullable = false, name = "visibility_range")
    @Builder.Default
    private Integer visibilityRange = 1;

    @Column(nullable = false, name = "seed_unlimited_time")
    @Builder.Default
    private Boolean seedUnlimitedTime = true;

    @Column(nullable = false, name = "reactivation_timeout_hours")
    @Builder.Default
    private Integer reactivationTimeoutHours = 24;

    // Additional flexible rules
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "additional_rules", columnDefinition = "jsonb")
    private Map<String, Object> additionalRules;

    // Metadata
    @Column(name = "created_by")
    private UUID createdBy;

    @CreatedDate
    @Column(nullable = false, updatable = false, name = "created_at")
    private Instant createdAt;

    @Column(nullable = false, name = "effective_from")
    private Instant effectiveFrom;

    @Column(name = "applied_at")
    private Instant appliedAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20, name = "deployment_mode")
    @Builder.Default
    private DeploymentMode deploymentMode = DeploymentMode.SCHEDULED;

    @Column(name = "change_description", columnDefinition = "TEXT")
    private String changeDescription;

    public enum DeploymentMode {
        INSTANT,    // Applied immediately
        SCHEDULED   // Applied at specific time
    }

    public boolean isActive() {
        return appliedAt != null && effectiveFrom.isBefore(Instant.now());
    }
}
