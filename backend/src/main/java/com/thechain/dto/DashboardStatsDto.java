package com.thechain.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Dashboard statistics for the current user
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStatsDto {

    /**
     * User's position in the global chain
     */
    private Integer position;

    /**
     * Total number of users invited by this user
     */
    private Integer totalInvited;

    /**
     * Number of currently active invitations
     */
    private Integer activeInvites;

    /**
     * Success rate (invited users who joined / total invitations sent)
     */
    private Double successRate;

    /**
     * Chain health score (0.0 to 1.0)
     */
    private Double chainHealth;

    /**
     * Total length of the global chain
     */
    private Integer totalChainLength;

    /**
     * Number of wasted tickets for this user
     */
    private Integer wastedTickets;
}
