-- ============================================================================
-- V1: Consolidated Initial Schema - The Chain Application
-- ============================================================================
-- This consolidated migration includes all tables and features from:
-- - Original V1 (base users, tickets, auth tables)
-- - Original V2 (chain mechanics: invitations, rules, badges, notifications)
-- - Original V3 (username/password authentication)
--
-- Total Tables: 17
-- - users (core user data with username/password auth)
-- - tickets (invitation tickets with 3-strike rule)
-- - attachments (parent-child relationships)
-- - invitations (invitation history tracking)
-- - chain_rules (dynamic game rules)
-- - badges (predefined badge definitions)
-- - user_badges (badges earned by users)
-- - notifications (user notifications)
-- - device_tokens (push notification tokens)
-- - country_change_events (temporary country change windows)
-- - audit_log (system audit trail)
-- - auth_sessions (JWT refresh tokens)
-- - password_reset_tokens (password recovery)
-- - magic_link_tokens (magic link authentication)
-- - email_verification_tokens (email verification)
--
-- IMPORTANT: This schema maintains exact compatibility with JPA entities
-- Column names use snake_case in DB, mapped to camelCase in Java
-- ============================================================================

-- ============================================================================
-- USERS TABLE (Core entity)
-- Purpose: Store all user data including authentication, profile, and chain position
-- ============================================================================

CREATE TABLE IF NOT EXISTS users (
    -- ========== Core Identity ==========
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chain_key VARCHAR(32) UNIQUE NOT NULL,
    display_name VARCHAR(50) NOT NULL,
    position INTEGER UNIQUE NOT NULL,

    -- ========== Chain Relationships ==========
    parent_id UUID REFERENCES users(id),
    -- Note: child_id (activeChildId) and wastedChildIds are managed in Java, not DB columns

    -- ========== Authentication (Username/Password - Required) ==========
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,

    -- ========== Optional Authentication Methods ==========
    email VARCHAR(255),
    email_verified BOOLEAN DEFAULT FALSE,
    apple_user_id VARCHAR(255),
    google_user_id VARCHAR(255),

    -- ========== User Profile ==========
    real_name VARCHAR(100),
    is_guest BOOLEAN DEFAULT FALSE,
    avatar_emoji VARCHAR(10) DEFAULT '👤',
    belongs_to VARCHAR(2),  -- ISO 3166-1 alpha-2 country code (e.g., "US", "GB")

    -- ========== Status Tracking ==========
    status VARCHAR(20) DEFAULT 'active',
    removal_reason VARCHAR(50),
    removed_at TIMESTAMP WITH TIME ZONE,

    -- ========== Activity & Stats ==========
    last_active_at TIMESTAMP WITH TIME ZONE,
    wasted_tickets_count INTEGER DEFAULT 0,
    total_tickets_generated INTEGER DEFAULT 0,

    -- ========== Chain Mechanics (V2 additions) ==========
    inviter_position INTEGER,  -- Position of user who invited this user (±1 visibility)
    invitee_position INTEGER,  -- Position of user this user invited (±1 visibility)
    country_locked BOOLEAN DEFAULT TRUE,
    country_changed_at TIMESTAMP WITH TIME ZONE,
    display_name_changed_at TIMESTAMP WITH TIME ZONE,

    -- ========== Timestamps ==========
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- ============================================================================
-- USERS TABLE - INDEXES
-- ============================================================================

-- Core identity indexes
CREATE INDEX IF NOT EXISTS idx_users_chain_key ON users(chain_key);
CREATE INDEX IF NOT EXISTS idx_users_parent_id ON users(parent_id);
CREATE INDEX IF NOT EXISTS idx_users_position ON users(position);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- Authentication indexes (unique where not null for optional methods)
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_username ON users(username);

CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email
    ON users(email)
    WHERE email IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_users_apple_id
    ON users(apple_user_id)
    WHERE apple_user_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_users_google_id
    ON users(google_user_id)
    WHERE google_user_id IS NOT NULL;

-- Display name must be case-insensitive unique
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_display_name_lower
    ON users(LOWER(display_name));

-- Status and activity indexes
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
CREATE INDEX IF NOT EXISTS idx_users_last_active ON users(last_active_at);
CREATE INDEX IF NOT EXISTS idx_users_removed_at ON users(removed_at);
CREATE INDEX IF NOT EXISTS idx_users_belongs_to ON users(belongs_to);

-- Chain mechanics indexes
CREATE INDEX IF NOT EXISTS idx_users_inviter_position ON users(inviter_position);
CREATE INDEX IF NOT EXISTS idx_users_invitee_position ON users(invitee_position);

-- ============================================================================
-- USERS TABLE - CONSTRAINTS
-- ============================================================================

-- Status must be valid
ALTER TABLE users ADD CONSTRAINT chk_users_status
    CHECK (status IN ('active', 'removed', 'seed'));

-- Removal reason must be valid (if present)
ALTER TABLE users ADD CONSTRAINT chk_users_removal_reason
    CHECK (
        removal_reason IS NULL OR
        removal_reason IN ('3_failed_attempts', 'inactive_when_reactivated', 'admin_action')
    );

-- Country code must be 2 uppercase letters (if present)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'chk_users_belongs_to'
    ) THEN
        ALTER TABLE users ADD CONSTRAINT chk_users_belongs_to
            CHECK (
                belongs_to IS NULL OR
                (belongs_to ~ '^[A-Z]{2}$')
            );
    END IF;
