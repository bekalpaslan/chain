package com.thechain.scheduler;

import com.thechain.entity.Ticket;
import com.thechain.repository.TicketRepository;
import com.thechain.service.ChainService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.List;

/**
 * TicketExpirationScheduler
 * Background job that checks for expired tickets and processes them
 * Implements the 3-strike removal rule (FR-3.3)
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class TicketExpirationScheduler {

    private final TicketRepository ticketRepository;
    private final ChainService chainService;

    /**
     * Check for expired tickets every minute
     * Processes tickets that have passed their expiration time
     */
    @Scheduled(fixedRate = 60000) // Every 60 seconds
    public void processExpiredTickets() {
        log.debug("Running ticket expiration check...");

        try {
            Instant now = Instant.now();

            // Find all active tickets that have expired
            List<Ticket> expiredTickets = ticketRepository
                .findByStatusAndExpiresAtBefore(Ticket.TicketStatus.ACTIVE, now);

            if (expiredTickets.isEmpty()) {
                log.debug("No expired tickets found");
                return;
            }

            log.info("Found {} expired tickets to process", expiredTickets.size());

            // Process each expired ticket
            for (Ticket ticket : expiredTickets) {
                try {
                    log.info("Processing expired ticket: {} (owner: {}, attempt: {}/{})",
                        ticket.getId(),
                        ticket.getOwnerId(),
                        ticket.getAttemptNumber(),
                        chainService.getMaxAttempts());

                    chainService.handleTicketExpiration(ticket.getId());

                } catch (Exception e) {
                    log.error("Error processing expired ticket {}: {}",
                        ticket.getId(), e.getMessage(), e);
                }
            }

            log.info("Finished processing {} expired tickets", expiredTickets.size());

        } catch (Exception e) {
            log.error("Error in ticket expiration scheduler: {}", e.getMessage(), e);
        }
    }

    /**
     * Check for tickets expiring soon and send warnings
     * Runs every 15 minutes
     */
    @Scheduled(fixedRate = 900000) // Every 15 minutes
    public void sendExpirationWarnings() {
        log.debug("Running expiration warning check...");

        try {
            Instant now = Instant.now();
            Instant oneHourFromNow = now.plusSeconds(3600);
            Instant twelveHoursFromNow = now.plusSeconds(43200);

            // Find tickets expiring within 1 hour
            List<Ticket> soonExpiring = ticketRepository.findAll().stream()
                .filter(t -> t.getStatus() == Ticket.TicketStatus.ACTIVE)
                .filter(t -> t.getExpiresAt().isAfter(now))
                .filter(t -> t.getExpiresAt().isBefore(oneHourFromNow))
                .toList();

            log.debug("Found {} tickets expiring within 1 hour", soonExpiring.size());

            // TODO: Send notifications via NotificationService
            // For each ticket, send push/email notification to owner

            // Find tickets expiring within 12 hours
            List<Ticket> expiringIn12Hours = ticketRepository.findAll().stream()
                .filter(t -> t.getStatus() == Ticket.TicketStatus.ACTIVE)
                .filter(t -> t.getExpiresAt().isAfter(oneHourFromNow))
                .filter(t -> t.getExpiresAt().isBefore(twelveHoursFromNow))
                .toList();

            log.debug("Found {} tickets expiring within 12 hours", expiringIn12Hours.size());

            // TODO: Send notifications via NotificationService

        } catch (Exception e) {
            log.error("Error in expiration warning scheduler: {}", e.getMessage(), e);
        }
    }

    /**
     * Clean up old expired tickets (after 90 days)
     * Runs daily at 3 AM
     */
    @Scheduled(cron = "0 0 3 * * *") // Daily at 3 AM
    public void cleanupOldTickets() {
        log.info("Running ticket cleanup job...");

        try {
            Instant ninetyDaysAgo = Instant.now().minusSeconds(90 * 24 * 3600L);

            List<Ticket> oldTickets = ticketRepository.findAll().stream()
                .filter(t -> t.getStatus() == Ticket.TicketStatus.EXPIRED ||
                            t.getStatus() == Ticket.TicketStatus.CANCELLED)
                .filter(t -> t.getExpiresAt().isBefore(ninetyDaysAgo))
                .toList();

            if (!oldTickets.isEmpty()) {
                log.info("Deleting {} old tickets from database", oldTickets.size());
                ticketRepository.deleteAll(oldTickets);
            } else {
                log.debug("No old tickets to clean up");
            }

        } catch (Exception e) {
            log.error("Error in ticket cleanup scheduler: {}", e.getMessage(), e);
        }
    }
}
