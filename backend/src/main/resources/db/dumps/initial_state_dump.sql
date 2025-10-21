--
-- PostgreSQL database dump
--

\restrict kAwQuuNI02obovnHC9BfeFK8g6clwAxPj97febUgFIpMgQVw4ovgcM2Lxs2bvJH

-- Dumped from database version 15.14
-- Dumped by pg_dump version 15.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_parent_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_badges DROP CONSTRAINT IF EXISTS user_badges_badge_type_fkey;
ALTER TABLE IF EXISTS ONLY public.tickets DROP CONSTRAINT IF EXISTS tickets_owner_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tickets DROP CONSTRAINT IF EXISTS tickets_claimed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.password_reset_tokens DROP CONSTRAINT IF EXISTS password_reset_tokens_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.notifications DROP CONSTRAINT IF EXISTS notifications_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.invitations DROP CONSTRAINT IF EXISTS invitations_ticket_id_fkey;
ALTER TABLE IF EXISTS ONLY public.invitations DROP CONSTRAINT IF EXISTS invitations_parent_id_fkey;
ALTER TABLE IF EXISTS ONLY public.invitations DROP CONSTRAINT IF EXISTS invitations_child_id_fkey;
ALTER TABLE IF EXISTS ONLY public.email_verification_tokens DROP CONSTRAINT IF EXISTS email_verification_tokens_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.device_tokens DROP CONSTRAINT IF EXISTS device_tokens_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.country_change_events DROP CONSTRAINT IF EXISTS country_change_events_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.chain_rules DROP CONSTRAINT IF EXISTS chain_rules_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.auth_sessions DROP CONSTRAINT IF EXISTS auth_sessions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.audit_log DROP CONSTRAINT IF EXISTS audit_log_actor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.attachments DROP CONSTRAINT IF EXISTS attachments_ticket_id_fkey;
ALTER TABLE IF EXISTS ONLY public.attachments DROP CONSTRAINT IF EXISTS attachments_parent_id_fkey;
ALTER TABLE IF EXISTS ONLY public.attachments DROP CONSTRAINT IF EXISTS attachments_child_id_fkey;
DROP INDEX IF EXISTS public.idx_users_username;
DROP INDEX IF EXISTS public.idx_users_status;
DROP INDEX IF EXISTS public.idx_users_removed_at;
DROP INDEX IF EXISTS public.idx_users_position;
DROP INDEX IF EXISTS public.idx_users_parent_id;
DROP INDEX IF EXISTS public.idx_users_last_active;
DROP INDEX IF EXISTS public.idx_users_is_admin;
DROP INDEX IF EXISTS public.idx_users_inviter_position;
DROP INDEX IF EXISTS public.idx_users_invitee_position;
DROP INDEX IF EXISTS public.idx_users_google_id;
DROP INDEX IF EXISTS public.idx_users_email;
DROP INDEX IF EXISTS public.idx_users_display_name_lower;
DROP INDEX IF EXISTS public.idx_users_created_at;
DROP INDEX IF EXISTS public.idx_users_chain_key;
DROP INDEX IF EXISTS public.idx_users_belongs_to;
DROP INDEX IF EXISTS public.idx_users_apple_id;
DROP INDEX IF EXISTS public.idx_user_badges_user_pos;
DROP INDEX IF EXISTS public.idx_user_badges_earned_at;
DROP INDEX IF EXISTS public.idx_user_badges_badge_type;
DROP INDEX IF EXISTS public.idx_tickets_ticket_code;
DROP INDEX IF EXISTS public.idx_tickets_status;
DROP INDEX IF EXISTS public.idx_tickets_owner_id;
DROP INDEX IF EXISTS public.idx_tickets_one_active_per_user;
DROP INDEX IF EXISTS public.idx_tickets_expires_at;
DROP INDEX IF EXISTS public.idx_tickets_claimed_by;
DROP INDEX IF EXISTS public.idx_tickets_attempt_number;
DROP INDEX IF EXISTS public.idx_password_reset_tokens_user_id;
DROP INDEX IF EXISTS public.idx_password_reset_tokens_token;
DROP INDEX IF EXISTS public.idx_password_reset_tokens_expires_at;
DROP INDEX IF EXISTS public.idx_notifications_user_id;
DROP INDEX IF EXISTS public.idx_notifications_type;
DROP INDEX IF EXISTS public.idx_notifications_read_at;
DROP INDEX IF EXISTS public.idx_notifications_priority;
DROP INDEX IF EXISTS public.idx_notifications_created_at;
DROP INDEX IF EXISTS public.idx_magic_link_tokens_token;
DROP INDEX IF EXISTS public.idx_magic_link_tokens_expires_at;
DROP INDEX IF EXISTS public.idx_magic_link_tokens_email;
DROP INDEX IF EXISTS public.idx_invitations_ticket_id;
DROP INDEX IF EXISTS public.idx_invitations_status;
DROP INDEX IF EXISTS public.idx_invitations_parent_id;
DROP INDEX IF EXISTS public.idx_invitations_child_id;
DROP INDEX IF EXISTS public.idx_email_verification_tokens_user_id;
DROP INDEX IF EXISTS public.idx_email_verification_tokens_token;
DROP INDEX IF EXISTS public.idx_email_verification_tokens_expires_at;
DROP INDEX IF EXISTS public.idx_device_tokens_user_id;
DROP INDEX IF EXISTS public.idx_device_tokens_platform;
DROP INDEX IF EXISTS public.idx_device_tokens_device_id;
DROP INDEX IF EXISTS public.idx_country_change_events_enabled_at;
DROP INDEX IF EXISTS public.idx_country_change_events_disabled_at;
DROP INDEX IF EXISTS public.idx_chain_rules_version;
DROP INDEX IF EXISTS public.idx_chain_rules_effective_from;
DROP INDEX IF EXISTS public.idx_chain_rules_applied_at;
DROP INDEX IF EXISTS public.idx_auth_sessions_user_id;
DROP INDEX IF EXISTS public.idx_auth_sessions_refresh_token;
DROP INDEX IF EXISTS public.idx_auth_sessions_expires_at;
DROP INDEX IF EXISTS public.idx_audit_log_entity;
DROP INDEX IF EXISTS public.idx_audit_log_created_at;
DROP INDEX IF EXISTS public.idx_audit_log_actor_id;
DROP INDEX IF EXISTS public.idx_audit_log_action_type;
DROP INDEX IF EXISTS public.idx_attachments_ticket_id;
DROP INDEX IF EXISTS public.idx_attachments_parent_id;
DROP INDEX IF EXISTS public.idx_attachments_child_id;
DROP INDEX IF EXISTS public.idx_attachments_attached_at;
DROP INDEX IF EXISTS public.flyway_schema_history_s_idx;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_username_key;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_position_key;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_chain_key_key;
ALTER TABLE IF EXISTS ONLY public.user_badges DROP CONSTRAINT IF EXISTS user_badges_user_position_badge_type_key;
ALTER TABLE IF EXISTS ONLY public.user_badges DROP CONSTRAINT IF EXISTS user_badges_pkey;
ALTER TABLE IF EXISTS ONLY public.user_badges DROP CONSTRAINT IF EXISTS ukie34edyxlqvbtxg3qhu45ph51;
ALTER TABLE IF EXISTS ONLY public.attachments DROP CONSTRAINT IF EXISTS uk3j2topsf0j6xt92mr5b35r60m;
ALTER TABLE IF EXISTS ONLY public.attachments DROP CONSTRAINT IF EXISTS uk39cd0tchq77lsdukl1nqlq2rp;
ALTER TABLE IF EXISTS ONLY public.tickets DROP CONSTRAINT IF EXISTS tickets_pkey;
ALTER TABLE IF EXISTS ONLY public.password_reset_tokens DROP CONSTRAINT IF EXISTS password_reset_tokens_token_key;
ALTER TABLE IF EXISTS ONLY public.password_reset_tokens DROP CONSTRAINT IF EXISTS password_reset_tokens_pkey;
ALTER TABLE IF EXISTS ONLY public.notifications DROP CONSTRAINT IF EXISTS notifications_pkey;
ALTER TABLE IF EXISTS ONLY public.magic_link_tokens DROP CONSTRAINT IF EXISTS magic_link_tokens_token_key;
ALTER TABLE IF EXISTS ONLY public.magic_link_tokens DROP CONSTRAINT IF EXISTS magic_link_tokens_pkey;
ALTER TABLE IF EXISTS ONLY public.invitations DROP CONSTRAINT IF EXISTS invitations_pkey;
ALTER TABLE IF EXISTS ONLY public.invitations DROP CONSTRAINT IF EXISTS invitations_child_id_key;
ALTER TABLE IF EXISTS ONLY public.flyway_schema_history DROP CONSTRAINT IF EXISTS flyway_schema_history_pk;
ALTER TABLE IF EXISTS ONLY public.email_verification_tokens DROP CONSTRAINT IF EXISTS email_verification_tokens_token_key;
ALTER TABLE IF EXISTS ONLY public.email_verification_tokens DROP CONSTRAINT IF EXISTS email_verification_tokens_pkey;
ALTER TABLE IF EXISTS ONLY public.device_tokens DROP CONSTRAINT IF EXISTS device_tokens_user_id_device_id_key;
ALTER TABLE IF EXISTS ONLY public.device_tokens DROP CONSTRAINT IF EXISTS device_tokens_pkey;
ALTER TABLE IF EXISTS ONLY public.country_change_events DROP CONSTRAINT IF EXISTS country_change_events_pkey;
ALTER TABLE IF EXISTS ONLY public.chain_rules DROP CONSTRAINT IF EXISTS chain_rules_version_key;
ALTER TABLE IF EXISTS ONLY public.chain_rules DROP CONSTRAINT IF EXISTS chain_rules_pkey;
ALTER TABLE IF EXISTS ONLY public.badges DROP CONSTRAINT IF EXISTS badges_pkey;
ALTER TABLE IF EXISTS ONLY public.badges DROP CONSTRAINT IF EXISTS badges_badge_type_key;
ALTER TABLE IF EXISTS ONLY public.auth_sessions DROP CONSTRAINT IF EXISTS auth_sessions_refresh_token_key;
ALTER TABLE IF EXISTS ONLY public.auth_sessions DROP CONSTRAINT IF EXISTS auth_sessions_pkey;
ALTER TABLE IF EXISTS ONLY public.audit_log DROP CONSTRAINT IF EXISTS audit_log_pkey;
ALTER TABLE IF EXISTS ONLY public.attachments DROP CONSTRAINT IF EXISTS attachments_pkey;
ALTER TABLE IF EXISTS ONLY public.attachments DROP CONSTRAINT IF EXISTS attachments_parent_id_child_id_key;
ALTER TABLE IF EXISTS ONLY public.attachments DROP CONSTRAINT IF EXISTS attachments_child_id_key;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.user_badges;
DROP TABLE IF EXISTS public.tickets;
DROP TABLE IF EXISTS public.password_reset_tokens;
DROP TABLE IF EXISTS public.notifications;
DROP TABLE IF EXISTS public.magic_link_tokens;
DROP TABLE IF EXISTS public.invitations;
DROP TABLE IF EXISTS public.flyway_schema_history;
DROP TABLE IF EXISTS public.email_verification_tokens;
DROP TABLE IF EXISTS public.device_tokens;
DROP TABLE IF EXISTS public.country_change_events;
DROP TABLE IF EXISTS public.chain_rules;
DROP TABLE IF EXISTS public.badges;
DROP TABLE IF EXISTS public.auth_sessions;
DROP TABLE IF EXISTS public.audit_log;
DROP TABLE IF EXISTS public.attachments;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: attachments; Type: TABLE; Schema: public; Owner: chain_user
--

