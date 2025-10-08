package com.thechain.dto;

import lombok.Builder;
import lombok.Data;

import java.time.Instant;
import java.util.List;

@Data
@Builder
public class ChainStatsResponse {

    private Long totalUsers;
    private Long activeTickets;
    private Instant chainStartDate;
    private Double averageGrowthRate;
    private Long totalWastedTickets;
    private Double wasteRate;
    private Integer countries;
    private Instant lastUpdate;
    private List<RecentAttachment> recentAttachments;

    @Data
    @Builder
    public static class RecentAttachment {
        private Integer childPosition;
        private String displayName;
        private Instant timestamp;
        private String country;
    }
}
