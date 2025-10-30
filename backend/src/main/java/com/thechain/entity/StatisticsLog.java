package com.thechain.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.Instant;
import java.util.UUID;

/**
 * Time-series log of chain statistics, recorded every minute.
 * Used for historical tracking, growth analysis, and trend visualization.
 */
@Entity
@Table(name = "statistics_log", indexes = {
    @Index(name = "idx_statistics_log_logged_at", columnList = "loggedAt")
})
@EntityListeners(AuditingEntityListener.class)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StatisticsLog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /**
     * Timestamp rounded to the minute (e.g., 2025-01-15 10:30:00).
     * This ensures consistency across platforms and easy querying.
     */
    @Column(nullable = false, unique = true)
    private Instant loggedAt;

    /**
     * Total registered users in the chain at this point in time.
     */
    @Column(nullable = false)
    private Long totalUsers;

    /**
     * Number of active (unexpired, unclaimed) invitation tickets.
     */
    @Column(nullable = false)
    private Long activeTickets;

    /**
     * Cumulative count of expired unused tickets (wasted opportunities).
     */
    @Column(nullable = false)
    private Long totalWastedTickets;

    /**
     * Number of unique countries represented in the chain.
     */
    @Column(nullable = false)
    private Integer countries;

    /**
     * Average daily growth rate (users per day).
     */
    @Column
    private Double averageGrowthRate;

    /**
     * Percentage of tickets that expired unused (0.0 to 1.0).
     */
    @Column
    private Double wasteRate;

    /**
     * Timestamp when this record was created.
     */
    @CreatedDate
    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    /**
     * Creates a StatisticsLog from current chain stats.
     * @param totalUsers Total users in chain
     * @param activeTickets Active tickets count
     * @param totalWastedTickets Wasted tickets count
     * @param countries Number of countries
     * @param averageGrowthRate Average growth rate
     * @param wasteRate Waste rate percentage
     * @param loggedAt Timestamp rounded to the minute
     * @return StatisticsLog builder
     */
    public static StatisticsLog fromStats(
        Long totalUsers,
        Long activeTickets,
        Long totalWastedTickets,
        Integer countries,
        Double averageGrowthRate,
        Double wasteRate,
        Instant loggedAt
    ) {
        return StatisticsLog.builder()
            .loggedAt(loggedAt)
            .totalUsers(totalUsers)
            .activeTickets(activeTickets)
            .totalWastedTickets(totalWastedTickets)
            .countries(countries)
            .averageGrowthRate(averageGrowthRate)
            .wasteRate(wasteRate)
            .build();
    }
}