CREATE TABLE public.attachments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    parent_id uuid NOT NULL,
    child_id uuid NOT NULL,
    ticket_id uuid NOT NULL,
    attached_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.attachments OWNER TO chain_user;

--
-- Name: TABLE attachments; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON TABLE public.attachments IS 'Parent-child relationships in the chain (who invited whom)';


--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: chain_user
--

CREATE TABLE public.audit_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    actor_id uuid,
    actor_type character varying(20) DEFAULT 'user'::character varying NOT NULL,
    action_type character varying(50) NOT NULL,
    entity_type character varying(50),
    entity_id uuid,
    description text NOT NULL,
    metadata jsonb,
    ip_address character varying(45),
    user_agent text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_audit_log_actor_type CHECK (((actor_type)::text = ANY ((ARRAY['user'::character varying, 'admin'::character varying, 'system'::character varying])::text[])))
);


ALTER TABLE public.audit_log OWNER TO chain_user;

--
-- Name: TABLE audit_log; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON TABLE public.audit_log IS 'System-wide audit trail for security and compliance';


--
-- Name: auth_sessions; Type: TABLE; Schema: public; Owner: chain_user
--

CREATE TABLE public.auth_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    refresh_token character varying(500) NOT NULL,
    ip_address character varying(45),
    user_agent text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone
);


