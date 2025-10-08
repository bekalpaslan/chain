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
@Table(name = "attachments", indexes = {
    @Index(name = "idx_attachments_parent_id", columnList = "parentId"),
    @Index(name = "idx_attachments_child_id", columnList = "childId"),
    @Index(name = "idx_attachments_ticket_id", columnList = "ticketId")
}, uniqueConstraints = {
    @UniqueConstraint(columnNames = {"parentId", "childId"}),
    @UniqueConstraint(columnNames = "childId")
})
@EntityListeners(AuditingEntityListener.class)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Attachment {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, name = "parent_id")
    private UUID parentId;

    @Column(nullable = false, name = "child_id")
    private UUID childId;

    @Column(nullable = false, name = "ticket_id")
    private UUID ticketId;

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private Instant attachedAt;
}
