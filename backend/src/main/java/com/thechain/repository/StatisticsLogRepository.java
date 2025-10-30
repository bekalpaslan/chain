package com.thechain.repository;

import com.thechain.entity.StatisticsLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository for accessing statistics log data.
 * Provides methods for querying time-series statistics.
 */
@Repository
public interface StatisticsLogRepository extends JpaRepository<StatisticsLog, UUID> {

    /**
     * Find statistics log entry for a specific timestamp.
     * @param loggedAt The timestamp to search for
     * @return Optional containing the log entry if found
     */
    Optional<StatisticsLog> findByLoggedAt(Instant loggedAt);

    /**
     * Check if a log entry already exists for a specific timestamp.
     * @param loggedAt The timestamp to check
     * @return true if entry exists, false otherwise
     */
    boolean existsByLoggedAt(Instant loggedAt);

    /**
     * Find all statistics within a time range, ordered by time descending.
     * @param startTime Start of time range (inclusive)
     * @param endTime End of time range (inclusive)
     * @return List of statistics logs in the range
     */
    List<StatisticsLog> findByLoggedAtBetweenOrderByLoggedAtDesc(Instant startTime, Instant endTime);

    /**
     * Get the most recent statistics log entry.
     * @return Optional containing the most recent entry
     */
    Optional<StatisticsLog> findTopByOrderByLoggedAtDesc();

    /**
     * Get the N most recent statistics log entries.
     * @param limit Maximum number of entries to return
     * @return List of recent statistics logs
     */
    @Query("SELECT s FROM StatisticsLog s ORDER BY s.loggedAt DESC LIMIT :limit")
    List<StatisticsLog> findRecentLogs(@Param("limit") int limit);

    /**
     * Delete old statistics logs before a specific timestamp.
     * Useful for cleanup/archival of old data.
     * @param before Timestamp before which to delete logs
     */
    void deleteByLoggedAtBefore(Instant before);
}