ALTER TABLE public.auth_sessions OWNER TO chain_user;

--
-- Name: TABLE auth_sessions; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON TABLE public.auth_sessions IS 'JWT refresh tokens with session management';


--
-- Name: badges; Type: TABLE; Schema: public; Owner: chain_user
--

CREATE TABLE public.badges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    badge_type character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    icon character varying(10) NOT NULL,
    description text,
    CONSTRAINT chk_badges_type CHECK (((badge_type)::text = ANY ((ARRAY['chain_savior'::character varying, 'chain_guardian'::character varying, 'chain_legend'::character varying])::text[])))
);


ALTER TABLE public.badges OWNER TO chain_user;

--
-- Name: TABLE badges; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON TABLE public.badges IS 'Predefined badge definitions';


--
-- Name: chain_rules; Type: TABLE; Schema: public; Owner: chain_user
--

CREATE TABLE public.chain_rules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    version integer NOT NULL,
    ticket_duration_hours integer DEFAULT 24 NOT NULL,
    max_attempts integer DEFAULT 3 NOT NULL,
    visibility_range integer DEFAULT 1 NOT NULL,
    seed_unlimited_time boolean DEFAULT true NOT NULL,
    reactivation_timeout_hours integer DEFAULT 24 NOT NULL,
    additional_rules jsonb,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    effective_from timestamp with time zone NOT NULL,
    applied_at timestamp with time zone,
    deployment_mode character varying(20) DEFAULT 'SCHEDULED'::character varying NOT NULL,
    change_description text,
    CONSTRAINT chk_chain_rules_deployment CHECK (((deployment_mode)::text = ANY ((ARRAY['INSTANT'::character varying, 'SCHEDULED'::character varying])::text[])))
);


ALTER TABLE public.chain_rules OWNER TO chain_user;

--
-- Name: TABLE chain_rules; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON TABLE public.chain_rules IS 'Versioned game rules allowing dynamic rule changes over time';


--
-- Name: COLUMN chain_rules.version; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON COLUMN public.chain_rules.version IS 'Unique version number (monotonically increasing)';


--
-- Name: COLUMN chain_rules.deployment_mode; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON COLUMN public.chain_rules.deployment_mode IS 'INSTANT: applied immediately, SCHEDULED: applied at effective_from';


--
-- Name: country_change_events; Type: TABLE; Schema: public; Owner: chain_user
--

CREATE TABLE public.country_change_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_name character varying(100) NOT NULL,
    description text,
    enabled_at timestamp with time zone NOT NULL,
    disabled_at timestamp with time zone NOT NULL,
    applies_to character varying(20) DEFAULT 'all'::character varying NOT NULL,
    allowed_countries text[],
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_country_events_applies CHECK (((applies_to)::text = ANY ((ARRAY['all'::character varying, 'specific_users'::character varying])::text[]))),
    CONSTRAINT chk_country_events_dates CHECK ((disabled_at > enabled_at))
);


ALTER TABLE public.country_change_events OWNER TO chain_user;

--
-- Name: TABLE country_change_events; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON TABLE public.country_change_events IS 'Admin-defined windows when users can change their country';


--
-- Name: device_tokens; Type: TABLE; Schema: public; Owner: chain_user
--

