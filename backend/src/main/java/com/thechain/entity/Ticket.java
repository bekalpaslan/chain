package com.thechain.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "tickets", indexes = {
    @Index(name = "idx_tickets_owner_id", columnList = "ownerId"),
    @Index(name = "idx_tickets_status", columnList = "status"),
    @Index(name = "idx_tickets_expires_at", columnList = "expiresAt"),
    @Index(name = "idx_tickets_ticket_code", columnList = "ticketCode"),
    @Index(name = "idx_tickets_attempt_number", columnList = "attemptNumber")
})
@EntityListeners(AuditingEntityListener.class)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Ticket {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, name = "owner_id")
    private UUID ownerId;

    @Column(name = "ticket_code", length = 50)
    private String ticketCode;

    @Column(name = "next_position")
    private Integer nextPosition;

    @Column(name = "attempt_number")
    @Builder.Default
    private Integer attemptNumber = 1;

    @Column(name = "rule_version")
    @Builder.Default
    private Integer ruleVersion = 1;

    @Column(name = "duration_hours")
    @Builder.Default
    private Integer durationHours = 24;

    @Column(name = "qr_code_url", length = 500)
    private String qrCodeUrl;

    @CreatedDate
    @Column(nullable = false, updatable = false, name = "issued_at")
    private Instant issuedAt;

    @Column(nullable = false)
    private Instant expiresAt;

    @Column(name = "used_at")
    private Instant usedAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private TicketStatus status = TicketStatus.ACTIVE;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String signature;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String payload;

    @Column(name = "claimed_by")
    private UUID claimedBy;

    @Column
    private Instant claimedAt;

    @Column(length = 100)
    private String message;

    public enum TicketStatus {
        ACTIVE,
        USED,
        EXPIRED,
        CANCELLED
    }
}
