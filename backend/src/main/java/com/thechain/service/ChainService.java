package com.thechain.service;

import com.thechain.entity.*;
import com.thechain.exception.BusinessException;
import com.thechain.repository.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;

/**
 * ChainService - Core chain mechanics implementation
 * Handles:
 * - Tip identification and management (FR-3.2)
 * - User removal system (FR-3.3)
 * - Chain reversion/cascading (FR-3.4)
 * - Badge awarding (FR-3.6)
 */
@Service
@Slf4j
public class ChainService {
    private final UserRepository userRepository;
    private final InvitationRepository invitationRepository;
    private final TicketRepository ticketRepository;
    private final UserBadgeRepository userBadgeRepository;
    private final ChainService self;
    private final ChainRuleRepository chainRuleRepository;

    public ChainService(
        UserRepository userRepository,
        InvitationRepository invitationRepository,
        TicketRepository ticketRepository,
        UserBadgeRepository userBadgeRepository,
        @Lazy ChainService self,
        ChainRuleRepository chainRuleRepository
    ) {
        this.userRepository = userRepository;
        this.invitationRepository = invitationRepository;
        this.ticketRepository = ticketRepository;
        this.userBadgeRepository = userBadgeRepository;
        this.self = self;
        this.chainRuleRepository = chainRuleRepository;
    }

    /**
     * Get the current tip of the chain (FR-3.2)
     * The tip is the last active user who has not successfully invited anyone
     */
    @Transactional(readOnly = true)
    public User getCurrentTip() {
        // Find user with highest position who is active and has no active invitee
        Optional<User> tipUser = userRepository.findAll().stream()
            .filter(u -> "active".equals(u.getStatus()) || "seed".equals(u.getStatus()))
            .filter(u -> u.getInviteePosition() == null ||
                        !invitationRepository.existsByInviteePositionAndStatus(
                            u.getInviteePosition(),
                            Invitation.InvitationStatus.ACTIVE))
            .max(Comparator.comparing(User::getPosition));

        return tipUser.orElseThrow(() ->
            new BusinessException("NO_TIP_FOUND", "Unable to identify chain tip"));
    }
    @Transactional(readOnly = true)
    public boolean isCurrentTip(UUID userId) {
        User currentTip = self.getCurrentTip();
        return currentTip.getId().equals(userId);
    }

    @Transactional(readOnly = true)
    public boolean isCurrentTipByPosition(Integer position) {
        User currentTip = self.getCurrentTip();
        return currentTip.getPosition().equals(position);
    }


    /**
     * Get visible users for a given user (±1 visibility - FR-3.5)
     */
    @Transactional(readOnly = true)
    public Map<String, Object> getVisibleUsers(UUID userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found"));

        Map<String, Object> result = new HashMap<>();

        // Get inviter (if exists)
        if (user.getInviterPosition() != null) {
            userRepository.findByPosition(user.getInviterPosition())
                .ifPresent(inviter -> result.put("inviter", toUserSummary(inviter)));
        }

        // Get invitee (if exists)
        if (user.getInviteePosition() != null) {
            userRepository.findByPosition(user.getInviteePosition())
                .ifPresent(invitee -> result.put("invitee", toUserSummary(invitee)));
        }

        return result;
    }