END $$;

-- ============================================================================
-- USERS TABLE - COMMENTS
-- ============================================================================

COMMENT ON TABLE users IS 'Core user table storing all user data, authentication, and chain position';
COMMENT ON COLUMN users.chain_key IS 'Unique 12-character identifier for the user in the chain';
COMMENT ON COLUMN users.position IS 'Sequential position in the chain (1 = Seeder, 2 = first invitee, etc.)';
COMMENT ON COLUMN users.username IS 'Unique username for authentication (required)';
COMMENT ON COLUMN users.belongs_to IS 'User''s country (ISO 3166-1 alpha-2 code)';
COMMENT ON COLUMN users.inviter_position IS 'Position of the user who invited this user (±1 visibility)';
COMMENT ON COLUMN users.invitee_position IS 'Position of the user this user invited (±1 visibility)';
COMMENT ON COLUMN users.country_locked IS 'Whether country field is locked (can be temporarily unlocked by admin)';

-- ============================================================================
-- TICKETS TABLE
-- Purpose: Invitation tickets with expiration, 3-strike rule, and signatures
-- ============================================================================

CREATE TABLE IF NOT EXISTS tickets (
    -- ========== Core Identity ==========
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- ========== Ticket Metadata ==========
    ticket_code VARCHAR(50),     -- For QR/link sharing
    next_position INTEGER,        -- What position the invitee will receive

    -- ========== 3-Strike Rule Support ==========
    attempt_number INTEGER DEFAULT 1,
    rule_version INTEGER DEFAULT 1,  -- For grandfathering rules
    duration_hours INTEGER DEFAULT 24,
    qr_code_url VARCHAR(500),

    -- ========== Timing ==========
    issued_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE,

    -- ========== Status ==========
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    -- ========== Security ==========
    signature TEXT NOT NULL,
    payload TEXT NOT NULL,

    -- ========== Usage Tracking ==========
    claimed_by UUID REFERENCES users(id),
    claimed_at TIMESTAMP WITH TIME ZONE,
    message VARCHAR(100),

    -- ========== Constraints ==========
    CONSTRAINT chk_tickets_status CHECK (status IN ('ACTIVE', 'USED', 'EXPIRED', 'CANCELLED')),
    CONSTRAINT chk_tickets_expiration CHECK (expires_at > issued_at)
);

-- ============================================================================
-- TICKETS TABLE - INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_tickets_owner_id ON tickets(owner_id);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON tickets(status);
CREATE INDEX IF NOT EXISTS idx_tickets_expires_at ON tickets(expires_at);
CREATE INDEX IF NOT EXISTS idx_tickets_claimed_by ON tickets(claimed_by);
CREATE INDEX IF NOT EXISTS idx_tickets_ticket_code ON tickets(ticket_code);
CREATE INDEX IF NOT EXISTS idx_tickets_attempt_number ON tickets(attempt_number);

