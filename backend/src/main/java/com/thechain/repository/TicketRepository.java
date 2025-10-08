package com.thechain.repository;

import com.thechain.entity.Ticket;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TicketRepository extends JpaRepository<Ticket, UUID> {

    Optional<Ticket> findByOwnerIdAndStatus(UUID ownerId, Ticket.TicketStatus status);

    List<Ticket> findByStatusAndExpiresAtBefore(Ticket.TicketStatus status, Instant expiresAt);

    long countByStatus(Ticket.TicketStatus status);
}