    /**
     * Handle ticket expiration and implement 3-strike rule (FR-3.3)
     */
    @Transactional
    public void handleTicketExpiration(UUID ticketId) {
        Ticket ticket = ticketRepository.findById(ticketId)
            .orElseThrow(() -> new BusinessException("TICKET_NOT_FOUND", "Ticket not found"));

        if (ticket.getStatus() == Ticket.TicketStatus.EXPIRED) {
            log.debug("Ticket {} already marked as expired", ticketId);
            return;
        }

        User owner = userRepository.findById(ticket.getOwnerId())
            .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "Ticket owner not found"));

        // Mark ticket as expired
        ticket.setStatus(Ticket.TicketStatus.EXPIRED);
        ticketRepository.save(ticket);

        // Increment wasted tickets count
        owner.setWastedTicketsCount(owner.getWastedTicketsCount() + 1);
        userRepository.save(owner);

        log.info("Ticket {} expired. User {} attempt {}/{}",
            ticketId, owner.getChainKey(), ticket.getAttemptNumber(), getMaxAttempts());

        // Check if user has exceeded max attempts
        ChainRule currentRule = getCurrentRule();
        if (ticket.getAttemptNumber() >= currentRule.getMaxAttempts()) {
            removeUserFromChain(owner.getId(), "3_failed_attempts");
        }
    }

    /**
     * Remove user from chain (FR-3.3)
     */
    @Transactional
    public void removeUserFromChain(UUID userId, String reason) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found"));

        // Don't remove seed
        if ("seed".equals(user.getStatus())) {
            log.warn("Cannot remove seed user");
            return;
        }

        // Already removed
        if ("removed".equals(user.getStatus())) {
            log.debug("User {} already removed", user.getChainKey());
            return;
        }

        log.info("Removing user {} (position {}) from chain. Reason: {}",
            user.getChainKey(), user.getPosition(), reason);

        // Mark user as removed
        user.setStatus("removed");
        user.setRemovalReason(reason);
        user.setRemovedAt(Instant.now());
        userRepository.save(user);

        // Mark invitation as removed
        if (user.getPosition() != null) {
            invitationRepository.findByInviteePosition(user.getPosition())
                .ifPresent(invitation -> {
                    invitation.setStatus(Invitation.InvitationStatus.REMOVED);
                    invitationRepository.save(invitation);
                });
        }

        // Revert chain to inviter (FR-3.4)
        if (user.getInviterPosition() != null) {
            revertChainToPosition(user.getInviterPosition());
        }
    }

    /**
     * Revert chain to a specific position (FR-3.4)
     * Called when a user is removed - makes their inviter the tip again
     */
    @Transactional
    public void revertChainToPosition(Integer position) {
        User newTip = userRepository.findByPosition(position)
            .orElseThrow(() -> new BusinessException("USER_NOT_FOUND",
                "Cannot revert chain - user at position " + position + " not found"));

        log.info("Reverting chain to position {}: {}", position, newTip.getChainKey());

        // Clear the invitee reference
        newTip.setInviteePosition(null);
        userRepository.save(newTip);

        // Check if new tip should earn Chain Savior badge
        // Badge earned if they were reactivated and successfully invite again
        // This will be checked when they successfully generate a new invitation
    }

    /**
     * Award badge to user (FR-3.6)
     */
    @Transactional
    public void awardBadge(Integer userPosition, String badgeType, Map<String, Object> context) {
        // Check if user already has this badge
        if (userBadgeRepository.existsByUserPositionAndBadgeType(userPosition, badgeType)) {
            log.debug("User at position {} already has badge {}", userPosition, badgeType);
            return;
        }

        UserBadge badge = UserBadge.builder()
            .userPosition(userPosition)
            .badgeType(badgeType)
            .context(context)
            .build();

        userBadgeRepository.save(badge);
        log.info("Awarded badge {} to user at position {}", badgeType, userPosition);
    }

    /**
     * Check if user should earn Chain Savior badge
     * Called after successful invitation following a reversion
     */
    @Transactional
    public void checkAndAwardChainSaviorBadge(User user) {
        // User earns Chain Savior if:
        // 1. Their previous invitee was removed
        // 2. They successfully invited someone new

        if (user.getWastedTicketsCount() > 0 && user.getInviteePosition() != null) {
            Map<String, Object> context = new HashMap<>();
            context.put("collapse_depth", 1);
            context.put("wasted_tickets", user.getWastedTicketsCount());

            awardBadge(user.getPosition(), Badge.CHAIN_SAVIOR, context);
        }
    }

    /**
     * Get current active rule
     */
    private ChainRule getCurrentRule() {
        return chainRuleRepository.findCurrentActiveRule(Instant.now())
            .orElseGet(() -> {
                // Return default rule if none found
                ChainRule defaultRule = new ChainRule();
                defaultRule.setVersion(1);
                defaultRule.setTicketDurationHours(24);
                defaultRule.setMaxAttempts(3);
                defaultRule.setVisibilityRange(1);
                defaultRule.setSeedUnlimitedTime(true);
                defaultRule.setReactivationTimeoutHours(24);
                return defaultRule;
            });
    }

    /**
     * Get max attempts from current rule
     */
    public int getMaxAttempts() {
        return getCurrentRule().getMaxAttempts();
    }

    /**
     * Get ticket duration from current rule
     */
    public int getTicketDurationHours() {
        return getCurrentRule().getTicketDurationHours();
    }

    /**
     * Convert user to summary DTO
     */
    private Map<String, Object> toUserSummary(User user) {
        Map<String, Object> summary = new HashMap<>();
        summary.put("position", user.getPosition());
        summary.put("chainKey", user.getChainKey());
        summary.put("displayName", user.getDisplayName());
        summary.put("avatarEmoji", user.getAvatarEmoji());
        summary.put("country", user.getAssociatedWith());
        summary.put("status", user.getStatus());

        // Get badges
        List<UserBadge> badges = userBadgeRepository.findAllByUserPosition(user.getPosition());
        if (!badges.isEmpty()) {
            summary.put("badges", badges.stream()
                .map(UserBadge::getBadgeType)
                .toList());
        }

        return summary;
    }

    /**
     * Get chain statistics (FR-4.1)
     */
    @Transactional(readOnly = true)
    public Map<String, Object> getChainStatistics() {
        Map<String, Object> stats = new HashMap<>();

        // Total positions issued
        Long totalPositions = userRepository.count();
        stats.put("total_positions_issued", totalPositions);

        // Active members
        Long activeMembers = userRepository.countByStatus("active") +
                            userRepository.countByStatus("seed");
        stats.put("active_members", activeMembers);

        // Removed members
        Long removedMembers = userRepository.countByStatus("removed");
        stats.put("removed_members", removedMembers);

        // Success rate (%) = active members / total positions
        double successRate = totalPositions > 0
            ? 100.0 * ((double) activeMembers / (double) totalPositions)
            : 0.0;
        stats.put("success_rate", successRate);

        // Current tip (invoke transactional method via injected proxy)
        User currentTip = self.getCurrentTip();
        Map<String, Object> tipInfo = new HashMap<>();
        tipInfo.put("position", currentTip.getPosition());
        tipInfo.put("display_name", currentTip.getDisplayName());

        // Check if tip has active ticket
        boolean hasActiveTicket = ticketRepository.existsByOwnerIdAndStatus(
            currentTip.getId(), Ticket.TicketStatus.ACTIVE);
        tipInfo.put("has_active_ticket", hasActiveTicket);

        stats.put("current_tip", tipInfo);

        // Countries represented
        Long countriesCount = userRepository.countDistinctCountries();
        stats.put("countries_represented", countriesCount);

        return stats;
    }
}