CREATE TABLE public.device_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    device_id character varying(255) NOT NULL,
    platform character varying(20) NOT NULL,
    push_token text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT chk_device_tokens_platform CHECK (((platform)::text = ANY ((ARRAY['ios'::character varying, 'android'::character varying, 'web'::character varying])::text[])))
);


ALTER TABLE public.device_tokens OWNER TO chain_user;

--
-- Name: TABLE device_tokens; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON TABLE public.device_tokens IS 'Device tokens for push notifications (FCM, APNs)';


--
-- Name: email_verification_tokens; Type: TABLE; Schema: public; Owner: chain_user
--

CREATE TABLE public.email_verification_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone
);


ALTER TABLE public.email_verification_tokens OWNER TO chain_user;

--
-- Name: TABLE email_verification_tokens; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON TABLE public.email_verification_tokens IS 'Tokens for email verification flow';


--
-- Name: flyway_schema_history; Type: TABLE; Schema: public; Owner: chain_user
--

CREATE TABLE public.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE public.flyway_schema_history OWNER TO chain_user;

--
-- Name: invitations; Type: TABLE; Schema: public; Owner: chain_user
--

CREATE TABLE public.invitations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    parent_id uuid NOT NULL,
    child_id uuid NOT NULL,
    ticket_id uuid NOT NULL,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    invited_at timestamp with time zone DEFAULT now() NOT NULL,
    accepted_at timestamp with time zone,
    CONSTRAINT chk_invitations_status CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'REMOVED'::character varying, 'REVERTED'::character varying])::text[])))
);


ALTER TABLE public.invitations OWNER TO chain_user;

--
-- Name: TABLE invitations; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON TABLE public.invitations IS 'Invitation history tracking (uses UUIDs, not positions)';


--
-- Name: COLUMN invitations.status; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON COLUMN public.invitations.status IS 'ACTIVE: valid, REMOVED: invitee removed, REVERTED: chain reverted past this point';


--
-- Name: magic_link_tokens; Type: TABLE; Schema: public; Owner: chain_user
--

CREATE TABLE public.magic_link_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used_at timestamp with time zone
);


ALTER TABLE public.magic_link_tokens OWNER TO chain_user;

--
-- Name: TABLE magic_link_tokens; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON TABLE public.magic_link_tokens IS 'One-time magic links for passwordless login';


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: chain_user
--

CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    notification_type character varying(50) NOT NULL,
    title character varying(200) NOT NULL,
    body text NOT NULL,
    sent_via_push boolean DEFAULT false,
    sent_via_email boolean DEFAULT false,
    action_url character varying(500),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    sent_at timestamp with time zone,
    read_at timestamp with time zone,
    priority character varying(20) DEFAULT 'NORMAL'::character varying NOT NULL,
    metadata jsonb,
    CONSTRAINT chk_notifications_priority CHECK (((priority)::text = ANY ((ARRAY['CRITICAL'::character varying, 'IMPORTANT'::character varying, 'NORMAL'::character varying, 'LOW'::character varying])::text[]))),
    CONSTRAINT chk_notifications_type CHECK (((notification_type)::text = ANY ((ARRAY['BECAME_TIP'::character varying, 'TICKET_EXPIRING_12H'::character varying, 'TICKET_EXPIRING_1H'::character varying, 'TICKET_EXPIRED'::character varying, 'INVITEE_JOINED'::character varying, 'INVITEE_FAILED'::character varying, 'REMOVED'::character varying, 'BADGE_EARNED'::character varying, 'RULE_CHANGE_ANNOUNCED'::character varying, 'RULE_CHANGE_REMINDER'::character varying, 'RULE_CHANGE_APPLIED'::character varying, 'MILESTONE_REACHED'::character varying, 'DAILY_SUMMARY'::character varying])::text[])))
);


ALTER TABLE public.notifications OWNER TO chain_user;

--
-- Name: TABLE notifications; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON TABLE public.notifications IS 'User notifications with multi-channel support (push, email, in-app)';


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: chain_user
--

CREATE TABLE public.password_reset_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used_at timestamp with time zone
);


ALTER TABLE public.password_reset_tokens OWNER TO chain_user;

--
-- Name: TABLE password_reset_tokens; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON TABLE public.password_reset_tokens IS 'One-time tokens for password reset flow';


--
-- Name: tickets; Type: TABLE; Schema: public; Owner: chain_user
--

CREATE TABLE public.tickets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    owner_id uuid NOT NULL,
    ticket_code character varying(50),
    next_position integer,
    attempt_number integer DEFAULT 1,
    rule_version integer DEFAULT 1,
    duration_hours integer DEFAULT 24,
    qr_code_url character varying(500),
    issued_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used_at timestamp with time zone,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    signature text NOT NULL,
    payload text NOT NULL,
    claimed_by uuid,
    claimed_at timestamp with time zone,
    message character varying(100),
    CONSTRAINT chk_tickets_expiration CHECK ((expires_at > issued_at)),
    CONSTRAINT chk_tickets_status CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'USED'::character varying, 'EXPIRED'::character varying, 'CANCELLED'::character varying])::text[])))
);


ALTER TABLE public.tickets OWNER TO chain_user;

--
-- Name: TABLE tickets; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON TABLE public.tickets IS 'Invitation tickets with expiration and 3-strike rule enforcement';


--
-- Name: COLUMN tickets.attempt_number; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON COLUMN public.tickets.attempt_number IS 'Current attempt (1-3) for the 3-strike rule';


