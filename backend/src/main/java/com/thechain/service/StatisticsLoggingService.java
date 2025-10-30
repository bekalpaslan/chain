package com.thechain.service;

import com.thechain.dto.ChainStatsResponse;
import com.thechain.entity.StatisticsLog;
import com.thechain.repository.StatisticsLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

/**
 * Service for logging chain statistics every minute.
 * Runs on a cron schedule, calculates current statistics, and writes them to the database.
 *
 * This service:
 * - Runs every minute at :00 seconds (e.g., 10:30:00, 10:31:00, etc.)
 * - Retrieves current chain statistics
 * - Rounds timestamp to the minute for consistency
 * - Writes log entry to statistics_log table
 * - Handles duplicate entries gracefully
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class StatisticsLoggingService {

    private final ChainStatsService chainStatsService;
    private final StatisticsLogRepository statisticsLogRepository;

    /**
     * Scheduled task that runs every minute to log chain statistics.
     * Cron expression: "0 * * * * *" = At 0 seconds of every minute
     *
     * Example execution times:
     * - 10:30:00
     * - 10:31:00
     * - 10:32:00
     *
     * The method:
     * 1. Calculates current timestamp rounded to the minute
     * 2. Checks if log already exists for this minute (prevents duplicates)
     * 3. Fetches current chain statistics
     * 4. Creates and saves StatisticsLog entry
     * 5. Logs success/failure
     */
    @Scheduled(cron = "0 * * * * *")
    @Transactional
    public void logStatistics() {
        try {
            // Round timestamp to the minute for consistency
            Instant now = Instant.now().truncatedTo(ChronoUnit.MINUTES);

            // Check if we already logged statistics for this minute
            if (statisticsLogRepository.existsByLoggedAt(now)) {
                log.debug("Statistics already logged for timestamp: {}", now);
                return;
            }

            // Fetch current chain statistics
            log.debug("Calculating chain statistics for timestamp: {}", now);
            ChainStatsResponse stats = chainStatsService.getGlobalStats();

            // Create statistics log entry
            StatisticsLog logEntry = StatisticsLog.fromStats(
                stats.getTotalUsers(),
                stats.getActiveTickets(),
                stats.getTotalWastedTickets(),
                stats.getCountries(),
                stats.getAverageGrowthRate(),
                stats.getWasteRate(),
                now
            );

            // Save to database
            statisticsLogRepository.save(logEntry);

            log.info("✅ Statistics logged successfully for {}: {} users, {} active tickets",
                now, stats.getTotalUsers(), stats.getActiveTickets());

        } catch (Exception e) {
            // Log error but don't throw - we'll try again next minute
            log.error("❌ Failed to log statistics: {}", e.getMessage(), e);
        }
    }

    /**
     * Manually trigger statistics logging (for testing or admin purposes).
     * @return The created StatisticsLog entry
     */
    @Transactional
    public StatisticsLog logStatisticsNow() {
        Instant now = Instant.now().truncatedTo(ChronoUnit.MINUTES);

        ChainStatsResponse stats = chainStatsService.getGlobalStats();

        StatisticsLog logEntry = StatisticsLog.fromStats(
            stats.getTotalUsers(),
            stats.getActiveTickets(),
            stats.getTotalWastedTickets(),
            stats.getCountries(),
            stats.getAverageGrowthRate(),
            stats.getWasteRate(),
            now
        );

        StatisticsLog saved = statisticsLogRepository.save(logEntry);
        log.info("Manual statistics log created for {}", now);

        return saved;
    }
}
