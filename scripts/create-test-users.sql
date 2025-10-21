-- Script to create 10 consecutive test users following the chain invitation system
-- Each user joins 5 hours after their parent
-- Username and password are the same for each user

-- User #2: Position 2 (invited by seed user)
INSERT INTO users (
    id,
    chain_key,
    display_name,
    position,
    parent_id,
    username,
    password_hash,
    email,
    email_verified,
    belongs_to,
    status,
    created_at,
    updated_at,
    is_admin,
    wasted_tickets_count,
    total_tickets_generated
) VALUES (
    'b0000000-0000-0000-0000-000000000002'::UUID,
    'USER00000002',
    'Alice Johnson',
    2,
    'a0000000-0000-0000-0000-000000000001'::UUID,
    'alice',
    '$2a$10$/0wR9/haE0/pMqSV5azSuOMV89edvBKATy3g/IYTW25OCdalTeAuO', -- alice
    'alice@example.com',
    true,
    'US',
    'active',
    NOW() - INTERVAL '45 hours',
    NOW() - INTERVAL '45 hours',
    false,
    0,
    1
);

-- User #3: Position 3
INSERT INTO users (
    id,
    chain_key,
    display_name,
    position,
    parent_id,
    username,
    password_hash,
    email,
    email_verified,
    belongs_to,
    status,
    created_at,
    updated_at,
    is_admin,
    wasted_tickets_count,
    total_tickets_generated
) VALUES (
    'b0000000-0000-0000-0000-000000000003'::UUID,
    'USER00000003',
    'Bob Smith',
    3,
    'b0000000-0000-0000-0000-000000000002'::UUID,
    'bob',
    '$2a$10$/0wR9/haE0/pMqSV5azSuOMV89edvBKATy3g/IYTW25OCdalTeAuO', -- bob
    'bob@example.com',
    true,
    'US',
    'active',
    NOW() - INTERVAL '40 hours',
    NOW() - INTERVAL '40 hours',
    false,
    0,
    1
);

-- User #4: Position 4
INSERT INTO users (
    id,
    chain_key,
    display_name,
    position,
    parent_id,
    username,
    password_hash,
    email,
    email_verified,
    belongs_to,
    status,
    created_at,
    updated_at,
    is_admin,
    wasted_tickets_count,
    total_tickets_generated
) VALUES (
    'b0000000-0000-0000-0000-000000000004'::UUID,
    'USER00000004',
    'Carol White',
    4,
    'b0000000-0000-0000-0000-000000000003'::UUID,
    'carol',
    '$2a$10$/0wR9/haE0/pMqSV5azSuOMV89edvBKATy3g/IYTW25OCdalTeAuO', -- carol
    'carol@example.com',
    true,
    'GB',
    'active',
    NOW() - INTERVAL '35 hours',
    NOW() - INTERVAL '35 hours',
    false,
    0,
    1
);

-- User #5: Position 5
INSERT INTO users (
    id,
    chain_key,
    display_name,
    position,
    parent_id,
    username,
    password_hash,
    email,
    email_verified,
    belongs_to,
    status,
    created_at,
    updated_at,
    is_admin,
    wasted_tickets_count,
    total_tickets_generated
) VALUES (
    'b0000000-0000-0000-0000-000000000005'::UUID,
    'USER00000005',
    'David Brown',
    5,
    'b0000000-0000-0000-0000-000000000004'::UUID,
    'david',
    '$2a$10$/0wR9/haE0/pMqSV5azSuOMV89edvBKATy3g/IYTW25OCdalTeAuO', -- david
    'david@example.com',
    true,
    'CA',
    'active',
    NOW() - INTERVAL '30 hours',
    NOW() - INTERVAL '30 hours',
    false,
    0,
    1
);

