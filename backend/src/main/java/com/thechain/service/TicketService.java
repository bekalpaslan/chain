package com.thechain.service;

import com.thechain.config.CacheConfig;
import com.thechain.dto.TicketResponse;
import com.thechain.entity.Invitation;
import com.thechain.entity.RemovalReason;
import com.thechain.entity.Ticket;
import com.thechain.entity.User;
import com.thechain.exception.BusinessException;
import com.thechain.repository.InvitationRepository;
import com.thechain.repository.TicketRepository;
import com.thechain.repository.UserRepository;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Base64;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class TicketService {

    private final TicketRepository ticketRepository;
    private final UserRepository userRepository;
    private final InvitationRepository invitationRepository;
    private final ChainService chainService;

    @Value("${jwt.secret}")
    private String secretKey;

    @Value("${ticket.expiration-hours}")
    private int expirationHours;

    /**
     * Get the active ticket for a user.
     * Returns 404 if user has no active ticket (successfully completed invitation).
     */
    public TicketResponse getActiveTicketForUser(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found"));

        // Check if user has already successfully invited someone
        if (user.getActiveChildId() != null) {
            throw new BusinessException("NO_ACTIVE_TICKET", "User has already successfully completed their invitation");
        }

        // Find active ticket
        Ticket ticket = ticketRepository.findByOwnerIdAndStatus(userId, Ticket.TicketStatus.ACTIVE)
                .orElseThrow(() -> new BusinessException("NO_ACTIVE_TICKET", "No active ticket found"));

        // Check if ticket has expired (update status if needed)
        if (ticket.getExpiresAt().isBefore(Instant.now()) && ticket.getStatus() == Ticket.TicketStatus.ACTIVE) {
            ticket.setStatus(Ticket.TicketStatus.EXPIRED);
            ticketRepository.save(ticket);
        }

        return buildTicketResponse(ticket);
    }

    /**
     * Calculate ticket expiration time based on user's strike count.
     * Implements halving rule: 24h → 12h → 6h
     */
    private Instant calculateExpirationTime(User owner) {
        int strikeCount = owner.getWastedTicketsCount();

        int hours = switch(strikeCount) {
            case 0 -> 24;  // First attempt: full 24 hours
            case 1 -> 12;  // Second attempt: half time
            case 2 -> 6;   // Final attempt: quarter time
            default -> {
                // Should never reach here - user should be removed at 3 strikes
                log.error("User {} has {} strikes (should be removed at 3!)",
                          owner.getChainKey(), strikeCount);
                yield 6;  // Fallback to minimum time
            }
        };

        Instant expiresAt = Instant.now().plusSeconds(hours * 3600L);

        log.info("Ticket for user {} (strike {}/3) expires in {} hours at {}",
                 owner.getChainKey(), strikeCount, hours, expiresAt);

        return expiresAt;
    }

    /**
     * Internal method to create a new ticket for a user.
     * Called automatically after registration or ticket expiration.
     */
    @Transactional
    public Ticket createTicketForUser(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found"));

        // Check if user already has an active invitee (shouldn't create ticket)
        if (user.getActiveChildId() != null) {
            throw new BusinessException("ALREADY_HAS_INVITEE", "User already has an active invitee");
        }

        // Check for existing active ticket (avoid duplicates)
        ticketRepository.findByOwnerIdAndStatus(userId, Ticket.TicketStatus.ACTIVE)
                .ifPresent(existingTicket -> {
                    throw new BusinessException("ACTIVE_TICKET_EXISTS", "User already has an active ticket");
                });

        // NEW: Only candidates and reactivated permanents get tickets
        if ("permanent".equals(user.getMembershipTier()) && user.getActiveChildId() != null) {
            throw new BusinessException("USER_ALREADY_PERMANENT",
                "Permanent members with active children don't need tickets");
        }

        // Create ticket with variable expiration time based on strikes
        Instant now = Instant.now();
        Instant expiresAt = calculateExpirationTime(user);  // NEW: Variable time

        String payload = createPayload(userId, now, expiresAt);
        String signature = signPayload(payload);

        Ticket ticket = Ticket.builder()
                .ownerId(userId)
                .expiresAt(expiresAt)
                .status(Ticket.TicketStatus.ACTIVE)
                .payload(payload)
                .signature(signature)
                .build();

        ticket = ticketRepository.save(ticket);

        String tier = user.getMembershipTier();
        int duration = (int) ((expiresAt.toEpochMilli() - now.toEpochMilli()) / 3600000);
        log.info("Ticket created for user {} ({}), tier={}, strike={}/3, duration={}h",
                 user.getChainKey(), ticket.getId(), tier,
                 user.getWastedTicketsCount(), duration);

        return ticket;
    }

    @Cacheable(value = CacheConfig.TICKET_CACHE, key = "#ticketId")
    public TicketResponse getTicket(UUID ticketId) {
        Ticket ticket = ticketRepository.findById(ticketId)
                .orElseThrow(() -> new BusinessException("TICKET_NOT_FOUND", "Ticket not found"));

        if (ticket.getExpiresAt().isBefore(Instant.now()) && ticket.getStatus() == Ticket.TicketStatus.ACTIVE) {
            ticket.setStatus(Ticket.TicketStatus.EXPIRED);
            ticketRepository.save(ticket);
        }

        return buildTicketResponse(ticket);
    }

    public boolean verifyTicketSignature(Ticket ticket, String providedSignature) {
        String expectedSignature = signPayload(ticket.getPayload());
        return expectedSignature.equals(providedSignature);
    }

    private String createPayload(UUID ownerId, Instant issuedAt, Instant expiresAt) {
        return String.format("%s|%d|%d|%s",
                ownerId.toString(),
                issuedAt.toEpochMilli(),
                expiresAt.toEpochMilli(),
                UUID.randomUUID().toString() // nonce
        );
    }

    private String signPayload(String payload) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            SecretKeySpec secretKeySpec = new SecretKeySpec(secretKey.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            mac.init(secretKeySpec);
            byte[] hash = mac.doFinal(payload.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(hash);
        } catch (Exception e) {
            throw new RuntimeException("Error signing payload", e);
        }
    }

    private TicketResponse buildTicketResponse(Ticket ticket) {
        String qrPayload = Base64.getEncoder().encodeToString(
                (ticket.getId() + "|" + ticket.getSignature()).getBytes(StandardCharsets.UTF_8)
        );

        String deepLink = "thechain://join?t=" + qrPayload;

        long timeRemaining = ticket.getExpiresAt().toEpochMilli() - Instant.now().toEpochMilli();

        return TicketResponse.builder()
                .ticketId(ticket.getId())
                .qrPayload(qrPayload)
                .qrCodeUrl(generateQrCodeUrl(deepLink))
                .deepLink(deepLink)
                .signature(ticket.getSignature())
                .issuedAt(ticket.getIssuedAt())
                .expiresAt(ticket.getExpiresAt())
                .status(ticket.getStatus().name())
                .timeRemaining(Math.max(0, timeRemaining))
                .build();
    }

    private String generateQrCodeUrl(String content) {
        try {
            QRCodeWriter qrCodeWriter = new QRCodeWriter();
            BitMatrix bitMatrix = qrCodeWriter.encode(content, BarcodeFormat.QR_CODE, 300, 300);

            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            MatrixToImageWriter.writeToStream(bitMatrix, "PNG", outputStream);
            byte[] qrCodeBytes = outputStream.toByteArray();

            String base64Qr = Base64.getEncoder().encodeToString(qrCodeBytes);
            return "data:image/png;base64," + base64Qr;
        } catch (Exception e) {
            log.error("Error generating QR code", e);
            return null;
        }
    }

    /**
     * Expires a ticket and handles reversion to last permanent member.
     * Called by scheduler when a ticket passes its deadline without being used.
     */
    @CacheEvict(value = CacheConfig.TICKET_CACHE, key = "#ticketId")
    @Transactional
    public void expireTicket(UUID ticketId) {
        Ticket ticket = ticketRepository.findById(ticketId)
                .orElseThrow(() -> new BusinessException("TICKET_NOT_FOUND", "Ticket not found"));

        if (ticket.getStatus() != Ticket.TicketStatus.ACTIVE) {
            log.warn("Attempted to expire non-active ticket {}", ticketId);
            return;
        }

        // Mark ticket as expired
        ticket.setStatus(Ticket.TicketStatus.EXPIRED);
        ticketRepository.save(ticket);

        // Get the owner
        User owner = userRepository.findById(ticket.getOwnerId())
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "Ticket owner not found"));

        // Increment wasted tickets count
        owner.setWastedTicketsCount(owner.getWastedTicketsCount() + 1);
        log.warn("User {} wasted ticket {}/3 (tier={})",
                 owner.getChainKey(), owner.getWastedTicketsCount(), owner.getMembershipTier());

        // Check if user should be removed from chain (3 strikes rule)
        if (owner.getWastedTicketsCount() >= 3) {
            log.error("User {} reached 3 wasted tickets - removing from chain", owner.getChainKey());
            removeUserFromChain(owner);

            // NEW: Find last permanent member and give them the ticket
            User lastPermanent = chainService.findLastPermanentMember(owner.getId());

            if (lastPermanent.getId().equals(owner.getId())) {
                // Edge case: The removed user WAS the last permanent (shouldn't happen)
                log.error("Removed user {} was last permanent - walking up to parent",
                          owner.getChainKey());
                if (owner.getParentId() != null) {
                    lastPermanent = userRepository.findById(owner.getParentId()).get();
                } else {
                    // No parent - must be seed situation, get seed
                    lastPermanent = userRepository.findByChainKey("SEED00000001").get();
                }
            }

            log.info("Ticket reverting to last permanent member: {} (position {})",
                     lastPermanent.getChainKey(), lastPermanent.getPosition());

            // Clear last permanent's activeChildId (they lost their candidate chain)
            // This will be handled by removeUserFromChain which updates parent's activeChildId

            // Create new ticket for last permanent member
            try {
                createTicketForUser(lastPermanent.getId());
                log.info("New ticket created for last permanent {} after candidate removal",
                         lastPermanent.getChainKey());

                // Check if they qualify for Chain Savior badge
                chainService.checkAndAwardChainSaviorBadge(lastPermanent);

            } catch (Exception e) {
                log.error("Failed to create ticket for last permanent member {}",
                          lastPermanent.getChainKey(), e);
            }

        } else {
            userRepository.save(owner);

            // NEW: Only create ticket if they're still a candidate
            if ("candidate".equals(owner.getMembershipTier())) {
                try {
                    createTicketForUser(owner.getId());
                    log.info("New ticket auto-created for candidate {} (strike {}/3, next window shorter)",
                             owner.getChainKey(), owner.getWastedTicketsCount());
                } catch (Exception e) {
                    log.error("Failed to auto-create ticket for candidate {}",
                              owner.getChainKey(), e);
                }
            } else {
                log.warn("User {} is permanent but wasted a ticket - no auto-ticket",
                         owner.getChainKey());
            }
        }

        log.info("Ticket {} expired for user {}", ticketId, owner.getChainKey());
    }

    /**
     * Removes a user from the chain and triggers chain reversion.
     */
    private void removeUserFromChain(User user) {
        UUID parentId = user.getParentId();
        Integer userPosition = user.getPosition();

        // 1. Mark user as removed
        user.setStatus("removed");
        user.setRemovedAt(Instant.now());
        user.setRemovalReason(RemovalReason.WASTED.name());
        user.setWastedTicketsCount(0); // Reset counter after removal
        userRepository.save(user);

        // 2. Update invitation status to REMOVED
        invitationRepository.findByChildId(user.getId())
            .ifPresent(invitation -> {
                invitation.setStatus(Invitation.InvitationStatus.REMOVED);
                invitationRepository.save(invitation);
            });

        // 3. If user has a parent, trigger chain reversion
        if (parentId != null) {
            userRepository.findById(parentId).ifPresent(parent -> {
                // Clear parent's activeChildId (they lost their child)
                parent.setActiveChildId(null);
                userRepository.save(parent);
                log.info("Chain reverted: Parent {} lost child at position {}",
                         parent.getChainKey(), userPosition);
            });

            // 4. CHECK IF PARENT SHOULD BE REMOVED (3-strike rule)
            chainService.checkParentRemovalFor3Strikes(user.getId());
        }

        log.info("User {} at position {} removed from chain", user.getChainKey(), userPosition);
    }
}
