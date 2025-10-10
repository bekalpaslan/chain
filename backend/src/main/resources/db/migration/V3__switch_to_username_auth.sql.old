-- V3: Switch to Username/Password Authentication
-- This migration removes device-based authentication and switches to username/password

-- ============================================================================
-- ADD USERNAME COLUMN AND UPDATE SEED USER
-- ============================================================================

-- Add username column
ALTER TABLE users ADD COLUMN IF NOT EXISTS username VARCHAR(50);

-- Update seed user with username and password (password: "alpaslan")
UPDATE users
SET
    username = 'alpaslan',
    password_hash = '$2a$10$N9qo8uLOickgx2Z0J8s42O5P3Qh3vJGqOPXw3V8Cm0fxPX3kGPGxS'  -- bcrypt hash of "alpaslan"
WHERE id = 'a0000000-0000-0000-0000-000000000001'::UUID;

-- ============================================================================
-- REMOVE DEVICE AUTHENTICATION COLUMNS FROM USERS TABLE
-- ============================================================================

-- Drop device-related indexes
DROP INDEX IF EXISTS idx_users_device_id;

-- Drop device columns
ALTER TABLE users DROP COLUMN IF EXISTS device_id;
ALTER TABLE users DROP COLUMN IF EXISTS device_fingerprint;

-- ============================================================================
-- MAKE USERNAME AND PASSWORD REQUIRED
-- ============================================================================

-- Make username NOT NULL and UNIQUE
ALTER TABLE users
    ALTER COLUMN username SET NOT NULL,
    ADD CONSTRAINT uq_users_username UNIQUE (username);

-- Make password_hash NOT NULL
ALTER TABLE users
    ALTER COLUMN password_hash SET NOT NULL;

-- Create username index
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- Make email optional (nullable) - for password recovery later
ALTER TABLE users ALTER COLUMN email DROP NOT NULL;

-- Drop the email unique constraint if it exists
DROP INDEX IF EXISTS idx_users_email;
DROP INDEX IF EXISTS uq_users_email;

-- Create partial unique index on email (only when not null)
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email
    ON users(email)
    WHERE email IS NOT NULL;

-- ============================================================================
-- REMOVE DEVICE FIELDS FROM AUTH_SESSIONS TABLE
-- ============================================================================

-- Drop device columns from auth sessions
ALTER TABLE auth_sessions DROP COLUMN IF EXISTS device_id;
ALTER TABLE auth_sessions DROP COLUMN IF EXISTS device_fingerprint;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE 'V3 Migration Complete: Switched to Username/Password Authentication';
    RAISE NOTICE 'Changes:';
    RAISE NOTICE '  - Added username column to users table';
    RAISE NOTICE '  - Removed device_id and device_fingerprint columns from users table';
    RAISE NOTICE '  - Made username and password_hash required (NOT NULL) in users table';
    RAISE NOTICE '  - Made email optional (for password recovery)';
    RAISE NOTICE '  - Removed device fields from auth_sessions table';
    RAISE NOTICE '  - Updated seed user with username/password credentials';
    RAISE NOTICE 'Authentication: Username/Password only';
END $$;
