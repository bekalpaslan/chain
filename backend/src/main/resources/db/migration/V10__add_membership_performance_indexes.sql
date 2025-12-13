-- Migration V10: Add performance indexes for membership tier system
-- Date: December 13, 2025
-- Purpose: Optimize common queries for membership tier lookups
--
-- These composite indexes improve performance for:
-- 1. Filtering active permanent members
-- 2. Sorting permanent members by promotion date
-- 3. Counting candidates vs permanent members

-- Composite index for filtering active members by tier
-- Useful for queries like: WHERE status = 'active' AND membership_tier = 'permanent'
CREATE INDEX IF NOT EXISTS idx_users_status_tier
ON users(status, membership_tier);

-- Composite index for sorting permanent members by promotion date
-- Useful for queries like: ORDER BY promoted_to_permanent_at DESC
CREATE INDEX IF NOT EXISTS idx_users_tier_promoted_at
ON users(membership_tier, promoted_to_permanent_at DESC)
WHERE membership_tier = 'permanent';

-- Index for finding active permanent members efficiently
-- This is a partial index that only includes relevant rows
CREATE INDEX IF NOT EXISTS idx_users_active_permanent
ON users(id, invited_by_id)
WHERE status = 'active' AND membership_tier = 'permanent';

-- Index for finding candidates who need promotion checks
-- Useful for batch processing promotion eligibility
CREATE INDEX IF NOT EXISTS idx_users_active_candidates
ON users(id, invitee_depth)
WHERE status = 'active' AND membership_tier = 'candidate';

-- Add statistics comment for documentation
COMMENT ON INDEX idx_users_status_tier IS
'Composite index for efficient status + membership tier filtering';

COMMENT ON INDEX idx_users_tier_promoted_at IS
'Index for sorting permanent members by promotion date (DESC)';

COMMENT ON INDEX idx_users_active_permanent IS
'Partial index for quick access to active permanent members';

COMMENT ON INDEX idx_users_active_candidates IS
'Partial index for efficient candidate promotion eligibility checks';

-- Analyze the table to update query planner statistics
ANALYZE users;
