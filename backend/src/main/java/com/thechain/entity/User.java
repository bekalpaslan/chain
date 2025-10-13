package com.thechain.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.Instant;
import java.util.UUID;
import java.util.List;

@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_users_chain_key", columnList = "chainKey"),
    @Index(name = "idx_users_parent_id", columnList = "parentId"),
    @Index(name = "idx_users_position", columnList = "position"),
    @Index(name = "idx_users_username", columnList = "username")
})
@EntityListeners(AuditingEntityListener.class)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true, length = 32)
    private String chainKey;

    @Column(nullable = false, length = 50)
    private String displayName;

    @Column(nullable = false, unique = true)
    private Integer position;

    @Column(name = "parent_id")
    private UUID parentId;

    // Note: activeChildId is managed in application code, not stored in DB
    // It's computed from the attachments table relationship
    @Transient
    private UUID activeChildId;

    // Note: wastedChildIds are managed in application code, not stored in DB
    // They're tracked through attachment history
    @Transient
    private List<UUID> wastedChildIds;

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @LastModifiedDate
    @Column(nullable = false)
    private Instant updatedAt;

    @Column
    private Instant deletedAt;

    // Authentication fields - username/password required
    @Column(nullable = false, unique = true, length = 50)
    private String username;

    @Column(nullable = false, length = 255)
    private String passwordHash;

    @Column(length = 255)
    private String email;

    @Builder.Default
    @Column
    private Boolean emailVerified = false;

    // Social auth fields
    @Column(length = 255)
    private String appleUserId;

    @Column(length = 255)
    private String googleUserId;

    // Country of origin (ISO 3166-1 alpha-2 country code, e.g., "US", "GB", "DE")
    @Column(length = 2, name = "belongs_to")
    private String associatedWith;

    // Status tracking
    @Builder.Default
    @Column(length = 20)
    private String status = "active";

    // TO-CLAUDE: Removal reason can be ENUM, with only value "WASTED" for now.
    @Column(length = 50)
    private String removalReason;

    @Column
    private Instant removedAt;

    @Builder.Default
    @Column
    private Integer wastedTicketsCount = 0;

    @Builder.Default
    @Column
    private Integer totalTicketsGenerated = 0;

    // Admin role
    @Builder.Default
    @Column(name = "is_admin")
    private Boolean isAdmin = false;

    @PrePersist
    public void prePersist() {
        if (chainKey == null) {
            chainKey = generateChainKey();
        }
    }

    private String generateChainKey() {
        return UUID.randomUUID().toString()
            .replace("-", "")
            .substring(0, 12)
            .toUpperCase();
    }
}