--
-- Name: COLUMN tickets.rule_version; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON COLUMN public.tickets.rule_version IS 'Chain rule version when ticket was created (for grandfathering)';


--
-- Name: COLUMN tickets.duration_hours; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON COLUMN public.tickets.duration_hours IS 'Duration in hours for this specific ticket';


--
-- Name: user_badges; Type: TABLE; Schema: public; Owner: chain_user
--

CREATE TABLE public.user_badges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_position integer NOT NULL,
    badge_type character varying(50) NOT NULL,
    earned_at timestamp with time zone DEFAULT now() NOT NULL,
    context jsonb
);


ALTER TABLE public.user_badges OWNER TO chain_user;

--
-- Name: TABLE user_badges; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON TABLE public.user_badges IS 'Badges earned by users (tracks by position number)';


--
-- Name: COLUMN user_badges.context; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON COLUMN public.user_badges.context IS 'JSON context about how badge was earned';


--
-- Name: users; Type: TABLE; Schema: public; Owner: chain_user
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    chain_key character varying(32) NOT NULL,
    display_name character varying(50) NOT NULL,
    "position" integer NOT NULL,
    parent_id uuid,
    username character varying(50) NOT NULL,
    password_hash character varying(255) NOT NULL,
    email character varying(255),
    email_verified boolean DEFAULT false,
    apple_user_id character varying(255),
    google_user_id character varying(255),
    real_name character varying(100),
    is_guest boolean DEFAULT false,
    avatar_emoji character varying(10) DEFAULT '👤'::character varying,
    belongs_to character varying(2),
    status character varying(20) DEFAULT 'active'::character varying,
    removal_reason character varying(50),
    removed_at timestamp with time zone,
    last_active_at timestamp with time zone,
    wasted_tickets_count integer DEFAULT 0,
    total_tickets_generated integer DEFAULT 0,
    inviter_position integer,
    invitee_position integer,
    country_locked boolean DEFAULT true,
    country_changed_at timestamp with time zone,
    display_name_changed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    is_admin boolean DEFAULT false,
    child_id uuid,
    wasted_child_ids uuid[],
    CONSTRAINT chk_users_belongs_to CHECK (((belongs_to IS NULL) OR ((belongs_to)::text ~ '^[A-Z]{2}$'::text))),
    CONSTRAINT chk_users_removal_reason CHECK (((removal_reason IS NULL) OR ((removal_reason)::text = ANY ((ARRAY['3_failed_attempts'::character varying, 'inactive_when_reactivated'::character varying, 'admin_action'::character varying])::text[])))),
    CONSTRAINT chk_users_status CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'removed'::character varying, 'seed'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO chain_user;

--
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON TABLE public.users IS 'Core user table storing all user data, authentication, and chain position';


--
-- Name: COLUMN users.chain_key; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON COLUMN public.users.chain_key IS 'Unique 12-character identifier for the user in the chain';


--
-- Name: COLUMN users."position"; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON COLUMN public.users."position" IS 'Sequential position in the chain (1 = Seeder, 2 = first invitee, etc.)';


--
-- Name: COLUMN users.username; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON COLUMN public.users.username IS 'Unique username for authentication (required)';


--
-- Name: COLUMN users.belongs_to; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON COLUMN public.users.belongs_to IS 'User''s country (ISO 3166-1 alpha-2 code)';


--
-- Name: COLUMN users.inviter_position; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON COLUMN public.users.inviter_position IS 'Position of the user who invited this user (±1 visibility)';


--
-- Name: COLUMN users.invitee_position; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON COLUMN public.users.invitee_position IS 'Position of the user this user invited (±1 visibility)';


--
-- Name: COLUMN users.country_locked; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON COLUMN public.users.country_locked IS 'Whether country field is locked (can be temporarily unlocked by admin)';


--
-- Name: COLUMN users.is_admin; Type: COMMENT; Schema: public; Owner: chain_user
--

COMMENT ON COLUMN public.users.is_admin IS 'Whether the user has administrative privileges';


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: public; Owner: chain_user
--

COPY public.attachments (id, parent_id, child_id, ticket_id, attached_at) FROM stdin;
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: chain_user
--

COPY public.audit_log (id, actor_id, actor_type, action_type, entity_type, entity_id, description, metadata, ip_address, user_agent, created_at) FROM stdin;
\.


--
-- Data for Name: auth_sessions; Type: TABLE DATA; Schema: public; Owner: chain_user
--

COPY public.auth_sessions (id, user_id, refresh_token, ip_address, user_agent, created_at, expires_at, revoked_at) FROM stdin;
\.


--
-- Data for Name: badges; Type: TABLE DATA; Schema: public; Owner: chain_user
--

COPY public.badges (id, badge_type, name, icon, description) FROM stdin;
7728d112-860c-423f-b67c-ca611b815251	chain_savior	Chain Savior	🦸	Successfully attached someone after your invitee was removed
4d796e80-abe7-4971-bb7c-67c9aab5bec4	chain_guardian	Chain Guardian	🛡️	Saved chain after 5+ consecutive removals
db9070d5-1d49-4ce3-be7a-b0b34636a531	chain_legend	Chain Legend	⭐	Saved chain after 10+ consecutive removals
\.


--
-- Data for Name: chain_rules; Type: TABLE DATA; Schema: public; Owner: chain_user
--

COPY public.chain_rules (id, version, ticket_duration_hours, max_attempts, visibility_range, seed_unlimited_time, reactivation_timeout_hours, additional_rules, created_by, created_at, effective_from, applied_at, deployment_mode, change_description) FROM stdin;
\.