-- Unique constraint: one active ticket per user
CREATE UNIQUE INDEX IF NOT EXISTS idx_tickets_one_active_per_user
    ON tickets(owner_id)
    WHERE status = 'ACTIVE';

COMMENT ON TABLE tickets IS 'Invitation tickets with expiration and 3-strike rule enforcement';
COMMENT ON COLUMN tickets.attempt_number IS 'Current attempt (1-3) for the 3-strike rule';
COMMENT ON COLUMN tickets.rule_version IS 'Chain rule version when ticket was created (for grandfathering)';

-- ============================================================================
-- ATTACHMENTS TABLE
-- Purpose: Track parent-child relationships in the chain
-- ============================================================================

CREATE TABLE IF NOT EXISTS attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID NOT NULL REFERENCES users(id),
    child_id UUID NOT NULL REFERENCES users(id),
    ticket_id UUID NOT NULL REFERENCES tickets(id),
    attached_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    -- Each child can only have one parent, and each parent-child pair is unique
    UNIQUE(parent_id, child_id),
    UNIQUE(child_id)
);

CREATE INDEX IF NOT EXISTS idx_attachments_parent_id ON attachments(parent_id);
CREATE INDEX IF NOT EXISTS idx_attachments_child_id ON attachments(child_id);
CREATE INDEX IF NOT EXISTS idx_attachments_ticket_id ON attachments(ticket_id);
CREATE INDEX IF NOT EXISTS idx_attachments_attached_at ON attachments(attached_at);

COMMENT ON TABLE attachments IS 'Parent-child relationships in the chain (who invited whom)';

-- ============================================================================
-- INVITATIONS TABLE (V2 - Chain Mechanics)
-- Purpose: Track invitation history using user IDs (not positions)
-- ============================================================================

CREATE TABLE IF NOT EXISTS invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- User IDs instead of positions (different from original V2)
    parent_id UUID NOT NULL REFERENCES users(id),
    child_id UUID NOT NULL UNIQUE REFERENCES users(id),

    -- Ticket used for this invitation
    ticket_id UUID NOT NULL REFERENCES tickets(id),

    -- Status tracking
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    invited_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    accepted_at TIMESTAMP WITH TIME ZONE,

    -- Constraints
    CONSTRAINT chk_invitations_status CHECK (status IN ('ACTIVE', 'REMOVED', 'REVERTED'))
);

CREATE INDEX IF NOT EXISTS idx_invitations_parent_id ON invitations(parent_id);
CREATE INDEX IF NOT EXISTS idx_invitations_child_id ON invitations(child_id);
CREATE INDEX IF NOT EXISTS idx_invitations_ticket_id ON invitations(ticket_id);
CREATE INDEX IF NOT EXISTS idx_invitations_status ON invitations(status);

COMMENT ON TABLE invitations IS 'Invitation history tracking (uses UUIDs, not positions)';
COMMENT ON COLUMN invitations.status IS 'ACTIVE: valid, REMOVED: invitee removed, REVERTED: chain reverted past this point';

-- ============================================================================
-- CHAIN RULES TABLE (V2 - Dynamic Rule Management)
-- Purpose: Store versioned game rules that can change over time
-- ============================================================================

CREATE TABLE IF NOT EXISTS chain_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Versioning
    version INTEGER NOT NULL UNIQUE,

    -- Rule configuration
    ticket_duration_hours INTEGER NOT NULL DEFAULT 24,
    max_attempts INTEGER NOT NULL DEFAULT 3,
    visibility_range INTEGER NOT NULL DEFAULT 1,
    seed_unlimited_time BOOLEAN NOT NULL DEFAULT TRUE,
    reactivation_timeout_hours INTEGER NOT NULL DEFAULT 24,

    -- Additional rules as JSON
    additional_rules JSONB,

    -- Scheduling
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    effective_from TIMESTAMP WITH TIME ZONE NOT NULL,
    applied_at TIMESTAMP WITH TIME ZONE,

    -- Deployment mode
    deployment_mode VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED',

    -- Notes
    change_description TEXT,

    CONSTRAINT chk_chain_rules_deployment CHECK (deployment_mode IN ('INSTANT', 'SCHEDULED'))
);

