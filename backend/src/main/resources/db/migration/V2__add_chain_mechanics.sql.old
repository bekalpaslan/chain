-- V2: Add Chain Mechanics - Invitations, Rules, Badges, Notifications
-- This migration adds support for:
-- - Invitation tracking (inviter/invitee relationships)
-- - Chain rules management (dynamic configuration)
-- - Badge system
-- - Notification system

-- ============================================================================
-- INVITATIONS TABLE (FR-3.x)
-- ============================================================================
-- Tracks invitation relationships separate from user parent/child

CREATE TABLE IF NOT EXISTS invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Positions (not user IDs, to preserve history)
    inviter_position INTEGER NOT NULL,
    invitee_position INTEGER NOT NULL,

    -- Ticket used for this invitation
    ticket_id UUID NOT NULL REFERENCES tickets(id),

    -- Status tracking
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    invited_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    accepted_at TIMESTAMP WITH TIME ZONE,

    -- Constraints
    CONSTRAINT chk_invitations_status CHECK (status IN ('active', 'removed', 'reverted')),
    CONSTRAINT chk_invitations_positions CHECK (invitee_position > inviter_position),

    -- Each invitee can only be invited once
    UNIQUE(invitee_position)
);

CREATE INDEX IF NOT EXISTS idx_invitations_inviter_pos ON invitations(inviter_position);
CREATE INDEX IF NOT EXISTS idx_invitations_invitee_pos ON invitations(invitee_position);
CREATE INDEX IF NOT EXISTS idx_invitations_ticket_id ON invitations(ticket_id);
CREATE INDEX IF NOT EXISTS idx_invitations_status ON invitations(status);

-- ============================================================================
-- CHAIN RULES TABLE (FR-6.x)
-- ============================================================================
-- Dynamic rule management system

CREATE TABLE IF NOT EXISTS chain_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Versioning
    version INTEGER NOT NULL UNIQUE,

    -- Rule configuration (stored as JSONB for flexibility)
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
    deployment_mode VARCHAR(20) NOT NULL DEFAULT 'scheduled',

    -- Notes
    change_description TEXT,

    CONSTRAINT chk_chain_rules_deployment CHECK (deployment_mode IN ('instant', 'scheduled'))
);

CREATE INDEX IF NOT EXISTS idx_chain_rules_version ON chain_rules(version);
CREATE INDEX IF NOT EXISTS idx_chain_rules_effective_from ON chain_rules(effective_from);
CREATE INDEX IF NOT EXISTS idx_chain_rules_applied_at ON chain_rules(applied_at);

-- Insert default rule (version 1)
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
    'instant',
    'Initial rule set'
) ON CONFLICT (version) DO NOTHING;

-- ============================================================================
-- BADGES TABLE (FR-3.6)
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

-- Insert predefined badges
INSERT INTO badges (badge_type, name, icon, description) VALUES
    ('chain_savior', 'Chain Savior', '🦸', 'Successfully attached someone after your invitee was removed'),
    ('chain_guardian', 'Chain Guardian', '🛡️', 'Saved chain after 5+ consecutive removals'),
    ('chain_legend', 'Chain Legend', '⭐', 'Saved chain after 10+ consecutive removals')
ON CONFLICT (badge_type) DO NOTHING;

-- ============================================================================
-- USER BADGES TABLE (FR-3.6)
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

-- ============================================================================
-- NOTIFICATIONS TABLE (FR-5.x)
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
    priority VARCHAR(20) NOT NULL DEFAULT 'normal',

    -- Additional data
    metadata JSONB,

    CONSTRAINT chk_notifications_priority CHECK (priority IN ('critical', 'important', 'normal', 'low')),
    CONSTRAINT chk_notifications_type CHECK (notification_type IN (
        'became_tip',
        'ticket_expiring_12h',
        'ticket_expiring_1h',
        'ticket_expired',
        'invitee_joined',
        'invitee_failed',
        'removed',
        'badge_earned',
        'rule_change_announced',
        'rule_change_reminder',
        'rule_change_applied',
        'milestone_reached',
        'daily_summary'
    ))
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(notification_type);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_read_at ON notifications(read_at);
CREATE INDEX IF NOT EXISTS idx_notifications_priority ON notifications(priority);

-- ============================================================================
-- USER TABLE UPDATES
-- ============================================================================

-- Add new columns to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS inviter_position INTEGER;
ALTER TABLE users ADD COLUMN IF NOT EXISTS invitee_position INTEGER;
ALTER TABLE users ADD COLUMN IF NOT EXISTS country_locked BOOLEAN DEFAULT TRUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS country_changed_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS display_name_changed_at TIMESTAMP WITH TIME ZONE;

-- Add indexes for new columns
CREATE INDEX IF NOT EXISTS idx_users_inviter_position ON users(inviter_position);
CREATE INDEX IF NOT EXISTS idx_users_invitee_position ON users(invitee_position);

-- Add comment for clarity
COMMENT ON COLUMN users.inviter_position IS 'Position of the user who invited this user (±1 visibility)';
COMMENT ON COLUMN users.invitee_position IS 'Position of the user this user invited (±1 visibility)';
COMMENT ON COLUMN users.country_locked IS 'Whether country field is locked (can be temporarily unlocked by admin)';

-- ============================================================================
-- DEVICE TOKENS TABLE (for push notifications)
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

-- ============================================================================
-- COUNTRY CHANGE EVENTS TABLE (FR-7.1)
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

-- ============================================================================
-- AUDIT LOG TABLE (FR-8.x)
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

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE 'V2 Migration Complete: Chain Mechanics Added';
    RAISE NOTICE 'New Tables: invitations, chain_rules, badges, user_badges, notifications, device_tokens, country_change_events, audit_log';
    RAISE NOTICE 'Updated: users table with inviter/invitee positions and country locking';
    RAISE NOTICE 'Features: Full chain mechanics, rules, badges, notifications';
END $$;
