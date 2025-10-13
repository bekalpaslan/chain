package com.thechain.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;
import java.util.Map;

/**
 * Comprehensive dashboard response containing all user-specific data
 * for the private app dashboard screen.
 *
 * @author Backend Team
 * @since 2025-01-12
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardResponse {

    /**
     * Current user profile information
     */
    private UserProfileResponse user;

    /**
     * Visible chain members (±1 from user's position)
     */
    private List<ChainMemberDto> chainMembers;

    /**
     * Dashboard statistics
     */
    private DashboardStatsDto stats;

    /**
     * Critical actions requiring user attention
     */
    private List<CriticalActionDto> criticalActions;

    /**
     * Recent activity feed
     */
    private List<ActivityDto> recentActivities;

    /**
     * User's earned and in-progress achievements
     */
    private List<AchievementDto> achievements;

    /**
     * Achievement progress map (achievement_id -> progress 0.0 to 1.0)
     */
    private Map<String, Double> achievementProgress;

    /**
     * Number of unread notifications
     */
    private Integer unreadNotifications;

    /**
     * Whether user has an active (non-expired) ticket
     */
    private Boolean hasActiveTicket;

    /**
     * User's last activity timestamp
     */
    private Instant lastActivity;
}
