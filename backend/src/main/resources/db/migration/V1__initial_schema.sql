-- V1: Initial Schema - The Chain Application
-- This is the consolidated first migration including all base tables and authentication

-- ============================================================================
-- USERS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS users (
    -- Core identity
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chain_key VARCHAR(32) UNIQUE NOT NULL,
    display_name VARCHAR(50) NOT NULL,
    position INTEGER UNIQUE NOT NULL,

    -- Relationships
    parent_id UUID REFERENCES users(id),

    -- Device tracking (nullable - users may register without device info)
    device_id VARCHAR(255),
    device_fingerprint VARCHAR(255),

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,

    -- Authentication fields
    email VARCHAR(255),
    email_verified BOOLEAN DEFAULT FALSE,
    password_hash VARCHAR(255),

    -- Social authentication
    apple_user_id VARCHAR(255),
    google_user_id VARCHAR(255),

    -- User profile
    real_name VARCHAR(100),
    is_guest BOOLEAN DEFAULT FALSE,
    avatar_emoji VARCHAR(10) DEFAULT '👤',
    belongs_to VARCHAR(2),  -- ISO 3166-1 alpha-2 country code

    -- Status tracking
    status VARCHAR(20) DEFAULT 'active',
    removal_reason VARCHAR(50),
    removed_at TIMESTAMP WITH TIME ZONE,

    -- Activity tracking
    last_active_at TIMESTAMP WITH TIME ZONE,
    wasted_tickets_count INTEGER DEFAULT 0,
    total_tickets_generated INTEGER DEFAULT 0
);

-- ============================================================================
-- USERS TABLE - INDEXES
-- ============================================================================

-- Core indexes
CREATE INDEX IF NOT EXISTS idx_users_chain_key ON users(chain_key);
CREATE INDEX IF NOT EXISTS idx_users_parent_id ON users(parent_id);
CREATE INDEX IF NOT EXISTS idx_users_position ON users(position);
CREATE INDEX IF NOT EXISTS idx_users_device_id ON users(device_id);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- Authentication indexes (unique where not null for optional auth methods)
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
-- TICKETS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS tickets (
    -- Core identity
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Ticket metadata
    ticket_code VARCHAR(50),  -- For QR/link sharing
    next_position INTEGER,    -- What position the invitee will receive

    -- 3-strike rule support
    attempt_number INTEGER DEFAULT 1,
    rule_version INTEGER DEFAULT 1,  -- For grandfathering rules

    -- Timing
    issued_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,

    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    -- Security
    signature TEXT NOT NULL,
    payload TEXT NOT NULL,

    -- Usage tracking
    claimed_by UUID REFERENCES users(id),
    claimed_at TIMESTAMP WITH TIME ZONE,
    message VARCHAR(100),

    -- Constraints
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

-- Unique constraint: one active ticket per user
CREATE UNIQUE INDEX IF NOT EXISTS idx_tickets_one_active_per_user
    ON tickets(owner_id)
    WHERE status = 'ACTIVE';

-- ============================================================================
-- ATTACHMENTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID NOT NULL REFERENCES users(id),
    child_id UUID NOT NULL REFERENCES users(id),
    ticket_id UUID NOT NULL REFERENCES tickets(id),
    attached_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(parent_id, child_id),
    UNIQUE(child_id)
);

-- ============================================================================
-- ATTACHMENTS TABLE - INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_attachments_parent_id ON attachments(parent_id);
CREATE INDEX IF NOT EXISTS idx_attachments_child_id ON attachments(child_id);
CREATE INDEX IF NOT EXISTS idx_attachments_ticket_id ON attachments(ticket_id);
CREATE INDEX IF NOT EXISTS idx_attachments_attached_at ON attachments(attached_at);

-- ============================================================================
-- AUTHENTICATION SESSIONS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS auth_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    refresh_token VARCHAR(500) NOT NULL,
    device_id VARCHAR(255),
    device_fingerprint VARCHAR(255),
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(refresh_token)
);

CREATE INDEX IF NOT EXISTS idx_auth_sessions_user_id ON auth_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_auth_sessions_refresh_token ON auth_sessions(refresh_token);
CREATE INDEX IF NOT EXISTS idx_auth_sessions_expires_at ON auth_sessions(expires_at);

-- ============================================================================
-- PASSWORD RESET TOKENS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(token)
);

CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_user_id ON password_reset_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_token ON password_reset_tokens(token);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_expires_at ON password_reset_tokens(expires_at);

-- ============================================================================
-- MAGIC LINK TOKENS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS magic_link_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    token VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(token)
);

CREATE INDEX IF NOT EXISTS idx_magic_link_tokens_email ON magic_link_tokens(email);
CREATE INDEX IF NOT EXISTS idx_magic_link_tokens_token ON magic_link_tokens(token);
CREATE INDEX IF NOT EXISTS idx_magic_link_tokens_expires_at ON magic_link_tokens(expires_at);

-- ============================================================================
-- EMAIL VERIFICATION TOKENS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS email_verification_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    verified_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(token)
);

CREATE INDEX IF NOT EXISTS idx_email_verification_tokens_user_id ON email_verification_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_email_verification_tokens_token ON email_verification_tokens(token);
CREATE INDEX IF NOT EXISTS idx_email_verification_tokens_expires_at ON email_verification_tokens(expires_at);

-- ============================================================================
-- SEED DATA
-- ============================================================================

-- Insert seed user (The Seeder)
INSERT INTO users (
    id,
    chain_key,
    display_name,
    position,
    parent_id,
    device_id,
    device_fingerprint,
    belongs_to,
    status
) VALUES (
    'a0000000-0000-0000-0000-000000000001'::UUID,
    'SEED00000001',
    'The Seeder',
    1,
    NULL,
    'seed-device',
    'seed-fingerprint',
    'US',
    'seed'
) ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE 'V1 Migration Complete: Initial Schema Created';
    RAISE NOTICE 'Tables: users, tickets, attachments, auth_sessions, password_reset_tokens, magic_link_tokens, email_verification_tokens';
    RAISE NOTICE 'Authentication: Email/Password with social auth support (Apple, Google)';
    RAISE NOTICE 'Country tracking: belongs_to field (ISO 3166-1 alpha-2)';
    RAISE NOTICE 'Seed user: The Seeder (position 1)';
END $$;
