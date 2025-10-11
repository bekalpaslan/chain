-- ============================================================================
-- V5: Add Admin Role Column and Reset Database
-- ============================================================================
-- Purpose:
-- 1. Add is_admin column to users table
-- 2. Clear all existing user data
-- 3. Recreate seed user with email and admin privileges
-- ============================================================================

-- Step 1: Add is_admin column to users table
ALTER TABLE users
ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN users.is_admin IS 'Whether the user has administrative privileges';

CREATE INDEX IF NOT EXISTS idx_users_is_admin ON users(is_admin)
    WHERE is_admin = TRUE;

-- Step 2: Clear all existing data (CASCADE will handle foreign keys)
-- Order matters: child tables first, then parent tables

-- Clear device tokens
TRUNCATE TABLE device_tokens CASCADE;

-- Clear notifications
TRUNCATE TABLE notifications CASCADE;

-- Clear audit log
TRUNCATE TABLE audit_log CASCADE;

-- Clear user badges
TRUNCATE TABLE user_badges CASCADE;

-- Clear country change events
TRUNCATE TABLE country_change_events CASCADE;

-- Clear auth sessions
TRUNCATE TABLE auth_sessions CASCADE;

-- Clear password reset tokens
TRUNCATE TABLE password_reset_tokens CASCADE;

-- Clear magic link tokens
TRUNCATE TABLE magic_link_tokens CASCADE;

-- Clear email verification tokens
TRUNCATE TABLE email_verification_tokens CASCADE;

-- Clear invitations
TRUNCATE TABLE invitations CASCADE;

-- Clear attachments
TRUNCATE TABLE attachments CASCADE;

-- Clear tickets
TRUNCATE TABLE tickets CASCADE;

-- Clear users (this will cascade to anything with foreign keys)
TRUNCATE TABLE users RESTART IDENTITY CASCADE;

-- Step 3: Insert seed admin user with new credentials
INSERT INTO users (
    id,
    chain_key,
    display_name,
    position,
    parent_id,
    belongs_to,
    status,
    username,
    password_hash,
    email,
    email_verified,
    is_admin,
    created_at,
    updated_at
) VALUES (
    'a0000000-0000-0000-0000-000000000001'::UUID,
    'SEED00000001',
    'The Seeder',
    1,
    NULL,
    'US',
    'seed',
    'alpaslan',
    '$2a$10$N9qo8uLOickgx2Z0J8s42O5P3Qh3vJGqOPXw3V8Cm0fxPX3kGPGxS',  -- bcrypt hash of "alpaslan"
    'bekalpaslan@gmail.com',
    TRUE,
    TRUE,
    NOW(),
    NOW()
);

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '======================================================================';
    RAISE NOTICE 'V5 Migration Complete: Admin Role and Database Reset';
    RAISE NOTICE '======================================================================';
    RAISE NOTICE 'Changes Applied:';
    RAISE NOTICE '  ✓ Added is_admin column to users table';
    RAISE NOTICE '  ✓ Cleared all existing data from all tables';
    RAISE NOTICE '  ✓ Created seed admin user:';
    RAISE NOTICE '      - Username: alpaslan';
    RAISE NOTICE '      - Password: alpaslan';
    RAISE NOTICE '      - Email: bekalpaslan@gmail.com (verified)';
    RAISE NOTICE '      - Admin: YES';
    RAISE NOTICE '      - Position: 1 (Seeder)';
    RAISE NOTICE '======================================================================';
END $$;
