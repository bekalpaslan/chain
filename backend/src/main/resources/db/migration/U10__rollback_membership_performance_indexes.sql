-- Rollback Migration U10: Remove performance indexes for membership tier system
-- Date: December 13, 2025
-- Purpose: Revert V10__add_membership_performance_indexes.sql changes

-- Drop all indexes created in V10
DROP INDEX IF EXISTS idx_users_status_tier;
DROP INDEX IF EXISTS idx_users_tier_promoted_at;
DROP INDEX IF EXISTS idx_users_active_permanent;
DROP INDEX IF EXISTS idx_users_active_candidates;

-- Rollback complete
-- Note: Removing these indexes may impact query performance but will not affect data
