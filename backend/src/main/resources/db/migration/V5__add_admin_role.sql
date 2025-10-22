-- V5: Add admin role to users table
-- Description: Adds is_admin column to track administrative privileges

-- Step 1: Add is_admin column to users table
ALTER TABLE users
ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN users.is_admin IS 'Whether the user has administrative privileges';

CREATE INDEX IF NOT EXISTS idx_users_is_admin ON users(is_admin)
    WHERE is_admin = TRUE;

-- Step 2: Grant admin privileges to seed user (position 1)
UPDATE users
SET is_admin = TRUE
WHERE position = 1;

-- Step 3: Log the migration
DO $$
BEGIN
    RAISE NOTICE '✓ Added is_admin column to users table';
    RAISE NOTICE '✓ Granted admin privileges to seed user (position 1)';
END $$;