CREATE INDEX IF NOT EXISTS idx_chain_rules_version ON chain_rules(version);
CREATE INDEX IF NOT EXISTS idx_chain_rules_effective_from ON chain_rules(effective_from);
CREATE INDEX IF NOT EXISTS idx_chain_rules_applied_at ON chain_rules(applied_at);

COMMENT ON TABLE chain_rules IS 'Versioned game rules allowing dynamic rule changes over time';
COMMENT ON COLUMN chain_rules.version IS 'Unique version number (monotonically increasing)';
COMMENT ON COLUMN chain_rules.deployment_mode IS 'INSTANT: applied immediately, SCHEDULED: applied at effective_from';

-- ============================================================================
-- BADGES TABLE (V2 - Badge Definitions)
-- Purpose: Predefined badges that users can earn
-- ============================================================================

CREATE TABLE IF NOT EXISTS badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    badge_type VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    icon VARCHAR(10) NOT NULL,
    description TEXT,

    CONSTRAINT chk_badges_type CHECK (badge_type IN (
        'chain_savior',
        'chain_guardian',
        'chain_legend'
    ))
);

COMMENT ON TABLE badges IS 'Predefined badge definitions';

-- ============================================================================
-- USER BADGES TABLE (V2 - Badge Awards)
-- Purpose: Track which badges users have earned
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_position INTEGER NOT NULL,
    badge_type VARCHAR(50) NOT NULL REFERENCES badges(badge_type),
    earned_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    -- Context data (e.g., how many removed, collapse depth)
    context JSONB,

    -- Each user can only earn each badge once
    UNIQUE(user_position, badge_type)
);

CREATE INDEX IF NOT EXISTS idx_user_badges_user_pos ON user_badges(user_position);
CREATE INDEX IF NOT EXISTS idx_user_badges_badge_type ON user_badges(badge_type);
CREATE INDEX IF NOT EXISTS idx_user_badges_earned_at ON user_badges(earned_at);

COMMENT ON TABLE user_badges IS 'Badges earned by users (tracks by position number)';
COMMENT ON COLUMN user_badges.context IS 'JSON context about how badge was earned';

-- ============================================================================
-- NOTIFICATIONS TABLE (V2 - User Notifications)
-- Purpose: Store in-app and push notifications for users
-- ============================================================================

CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Recipient
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Content
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,

    -- Channels
    sent_via_push BOOLEAN DEFAULT FALSE,
    sent_via_email BOOLEAN DEFAULT FALSE,

    -- Action deep link
    action_url VARCHAR(500),

    -- Status
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    sent_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,

    -- Priority
    priority VARCHAR(20) NOT NULL DEFAULT 'NORMAL',

    -- Additional data
    metadata JSONB,

    CONSTRAINT chk_notifications_priority CHECK (priority IN ('CRITICAL', 'IMPORTANT', 'NORMAL', 'LOW')),
    CONSTRAINT chk_notifications_type CHECK (notification_type IN (
        'BECAME_TIP',
        'TICKET_EXPIRING_12H',
        'TICKET_EXPIRING_1H',
        'TICKET_EXPIRED',
        'INVITEE_JOINED',
        'INVITEE_FAILED',
        'REMOVED',
        'BADGE_EARNED',
        'RULE_CHANGE_ANNOUNCED',
        'RULE_CHANGE_REMINDER',
        'RULE_CHANGE_APPLIED',
        'MILESTONE_REACHED',
        'DAILY_SUMMARY'
    ))
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(notification_type);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_read_at ON notifications(read_at);
CREATE INDEX IF NOT EXISTS idx_notifications_priority ON notifications(priority);

COMMENT ON TABLE notifications IS 'User notifications with multi-channel support (push, email, in-app)';

-- ============================================================================
-- DEVICE TOKENS TABLE (V2 - Push Notifications)
-- Purpose: Store device tokens for push notifications
-- ============================================================================

