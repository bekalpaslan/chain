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

/**
 * Invitation entity - tracks invitation relationships between users
 * Uses UUID references for parent-child relationships
 */
@Entity
@Table(name = "invitations", indexes = {
    @Index(name = "idx_invitations_parent_id", columnList = "parentId"),
    @Index(name = "idx_invitations_child_id", columnList = "childId"),
    @Index(name = "idx_invitations_ticket_id", columnList = "ticketId"),
    @Index(name = "idx_invitations_status", columnList = "status")
})
@EntityListeners(AuditingEntityListener.class)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Invitation {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, name = "parent_id")
    private UUID parentId;

    @Column(nullable = false, unique = true, name = "child_id")
    private UUID childId;

    @Column(nullable = false, name = "ticket_id")
    private UUID ticketId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private InvitationStatus status = InvitationStatus.ACTIVE;

    @CreatedDate
    @Column(nullable = false, updatable = false, name = "invited_at")
    private Instant invitedAt;

    @Column(name = "accepted_at")
    private Instant acceptedAt;

    public enum InvitationStatus {
        ACTIVE,      // Currently valid in the chain
        REMOVED,     // Invitee was removed from chain
        REVERTED     // Chain reverted past this point
    }
}
