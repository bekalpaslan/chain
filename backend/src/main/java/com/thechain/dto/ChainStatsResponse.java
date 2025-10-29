package com.thechain.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Global chain statistics and metrics")
public class ChainStatsResponse {

    @Schema(description = "Total number of registered users in the chain", example = "12345")
    private Long totalUsers;

    @Schema(description = "Number of currently active invite tickets", example = "234")
    private Long activeTickets;

    @Schema(description = "Timestamp when the chain was started", example = "2024-01-01T00:00:00Z")
    private Instant chainStartDate;

    @Schema(description = "Average daily user growth rate", example = "1.15")
    private Double averageGrowthRate;

    @Schema(description = "Total number of expired unused tickets", example = "567")
    private Long totalWastedTickets;

    @Schema(description = "Percentage of tickets that expired unused", example = "0.045")
    private Double wasteRate;

    @Schema(description = "Number of countries represented in the chain", example = "42")
    private Integer countries;

    @Schema(description = "Timestamp of last statistics update", example = "2024-01-15T10:30:00Z")
    private Instant lastUpdate;

    @Schema(description = "List of recent users who joined the chain")
    private List<RecentAttachment> recentAttachments;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @Schema(description = "Recent user attachment to the chain")
    public static class RecentAttachment {

        @Schema(description = "Position of the new user in the chain", example = "12345")
        private Integer childPosition;

        @Schema(description = "Display name of the new user", example = "John Doe")
        private String displayName;

        @Schema(description = "Timestamp when user joined", example = "2024-01-15T10:30:00Z")
        private Instant timestamp;

        @Schema(description = "Country of the new user", example = "United States")
        private String country;
    }
}
