-- The Chain Database Schema

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chain_key VARCHAR(32) UNIQUE NOT NULL,
    display_name VARCHAR(50) NOT NULL,
    position INTEGER UNIQUE NOT NULL,
    parent_id UUID REFERENCES users(id),
    child_id UUID REFERENCES users(id),
    device_id VARCHAR(255) NOT NULL,
    device_fingerprint VARCHAR(255) NOT NULL,
    share_location BOOLEAN DEFAULT false,
    location_lat DECIMAL(9,6),
    location_lon DECIMAL(9,6),
    location_country VARCHAR(2),
    location_city VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_users_chain_key ON users(chain_key);
CREATE INDEX IF NOT EXISTS idx_users_parent_id ON users(parent_id);
CREATE INDEX IF NOT EXISTS idx_users_child_id ON users(child_id);
CREATE INDEX IF NOT EXISTS idx_users_position ON users(position);
CREATE INDEX IF NOT EXISTS idx_users_device_id ON users(device_id);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- Tickets table
CREATE TABLE IF NOT EXISTS tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    issued_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    signature TEXT NOT NULL,
    payload TEXT NOT NULL,
    claimed_by UUID REFERENCES users(id),
    claimed_at TIMESTAMP WITH TIME ZONE,
    message VARCHAR(100),
    CONSTRAINT chk_status CHECK (status IN ('ACTIVE', 'USED', 'EXPIRED', 'CANCELLED')),
    CONSTRAINT chk_expiration CHECK (expires_at > issued_at)
);

CREATE INDEX IF NOT EXISTS idx_tickets_owner_id ON tickets(owner_id);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON tickets(status);
CREATE INDEX IF NOT EXISTS idx_tickets_expires_at ON tickets(expires_at);
CREATE INDEX IF NOT EXISTS idx_tickets_claimed_by ON tickets(claimed_by);

-- Unique constraint: one active ticket per user
CREATE UNIQUE INDEX IF NOT EXISTS idx_tickets_one_active_per_user
    ON tickets(owner_id)
    WHERE status = 'ACTIVE';

-- Attachments table
CREATE TABLE IF NOT EXISTS attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID NOT NULL REFERENCES users(id),
    child_id UUID NOT NULL REFERENCES users(id),
    ticket_id UUID NOT NULL REFERENCES tickets(id),
    attached_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(parent_id, child_id),
    UNIQUE(child_id)
);

CREATE INDEX IF NOT EXISTS idx_attachments_parent_id ON attachments(parent_id);
CREATE INDEX IF NOT EXISTS idx_attachments_child_id ON attachments(child_id);
CREATE INDEX IF NOT EXISTS idx_attachments_ticket_id ON attachments(ticket_id);
CREATE INDEX IF NOT EXISTS idx_attachments_attached_at ON attachments(attached_at);

-- Insert seed user (The Seeder)
INSERT INTO users (
    id,
    chain_key,
    display_name,
    position,
    parent_id,
    device_id,
    device_fingerprint,
    location_country
) VALUES (
    'a0000000-0000-0000-0000-000000000001'::UUID,
    'SEED00000001',
    'The Seeder',
    1,
    NULL,
    'seed-device',
    'seed-fingerprint',
    'US'
) ON CONFLICT DO NOTHING;
