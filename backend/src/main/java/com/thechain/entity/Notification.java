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
 * Notification entity - stores notifications for users
 */
@Entity
@Table(name = "notifications", indexes = {
    @Index(name = "idx_notifications_user_id", columnList = "userId"),
    @Index(name = "idx_notifications_type", columnList = "notificationType"),
    @Index(name = "idx_notifications_created_at", columnList = "createdAt"),
    @Index(name = "idx_notifications_read_at", columnList = "readAt"),
    @Index(name = "idx_notifications_priority", columnList = "priority")
})
@EntityListeners(AuditingEntityListener.class)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, name = "user_id")
    private UUID userId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50, name = "notification_type")
    private NotificationType notificationType;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String body;

    // Channels
    @Builder.Default
    @Column(name = "sent_via_push")
    private Boolean sentViaPush = false;

    @Builder.Default
    @Column(name = "sent_via_email")
    private Boolean sentViaEmail = false;

    // Action
    @Column(length = 500, name = "action_url")
    private String actionUrl;

    // Status
    @CreatedDate
    @Column(nullable = false, updatable = false, name = "created_at")
    private Instant createdAt;

    @Column(name = "sent_at")
    private Instant sentAt;

    @Column(name = "read_at")
    private Instant readAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private Priority priority = Priority.NORMAL;

    // Additional data
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private Map<String, Object> metadata;

    public enum NotificationType {
        BECAME_TIP,
        TICKET_EXPIRING_12H,
        TICKET_EXPIRING_1H,
        TICKET_EXPIRED,
        INVITEE_JOINED,
        INVITEE_FAILED,
        REMOVED,
        BADGE_EARNED,
        RULE_CHANGE_ANNOUNCED,
        RULE_CHANGE_REMINDER,
        RULE_CHANGE_APPLIED,
        MILESTONE_REACHED,
        DAILY_SUMMARY
    }

    public enum Priority {
        CRITICAL,
        IMPORTANT,
        NORMAL,
        LOW
    }

    public boolean isRead() {
        return readAt != null;
    }
}