CREATE TABLE IF NOT EXISTS device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(255) NOT NULL,
    platform VARCHAR(20) NOT NULL,
    push_token TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    revoked_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT chk_device_tokens_platform CHECK (platform IN ('ios', 'android', 'web')),
    UNIQUE(user_id, device_id)
);

CREATE INDEX IF NOT EXISTS idx_device_tokens_user_id ON device_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_device_tokens_device_id ON device_tokens(device_id);
CREATE INDEX IF NOT EXISTS idx_device_tokens_platform ON device_tokens(platform);

COMMENT ON TABLE device_tokens IS 'Device tokens for push notifications (FCM, APNs)';

-- ============================================================================
-- COUNTRY CHANGE EVENTS TABLE (V2 - FR-7.1)
-- Purpose: Define time windows when users can change their country
-- ============================================================================

CREATE TABLE IF NOT EXISTS country_change_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_name VARCHAR(100) NOT NULL,
    description TEXT,
    enabled_at TIMESTAMP WITH TIME ZONE NOT NULL,
    disabled_at TIMESTAMP WITH TIME ZONE NOT NULL,
    applies_to VARCHAR(20) NOT NULL DEFAULT 'all',
    allowed_countries TEXT[], -- NULL means all countries allowed
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_country_events_applies CHECK (applies_to IN ('all', 'specific_users')),
    CONSTRAINT chk_country_events_dates CHECK (disabled_at > enabled_at)
);

CREATE INDEX IF NOT EXISTS idx_country_change_events_enabled_at ON country_change_events(enabled_at);
CREATE INDEX IF NOT EXISTS idx_country_change_events_disabled_at ON country_change_events(disabled_at);

COMMENT ON TABLE country_change_events IS 'Admin-defined windows when users can change their country';

-- ============================================================================
-- AUDIT LOG TABLE (V2 - FR-8.x)
-- Purpose: Comprehensive audit trail for compliance and debugging
-- ============================================================================

CREATE TABLE IF NOT EXISTS audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Actor
    actor_id UUID REFERENCES users(id),
    actor_type VARCHAR(20) NOT NULL DEFAULT 'user',

    -- Action
    action_type VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50),
    entity_id UUID,

    -- Details
    description TEXT NOT NULL,
    metadata JSONB,

    -- Context
    ip_address VARCHAR(45),
    user_agent TEXT,

    -- Timing
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_audit_log_actor_type CHECK (actor_type IN ('user', 'admin', 'system'))
);

