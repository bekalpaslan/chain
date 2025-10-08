package com.thechain.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_users_chain_key", columnList = "chainKey"),
    @Index(name = "idx_users_parent_id", columnList = "parentId"),
    @Index(name = "idx_users_position", columnList = "position"),
    @Index(name = "idx_users_device_id", columnList = "deviceId")
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

    @Column(name = "child_id")
    private UUID childId;

    @Column(nullable = false)
    private String deviceId;

    @Column(nullable = false)
    private String deviceFingerprint;

    @Column(nullable = false)
    @Builder.Default
    private Boolean shareLocation = false;

    @Column(precision = 9, scale = 6)
    private BigDecimal locationLat;

    @Column(precision = 9, scale = 6)
    private BigDecimal locationLon;

    @Column(length = 2)
    private String locationCountry;

    @Column(length = 100)
    private String locationCity;

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @LastModifiedDate
    @Column(nullable = false)
    private Instant updatedAt;

    @Column
    private Instant deletedAt;

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
