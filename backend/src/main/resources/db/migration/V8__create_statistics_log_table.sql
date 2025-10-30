-- Create statistics_log table for minute-by-minute chain statistics tracking
CREATE TABLE statistics_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Timestamp (rounded to the minute for consistency)
    logged_at TIMESTAMP NOT NULL,

    -- Core metrics
    total_users BIGINT NOT NULL,
    active_tickets BIGINT NOT NULL,
    total_wasted_tickets BIGINT NOT NULL,
    countries INTEGER NOT NULL,

    -- Growth metrics
    average_growth_rate DOUBLE PRECISION,
    waste_rate DOUBLE PRECISION,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT uk_statistics_log_logged_at UNIQUE (logged_at)
);

-- Index for time-series queries
CREATE INDEX idx_statistics_log_logged_at ON statistics_log(logged_at DESC);

-- Comments for documentation
COMMENT ON TABLE statistics_log IS 'Time-series log of chain statistics, recorded every minute';
COMMENT ON COLUMN statistics_log.logged_at IS 'Timestamp rounded to the minute (e.g., 2025-01-15 10:30:00)';
COMMENT ON COLUMN statistics_log.total_users IS 'Total registered users at this point in time';
COMMENT ON COLUMN statistics_log.active_tickets IS 'Number of active (unexpired, unclaimed) tickets';
COMMENT ON COLUMN statistics_log.total_wasted_tickets IS 'Cumulative count of expired unused tickets';
COMMENT ON COLUMN statistics_log.countries IS 'Number of unique countries represented';
COMMENT ON COLUMN statistics_log.average_growth_rate IS 'Average daily growth rate';
COMMENT ON COLUMN statistics_log.waste_rate IS 'Percentage of tickets that expired unused';
