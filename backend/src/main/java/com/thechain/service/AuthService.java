package com.thechain.service;

import com.thechain.dto.AuthResponse;
import com.thechain.dto.RegisterRequest;
import com.thechain.entity.Attachment;
import com.thechain.entity.Invitation;
import com.thechain.entity.Ticket;
import com.thechain.entity.User;
import com.thechain.exception.BusinessException;
import com.thechain.repository.AttachmentRepository;
import com.thechain.repository.InvitationRepository;
import com.thechain.repository.TicketRepository;
import com.thechain.repository.UserRepository;
import com.thechain.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final UserRepository userRepository;
    private final TicketRepository ticketRepository;
    private final AttachmentRepository attachmentRepository;
    private final InvitationRepository invitationRepository;
    private final TicketService ticketService;
    private final JwtUtil jwtUtil;
    private final ChainService chainService;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        // Validate ticket
        Ticket ticket = ticketRepository.findById(request.getTicketId())
                .orElseThrow(() -> new BusinessException("INVALID_TICKET", "Ticket not found"));

        if (ticket.getStatus() != Ticket.TicketStatus.ACTIVE) {
            throw new BusinessException("TICKET_" + ticket.getStatus(), "Ticket is " + ticket.getStatus().name().toLowerCase());
        }

        if (ticket.getExpiresAt().isBefore(Instant.now())) {
            ticket.setStatus(Ticket.TicketStatus.EXPIRED);
            ticketRepository.save(ticket);
            throw new BusinessException("TICKET_EXPIRED", "Ticket has expired");
        }

        // Verify signature
        if (!ticketService.verifyTicketSignature(ticket, request.getTicketSignature())) {
            throw new BusinessException("INVALID_SIGNATURE", "Invalid ticket signature");
        }

        // Check for duplicate device
        if (userRepository.existsByDeviceFingerprint(request.getDeviceFingerprint())) {
            throw new BusinessException("DUPLICATE_USER", "Device already registered");
        }

        // Get parent user
        User parent = userRepository.findById(ticket.getOwnerId())
                .orElseThrow(() -> new BusinessException("PARENT_NOT_FOUND", "Ticket owner not found"));

        if (parent.getActiveChildId() != null) {
            throw new BusinessException("PARENT_HAS_INVITEE", "Parent already has an active invitee");
        }

        // Create new user
        Integer nextPosition = userRepository.findMaxPosition();
        if (nextPosition == null) {
            nextPosition = 0;
        }
        nextPosition++;

        // Location tracking has been removed - simplified user creation
        User newUser = userRepository.save(User.builder()
                .displayName(request.getDisplayName() != null ? request.getDisplayName() : "Anonymous #" + nextPosition)
                .position(nextPosition)
                .parentId(parent.getId())
                .deviceId(request.getDeviceId())
                .deviceFingerprint(request.getDeviceFingerprint())
                .build());

        // Update parent's activeChildId reference
        parent.setActiveChildId(newUser.getId());
        userRepository.save(parent);

        // Mark ticket as used
        Instant now = Instant.now();
        ticket.setStatus(Ticket.TicketStatus.USED);
        ticket.setUsedAt(now);
        ticket.setClaimedBy(newUser.getId());
        ticket.setClaimedAt(now);
        ticketRepository.save(ticket);

        // Create invitation record (new relational storage)
        Invitation invitation = Invitation.builder()
                .parentId(parent.getId())
                .childId(newUser.getId())
                .ticketId(ticket.getId())
                .status(Invitation.InvitationStatus.ACTIVE)
                .acceptedAt(Instant.now())
                .build();
        invitationRepository.save(invitation);

        // Create attachment record (keep for backward compatibility if needed)
        Attachment attachment = Attachment.builder()
                .parentId(parent.getId())
                .childId(newUser.getId())
                .ticketId(ticket.getId())
                .build();
        attachmentRepository.save(attachment);

        // Check if parent deserves Chain Savior badge
        chainService.checkAndAwardChainSaviorBadge(parent);

        log.info("New user registered: {} at position {}", newUser.getChainKey(), newUser.getPosition());

        // Generate tokens
        String accessToken = jwtUtil.generateAccessToken(newUser.getId(), newUser.getChainKey(), newUser.getDeviceId());
        String refreshToken = jwtUtil.generateRefreshToken(newUser.getId(), newUser.getDeviceId());

        return AuthResponse.builder()
                .userId(newUser.getId())
                .chainKey(newUser.getChainKey())
                .displayName(newUser.getDisplayName())
                .position(newUser.getPosition())
                .parentId(parent.getId())
                .parentDisplayName(parent.getDisplayName())
                .createdAt(newUser.getCreatedAt())
                .tokens(AuthResponse.TokenInfo.builder()
                        .accessToken(accessToken)
                        .refreshToken(refreshToken)
                        .expiresIn(3600L)
                        .build())
                .build();
    }

    public AuthResponse login(String deviceId, String deviceFingerprint) {
        User user = userRepository.findByDeviceId(deviceId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found for this device"));

        // Verify device fingerprint matches
        if (!user.getDeviceFingerprint().equals(deviceFingerprint)) {
            log.warn("Device fingerprint mismatch for user {}", user.getId());
            throw new BusinessException("FINGERPRINT_MISMATCH", "Device verification failed");
        }

        // Generate new tokens
        String accessToken = jwtUtil.generateAccessToken(user.getId(), user.getChainKey(), user.getDeviceId());
        String refreshToken = jwtUtil.generateRefreshToken(user.getId(), user.getDeviceId());

        return AuthResponse.builder()
                .userId(user.getId())
                .chainKey(user.getChainKey())
                .displayName(user.getDisplayName())
                .position(user.getPosition())
                .tokens(AuthResponse.TokenInfo.builder()
                        .accessToken(accessToken)
                        .refreshToken(refreshToken)
                        .expiresIn(3600L)
                        .build())
                .build();
    }

    /**
     * Refresh access token using refresh token
     */
    public AuthResponse refreshToken(String refreshToken) {
        // Extract userId from refresh token
        UUID userId = jwtUtil.extractUserId(refreshToken);

        // Validate refresh token
        if (!jwtUtil.validateRefreshToken(refreshToken, userId)) {
            throw new BusinessException("INVALID_TOKEN", "Invalid or expired refresh token");
        }

        // Get user
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found"));

        // Generate new tokens
        String newAccessToken = jwtUtil.generateAccessToken(user.getId(), user.getChainKey(), user.getDeviceId());
        String newRefreshToken = jwtUtil.generateRefreshToken(user.getId(), user.getDeviceId());

        log.info("Tokens refreshed for user {}", user.getChainKey());

        return AuthResponse.builder()
                .userId(user.getId())
                .chainKey(user.getChainKey())
                .displayName(user.getDisplayName())
                .position(user.getPosition())
                .tokens(AuthResponse.TokenInfo.builder()
                        .accessToken(newAccessToken)
                        .refreshToken(newRefreshToken)
                        .expiresIn(3600L)
                        .build())
                .build();
    }
}
