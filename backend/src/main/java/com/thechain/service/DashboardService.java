package com.thechain.service;

import com.thechain.dto.*;
import com.thechain.entity.Ticket;
import com.thechain.entity.Ticket.TicketStatus;
import com.thechain.entity.User;
import com.thechain.exception.BusinessException;
import com.thechain.repository.TicketRepository;
import com.thechain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Dashboard service for aggregating all user-specific dashboard data
 *
 * @author Backend Team
 * @since 2025-01-12
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class DashboardService {

    private final UserRepository userRepository;
    private final TicketRepository ticketRepository;
    private final UserService userService;

    /**
     * Get comprehensive dashboard data for the current user
     */
    @Transactional(readOnly = true)
    public DashboardResponse getDashboardData(UUID userId) {
        log.info("Loading dashboard data for user: {}", userId);

        // Get user profile
        UserProfileResponse userProfile = userService.getUserProfile(userId);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found"));

        // Get visible chain members (±1 positions)
        List<ChainMemberDto> chainMembers = getVisibleChainMembers(user);

        // Get dashboard stats
        DashboardStatsDto stats = calculateDashboardStats(user);

        // Get critical actions
        List<CriticalActionDto> criticalActions = getCriticalActions(user);

        // Get recent activities
        List<ActivityDto> activities = getRecentActivities(user);

        // Get achievements (mock for now, will be implemented with badge system)
        List<AchievementDto> achievements = getAchievements(user);

        // Calculate achievement progress
        Map<String, Double> achievementProgress = calculateAchievementProgress(achievements);

        // Check for active ticket
        boolean hasActiveTicket = hasActiveTicket(userId);

        return DashboardResponse.builder()
                .user(userProfile)
                .chainMembers(chainMembers)
                .stats(stats)
                .criticalActions(criticalActions)
                .recentActivities(activities)
                .achievements(achievements)
                .achievementProgress(achievementProgress)
                .unreadNotifications(0) // TODO: Implement notification system
                .hasActiveTicket(hasActiveTicket)
                .lastActivity(user.getUpdatedAt() != null ? user.getUpdatedAt() : user.getCreatedAt())
                .build();
    }

    /**
     * Get visible chain members (±1 from user's position)
     * Shows: parent (position-1), user (position), and child (position+1)
     */
    private List<ChainMemberDto> getVisibleChainMembers(User user) {
        List<ChainMemberDto> members = new ArrayList<>();

        // Add parent (position - 1)
        if (user.getParentId() != null) {
            userRepository.findById(user.getParentId()).ifPresent(parent -> {
                members.add(createChainMemberDto(parent, false));
            });
        }

        // Add current user
        members.add(createChainMemberDto(user, true));

        // Add child (position + 1) if exists
        if (user.getActiveChildId() != null) {
            userRepository.findById(user.getActiveChildId()).ifPresent(child -> {
                members.add(createChainMemberDto(child, false));
            });
        }

        // If chain has more members, get the current tip
        Optional<User> tip = userRepository.findTopByOrderByPositionDesc();
        tip.ifPresent(tipUser -> {
            if (!tipUser.getId().equals(user.getId()) &&
                !members.stream().anyMatch(m -> m.getChainKey().equals(tipUser.getChainKey()))) {
                ChainMemberDto tipDto = createChainMemberDto(tipUser, false);
                tipDto.setStatus("tip");
                members.add(tipDto);
            }
        });

        return members;
    }

    private ChainMemberDto createChainMemberDto(User user, boolean isCurrentUser) {
        // Determine status
        String status = determineUserStatus(user);

        return ChainMemberDto.builder()
                .displayName(user.getDisplayName())
                .chainKey(user.getChainKey())
                .position(user.getPosition())
                .status(status)
                .isCurrentUser(isCurrentUser)
                .avatarEmoji("👤") // Default emoji, TODO: Add avatarEmoji field to User entity
                .joinedAt(user.getCreatedAt())
                .invitedCount(calculateInvitedCount(user.getId()))
                .build();
    }

    private String determineUserStatus(User user) {
        if (user.getPosition() == 1) {
            return "genesis";
        }
        if ("removed".equalsIgnoreCase(user.getStatus())) {
            return "removed";
        }
        if ("active".equalsIgnoreCase(user.getStatus())) {
            // Check if tip
            Optional<User> tip = userRepository.findTopByOrderByPositionDesc();
            if (tip.isPresent() && tip.get().getId().equals(user.getId())) {
                return "tip";
            }
            return "active";
        }
        return user.getStatus() != null ? user.getStatus().toLowerCase() : "active";
    }

    private Integer calculateInvitedCount(UUID userId) {
        // Count active children
        return userRepository.countByParentIdAndStatus(userId, "active");
    }

    /**
     * Calculate dashboard statistics
     */
    private DashboardStatsDto calculateDashboardStats(User user) {
        // Get total chain length
        Long totalChainLength = userRepository.count();

        // Calculate invited count
        Integer totalInvited = calculateInvitedCount(user.getId());

        // Active invites (pending tickets)
        Integer activeInvites = (int) ticketRepository.countByOwnerIdAndStatus(user.getId(), TicketStatus.ACTIVE);

        // Success rate (invited / total tickets generated)
        Double successRate = 0.0;
        if (user.getTotalTicketsGenerated() != null && user.getTotalTicketsGenerated() > 0) {
            successRate = (double) totalInvited / user.getTotalTicketsGenerated();
        }

        // Chain health (inverse of wasted tickets rate)
        Double chainHealth = 1.0;
        if (user.getWastedTicketsCount() != null && user.getWastedTicketsCount() > 0) {
            chainHealth = Math.max(0.0, 1.0 - (user.getWastedTicketsCount() / 3.0));
        }

        return DashboardStatsDto.builder()
                .position(user.getPosition())
                .totalInvited(totalInvited)
                .activeInvites(activeInvites)
                .successRate(successRate)
                .chainHealth(chainHealth)
                .totalChainLength(totalChainLength.intValue())
                .wastedTickets(user.getWastedTicketsCount() != null ? user.getWastedTicketsCount() : 0)
                .build();
    }

    /**
     * Get critical actions requiring user attention
     */
    private List<CriticalActionDto> getCriticalActions(User user) {
        List<CriticalActionDto> actions = new ArrayList<>();

        // Check for expiring ticket
        Optional<Ticket> activeTicket = ticketRepository
                .findTopByOwnerIdAndStatusOrderByIssuedAtDesc(user.getId(), TicketStatus.ACTIVE);

        activeTicket.ifPresent(ticket -> {
            if (ticket.getExpiresAt() != null) {
                Duration timeRemaining = Duration.between(Instant.now(), ticket.getExpiresAt());
                long hoursRemaining = timeRemaining.toHours();

                if (hoursRemaining <= 24 && hoursRemaining > 0) {
                    actions.add(CriticalActionDto.builder()
                            .type("ticketExpiring")
                            .title("Ticket Expiring Soon")
                            .description(String.format("Your invitation expires in %d hours", hoursRemaining))
                            .timeRemainingSeconds(timeRemaining.getSeconds())
                            .icon("timer")
                            .color("#F59E0B")
                            .build());
                }
            }
        });

        // Check if user is the tip
        Optional<User> tip = userRepository.findTopByOrderByPositionDesc();
        if (tip.isPresent() && tip.get().getId().equals(user.getId())) {
            actions.add(CriticalActionDto.builder()
                    .type("becameTip")
                    .title("You are now the TIP!")
                    .description("You can invite the next member to join the chain")
                    .icon("star")
                    .color("#00D4FF")
                    .build());
        }

        // Check for wasted tickets warning
        if (user.getWastedTicketsCount() != null && user.getWastedTicketsCount() >= 2) {
            actions.add(CriticalActionDto.builder()
                    .type("wastedTicketsWarning")
                    .title("Warning: Wasted Tickets")
                    .description(String.format("You have %d wasted tickets. 3 wasted tickets will result in removal.",
                            user.getWastedTicketsCount()))
                    .icon("warning")
                    .color("#EF4444")
                    .build());
        }

        return actions;
    }

    /**
     * Get recent activities for the user
     */
    private List<ActivityDto> getRecentActivities(User user) {
        List<ActivityDto> activities = new ArrayList<>();

        // Get recent tickets generated
        List<Ticket> recentTickets = ticketRepository
                .findByOwnerIdOrderByIssuedAtDesc(user.getId())
                .stream()
                .limit(5)
                .collect(Collectors.toList());

        for (Ticket ticket : recentTickets) {
            if (TicketStatus.USED.equals(ticket.getStatus()) && ticket.getUsedAt() != null) {
                activities.add(ActivityDto.builder()
                        .id("ticket_" + ticket.getId())
                        .type("ticketUsed")
                        .title("Invitation Accepted")
                        .description("Your invitation was accepted")
                        .timestamp(ticket.getUsedAt())
                        .build());
            } else if (TicketStatus.EXPIRED.equals(ticket.getStatus()) && ticket.getExpiresAt() != null) {
                activities.add(ActivityDto.builder()
                        .id("ticket_" + ticket.getId())
                        .type("inviteExpired")
                        .title("Invitation Expired")
                        .description("Your invitation ticket expired")
                        .timestamp(ticket.getExpiresAt())
                        .build());
            } else if (TicketStatus.ACTIVE.equals(ticket.getStatus())) {
                activities.add(ActivityDto.builder()
                        .id("ticket_" + ticket.getId())
                        .type("ticketGenerated")
                        .title("Invitation Generated")
                        .description("You created a new invitation")
                        .timestamp(ticket.getIssuedAt())
                        .build());
            }
        }

        // Sort by timestamp descending
        activities.sort((a, b) -> b.getTimestamp().compareTo(a.getTimestamp()));

        return activities.stream().limit(10).collect(Collectors.toList());
    }

    /**
     * Get user achievements (mock implementation)
     * TODO: Implement proper badge system
     */
    private List<AchievementDto> getAchievements(User user) {
        List<AchievementDto> achievements = new ArrayList<>();

        // Chain Savior badge (if user successfully reactivated chain)
        Integer invitedCount = calculateInvitedCount(user.getId());
        if (invitedCount > 0) {
            achievements.add(AchievementDto.builder()
                    .id("chain_savior")
                    .name("Chain Savior")
                    .description("Successfully invited a member to the chain")
                    .icon("🦸")
                    .rarity("legendary")
                    .earnedAt(user.getCreatedAt())
                    .progress(1.0)
                    .build());
        }

        // Early Adopter badge (for users in first 100)
        if (user.getPosition() != null && user.getPosition() <= 100) {
            achievements.add(AchievementDto.builder()
                    .id("early_adopter")
                    .name("Early Adopter")
                    .description("Joined in the first 100 members")
                    .icon("🌟")
                    .rarity("rare")
                    .earnedAt(user.getCreatedAt())
                    .progress(1.0)
                    .build());
        }

        // Chain Guardian badge (5+ successful invites)
        if (invitedCount >= 5) {
            achievements.add(AchievementDto.builder()
                    .id("chain_guardian")
                    .name("Chain Guardian")
                    .description("Successfully invited 5 or more members")
                    .icon("🛡️")
                    .rarity("epic")
                    .earnedAt(user.getCreatedAt())
                    .progress(1.0)
                    .build());
        } else if (invitedCount > 0) {
            // In progress
            achievements.add(AchievementDto.builder()
                    .id("chain_guardian")
                    .name("Chain Guardian")
                    .description("Successfully invite 5 members")
                    .icon("🛡️")
                    .rarity("epic")
                    .earnedAt(null)
                    .progress((double) invitedCount / 5.0)
                    .currentCount(invitedCount)
                    .targetCount(5)
                    .build());
        }

        return achievements;
    }

    private Map<String, Double> calculateAchievementProgress(List<AchievementDto> achievements) {
        return achievements.stream()
                .collect(Collectors.toMap(
                        AchievementDto::getId,
                        AchievementDto::getProgress
                ));
    }

    /**
     * Check if user has an active (non-expired) ticket
     */
    private boolean hasActiveTicket(UUID userId) {
        return ticketRepository.countByOwnerIdAndStatus(userId, TicketStatus.ACTIVE) > 0;
    }
}