CREATE INDEX IF NOT EXISTS idx_audit_log_actor_id ON audit_log(actor_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_action_type ON audit_log(action_type);
CREATE INDEX IF NOT EXISTS idx_audit_log_entity ON audit_log(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_created_at ON audit_log(created_at);

COMMENT ON TABLE audit_log IS 'System-wide audit trail for security and compliance';

-- ============================================================================
-- AUTHENTICATION SESSIONS TABLE (V1 - JWT Refresh Tokens)
-- Purpose: Manage JWT refresh token lifecycle
-- ============================================================================

CREATE TABLE IF NOT EXISTS auth_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    refresh_token VARCHAR(500) NOT NULL UNIQUE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_auth_sessions_user_id ON auth_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_auth_sessions_refresh_token ON auth_sessions(refresh_token);
CREATE INDEX IF NOT EXISTS idx_auth_sessions_expires_at ON auth_sessions(expires_at);

COMMENT ON TABLE auth_sessions IS 'JWT refresh tokens with session management';

-- ============================================================================
-- PASSWORD RESET TOKENS TABLE (V1)
-- Purpose: Temporary tokens for password recovery
-- ============================================================================

CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_user_id ON password_reset_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_token ON password_reset_tokens(token);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_expires_at ON password_reset_tokens(expires_at);

COMMENT ON TABLE password_reset_tokens IS 'One-time tokens for password reset flow';

-- ============================================================================
-- MAGIC LINK TOKENS TABLE (V1)
-- Purpose: Passwordless authentication via email magic links
-- ============================================================================

CREATE TABLE IF NOT EXISTS magic_link_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_magic_link_tokens_email ON magic_link_tokens(email);
CREATE INDEX IF NOT EXISTS idx_magic_link_tokens_token ON magic_link_tokens(token);
CREATE INDEX IF NOT EXISTS idx_magic_link_tokens_expires_at ON magic_link_tokens(expires_at);

COMMENT ON TABLE magic_link_tokens IS 'One-time magic links for passwordless login';

-- ============================================================================
-- EMAIL VERIFICATION TOKENS TABLE (V1)
-- Purpose: Verify user email addresses
-- ============================================================================

CREATE TABLE IF NOT EXISTS email_verification_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    verified_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_email_verification_tokens_user_id ON email_verification_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_email_verification_tokens_token ON email_verification_tokens(token);
CREATE INDEX IF NOT EXISTS idx_email_verification_tokens_expires_at ON email_verification_tokens(expires_at);

COMMENT ON TABLE email_verification_tokens IS 'Tokens for email verification flow';

-- ============================================================================
-- SEED DATA
-- ============================================================================

-- Insert default chain rule (version 1)
INSERT INTO chain_rules (
    version,
    ticket_duration_hours,
    max_attempts,
    visibility_range,
    seed_unlimited_time,
    reactivation_timeout_hours,
    effective_from,
    applied_at,
    deployment_mode,
    change_description
) VALUES (
    1,
    24,
    3,
    1,
    TRUE,
    24,
    NOW(),
    NOW(),
    'INSTANT',
    'Initial rule set'
) ON CONFLICT (version) DO NOTHING;

-- Insert predefined badges
INSERT INTO badges (badge_type, name, icon, description) VALUES
    ('chain_savior', 'Chain Savior', '🦸', 'Successfully attached someone after your invitee was removed'),
    ('chain_guardian', 'Chain Guardian', '🛡️', 'Saved chain after 5+ consecutive removals'),
    ('chain_legend', 'Chain Legend', '⭐', 'Saved chain after 10+ consecutive removals')
ON CONFLICT (badge_type) DO NOTHING;

-- Insert seed user (The Seeder)
INSERT INTO users (
    id,
    chain_key,
    display_name,
    position,
    parent_id,
    belongs_to,
    status,
    username,
    password_hash
) VALUES (
    'a0000000-0000-0000-0000-000000000001'::UUID,
    'SEED00000001',
    'The Seeder',
    1,
    NULL,
    'US',
    'seed',
    'alpaslan',
    '$2a$10$/0wR9/haE0/pMqSV5azSuOMV89edvBKATy3g/IYTW25OCdalTeAuO'  -- bcrypt hash of "alpaslan"
) ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '======================================================================';
    RAISE NOTICE 'V1 Consolidated Migration Complete: The Chain Schema';
    RAISE NOTICE '======================================================================';
    RAISE NOTICE 'Tables Created (17 total):';
    RAISE NOTICE '  Core: users, tickets, attachments, invitations';
    RAISE NOTICE '  Rules & Badges: chain_rules, badges, user_badges';
    RAISE NOTICE '  Notifications: notifications, device_tokens';
    RAISE NOTICE '  Admin: country_change_events, audit_log';
    RAISE NOTICE '  Auth: auth_sessions, password_reset_tokens, magic_link_tokens, email_verification_tokens';
    RAISE NOTICE '';
    RAISE NOTICE 'Features:';
    RAISE NOTICE '  ✓ Username/Password authentication (required)';
    RAISE NOTICE '  ✓ Social auth support (Apple, Google) - optional';
    RAISE NOTICE '  ✓ Chain mechanics with 3-strike rule';
    RAISE NOTICE '  ✓ Dynamic rule management';
    RAISE NOTICE '  ✓ Badge system';
    RAISE NOTICE '  ✓ Multi-channel notifications';
    RAISE NOTICE '  ✓ Country tracking with change events';
    RAISE NOTICE '  ✓ Comprehensive audit logging';
    RAISE NOTICE '';
    RAISE NOTICE 'Seed Data:';
    RAISE NOTICE '  ✓ Default chain rule (version 1)';
    RAISE NOTICE '  ✓ Predefined badges (chain_savior, chain_guardian, chain_legend)';
    RAISE NOTICE '  ✓ Seed user: alpaslan (position 1)';
    RAISE NOTICE '======================================================================';
END $$;
