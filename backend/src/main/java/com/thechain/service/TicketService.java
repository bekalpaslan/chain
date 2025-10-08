package com.thechain.service;

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

    @Transactional
    public TicketResponse generateTicket(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found"));

        // Check if user already has an active invitee
        if (user.getActiveChildId() != null) {
            throw new BusinessException("ALREADY_HAS_INVITEE", "User already has an active invitee");
        }

        // Check for existing active ticket
        ticketRepository.findByOwnerIdAndStatus(userId, Ticket.TicketStatus.ACTIVE)
                .ifPresent(existingTicket -> {
                    throw new BusinessException("ACTIVE_TICKET_EXISTS", "User already has an active ticket");
                });

        // Create ticket
        Instant now = Instant.now();
        Instant expiresAt = now.plusSeconds(expirationHours * 3600L);

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

        log.info("Ticket generated for user {} ({})", user.getChainKey(), ticket.getId());

        return buildTicketResponse(ticket);
    }

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
     * Expires a ticket and triggers chain reversion logic.
     * Called by scheduler when a ticket passes its deadline without being used.
     */
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
        log.warn("User {} wasted ticket {}/3", owner.getChainKey(), owner.getWastedTicketsCount());

        // Check if user should be removed from chain (3 strikes rule)
        if (owner.getWastedTicketsCount() >= 3) {
            log.error("User {} reached 3 wasted tickets - removing from chain", owner.getChainKey());
            removeUserFromChain(owner);
        } else {
            userRepository.save(owner);
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