--
-- Data for Name: country_change_events; Type: TABLE DATA; Schema: public; Owner: chain_user
--

COPY public.country_change_events (id, event_name, description, enabled_at, disabled_at, applies_to, allowed_countries, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: device_tokens; Type: TABLE DATA; Schema: public; Owner: chain_user
--

COPY public.device_tokens (id, user_id, device_id, platform, push_token, created_at, updated_at, revoked_at) FROM stdin;
\.


--
-- Data for Name: email_verification_tokens; Type: TABLE DATA; Schema: public; Owner: chain_user
--

COPY public.email_verification_tokens (id, user_id, token, created_at, expires_at, verified_at) FROM stdin;
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: chain_user
--

COPY public.flyway_schema_history (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
1	1	initial schema consolidated	SQL	V1__initial_schema_consolidated.sql	1712034123	chain_user	2025-10-20 20:42:29.713931	383	t
2	4	schema optimization	SQL	V4__schema_optimization.sql	2827436	chain_user	2025-10-20 20:42:30.175904	21	t
3	5	add admin role and reset data	SQL	V5__add_admin_role_and_reset_data.sql	538793070	chain_user	2025-10-20 20:42:30.211648	580	t
\.


--
-- Data for Name: invitations; Type: TABLE DATA; Schema: public; Owner: chain_user
--

COPY public.invitations (id, parent_id, child_id, ticket_id, status, invited_at, accepted_at) FROM stdin;
\.


--
-- Data for Name: magic_link_tokens; Type: TABLE DATA; Schema: public; Owner: chain_user
--

COPY public.magic_link_tokens (id, email, token, created_at, expires_at, used_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: chain_user
--

COPY public.notifications (id, user_id, notification_type, title, body, sent_via_push, sent_via_email, action_url, created_at, sent_at, read_at, priority, metadata) FROM stdin;
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: chain_user
--

COPY public.password_reset_tokens (id, user_id, token, created_at, expires_at, used_at) FROM stdin;
\.


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: chain_user
--

COPY public.tickets (id, owner_id, ticket_code, next_position, attempt_number, rule_version, duration_hours, qr_code_url, issued_at, expires_at, used_at, status, signature, payload, claimed_by, claimed_at, message) FROM stdin;
\.


--
-- Data for Name: user_badges; Type: TABLE DATA; Schema: public; Owner: chain_user
--

COPY public.user_badges (id, user_position, badge_type, earned_at, context) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: chain_user
--

COPY public.users (id, chain_key, display_name, "position", parent_id, username, password_hash, email, email_verified, apple_user_id, google_user_id, real_name, is_guest, avatar_emoji, belongs_to, status, removal_reason, removed_at, last_active_at, wasted_tickets_count, total_tickets_generated, inviter_position, invitee_position, country_locked, country_changed_at, display_name_changed_at, created_at, updated_at, deleted_at, is_admin, child_id, wasted_child_ids) FROM stdin;
a0000000-0000-0000-0000-000000000001	SEED00000001	The Seeder	1	\N	alpaslan	$2a$10$/0wR9/haE0/pMqSV5azSuOMV89edvBKATy3g/IYTW25OCdalTeAuO	bekalpaslan@gmail.com	t	\N	\N	\N	f	👤	US	seed	\N	\N	\N	0	0	\N	\N	t	\N	\N	2025-10-20 20:42:30.215614+00	2025-10-20 20:47:21.677293+00	\N	t	\N	\N
\.


--
-- Name: attachments attachments_child_id_key; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_child_id_key UNIQUE (child_id);


--
-- Name: attachments attachments_parent_id_child_id_key; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_parent_id_child_id_key UNIQUE (parent_id, child_id);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: auth_sessions auth_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.auth_sessions
    ADD CONSTRAINT auth_sessions_pkey PRIMARY KEY (id);


--
-- Name: auth_sessions auth_sessions_refresh_token_key; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.auth_sessions
    ADD CONSTRAINT auth_sessions_refresh_token_key UNIQUE (refresh_token);


--
-- Name: badges badges_badge_type_key; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.badges
    ADD CONSTRAINT badges_badge_type_key UNIQUE (badge_type);


--
-- Name: badges badges_pkey; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.badges
    ADD CONSTRAINT badges_pkey PRIMARY KEY (id);


--
-- Name: chain_rules chain_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.chain_rules
    ADD CONSTRAINT chain_rules_pkey PRIMARY KEY (id);


--
-- Name: chain_rules chain_rules_version_key; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.chain_rules
    ADD CONSTRAINT chain_rules_version_key UNIQUE (version);


--
-- Name: country_change_events country_change_events_pkey; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.country_change_events
    ADD CONSTRAINT country_change_events_pkey PRIMARY KEY (id);


--
-- Name: device_tokens device_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_pkey PRIMARY KEY (id);


--
-- Name: device_tokens device_tokens_user_id_device_id_key; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_user_id_device_id_key UNIQUE (user_id, device_id);


--
-- Name: email_verification_tokens email_verification_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.email_verification_tokens
    ADD CONSTRAINT email_verification_tokens_pkey PRIMARY KEY (id);


--
-- Name: email_verification_tokens email_verification_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.email_verification_tokens
    ADD CONSTRAINT email_verification_tokens_token_key UNIQUE (token);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: invitations invitations_child_id_key; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_child_id_key UNIQUE (child_id);


--
-- Name: invitations invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (id);


--
-- Name: magic_link_tokens magic_link_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.magic_link_tokens
    ADD CONSTRAINT magic_link_tokens_pkey PRIMARY KEY (id);


--
-- Name: magic_link_tokens magic_link_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.magic_link_tokens
    ADD CONSTRAINT magic_link_tokens_token_key UNIQUE (token);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_token_key UNIQUE (token);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: attachments uk39cd0tchq77lsdukl1nqlq2rp; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT uk39cd0tchq77lsdukl1nqlq2rp UNIQUE (child_id);


--
-- Name: attachments uk3j2topsf0j6xt92mr5b35r60m; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT uk3j2topsf0j6xt92mr5b35r60m UNIQUE (parent_id, child_id);


--
-- Name: user_badges ukie34edyxlqvbtxg3qhu45ph51; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.user_badges
    ADD CONSTRAINT ukie34edyxlqvbtxg3qhu45ph51 UNIQUE (user_position, badge_type);


--
-- Name: user_badges user_badges_pkey; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.user_badges
    ADD CONSTRAINT user_badges_pkey PRIMARY KEY (id);


--
-- Name: user_badges user_badges_user_position_badge_type_key; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.user_badges
    ADD CONSTRAINT user_badges_user_position_badge_type_key UNIQUE (user_position, badge_type);


--
-- Name: users users_chain_key_key; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_chain_key_key UNIQUE (chain_key);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_position_key; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_position_key UNIQUE ("position");


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);


--
-- Name: idx_attachments_attached_at; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_attachments_attached_at ON public.attachments USING btree (attached_at);


--
-- Name: idx_attachments_child_id; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_attachments_child_id ON public.attachments USING btree (child_id);


--
-- Name: idx_attachments_parent_id; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_attachments_parent_id ON public.attachments USING btree (parent_id);


--
-- Name: idx_attachments_ticket_id; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_attachments_ticket_id ON public.attachments USING btree (ticket_id);


--
-- Name: idx_audit_log_action_type; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_audit_log_action_type ON public.audit_log USING btree (action_type);


--
-- Name: idx_audit_log_actor_id; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_audit_log_actor_id ON public.audit_log USING btree (actor_id);


--
-- Name: idx_audit_log_created_at; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_audit_log_created_at ON public.audit_log USING btree (created_at);


--
-- Name: idx_audit_log_entity; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_audit_log_entity ON public.audit_log USING btree (entity_type, entity_id);


--
-- Name: idx_auth_sessions_expires_at; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_auth_sessions_expires_at ON public.auth_sessions USING btree (expires_at);


--
-- Name: idx_auth_sessions_refresh_token; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_auth_sessions_refresh_token ON public.auth_sessions USING btree (refresh_token);


--
-- Name: idx_auth_sessions_user_id; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_auth_sessions_user_id ON public.auth_sessions USING btree (user_id);


--
-- Name: idx_chain_rules_applied_at; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_chain_rules_applied_at ON public.chain_rules USING btree (applied_at);


--
-- Name: idx_chain_rules_effective_from; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_chain_rules_effective_from ON public.chain_rules USING btree (effective_from);


--
-- Name: idx_chain_rules_version; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_chain_rules_version ON public.chain_rules USING btree (version);


--
-- Name: idx_country_change_events_disabled_at; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_country_change_events_disabled_at ON public.country_change_events USING btree (disabled_at);


--
-- Name: idx_country_change_events_enabled_at; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_country_change_events_enabled_at ON public.country_change_events USING btree (enabled_at);


--
-- Name: idx_device_tokens_device_id; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_device_tokens_device_id ON public.device_tokens USING btree (device_id);


--
-- Name: idx_device_tokens_platform; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_device_tokens_platform ON public.device_tokens USING btree (platform);


--
-- Name: idx_device_tokens_user_id; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_device_tokens_user_id ON public.device_tokens USING btree (user_id);


--
-- Name: idx_email_verification_tokens_expires_at; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_email_verification_tokens_expires_at ON public.email_verification_tokens USING btree (expires_at);


--
-- Name: idx_email_verification_tokens_token; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_email_verification_tokens_token ON public.email_verification_tokens USING btree (token);


--
-- Name: idx_email_verification_tokens_user_id; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_email_verification_tokens_user_id ON public.email_verification_tokens USING btree (user_id);


--
-- Name: idx_invitations_child_id; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_invitations_child_id ON public.invitations USING btree (child_id);


--
-- Name: idx_invitations_parent_id; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_invitations_parent_id ON public.invitations USING btree (parent_id);


--
-- Name: idx_invitations_status; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_invitations_status ON public.invitations USING btree (status);


--
-- Name: idx_invitations_ticket_id; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_invitations_ticket_id ON public.invitations USING btree (ticket_id);


--
-- Name: idx_magic_link_tokens_email; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_magic_link_tokens_email ON public.magic_link_tokens USING btree (email);


--
-- Name: idx_magic_link_tokens_expires_at; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_magic_link_tokens_expires_at ON public.magic_link_tokens USING btree (expires_at);


--
-- Name: idx_magic_link_tokens_token; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_magic_link_tokens_token ON public.magic_link_tokens USING btree (token);


--
-- Name: idx_notifications_created_at; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_notifications_created_at ON public.notifications USING btree (created_at);


--
-- Name: idx_notifications_priority; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_notifications_priority ON public.notifications USING btree (priority);


--
-- Name: idx_notifications_read_at; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_notifications_read_at ON public.notifications USING btree (read_at);


--
-- Name: idx_notifications_type; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_notifications_type ON public.notifications USING btree (notification_type);


--
-- Name: idx_notifications_user_id; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_notifications_user_id ON public.notifications USING btree (user_id);


--
-- Name: idx_password_reset_tokens_expires_at; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_password_reset_tokens_expires_at ON public.password_reset_tokens USING btree (expires_at);


--
-- Name: idx_password_reset_tokens_token; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_password_reset_tokens_token ON public.password_reset_tokens USING btree (token);


--
-- Name: idx_password_reset_tokens_user_id; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_password_reset_tokens_user_id ON public.password_reset_tokens USING btree (user_id);


--
-- Name: idx_tickets_attempt_number; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_tickets_attempt_number ON public.tickets USING btree (attempt_number);


--
-- Name: idx_tickets_claimed_by; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_tickets_claimed_by ON public.tickets USING btree (claimed_by);


--
-- Name: idx_tickets_expires_at; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_tickets_expires_at ON public.tickets USING btree (expires_at);


--
-- Name: idx_tickets_one_active_per_user; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE UNIQUE INDEX idx_tickets_one_active_per_user ON public.tickets USING btree (owner_id) WHERE ((status)::text = 'ACTIVE'::text);


--
-- Name: idx_tickets_owner_id; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_tickets_owner_id ON public.tickets USING btree (owner_id);


--
-- Name: idx_tickets_status; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_tickets_status ON public.tickets USING btree (status);


--
-- Name: idx_tickets_ticket_code; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_tickets_ticket_code ON public.tickets USING btree (ticket_code);


--
-- Name: idx_user_badges_badge_type; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_user_badges_badge_type ON public.user_badges USING btree (badge_type);


--
-- Name: idx_user_badges_earned_at; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_user_badges_earned_at ON public.user_badges USING btree (earned_at);


--
-- Name: idx_user_badges_user_pos; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_user_badges_user_pos ON public.user_badges USING btree (user_position);


--
-- Name: idx_users_apple_id; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE UNIQUE INDEX idx_users_apple_id ON public.users USING btree (apple_user_id) WHERE (apple_user_id IS NOT NULL);


--
-- Name: idx_users_belongs_to; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_users_belongs_to ON public.users USING btree (belongs_to);


--
-- Name: idx_users_chain_key; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_users_chain_key ON public.users USING btree (chain_key);


--
-- Name: idx_users_created_at; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_users_created_at ON public.users USING btree (created_at);


--
-- Name: idx_users_display_name_lower; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE UNIQUE INDEX idx_users_display_name_lower ON public.users USING btree (lower((display_name)::text));


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE UNIQUE INDEX idx_users_email ON public.users USING btree (email) WHERE (email IS NOT NULL);


--
-- Name: idx_users_google_id; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE UNIQUE INDEX idx_users_google_id ON public.users USING btree (google_user_id) WHERE (google_user_id IS NOT NULL);


--
-- Name: idx_users_invitee_position; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_users_invitee_position ON public.users USING btree (invitee_position);


--
-- Name: idx_users_inviter_position; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_users_inviter_position ON public.users USING btree (inviter_position);


--
-- Name: idx_users_is_admin; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_users_is_admin ON public.users USING btree (is_admin) WHERE (is_admin = true);


--
-- Name: idx_users_last_active; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_users_last_active ON public.users USING btree (last_active_at);


--
-- Name: idx_users_parent_id; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_users_parent_id ON public.users USING btree (parent_id);


--
-- Name: idx_users_position; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_users_position ON public.users USING btree ("position");


--
-- Name: idx_users_removed_at; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_users_removed_at ON public.users USING btree (removed_at);


--
-- Name: idx_users_status; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE INDEX idx_users_status ON public.users USING btree (status);


--
-- Name: idx_users_username; Type: INDEX; Schema: public; Owner: chain_user
--

CREATE UNIQUE INDEX idx_users_username ON public.users USING btree (username);


--
-- Name: attachments attachments_child_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_child_id_fkey FOREIGN KEY (child_id) REFERENCES public.users(id);


--
-- Name: attachments attachments_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.users(id);


--
-- Name: attachments attachments_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id);


--
-- Name: audit_log audit_log_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.users(id);


--
-- Name: auth_sessions auth_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.auth_sessions
    ADD CONSTRAINT auth_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: chain_rules chain_rules_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.chain_rules
    ADD CONSTRAINT chain_rules_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: country_change_events country_change_events_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.country_change_events
    ADD CONSTRAINT country_change_events_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: device_tokens device_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: email_verification_tokens email_verification_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.email_verification_tokens
    ADD CONSTRAINT email_verification_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: invitations invitations_child_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_child_id_fkey FOREIGN KEY (child_id) REFERENCES public.users(id);


--
-- Name: invitations invitations_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.users(id);


--
-- Name: invitations invitations_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id);


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: password_reset_tokens password_reset_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: tickets tickets_claimed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_claimed_by_fkey FOREIGN KEY (claimed_by) REFERENCES public.users(id);


--
-- Name: tickets tickets_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_badges user_badges_badge_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.user_badges
    ADD CONSTRAINT user_badges_badge_type_fkey FOREIGN KEY (badge_type) REFERENCES public.badges(badge_type);


--
-- Name: users users_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chain_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict kAwQuuNI02obovnHC9BfeFK8g6clwAxPj97febUgFIpMgQVw4ovgcM2Lxs2bvJH

