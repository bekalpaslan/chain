package com.thechain.service;

import com.thechain.entity.*;
import com.thechain.exception.BusinessException;
import com.thechain.repository.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
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
     *
     * OPTIMIZED: Uses database query instead of loading all users into memory
     */
    @Transactional(readOnly = true)
    public User getCurrentTip() {
        return userRepository.findCurrentTipOptimized()
            .orElseThrow(() -> new BusinessException("NO_TIP_FOUND", "Unable to identify chain tip"));
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

        // Get parent (if exists)
        if (user.getParentId() != null) {
            userRepository.findById(user.getParentId())
                .ifPresent(parent -> result.put("parent", toUserSummary(parent)));
        }

        // Get active child (if exists)
        if (user.getActiveChildId() != null) {
            userRepository.findById(user.getActiveChildId())
                .ifPresent(child -> result.put("child", toUserSummary(child)));
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
        invitationRepository.findByChildId(userId)
            .ifPresent(invitation -> {
                invitation.setStatus(Invitation.InvitationStatus.REMOVED);
                invitationRepository.save(invitation);
            });

        // Clear parent's activeChildId reference
        if (user.getParentId() != null) {
            userRepository.findById(user.getParentId()).ifPresent(parent -> {
                parent.setActiveChildId(null);
                userRepository.save(parent);
            });
        }

        // Check if parent should be removed (3-strike rule)
        // This can trigger cascading removal up the chain
        self.checkParentRemovalFor3Strikes(userId);
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
     * Check if parent should be removed due to 3-strike rule
     * Called when a child is removed from the chain
     *
     * 3-Strike Rule:
     * - Parent gets removed after 3 CHILDREN fail (not after wasting 3 tickets)
     * - Each removed child counts as one strike
     * - Uses Invitation table with status=REMOVED to track wasted children
     *
     * @param removedChildId UUID of the child that was just removed
     */
    @Transactional
    public void checkParentRemovalFor3Strikes(UUID removedChildId) {
        // Find the invitation record for this child
        Optional<Invitation> invitationOpt = invitationRepository.findByChildId(removedChildId);

        if (invitationOpt.isEmpty()) {
            log.warn("No invitation found for removed child {}", removedChildId);
            return;
        }

        Invitation invitation = invitationOpt.get();
        UUID parentId = invitation.getParentId();

        // Get parent user
        Optional<User> parentOpt = userRepository.findById(parentId);
        if (parentOpt.isEmpty()) {
            log.warn("Parent {} not found for removed child {}", parentId, removedChildId);
            return;
        }

        User parent = parentOpt.get();

        // Don't remove seed user
        if ("seed".equals(parent.getStatus())) {
            log.debug("Parent {} is seed - immune to 3-strike removal", parent.getChainKey());
            return;
        }

        // Already removed
        if ("removed".equals(parent.getStatus())) {
            log.debug("Parent {} already removed", parent.getChainKey());
            return;
        }

        // Count total removed children (wasted children) for this parent
        List<UUID> wastedChildIds = invitationRepository.findWastedChildIdsByParentId(parentId);
        int wastedChildCount = wastedChildIds.size();

        log.info("Parent {} has {} wasted children (strike {}/3)",
            parent.getChainKey(), wastedChildCount, wastedChildCount);

        // Check if parent has reached 3 strikes
        ChainRule currentRule = getCurrentRule();
        if (wastedChildCount >= currentRule.getMaxAttempts()) {
            log.warn("Parent {} reached 3 strikes - removing from chain", parent.getChainKey());

            // Remove parent from chain (use self-proxy for transactional boundary)
            self.removeUserFromChain(parentId, RemovalReason.WASTED.name());

            // IMPORTANT: This can trigger cascading removal
            // The parent's removal will call checkParentRemovalFor3Strikes on THEIR parent
            // This continues until we reach seed or a parent with < 3 strikes
        }
    }

    /**
     * Check if user should earn Chain Savior badge
     * Called after successful invitation following a child removal
     *
     * Badge Logic:
     * - User must have had a previous child that was removed (wasted)
     * - User successfully invited a new child (activeChildId is set)
     * - This shows they "saved" the chain after a failure
     */
    @Transactional
    public void checkAndAwardChainSaviorBadge(User user) {
        // Get list of wasted children for this user
        List<UUID> wastedChildIds = invitationRepository.findWastedChildIdsByParentId(user.getId());

        // User earns Chain Savior if:
        // 1. They have at least one wasted child (previous failure)
        // 2. They now have an active child (successful recovery)
        if (!wastedChildIds.isEmpty() && user.getActiveChildId() != null) {
            Map<String, Object> context = new HashMap<>();
            context.put("collapse_depth", 1);
            context.put("wasted_children_count", wastedChildIds.size());
            context.put("recovered_at", Instant.now());

            awardBadge(user.getPosition(), Badge.CHAIN_SAVIOR, context);

            log.info("Awarded Chain Savior badge to user {} after {} failed attempts",
                user.getChainKey(), wastedChildIds.size());
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
