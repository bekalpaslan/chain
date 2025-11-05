-- Migration V007: Add membership tier system
-- Date: November 4, 2025
-- Purpose: Support candidate/permanent member distinction for probation period model
--
-- This migration transforms the simple "hot potato" model into a sophisticated
-- "probation period" model with two membership tiers:
-- - Candidates: New users in probation who must prove themselves
-- - Permanent: Users who achieved depth-2 (their invitee invited someone)

-- Add new columns for membership tier tracking
ALTER TABLE users
ADD COLUMN membership_tier VARCHAR(20) DEFAULT 'candidate',
ADD COLUMN promoted_to_permanent_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN invitee_depth INTEGER DEFAULT 0;

-- Add indexes for efficient queries
CREATE INDEX idx_users_membership_tier ON users(membership_tier);
CREATE INDEX idx_users_invitee_depth ON users(invitee_depth);

-- Grandfather existing active users as permanent members
-- This ensures no disruption to current users
UPDATE users
SET membership_tier = 'permanent',
    promoted_to_permanent_at = created_at,
    invitee_depth = CASE
        WHEN active_child_id IS NULL THEN 0
        ELSE 2  -- Assume existing users with children have achieved depth-2
    END
WHERE status = 'active';

-- Seed user is always permanent
UPDATE users
SET membership_tier = 'permanent',
    promoted_to_permanent_at = created_at,
    invitee_depth = 2
WHERE status = 'seed';

-- Removed users don't have a membership tier
UPDATE users
SET membership_tier = NULL
WHERE status = 'removed';

-- Add constraint to ensure valid membership tiers
ALTER TABLE users
ADD CONSTRAINT check_membership_tier
CHECK (membership_tier IN ('candidate', 'permanent') OR membership_tier IS NULL);

-- Add documentation comments for future reference
COMMENT ON COLUMN users.membership_tier IS
'Membership tier: candidate (probationary period), permanent (verified through depth-2), NULL (removed users)';

COMMENT ON COLUMN users.promoted_to_permanent_at IS
'Timestamp when user achieved permanent status by reaching depth-2 (their invitee successfully invited someone)';

COMMENT ON COLUMN users.invitee_depth IS
'Depth of invitee chain: 0=no child, 1=has direct child, 2=has grandchild (triggers promotion to permanent)';