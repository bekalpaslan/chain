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
    @Index(name = "idx_tickets_expires_at", columnList = "expiresAt")
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

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private Instant issuedAt;

    @Column(nullable = false)
    private Instant expiresAt;

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