-- User #6: Position 6
INSERT INTO users (
    id,
    chain_key,
    display_name,
    position,
    parent_id,
    username,
    password_hash,
    email,
    email_verified,
    belongs_to,
    status,
    created_at,
    updated_at,
    is_admin,
    wasted_tickets_count,
    total_tickets_generated
) VALUES (
    'b0000000-0000-0000-0000-000000000006'::UUID,
    'USER00000006',
    'Emma Davis',
    6,
    'b0000000-0000-0000-0000-000000000005'::UUID,
    'emma',
    '$2a$10$/0wR9/haE0/pMqSV5azSuOMV89edvBKATy3g/IYTW25OCdalTeAuO', -- emma
    'emma@example.com',
    true,
    'AU',
    'active',
    NOW() - INTERVAL '25 hours',
    NOW() - INTERVAL '25 hours',
    false,
    0,
    1
);

-- User #7: Position 7
INSERT INTO users (
    id,
    chain_key,
    display_name,
    position,
    parent_id,
    username,
    password_hash,
    email,
    email_verified,
    belongs_to,
    status,
    created_at,
    updated_at,
    is_admin,
    wasted_tickets_count,
    total_tickets_generated
) VALUES (
    'b0000000-0000-0000-0000-000000000007'::UUID,
    'USER00000007',
    'Frank Miller',
    7,
    'b0000000-0000-0000-0000-000000000006'::UUID,
    'frank',
    '$2a$10$/0wR9/haE0/pMqSV5azSuOMV89edvBKATy3g/IYTW25OCdalTeAuO', -- frank
    'frank@example.com',
    true,
    'DE',
    'active',
    NOW() - INTERVAL '20 hours',
    NOW() - INTERVAL '20 hours',
    false,
    0,
    1
);

-- User #8: Position 8
INSERT INTO users (
    id,
    chain_key,
    display_name,
    position,
    parent_id,
    username,
    password_hash,
    email,
    email_verified,
    belongs_to,
    status,
    created_at,
    updated_at,
    is_admin,
    wasted_tickets_count,
    total_tickets_generated
) VALUES (
    'b0000000-0000-0000-0000-000000000008'::UUID,
    'USER00000008',
    'Grace Wilson',
    8,
    'b0000000-0000-0000-0000-000000000007'::UUID,
    'grace',
    '$2a$10$/0wR9/haE0/pMqSV5azSuOMV89edvBKATy3g/IYTW25OCdalTeAuO', -- grace
    'grace@example.com',
    true,
    'FR',
    'active',
    NOW() - INTERVAL '15 hours',
    NOW() - INTERVAL '15 hours',
    false,
    0,
    1
);

-- User #9: Position 9
INSERT INTO users (
    id,
    chain_key,
    display_name,
    position,
    parent_id,
    username,
    password_hash,
    email,
    email_verified,
    belongs_to,
    status,
    created_at,
    updated_at,
    is_admin,
    wasted_tickets_count,
    total_tickets_generated
) VALUES (
    'b0000000-0000-0000-0000-000000000009'::UUID,
    'USER00000009',
    'Henry Taylor',
    9,
    'b0000000-0000-0000-0000-000000000008'::UUID,
    'henry',
    '$2a$10$/0wR9/haE0/pMqSV5azSuOMV89edvBKATy3g/IYTW25OCdalTeAuO', -- henry
    'henry@example.com',
    true,
    'IT',
    'active',
    NOW() - INTERVAL '10 hours',
    NOW() - INTERVAL '10 hours',
    false,
    0,
    1
);

-- User #10: Position 10
INSERT INTO users (
    id,
    chain_key,
    display_name,
    position,
    parent_id,
    username,
    password_hash,
    email,
    email_verified,
    belongs_to,
    status,
    created_at,
    updated_at,
    is_admin,
    wasted_tickets_count,
    total_tickets_generated
) VALUES (
    'b0000000-0000-0000-0000-000000000010'::UUID,
    'USER00000010',
    'Ivy Anderson',
    10,
    'b0000000-0000-0000-0000-000000000009'::UUID,
    'ivy',
    '$2a$10$/0wR9/haE0/pMqSV5azSuOMV89edvBKATy3g/IYTW25OCdalTeAuO', -- ivy
    'ivy@example.com',
    true,
    'ES',
    'active',
    NOW() - INTERVAL '5 hours',
    NOW() - INTERVAL '5 hours',
    false,
    0,
    1
);

