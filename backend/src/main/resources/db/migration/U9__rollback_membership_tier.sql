-- Rollback Migration U9: Remove membership tier system
-- Date: December 13, 2025
-- Purpose: Revert V9__add_membership_tier.sql changes
--
-- WARNING: This rollback will permanently remove membership tier data.
-- Users will lose their permanent status and promotion timestamps.
-- Use only in emergency rollback scenarios.

-- Step 1: Remove column comments first
COMMENT ON COLUMN users.membership_tier IS NULL;
COMMENT ON COLUMN users.promoted_to_permanent_at IS NULL;
COMMENT ON COLUMN users.invitee_depth IS NULL;

-- Step 2: Drop constraint before dropping columns
ALTER TABLE users DROP CONSTRAINT IF EXISTS check_membership_tier;

-- Step 3: Drop indexes before dropping columns
DROP INDEX IF EXISTS idx_users_membership_tier;
DROP INDEX IF EXISTS idx_users_invitee_depth;

-- Step 4: Drop the columns added in V9
ALTER TABLE users
DROP COLUMN IF EXISTS membership_tier,
DROP COLUMN IF EXISTS promoted_to_permanent_at,
DROP COLUMN IF EXISTS invitee_depth;

-- Rollback complete
-- Note: User status data (active, removed, seed) is preserved
-- Only membership tier tracking is removed
