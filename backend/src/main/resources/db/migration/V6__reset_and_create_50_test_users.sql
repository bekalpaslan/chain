-- V6: Reset all data and create 50 test users with chain structure
-- Description: Removes all existing test data and creates a fresh set of 50 test users

-- Step 1: Clean all existing data
TRUNCATE TABLE notifications CASCADE;
TRUNCATE TABLE tickets CASCADE;
TRUNCATE TABLE users CASCADE;

-- Step 2: Create 50 test users with proper chain structure
DO $$
DECLARE
    i INTEGER;
    user_uuid UUID;
    parent_uuid UUID;
    join_time TIMESTAMP;
    ticket_uuid UUID;
    bcrypt_hash VARCHAR(255) := '$2a$10$N9qo8uLOickgx2ZMRZoMye7aQ3Jvp7n/VKxR4YmJZqKhJvFXg9vKi'; -- password123
BEGIN
    -- Create first user (genesis)
    user_uuid := 'a0000000-0000-0000-0000-000000000001'::UUID;
    join_time := CURRENT_TIMESTAMP - INTERVAL '250 hours';

    INSERT INTO users (
        id, username, email, password_hash, chain_key, display_name,
        position, parent_id, is_admin, status, created_at, updated_at,
        email_verified, is_guest, avatar_emoji, belongs_to,
        last_active_at, wasted_tickets_count, total_tickets_generated
    ) VALUES (
        user_uuid,
        'testuser_01',
        'testuser01@example.com',
        bcrypt_hash,
        'SEED00000001',
        'Test User 01',
        1,
        NULL,
        true,
        'active',
        join_time,
        join_time,
        true,
        false,
        '🎯',
        'US',
        join_time,
        0,
        0
    );

    -- Create remaining 49 users
    FOR i IN 2..50 LOOP
        -- Calculate parent (previous user)
        parent_uuid := ('a0000000-0000-0000-0000-00000000' || LPAD((i-1)::text, 4, '0'))::UUID;
        user_uuid := ('a0000000-0000-0000-0000-00000000' || LPAD(i::text, 4, '0'))::UUID;
        join_time := CURRENT_TIMESTAMP - INTERVAL '250 hours' + (INTERVAL '5 hours' * (i - 1));

        -- Insert user
        INSERT INTO users (
            id, username, email, password_hash, chain_key, display_name,
            position, parent_id, is_admin, status, created_at, updated_at,
            email_verified, is_guest, avatar_emoji, belongs_to,
            last_active_at, wasted_tickets_count, total_tickets_generated
        ) VALUES (
            user_uuid,
            'testuser_' || LPAD(i::text, 2, '0'),
            'testuser' || LPAD(i::text, 2, '0') || '@example.com',
            bcrypt_hash,
            'USER' || LPAD(i::text, 8, '0'),
            'Test User ' || LPAD(i::text, 2, '0'),
            i,
            parent_uuid,
            false,
            'active',
            join_time,
            join_time,
            true,
            false,
            CASE
                WHEN i % 5 = 0 THEN '🚀'
                WHEN i % 5 = 1 THEN '🎯'
                WHEN i % 5 = 2 THEN '💎'
                WHEN i % 5 = 3 THEN '🔥'
                ELSE '⚡'
            END,
            'US',
            join_time,
            0,
            0
        );
    END LOOP;

    -- Step 3: Create tickets for users who invited others (positions 1-49)
    FOR i IN 1..49 LOOP
        user_uuid := ('a0000000-0000-0000-0000-00000000' || LPAD(i::text, 4, '0'))::UUID;
        ticket_uuid := ('b0000000-0000-0000-0000-00000000' || LPAD(i::text, 4, '0'))::UUID;
        join_time := CURRENT_TIMESTAMP - INTERVAL '250 hours' + (INTERVAL '5 hours' * (i - 1));

        INSERT INTO tickets (
            id, owner_id, ticket_code, next_position, status,
            issued_at, expires_at, used_at,
            claimed_by, claimed_at,
            signature, payload
        ) VALUES (
            ticket_uuid,
            user_uuid,
            'TICKET' || LPAD(i::text, 6, '0'),
            i + 1,
            'USED',
            join_time + INTERVAL '1 hour',
            join_time + INTERVAL '25 hours',
            join_time + INTERVAL '5 hours',
            ('a0000000-0000-0000-0000-00000000' || LPAD((i+1)::text, 4, '0'))::UUID,
            join_time + INTERVAL '5 hours',
            'test_signature_' || LPAD(i::text, 6, '0'),
            '{"position": ' || (i + 1) || ', "test": true, "created_for_testing": "V6_migration"}'
        );
    END LOOP;

    -- Step 4: Create an active ticket for the last user (position 50) to generate invites
    INSERT INTO tickets (
        id, owner_id, ticket_code, next_position, status,
        issued_at, expires_at,
        signature, payload
    ) VALUES (
        'b0000000-0000-0000-0000-000000000050'::UUID,
        'a0000000-0000-0000-0000-000000000050'::UUID,
        'TICKET000050',
        51,
        'ACTIVE',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP + INTERVAL '24 hours',
        'test_signature_000050',
        '{"position": 51, "test": true, "created_for_testing": "V6_migration"}'
    );

    RAISE NOTICE 'Successfully created 50 test users with chain structure';
END $$;

-- Step 5: Verify the data
DO $$
DECLARE
    user_count INTEGER;
    ticket_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count FROM users;
    SELECT COUNT(*) INTO ticket_count FROM tickets;

    RAISE NOTICE 'Created % users and % tickets', user_count, ticket_count;

    IF user_count != 50 THEN
        RAISE EXCEPTION 'Expected 50 users but found %', user_count;
    END IF;
END $$;