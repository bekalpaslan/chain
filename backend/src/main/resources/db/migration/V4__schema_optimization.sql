-- ============================================================================
-- V4: Schema Optimization and Missing Columns
-- ============================================================================
-- This migration adds any missing columns identified during schema consolidation
-- and adds documentation comments to all tables.
--
-- Safe to run on existing databases - all operations are idempotent.
-- ============================================================================

-- ============================================================================
-- ADD MISSING COLUMNS TO TICKETS TABLE
-- ============================================================================

-- Duration hours for each ticket (may differ from rule if rules changed)
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS duration_hours INTEGER DEFAULT 24;

-- QR code URL for visual ticket sharing
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS qr_code_url VARCHAR(500);

-- When ticket was actually used (different from claimed_at)
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS used_at TIMESTAMP WITH TIME ZONE;

-- ============================================================================
-- ADD MISSING INDEXES
-- ============================================================================

-- Index on attempt_number for 3-strike rule queries
CREATE INDEX IF NOT EXISTS idx_tickets_attempt_number ON tickets(attempt_number);

-- ============================================================================
-- ADD TABLE COMMENTS FOR DOCUMENTATION
-- ============================================================================

-- Core tables
COMMENT ON TABLE users IS 'Core user table storing all user data, authentication, and chain position';
COMMENT ON TABLE tickets IS 'Invitation tickets with expiration and 3-strike rule enforcement';
COMMENT ON TABLE attachments IS 'Parent-child relationships in the chain (who invited whom)';

-- Chain mechanics tables
COMMENT ON TABLE invitations IS 'Invitation history tracking (uses UUIDs, not positions)';
COMMENT ON TABLE chain_rules IS 'Versioned game rules allowing dynamic rule changes over time';

-- Badge system
COMMENT ON TABLE badges IS 'Predefined badge definitions';
COMMENT ON TABLE user_badges IS 'Badges earned by users (tracks by position number)';

-- Notification system
COMMENT ON TABLE notifications IS 'User notifications with multi-channel support (push, email, in-app)';
COMMENT ON TABLE device_tokens IS 'Device tokens for push notifications (FCM, APNs)';

-- Admin tools
COMMENT ON TABLE country_change_events IS 'Admin-defined windows when users can change their country';
COMMENT ON TABLE audit_log IS 'System-wide audit trail for security and compliance';

-- Authentication tables
COMMENT ON TABLE auth_sessions IS 'JWT refresh tokens with session management';
COMMENT ON TABLE password_reset_tokens IS 'One-time tokens for password reset flow';
COMMENT ON TABLE magic_link_tokens IS 'One-time magic links for passwordless login';
COMMENT ON TABLE email_verification_tokens IS 'Tokens for email verification flow';

-- ============================================================================
-- ADD COLUMN COMMENTS FOR KEY FIELDS
-- ============================================================================

-- Users table
COMMENT ON COLUMN users.chain_key IS 'Unique 12-character identifier for the user in the chain';
COMMENT ON COLUMN users.position IS 'Sequential position in the chain (1 = Seeder, 2 = first invitee, etc.)';
COMMENT ON COLUMN users.username IS 'Unique username for authentication (required)';
COMMENT ON COLUMN users.belongs_to IS 'User''s country (ISO 3166-1 alpha-2 code)';
COMMENT ON COLUMN users.inviter_position IS 'Position of the user who invited this user (±1 visibility)';
COMMENT ON COLUMN users.invitee_position IS 'Position of the user this user invited (±1 visibility)';
COMMENT ON COLUMN users.country_locked IS 'Whether country field is locked (can be temporarily unlocked by admin)';

-- Tickets table
COMMENT ON COLUMN tickets.attempt_number IS 'Current attempt (1-3) for the 3-strike rule';
COMMENT ON COLUMN tickets.rule_version IS 'Chain rule version when ticket was created (for grandfathering)';
COMMENT ON COLUMN tickets.duration_hours IS 'Duration in hours for this specific ticket';

-- Invitations table
COMMENT ON COLUMN invitations.status IS 'ACTIVE: valid, REMOVED: invitee removed, REVERTED: chain reverted past this point';

-- Chain rules table
COMMENT ON COLUMN chain_rules.version IS 'Unique version number (monotonically increasing)';
COMMENT ON COLUMN chain_rules.deployment_mode IS 'INSTANT: applied immediately, SCHEDULED: applied at effective_from';

-- User badges table
COMMENT ON COLUMN user_badges.context IS 'JSON context about how badge was earned';

-- ============================================================================
-- VERIFY SCHEMA INTEGRITY
-- ============================================================================

DO $$
DECLARE
    table_count INTEGER;
    index_count INTEGER;
    seed_user_count INTEGER;
    rule_count INTEGER;
    badge_count INTEGER;
BEGIN
    -- Count tables
    SELECT COUNT(*) INTO table_count
    FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE';

    -- Count indexes
    SELECT COUNT(*) INTO index_count
    FROM pg_indexes
    WHERE schemaname = 'public';

    -- Verify seed data
    SELECT COUNT(*) INTO seed_user_count
    FROM users
    WHERE position = 1;

    SELECT COUNT(*) INTO rule_count
    FROM chain_rules
    WHERE version = 1;

    SELECT COUNT(*) INTO badge_count
    FROM badges;

    -- Report results
    RAISE NOTICE '======================================================================';
    RAISE NOTICE 'V4 Schema Optimization Complete';
    RAISE NOTICE '======================================================================';
    RAISE NOTICE 'Schema Validation:';
    RAISE NOTICE '  Tables: % (expected: 17)', table_count;
    RAISE NOTICE '  Indexes: % (expected: 50+)', index_count;
    RAISE NOTICE '  Seed user: % (expected: 1)', seed_user_count;
    RAISE NOTICE '  Default rule: % (expected: 1)', rule_count;
    RAISE NOTICE '  Badges: % (expected: 3)', badge_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Changes Applied:';
    RAISE NOTICE '  ✓ Added missing columns to tickets table';
    RAISE NOTICE '  ✓ Added missing indexes';
    RAISE NOTICE '  ✓ Added documentation comments to all tables';
    RAISE NOTICE '  ✓ Added column comments for key fields';
    RAISE NOTICE '======================================================================';

    -- Validate expectations
    IF table_count != 17 THEN
        RAISE WARNING 'Expected 17 tables but found %', table_count;
    END IF;

    IF seed_user_count != 1 THEN
        RAISE WARNING 'Expected 1 seed user but found %', seed_user_count;
    END IF;

    IF rule_count != 1 THEN
        RAISE WARNING 'Expected 1 default rule but found %', rule_count;
    END IF;

    IF badge_count != 3 THEN
        RAISE WARNING 'Expected 3 badges but found %', badge_count;
    END IF;
END $$;
