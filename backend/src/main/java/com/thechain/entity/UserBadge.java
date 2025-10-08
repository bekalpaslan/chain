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
 * UserBadge entity - tracks badges earned by users
 */
@Entity
@Table(name = "user_badges",
    uniqueConstraints = {
        @UniqueConstraint(columnNames = {"userPosition", "badgeType"})
    },
    indexes = {
        @Index(name = "idx_user_badges_user_pos", columnList = "userPosition"),
        @Index(name = "idx_user_badges_badge_type", columnList = "badgeType"),
        @Index(name = "idx_user_badges_earned_at", columnList = "earnedAt")
    })
@EntityListeners(AuditingEntityListener.class)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserBadge {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, name = "user_position")
    private Integer userPosition;

    @Column(nullable = false, length = 50, name = "badge_type")
    private String badgeType;

    @CreatedDate
    @Column(nullable = false, updatable = false, name = "earned_at")
    private Instant earnedAt;

    // Context data (e.g., removed positions, collapse depth)
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private Map<String, Object> context;
}