-- User #11: Position 11 (most recent)
INSERT INTO users (
    id,
    chain_key,
    display_name,
    position,
    parent_id,
    username,
    password_hash,
    email,
    email_verified,
    belongs_to,
    status,
    created_at,
    updated_at,
    is_admin,
    wasted_tickets_count,
    total_tickets_generated
) VALUES (
    'b0000000-0000-0000-0000-000000000011'::UUID,
    'USER00000011',
    'Jack Roberts',
    11,
    'b0000000-0000-0000-0000-000000000010'::UUID,
    'jack',
    '$2a$10$/0wR9/haE0/pMqSV5azSuOMV89edvBKATy3g/IYTW25OCdalTeAuO', -- jack
    'jack@example.com',
    true,
    'NL',
    'active',
    NOW(),
    NOW(),
    false,
    0,
    0
);

-- Create attachments (parent-child relationships)
-- We need to create dummy tickets first for the attachments

-- Create tickets for each invitation
INSERT INTO tickets (id, owner_id, next_position, attempt_number, duration_hours, issued_at, expires_at, status, signature, payload)
SELECT
    gen_random_uuid(),
    parent_id,
    position,
    1,
    24,
    created_at - INTERVAL '1 hour',
    created_at + INTERVAL '23 hours',
    'USED',
    'dummy_signature_' || position,
    'dummy_payload_' || position
FROM users
WHERE position > 1 AND position <= 11;

-- Create attachments using the tickets
INSERT INTO attachments (id, parent_id, child_id, ticket_id, attached_at)
SELECT
    gen_random_uuid(),
    u.parent_id,
    u.id,
    t.id,
    u.created_at
FROM users u
JOIN tickets t ON t.owner_id = u.parent_id AND t.next_position = u.position
WHERE u.position > 1 AND u.position <= 11;

-- Create invitations
INSERT INTO invitations (id, parent_id, child_id, ticket_id, status, invited_at, accepted_at)
SELECT
    gen_random_uuid(),
    u.parent_id,
    u.id,
    t.id,
    'ACTIVE',
    u.created_at - INTERVAL '1 hour',
    u.created_at
FROM users u
JOIN tickets t ON t.owner_id = u.parent_id AND t.next_position = u.position
WHERE u.position > 1 AND u.position <= 11;

-- Summary
DO $$
DECLARE
    user_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count FROM users WHERE position > 1;

    RAISE NOTICE '=======================================================';
    RAISE NOTICE 'Test Users Created Successfully!';
    RAISE NOTICE '=======================================================';
    RAISE NOTICE 'Total users created: %', user_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Login credentials (username = password):';
    RAISE NOTICE '  Position #2:  alice   / alice';
    RAISE NOTICE '  Position #3:  bob     / bob';
    RAISE NOTICE '  Position #4:  carol   / carol';
    RAISE NOTICE '  Position #5:  david   / david';
    RAISE NOTICE '  Position #6:  emma    / emma';
    RAISE NOTICE '  Position #7:  frank   / frank';
    RAISE NOTICE '  Position #8:  grace   / grace';
    RAISE NOTICE '  Position #9:  henry   / henry';
    RAISE NOTICE '  Position #10: ivy     / ivy';
    RAISE NOTICE '  Position #11: jack    / jack';
    RAISE NOTICE '';
    RAISE NOTICE 'Each user joined 5 hours after their parent';
    RAISE NOTICE 'All users have email verified and status = active';
    RAISE NOTICE '=======================================================';
END $$;
