package com.thechain.repository;

import com.thechain.entity.Ticket;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TicketRepository extends JpaRepository<Ticket, UUID> {

    Optional<Ticket> findByOwnerIdAndStatus(UUID ownerId, Ticket.TicketStatus status);

    Optional<Ticket> findByTicketCode(String ticketCode);

    List<Ticket> findByStatusAndExpiresAtBefore(Ticket.TicketStatus status, Instant expiresAt);

    List<Ticket> findAllByOwnerId(UUID ownerId);

    long countByStatus(Ticket.TicketStatus status);

    boolean existsByOwnerIdAndStatus(UUID ownerId, Ticket.TicketStatus status);

    @Query("SELECT t FROM Ticket t WHERE t.ownerId = :ownerId ORDER BY t.issuedAt DESC")
    List<Ticket> findTicketHistoryByOwnerId(@Param("ownerId") UUID ownerId);
}
