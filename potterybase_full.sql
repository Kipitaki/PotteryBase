--
-- PostgreSQL database dump
--

\restrict lcKnt3ChbVNprnez7nleH9KLwdAHLx1o7CzZ9wXGzCFN9yS2Fyh8Vqr77OJ9l5e

-- Dumped from database version 14.18
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: nhost_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO nhost_admin;

--
-- Name: hdb_catalog; Type: SCHEMA; Schema: -; Owner: nhost_hasura
--

CREATE SCHEMA hdb_catalog;


ALTER SCHEMA hdb_catalog OWNER TO nhost_hasura;

--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: nhost_admin
--

CREATE SCHEMA pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO nhost_admin;

--
-- Name: potterbase; Type: SCHEMA; Schema: -; Owner: nhost_hasura
--

CREATE SCHEMA potterbase;


ALTER SCHEMA potterbase OWNER TO nhost_hasura;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: nhost_admin
--

CREATE SCHEMA storage;


ALTER SCHEMA storage OWNER TO nhost_admin;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: email; Type: DOMAIN; Schema: auth; Owner: nhost_auth_admin
--

CREATE DOMAIN auth.email AS public.citext
	CONSTRAINT email_check CHECK ((VALUE OPERATOR(public.~) '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'::public.citext));


ALTER DOMAIN auth.email OWNER TO nhost_auth_admin;

--
-- Name: set_current_timestamp_updated_at(); Type: FUNCTION; Schema: auth; Owner: nhost_auth_admin
--

CREATE FUNCTION auth.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := new;
  _new. "updated_at" = now();
  RETURN _new;
END;
$$;


ALTER FUNCTION auth.set_current_timestamp_updated_at() OWNER TO nhost_auth_admin;

--
-- Name: gen_hasura_uuid(); Type: FUNCTION; Schema: hdb_catalog; Owner: nhost_hasura
--

CREATE FUNCTION hdb_catalog.gen_hasura_uuid() RETURNS uuid
    LANGUAGE sql
    AS $$select gen_random_uuid()$$;


ALTER FUNCTION hdb_catalog.gen_hasura_uuid() OWNER TO nhost_hasura;

--
-- Name: user_lookup(text); Type: FUNCTION; Schema: pgbouncer; Owner: postgres
--

CREATE FUNCTION pgbouncer.user_lookup(i_username text, OUT uname text, OUT phash text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    SELECT usename, passwd FROM pg_catalog.pg_shadow
    WHERE usename = i_username INTO uname, phash;
    RETURN;
END;
$$;


ALTER FUNCTION pgbouncer.user_lookup(i_username text, OUT uname text, OUT phash text) OWNER TO postgres;

--
-- Name: create_profile_for_new_user(); Type: FUNCTION; Schema: potterbase; Owner: nhost_hasura
--

CREATE FUNCTION potterbase.create_profile_for_new_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  insert into potterbase.profiles (id, display_name, avatar_url)
  values (
    new.id,
    new.display_name,
    new.avatar_url
  )
  on conflict (id) do nothing; -- prevent duplicate inserts if profile already exists
  return new;
end;
$$;


ALTER FUNCTION potterbase.create_profile_for_new_user() OWNER TO nhost_hasura;

--
-- Name: set_current_timestamp_updated_at(); Type: FUNCTION; Schema: potterbase; Owner: nhost_hasura
--

CREATE FUNCTION potterbase.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.updated_at = now();
  return new;
end;
$$;


ALTER FUNCTION potterbase.set_current_timestamp_updated_at() OWNER TO nhost_hasura;

--
-- Name: set_current_timestamp_updated_at(); Type: FUNCTION; Schema: public; Owner: nhost_hasura
--

CREATE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.updated_at = now();
  return new;
end;
$$;


ALTER FUNCTION public.set_current_timestamp_updated_at() OWNER TO nhost_hasura;

--
-- Name: protect_default_bucket_delete(); Type: FUNCTION; Schema: storage; Owner: nhost_storage_admin
--

CREATE FUNCTION storage.protect_default_bucket_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF OLD.ID = 'default' THEN
    RAISE EXCEPTION 'Can not delete default bucket';
  END IF;
  RETURN OLD;
END;
$$;


ALTER FUNCTION storage.protect_default_bucket_delete() OWNER TO nhost_storage_admin;

--
-- Name: protect_default_bucket_update(); Type: FUNCTION; Schema: storage; Owner: nhost_storage_admin
--

CREATE FUNCTION storage.protect_default_bucket_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF OLD.ID = 'default' AND NEW.ID <> 'default' THEN
    RAISE EXCEPTION 'Can not rename default bucket';
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION storage.protect_default_bucket_update() OWNER TO nhost_storage_admin;

--
-- Name: set_current_timestamp_updated_at(); Type: FUNCTION; Schema: storage; Owner: nhost_storage_admin
--

CREATE FUNCTION storage.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := new;
  _new. "updated_at" = now();
  RETURN _new;
END;
$$;


ALTER FUNCTION storage.set_current_timestamp_updated_at() OWNER TO nhost_storage_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: migrations; Type: TABLE; Schema: auth; Owner: nhost_auth_admin
--

CREATE TABLE auth.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE auth.migrations OWNER TO nhost_auth_admin;

--
-- Name: TABLE migrations; Type: COMMENT; Schema: auth; Owner: nhost_auth_admin
--

COMMENT ON TABLE auth.migrations IS 'Internal table for tracking migrations. Don''t modify its structure as Hasura Auth relies on it to function properly.';


--
-- Name: provider_requests; Type: TABLE; Schema: auth; Owner: nhost_auth_admin
--

CREATE TABLE auth.provider_requests (
    id uuid NOT NULL,
    options jsonb
);


ALTER TABLE auth.provider_requests OWNER TO nhost_auth_admin;

--
-- Name: TABLE provider_requests; Type: COMMENT; Schema: auth; Owner: nhost_auth_admin
--

COMMENT ON TABLE auth.provider_requests IS 'Oauth requests, inserted before redirecting to the provider''s site. Don''t modify its structure as Hasura Auth relies on it to function properly.';


--
-- Name: providers; Type: TABLE; Schema: auth; Owner: nhost_auth_admin
--

CREATE TABLE auth.providers (
    id text NOT NULL
);


ALTER TABLE auth.providers OWNER TO nhost_auth_admin;

--
-- Name: TABLE providers; Type: COMMENT; Schema: auth; Owner: nhost_auth_admin
--

COMMENT ON TABLE auth.providers IS 'List of available Oauth providers. Don''t modify its structure as Hasura Auth relies on it to function properly.';


--
-- Name: refresh_token_types; Type: TABLE; Schema: auth; Owner: nhost_auth_admin
--

CREATE TABLE auth.refresh_token_types (
    value text NOT NULL,
    comment text
);


ALTER TABLE auth.refresh_token_types OWNER TO nhost_auth_admin;

--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: nhost_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    user_id uuid NOT NULL,
    metadata jsonb,
    type text DEFAULT 'regular'::text NOT NULL,
    refresh_token_hash character varying(255)
);


ALTER TABLE auth.refresh_tokens OWNER TO nhost_auth_admin;

--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: nhost_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'User refresh tokens. Hasura auth uses them to rotate new access tokens as long as the refresh token is not expired. Don''t modify its structure as Hasura Auth relies on it to function properly.';


--
-- Name: roles; Type: TABLE; Schema: auth; Owner: nhost_auth_admin
--

CREATE TABLE auth.roles (
    role text NOT NULL
);


ALTER TABLE auth.roles OWNER TO nhost_auth_admin;

--
-- Name: TABLE roles; Type: COMMENT; Schema: auth; Owner: nhost_auth_admin
--

COMMENT ON TABLE auth.roles IS 'Persistent Hasura roles for users. Don''t modify its structure as Hasura Auth relies on it to function properly.';


--
-- Name: user_providers; Type: TABLE; Schema: auth; Owner: nhost_auth_admin
--

CREATE TABLE auth.user_providers (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id uuid NOT NULL,
    access_token text NOT NULL,
    refresh_token text,
    provider_id text NOT NULL,
    provider_user_id text NOT NULL
);


ALTER TABLE auth.user_providers OWNER TO nhost_auth_admin;

--
-- Name: TABLE user_providers; Type: COMMENT; Schema: auth; Owner: nhost_auth_admin
--

COMMENT ON TABLE auth.user_providers IS 'Active providers for a given user. Don''t modify its structure as Hasura Auth relies on it to function properly.';


--
-- Name: user_roles; Type: TABLE; Schema: auth; Owner: nhost_auth_admin
--

CREATE TABLE auth.user_roles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id uuid NOT NULL,
    role text NOT NULL
);


ALTER TABLE auth.user_roles OWNER TO nhost_auth_admin;

--
-- Name: TABLE user_roles; Type: COMMENT; Schema: auth; Owner: nhost_auth_admin
--

COMMENT ON TABLE auth.user_roles IS 'Roles of users. Don''t modify its structure as Hasura Auth relies on it to function properly.';


--
-- Name: user_security_keys; Type: TABLE; Schema: auth; Owner: nhost_auth_admin
--

CREATE TABLE auth.user_security_keys (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    credential_id text NOT NULL,
    credential_public_key bytea,
    counter bigint DEFAULT 0 NOT NULL,
    transports character varying(255) DEFAULT ''::character varying NOT NULL,
    nickname text
);


ALTER TABLE auth.user_security_keys OWNER TO nhost_auth_admin;

--
-- Name: TABLE user_security_keys; Type: COMMENT; Schema: auth; Owner: nhost_auth_admin
--

COMMENT ON TABLE auth.user_security_keys IS 'User webauthn security keys. Don''t modify its structure as Hasura Auth relies on it to function properly.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: nhost_auth_admin
--

CREATE TABLE auth.users (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_seen timestamp with time zone,
    disabled boolean DEFAULT false NOT NULL,
    display_name text DEFAULT ''::text NOT NULL,
    avatar_url text DEFAULT ''::text NOT NULL,
    locale character varying(2) NOT NULL,
    email auth.email,
    phone_number text,
    password_hash text,
    email_verified boolean DEFAULT false NOT NULL,
    phone_number_verified boolean DEFAULT false NOT NULL,
    new_email auth.email,
    otp_method_last_used text,
    otp_hash text,
    otp_hash_expires_at timestamp with time zone DEFAULT now() NOT NULL,
    default_role text DEFAULT 'user'::text NOT NULL,
    is_anonymous boolean DEFAULT false NOT NULL,
    totp_secret text,
    active_mfa_type text,
    ticket text,
    ticket_expires_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb,
    webauthn_current_challenge text,
    CONSTRAINT active_mfa_types_check CHECK (((active_mfa_type = 'totp'::text) OR (active_mfa_type = 'sms'::text)))
);


ALTER TABLE auth.users OWNER TO nhost_auth_admin;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: nhost_auth_admin
--

COMMENT ON TABLE auth.users IS 'User account information. Don''t modify its structure as Hasura Auth relies on it to function properly.';


--
-- Name: hdb_action_log; Type: TABLE; Schema: hdb_catalog; Owner: nhost_hasura
--

CREATE TABLE hdb_catalog.hdb_action_log (
    id uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    action_name text,
    input_payload jsonb NOT NULL,
    request_headers jsonb NOT NULL,
    session_variables jsonb NOT NULL,
    response_payload jsonb,
    errors jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    response_received_at timestamp with time zone,
    status text NOT NULL,
    CONSTRAINT hdb_action_log_status_check CHECK ((status = ANY (ARRAY['created'::text, 'processing'::text, 'completed'::text, 'error'::text])))
);


ALTER TABLE hdb_catalog.hdb_action_log OWNER TO nhost_hasura;

--
-- Name: hdb_cron_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: nhost_hasura
--

CREATE TABLE hdb_catalog.hdb_cron_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_cron_event_invocation_logs OWNER TO nhost_hasura;

--
-- Name: hdb_cron_events; Type: TABLE; Schema: hdb_catalog; Owner: nhost_hasura
--

CREATE TABLE hdb_catalog.hdb_cron_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    trigger_name text NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_cron_events OWNER TO nhost_hasura;

--
-- Name: hdb_metadata; Type: TABLE; Schema: hdb_catalog; Owner: nhost_hasura
--

CREATE TABLE hdb_catalog.hdb_metadata (
    id integer NOT NULL,
    metadata json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL
);


ALTER TABLE hdb_catalog.hdb_metadata OWNER TO nhost_hasura;

--
-- Name: hdb_scheduled_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: nhost_hasura
--

CREATE TABLE hdb_catalog.hdb_scheduled_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_scheduled_event_invocation_logs OWNER TO nhost_hasura;

--
-- Name: hdb_scheduled_events; Type: TABLE; Schema: hdb_catalog; Owner: nhost_hasura
--

CREATE TABLE hdb_catalog.hdb_scheduled_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    webhook_conf json NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    retry_conf json,
    payload json,
    header_conf json,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    comment text,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_scheduled_events OWNER TO nhost_hasura;

--
-- Name: hdb_schema_notifications; Type: TABLE; Schema: hdb_catalog; Owner: nhost_hasura
--

CREATE TABLE hdb_catalog.hdb_schema_notifications (
    id integer NOT NULL,
    notification json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL,
    instance_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT hdb_schema_notifications_id_check CHECK ((id = 1))
);


ALTER TABLE hdb_catalog.hdb_schema_notifications OWNER TO nhost_hasura;

--
-- Name: hdb_version; Type: TABLE; Schema: hdb_catalog; Owner: nhost_hasura
--

CREATE TABLE hdb_catalog.hdb_version (
    hasura_uuid uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    version text NOT NULL,
    upgraded_on timestamp with time zone NOT NULL,
    cli_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    console_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    ee_client_id text,
    ee_client_secret text
);


ALTER TABLE hdb_catalog.hdb_version OWNER TO nhost_hasura;

--
-- Name: clay_body; Type: TABLE; Schema: potterbase; Owner: nhost_hasura
--

CREATE TABLE potterbase.clay_body (
    id integer NOT NULL,
    name text NOT NULL,
    brand text,
    notes text
);


ALTER TABLE potterbase.clay_body OWNER TO nhost_hasura;

--
-- Name: clay_body_id_seq; Type: SEQUENCE; Schema: potterbase; Owner: nhost_hasura
--

CREATE SEQUENCE potterbase.clay_body_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE potterbase.clay_body_id_seq OWNER TO nhost_hasura;

--
-- Name: clay_body_id_seq; Type: SEQUENCE OWNED BY; Schema: potterbase; Owner: nhost_hasura
--

ALTER SEQUENCE potterbase.clay_body_id_seq OWNED BY potterbase.clay_body.id;


--
-- Name: glaze; Type: TABLE; Schema: potterbase; Owner: nhost_hasura
--

CREATE TABLE potterbase.glaze (
    id integer NOT NULL,
    name text NOT NULL,
    brand text,
    cone text,
    color text,
    notes text,
    code character varying(50),
    series character varying(100),
    finish character varying(50),
    display_name character varying(255) GENERATED ALWAYS AS ((((name || ' ('::text) || (code)::text) || ')'::text)) STORED
);


ALTER TABLE potterbase.glaze OWNER TO nhost_hasura;

--
-- Name: glaze_id_seq; Type: SEQUENCE; Schema: potterbase; Owner: nhost_hasura
--

CREATE SEQUENCE potterbase.glaze_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE potterbase.glaze_id_seq OWNER TO nhost_hasura;

--
-- Name: glaze_id_seq; Type: SEQUENCE OWNED BY; Schema: potterbase; Owner: nhost_hasura
--

ALTER SEQUENCE potterbase.glaze_id_seq OWNED BY potterbase.glaze.id;


--
-- Name: piece; Type: TABLE; Schema: potterbase; Owner: nhost_hasura
--

CREATE TABLE potterbase.piece (
    title text NOT NULL,
    id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    owner_id uuid DEFAULT '005202a4-fd35-4761-8a91-4faf0f6b1009'::uuid NOT NULL,
    visibility text DEFAULT 'Private'::text NOT NULL,
    "stageDates" jsonb DEFAULT '{}'::jsonb,
    stage text,
    "stageDate" timestamp with time zone,
    notes text
);


ALTER TABLE potterbase.piece OWNER TO nhost_hasura;

--
-- Name: piece_clay; Type: TABLE; Schema: potterbase; Owner: nhost_hasura
--

CREATE TABLE potterbase.piece_clay (
    id integer NOT NULL,
    piece_id integer NOT NULL,
    clay_body_id integer NOT NULL,
    notes text
);


ALTER TABLE potterbase.piece_clay OWNER TO nhost_hasura;

--
-- Name: piece_clay_id_seq; Type: SEQUENCE; Schema: potterbase; Owner: nhost_hasura
--

CREATE SEQUENCE potterbase.piece_clay_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE potterbase.piece_clay_id_seq OWNER TO nhost_hasura;

--
-- Name: piece_clay_id_seq; Type: SEQUENCE OWNED BY; Schema: potterbase; Owner: nhost_hasura
--

ALTER SEQUENCE potterbase.piece_clay_id_seq OWNED BY potterbase.piece_clay.id;


--
-- Name: piece_firing; Type: TABLE; Schema: potterbase; Owner: nhost_hasura
--

CREATE TABLE potterbase.piece_firing (
    id integer NOT NULL,
    piece_id integer NOT NULL,
    cone text,
    temperature_f integer,
    kiln_type text,
    kiln_location text,
    load_name text,
    date timestamp with time zone DEFAULT now(),
    notes text
);


ALTER TABLE potterbase.piece_firing OWNER TO nhost_hasura;

--
-- Name: piece_firing_id_seq; Type: SEQUENCE; Schema: potterbase; Owner: nhost_hasura
--

CREATE SEQUENCE potterbase.piece_firing_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE potterbase.piece_firing_id_seq OWNER TO nhost_hasura;

--
-- Name: piece_firing_id_seq; Type: SEQUENCE OWNED BY; Schema: potterbase; Owner: nhost_hasura
--

ALTER SEQUENCE potterbase.piece_firing_id_seq OWNED BY potterbase.piece_firing.id;


--
-- Name: piece_glaze; Type: TABLE; Schema: potterbase; Owner: nhost_hasura
--

CREATE TABLE potterbase.piece_glaze (
    id integer NOT NULL,
    piece_id integer NOT NULL,
    glaze_id integer NOT NULL,
    layer_number integer,
    application_method text,
    notes text
);


ALTER TABLE potterbase.piece_glaze OWNER TO nhost_hasura;

--
-- Name: piece_glaze_id_seq; Type: SEQUENCE; Schema: potterbase; Owner: nhost_hasura
--

CREATE SEQUENCE potterbase.piece_glaze_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE potterbase.piece_glaze_id_seq OWNER TO nhost_hasura;

--
-- Name: piece_glaze_id_seq; Type: SEQUENCE OWNED BY; Schema: potterbase; Owner: nhost_hasura
--

ALTER SEQUENCE potterbase.piece_glaze_id_seq OWNED BY potterbase.piece_glaze.id;


--
-- Name: piece_id_seq; Type: SEQUENCE; Schema: potterbase; Owner: nhost_hasura
--

CREATE SEQUENCE potterbase.piece_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE potterbase.piece_id_seq OWNER TO nhost_hasura;

--
-- Name: piece_id_seq; Type: SEQUENCE OWNED BY; Schema: potterbase; Owner: nhost_hasura
--

ALTER SEQUENCE potterbase.piece_id_seq OWNED BY potterbase.piece.id;


--
-- Name: piece_image; Type: TABLE; Schema: potterbase; Owner: nhost_hasura
--

CREATE TABLE potterbase.piece_image (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    piece_id integer NOT NULL,
    file_id text NOT NULL,
    url text NOT NULL,
    stage text,
    is_main boolean DEFAULT false NOT NULL,
    uploaded_at timestamp with time zone DEFAULT now() NOT NULL,
    taken_at date,
    notes text
);


ALTER TABLE potterbase.piece_image OWNER TO nhost_hasura;

--
-- Name: piece_stage_history; Type: TABLE; Schema: potterbase; Owner: nhost_hasura
--

CREATE TABLE potterbase.piece_stage_history (
    id integer NOT NULL,
    piece_id integer NOT NULL,
    stage text NOT NULL,
    date timestamp with time zone DEFAULT now() NOT NULL,
    length_cm numeric,
    width_cm numeric,
    height_cm numeric,
    weight_g numeric,
    location text,
    CONSTRAINT stage_valid CHECK ((stage = ANY (ARRAY['lump'::text, 'formed'::text, 'trimmed'::text, 'bisque'::text, 'glazed'::text, 'fired'::text, 'sold_posted'::text, 'sold_kept'::text])))
);


ALTER TABLE potterbase.piece_stage_history OWNER TO nhost_hasura;

--
-- Name: piece_stage_history_id_seq; Type: SEQUENCE; Schema: potterbase; Owner: nhost_hasura
--

CREATE SEQUENCE potterbase.piece_stage_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE potterbase.piece_stage_history_id_seq OWNER TO nhost_hasura;

--
-- Name: piece_stage_history_id_seq; Type: SEQUENCE OWNED BY; Schema: potterbase; Owner: nhost_hasura
--

ALTER SEQUENCE potterbase.piece_stage_history_id_seq OWNED BY potterbase.piece_stage_history.id;


--
-- Name: profiles; Type: TABLE; Schema: potterbase; Owner: nhost_hasura
--

CREATE TABLE potterbase.profiles (
    id uuid NOT NULL,
    display_name text NOT NULL,
    avatar_url text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    unit_preference text DEFAULT 'imperial'::text,
    length_unit text GENERATED ALWAYS AS (
CASE
    WHEN (unit_preference = 'metric'::text) THEN 'cm'::text
    ELSE 'in'::text
END) STORED,
    weight_unit text GENERATED ALWAYS AS (
CASE
    WHEN (unit_preference = 'metric'::text) THEN 'g'::text
    ELSE 'lb'::text
END) STORED,
    CONSTRAINT profiles_unit_preference_check CHECK ((unit_preference = ANY (ARRAY['metric'::text, 'imperial'::text])))
);


ALTER TABLE potterbase.profiles OWNER TO nhost_hasura;

--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: nhost_storage_admin
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    download_expiration integer DEFAULT 30 NOT NULL,
    min_upload_file_size integer DEFAULT 1 NOT NULL,
    max_upload_file_size integer DEFAULT 50000000 NOT NULL,
    cache_control text DEFAULT 'max-age=3600'::text,
    presigned_urls_enabled boolean DEFAULT true NOT NULL,
    CONSTRAINT download_expiration_valid_range CHECK (((download_expiration >= 1) AND (download_expiration <= 604800)))
);


ALTER TABLE storage.buckets OWNER TO nhost_storage_admin;

--
-- Name: files; Type: TABLE; Schema: storage; Owner: nhost_storage_admin
--

CREATE TABLE storage.files (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    bucket_id text DEFAULT 'default'::text NOT NULL,
    name text,
    size integer,
    mime_type text,
    etag text,
    is_uploaded boolean DEFAULT false,
    uploaded_by_user_id uuid,
    metadata jsonb
);


ALTER TABLE storage.files OWNER TO nhost_storage_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: storage; Owner: nhost_storage_admin
--

CREATE TABLE storage.schema_migrations (
    version bigint NOT NULL,
    dirty boolean NOT NULL
);


ALTER TABLE storage.schema_migrations OWNER TO nhost_storage_admin;

--
-- Name: virus; Type: TABLE; Schema: storage; Owner: nhost_storage_admin
--

CREATE TABLE storage.virus (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    file_id uuid NOT NULL,
    filename text NOT NULL,
    virus text NOT NULL,
    user_session jsonb NOT NULL
);


ALTER TABLE storage.virus OWNER TO nhost_storage_admin;

--
-- Name: clay_body id; Type: DEFAULT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.clay_body ALTER COLUMN id SET DEFAULT nextval('potterbase.clay_body_id_seq'::regclass);


--
-- Name: glaze id; Type: DEFAULT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.glaze ALTER COLUMN id SET DEFAULT nextval('potterbase.glaze_id_seq'::regclass);


--
-- Name: piece id; Type: DEFAULT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece ALTER COLUMN id SET DEFAULT nextval('potterbase.piece_id_seq'::regclass);


--
-- Name: piece_clay id; Type: DEFAULT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece_clay ALTER COLUMN id SET DEFAULT nextval('potterbase.piece_clay_id_seq'::regclass);


--
-- Name: piece_firing id; Type: DEFAULT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece_firing ALTER COLUMN id SET DEFAULT nextval('potterbase.piece_firing_id_seq'::regclass);


--
-- Name: piece_glaze id; Type: DEFAULT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece_glaze ALTER COLUMN id SET DEFAULT nextval('potterbase.piece_glaze_id_seq'::regclass);


--
-- Name: piece_stage_history id; Type: DEFAULT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece_stage_history ALTER COLUMN id SET DEFAULT nextval('potterbase.piece_stage_history_id_seq'::regclass);


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: auth; Owner: nhost_auth_admin
--

COPY auth.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	9c0c864e0ccb0f8d1c77ab0576ef9f2841ec1b68	2025-08-22 16:29:19.380403
1	create-initial-tables	c16083c88329c867581a9c73c3f140783a1a5df4	2025-08-22 16:29:19.465872
2	custom-user-fields	78236c9c2b50da88786bcf50099dd290f820e000	2025-08-22 16:29:19.469566
3	discord-twitch-providers	857db1e92c7a8034e61a3d88ea672aec9b424036	2025-08-22 16:29:19.473307
4	provider-request-options	42428265112b904903d9ad7833d8acf2812a00ed	2025-08-22 16:29:19.477193
5	table-comments	78f76f88eff3b11ebab9be4f2469020dae017110	2025-08-22 16:29:19.478879
6	setup-webauthn	87ba279363f8ecf8b450a681938a74b788cf536c	2025-08-22 16:29:19.494654
7	add_authenticator_nickname	d32fd62bb7a441eea48c5434f5f3744f2e334288	2025-08-22 16:29:19.498124
8	workos-provider	0727238a633ff119bedcbebfec6a9ea83b2bd01d	2025-08-22 16:29:19.502136
9	rename-authenticator-to-security-key	fd7e00bef4d141a6193cf9642afd88fb6fe2b283	2025-08-22 16:29:19.506868
10	azuread-provider	f492ff4780f8210016e1c12fa0ed83eb4278a780	2025-08-22 16:29:19.510287
11	add_refresh_token_hash_column	62a2cd295f63153dd9f16f3159d1ab2a49b01c2f	2025-08-22 16:29:19.518313
12	add_refresh_token_metadata	3daa907e813d1e8b72107112a89916909702897c	2025-08-22 16:29:19.525629
13	add_refresh_token_type	0937470d919981a2052e4a00dfaad34378477765	2025-08-22 16:29:19.529751
14	alter_refresh_token_type	e23fd094aef2ef926a06ac84000471a829548165	2025-08-22 16:29:19.549359
15	rename_refresh_token_column	71e1d7fa6e6056fa193b4ff4d6f8e61cf3f5cd9f	2025-08-22 16:29:19.553197
16	index_on_refresh_tokens	f129db784d60b1578ca310d9f49fc9363c257431	2025-08-22 16:29:19.555168
17	drop_user_providers_user_id_provider_id_key	129a2f7c906de5a29c34a832b5d961a1226ce928	2025-08-22 16:29:19.561685
\.


--
-- Data for Name: provider_requests; Type: TABLE DATA; Schema: auth; Owner: nhost_auth_admin
--

COPY auth.provider_requests (id, options) FROM stdin;
34238564-00db-4069-9b86-59a1d281372d	{"cookie": {"path": "/", "expires": null, "httpOnly": true, "originalMaxAge": null}}
\.


--
-- Data for Name: providers; Type: TABLE DATA; Schema: auth; Owner: nhost_auth_admin
--

COPY auth.providers (id) FROM stdin;
github
facebook
twitter
google
apple
linkedin
windowslive
spotify
strava
gitlab
bitbucket
discord
twitch
workos
azuread
\.


--
-- Data for Name: refresh_token_types; Type: TABLE DATA; Schema: auth; Owner: nhost_auth_admin
--

COPY auth.refresh_token_types (value, comment) FROM stdin;
regular	Regular refresh token
pat	Personal access token
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: nhost_auth_admin
--

COPY auth.refresh_tokens (id, created_at, expires_at, user_id, metadata, type, refresh_token_hash) FROM stdin;
4ed0abe1-61c1-40fb-9604-d69d47ef77f0	2025-09-06 22:24:39.44467+00	2025-10-12 12:39:34.743045+00	2cdfd34c-369c-46ba-8e41-309c66f18ba2	\N	regular	\\x8ca6c8bcb4ad304cd71d7033c4b6a12d2547c623b7bc16fd394fcd6632041bef
22dad547-5c57-424a-9c2c-4b1e714a3ddf	2025-09-07 18:33:45.500095+00	2025-10-07 18:33:45.500059+00	005202a4-fd35-4761-8a91-4faf0f6b1009	\N	regular	\\x6cd0537acae3b9625149ebbbd444bce827df28e684a37ba3bb50a25f68c9899f
a8c2f936-f209-4d0b-9db0-2ada63bb34dd	2025-09-07 18:49:23.305107+00	2025-10-08 21:01:45.5293+00	005202a4-fd35-4761-8a91-4faf0f6b1009	\N	regular	\\x1f6df6ff1310dae6f30186604ac31a8bdb866ba7c4e556f41e72d8589c264195
084c3faa-7329-4069-9bff-d04c98c9367f	2025-08-30 16:08:58.355811+00	2025-10-04 21:06:40.102634+00	005202a4-fd35-4761-8a91-4faf0f6b1009	\N	regular	\\xdac85e9a855d2f288c3f2a1b954df9d202c2172918f2bb2b8b070d057a13f405
5aa65ece-3c1e-4911-bfde-7d4a0fc28fa6	2025-09-04 21:29:54.043329+00	2025-10-04 21:29:54.043238+00	2cdfd34c-369c-46ba-8e41-309c66f18ba2	\N	regular	\\x4479010d5f269bcba626c71953b15db831fac19b607b7d4f45a12c4659437546
79ad98e8-0def-494b-83bb-ecf24c269bdc	2025-08-23 19:22:14.763024+00	2025-10-01 15:38:20.948887+00	005202a4-fd35-4761-8a91-4faf0f6b1009	\N	regular	\\xfa39b9894e872a98b2887e16513789e286576c747ae496bfeb4b5d302a7be9d4
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: auth; Owner: nhost_auth_admin
--

COPY auth.roles (role) FROM stdin;
user
anonymous
me
public
admin
\.


--
-- Data for Name: user_providers; Type: TABLE DATA; Schema: auth; Owner: nhost_auth_admin
--

COPY auth.user_providers (id, created_at, updated_at, user_id, access_token, refresh_token, provider_id, provider_user_id) FROM stdin;
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: auth; Owner: nhost_auth_admin
--

COPY auth.user_roles (id, created_at, user_id, role) FROM stdin;
4511b9e0-f7ce-40cf-8091-5cfea54d013d	2025-08-22 17:49:13.458666+00	005202a4-fd35-4761-8a91-4faf0f6b1009	me
bb44a9d2-d330-42af-b2ce-e664407c0941	2025-08-22 17:49:13.458666+00	005202a4-fd35-4761-8a91-4faf0f6b1009	admin
ed03f332-69d3-433c-8955-b0c718e150f7	2025-09-04 21:29:38.96258+00	2cdfd34c-369c-46ba-8e41-309c66f18ba2	user
17850801-8436-4396-8639-3e1c29ebce30	2025-09-04 21:29:38.96258+00	2cdfd34c-369c-46ba-8e41-309c66f18ba2	me
32914d34-7225-400b-a675-05f7e55f8353	2025-09-04 21:29:38.96258+00	2cdfd34c-369c-46ba-8e41-309c66f18ba2	public
e5eb9934-8235-4e6a-99b7-715491515b6f	2025-09-05 13:50:42.351309+00	bf079960-eed3-497e-adc2-480a2f91fe3f	user
d499d3a3-6c32-4200-9207-4842171b6d35	2025-09-05 13:50:42.351309+00	bf079960-eed3-497e-adc2-480a2f91fe3f	me
1bcfb802-4da9-4aa2-9026-a16c84ca7e7e	2025-09-05 13:50:42.351309+00	bf079960-eed3-497e-adc2-480a2f91fe3f	public
\.


--
-- Data for Name: user_security_keys; Type: TABLE DATA; Schema: auth; Owner: nhost_auth_admin
--

COPY auth.user_security_keys (id, user_id, credential_id, credential_public_key, counter, transports, nickname) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: nhost_auth_admin
--

COPY auth.users (id, created_at, updated_at, last_seen, disabled, display_name, avatar_url, locale, email, phone_number, password_hash, email_verified, phone_number_verified, new_email, otp_method_last_used, otp_hash, otp_hash_expires_at, default_role, is_anonymous, totp_secret, active_mfa_type, ticket, ticket_expires_at, metadata, webauthn_current_challenge) FROM stdin;
bf079960-eed3-497e-adc2-480a2f91fe3f	2025-09-05 13:50:42.351309+00	2025-09-06 15:39:57.4547+00	2025-09-06 15:39:57.4547+00	f	1@2.com	https://www.gravatar.com/avatar/dae916a6316c3421fd42193bc8a06332?d=blank&r=g	en	1@2.com	\N	$2a$10$p.8a0wPn.QoCbilJFeBwFOePzrMDc.FcJBmKwGTITZBI1Dz5maoJS	t	f	\N	\N	\N	2025-09-05 13:50:42.351309+00	user	f	\N	\N	verifyEmail:c0b71199-b916-4a38-970d-12c49442445e	2025-10-05 13:50:42.350477+00	null	\N
005202a4-fd35-4761-8a91-4faf0f6b1009	2025-08-22 17:49:13.458666+00	2025-09-08 21:01:45.529352+00	2025-09-08 21:01:45.529352+00	f	admin	https://www.gravatar.com/avatar/602d5aa667ec6808fc96ac98c1cacfb9?d=blank&r=g	en	allyayoung@gmail.com	\N	$2a$10$y.bWXYSnOcNC3lGfFGX5oOvL6xMlebW3/x0.RTvNrAN9Bg4rxR172	t	f	\N	\N	\N	2025-08-22 17:49:13.458666+00	admin	f	\N	\N	verifyEmail:34063e26-fc59-4100-aba9-73e6e6d9007e	2025-09-21 17:49:13.457385+00	\N	\N
2cdfd34c-369c-46ba-8e41-309c66f18ba2	2025-09-04 21:29:38.96258+00	2025-09-12 12:39:34.743237+00	2025-09-12 12:39:34.743237+00	f	allyanne74@yahoo.com	https://www.gravatar.com/avatar/e519a3d589db7097bf9294c1fe7db1ae?d=blank&r=g	en	allyanne74@yahoo.com	\N	$2a$10$fEVAU2W9wW/4nN2/bgOnP.0d82GwDh9ccv7G3kWZEic7lAv4oDRkG	t	f	\N	\N	\N	2025-09-04 21:29:38.96258+00	user	f	\N	\N	\N	2025-09-04 21:29:54.039221+00	null	\N
\.


--
-- Data for Name: hdb_action_log; Type: TABLE DATA; Schema: hdb_catalog; Owner: nhost_hasura
--

COPY hdb_catalog.hdb_action_log (id, action_name, input_payload, request_headers, session_variables, response_payload, errors, created_at, response_received_at, status) FROM stdin;
\.


--
-- Data for Name: hdb_cron_event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: nhost_hasura
--

COPY hdb_catalog.hdb_cron_event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
\.


--
-- Data for Name: hdb_cron_events; Type: TABLE DATA; Schema: hdb_catalog; Owner: nhost_hasura
--

COPY hdb_catalog.hdb_cron_events (id, trigger_name, scheduled_time, status, tries, created_at, next_retry_at) FROM stdin;
\.


--
-- Data for Name: hdb_metadata; Type: TABLE DATA; Schema: hdb_catalog; Owner: nhost_hasura
--

COPY hdb_catalog.hdb_metadata (id, metadata, resource_version) FROM stdin;
1	{"sources":[{"configuration":{"connection_info":{"database_url":{"from_env":"HASURA_GRAPHQL_DATABASE_URL"},"isolation_level":"read-committed","pool_settings":{"connection_lifetime":600,"idle_timeout":180,"max_connections":50,"retries":1},"use_prepared_statements":true}},"kind":"postgres","name":"default","tables":[{"configuration":{"column_config":{"id":{"custom_name":"id"},"options":{"custom_name":"options"}},"custom_column_names":{"id":"id","options":"options"},"custom_name":"authProviderRequests","custom_root_fields":{"delete":"deleteAuthProviderRequests","delete_by_pk":"deleteAuthProviderRequest","insert":"insertAuthProviderRequests","insert_one":"insertAuthProviderRequest","select":"authProviderRequests","select_aggregate":"authProviderRequestsAggregate","select_by_pk":"authProviderRequest","update":"updateAuthProviderRequests","update_by_pk":"updateAuthProviderRequest"}},"table":{"name":"provider_requests","schema":"auth"}},{"array_relationships":[{"name":"userProviders","using":{"foreign_key_constraint_on":{"column":"provider_id","table":{"name":"user_providers","schema":"auth"}}}}],"configuration":{"column_config":{"id":{"custom_name":"id"}},"custom_column_names":{"id":"id"},"custom_name":"authProviders","custom_root_fields":{"delete":"deleteAuthProviders","delete_by_pk":"deleteAuthProvider","insert":"insertAuthProviders","insert_one":"insertAuthProvider","select":"authProviders","select_aggregate":"authProvidersAggregate","select_by_pk":"authProvider","update":"updateAuthProviders","update_by_pk":"updateAuthProvider"}},"table":{"name":"providers","schema":"auth"}},{"array_relationships":[{"name":"refreshTokens","using":{"foreign_key_constraint_on":{"column":"type","table":{"name":"refresh_tokens","schema":"auth"}}}}],"configuration":{"column_config":{},"custom_column_names":{},"custom_name":"authRefreshTokenTypes","custom_root_fields":{"delete":"deleteAuthRefreshTokenTypes","delete_by_pk":"deleteAuthRefreshTokenType","insert":"insertAuthRefreshTokenTypes","insert_one":"insertAuthRefreshTokenType","select":"authRefreshTokenTypes","select_aggregate":"authRefreshTokenTypesAggregate","select_by_pk":"authRefreshTokenType","update":"updateAuthRefreshTokenTypes","update_by_pk":"updateAuthRefreshTokenType"}},"is_enum":true,"table":{"name":"refresh_token_types","schema":"auth"}},{"configuration":{"column_config":{"created_at":{"custom_name":"createdAt"},"expires_at":{"custom_name":"expiresAt"},"refresh_token_hash":{"custom_name":"refreshTokenHash"},"user_id":{"custom_name":"userId"}},"custom_column_names":{"created_at":"createdAt","expires_at":"expiresAt","refresh_token_hash":"refreshTokenHash","user_id":"userId"},"custom_name":"authRefreshTokens","custom_root_fields":{"delete":"deleteAuthRefreshTokens","delete_by_pk":"deleteAuthRefreshToken","insert":"insertAuthRefreshTokens","insert_one":"insertAuthRefreshToken","select":"authRefreshTokens","select_aggregate":"authRefreshTokensAggregate","select_by_pk":"authRefreshToken","update":"updateAuthRefreshTokens","update_by_pk":"updateAuthRefreshToken"}},"delete_permissions":[{"permission":{"filter":{"_and":[{"user_id":{"_eq":"X-Hasura-User-Id"}},{"type":{"_eq":"pat"}}]}},"role":"user"}],"object_relationships":[{"name":"user","using":{"foreign_key_constraint_on":"user_id"}}],"select_permissions":[{"permission":{"columns":["id","created_at","expires_at","metadata","type","user_id"],"filter":{"user_id":{"_eq":"X-Hasura-User-Id"}}},"role":"user"}],"table":{"name":"refresh_tokens","schema":"auth"}},{"array_relationships":[{"name":"userRoles","using":{"foreign_key_constraint_on":{"column":"role","table":{"name":"user_roles","schema":"auth"}}}},{"name":"usersByDefaultRole","using":{"foreign_key_constraint_on":{"column":"default_role","table":{"name":"users","schema":"auth"}}}}],"configuration":{"column_config":{"role":{"custom_name":"role"}},"custom_column_names":{"role":"role"},"custom_name":"authRoles","custom_root_fields":{"delete":"deleteAuthRoles","delete_by_pk":"deleteAuthRole","insert":"insertAuthRoles","insert_one":"insertAuthRole","select":"authRoles","select_aggregate":"authRolesAggregate","select_by_pk":"authRole","update":"updateAuthRoles","update_by_pk":"updateAuthRole"}},"table":{"name":"roles","schema":"auth"}},{"configuration":{"column_config":{"access_token":{"custom_name":"accessToken"},"created_at":{"custom_name":"createdAt"},"id":{"custom_name":"id"},"provider_id":{"custom_name":"providerId"},"provider_user_id":{"custom_name":"providerUserId"},"refresh_token":{"custom_name":"refreshToken"},"updated_at":{"custom_name":"updatedAt"},"user_id":{"custom_name":"userId"}},"custom_column_names":{"access_token":"accessToken","created_at":"createdAt","id":"id","provider_id":"providerId","provider_user_id":"providerUserId","refresh_token":"refreshToken","updated_at":"updatedAt","user_id":"userId"},"custom_name":"authUserProviders","custom_root_fields":{"delete":"deleteAuthUserProviders","delete_by_pk":"deleteAuthUserProvider","insert":"insertAuthUserProviders","insert_one":"insertAuthUserProvider","select":"authUserProviders","select_aggregate":"authUserProvidersAggregate","select_by_pk":"authUserProvider","update":"updateAuthUserProviders","update_by_pk":"updateAuthUserProvider"}},"object_relationships":[{"name":"provider","using":{"foreign_key_constraint_on":"provider_id"}},{"name":"user","using":{"foreign_key_constraint_on":"user_id"}}],"table":{"name":"user_providers","schema":"auth"}},{"configuration":{"column_config":{"created_at":{"custom_name":"createdAt"},"id":{"custom_name":"id"},"role":{"custom_name":"role"},"user_id":{"custom_name":"userId"}},"custom_column_names":{"created_at":"createdAt","id":"id","role":"role","user_id":"userId"},"custom_name":"authUserRoles","custom_root_fields":{"delete":"deleteAuthUserRoles","delete_by_pk":"deleteAuthUserRole","insert":"insertAuthUserRoles","insert_one":"insertAuthUserRole","select":"authUserRoles","select_aggregate":"authUserRolesAggregate","select_by_pk":"authUserRole","update":"updateAuthUserRoles","update_by_pk":"updateAuthUserRole"}},"object_relationships":[{"name":"roleByRole","using":{"foreign_key_constraint_on":"role"}},{"name":"user","using":{"foreign_key_constraint_on":"user_id"}}],"table":{"name":"user_roles","schema":"auth"}},{"configuration":{"column_config":{"credential_id":{"custom_name":"credentialId"},"credential_public_key":{"custom_name":"credentialPublicKey"},"id":{"custom_name":"id"},"user_id":{"custom_name":"userId"}},"custom_column_names":{"credential_id":"credentialId","credential_public_key":"credentialPublicKey","id":"id","user_id":"userId"},"custom_name":"authUserSecurityKeys","custom_root_fields":{"delete":"deleteAuthUserSecurityKeys","delete_by_pk":"deleteAuthUserSecurityKey","insert":"insertAuthUserSecurityKeys","insert_one":"insertAuthUserSecurityKey","select":"authUserSecurityKeys","select_aggregate":"authUserSecurityKeysAggregate","select_by_pk":"authUserSecurityKey","update":"updateAuthUserSecurityKeys","update_by_pk":"updateAuthUserSecurityKey"}},"object_relationships":[{"name":"user","using":{"foreign_key_constraint_on":"user_id"}}],"table":{"name":"user_security_keys","schema":"auth"}},{"array_relationships":[{"name":"refreshTokens","using":{"foreign_key_constraint_on":{"column":"user_id","table":{"name":"refresh_tokens","schema":"auth"}}}},{"name":"roles","using":{"foreign_key_constraint_on":{"column":"user_id","table":{"name":"user_roles","schema":"auth"}}}},{"name":"securityKeys","using":{"foreign_key_constraint_on":{"column":"user_id","table":{"name":"user_security_keys","schema":"auth"}}}},{"name":"userProviders","using":{"foreign_key_constraint_on":{"column":"user_id","table":{"name":"user_providers","schema":"auth"}}}}],"configuration":{"column_config":{"active_mfa_type":{"custom_name":"activeMfaType"},"avatar_url":{"custom_name":"avatarUrl"},"created_at":{"custom_name":"createdAt"},"default_role":{"custom_name":"defaultRole"},"disabled":{"custom_name":"disabled"},"display_name":{"custom_name":"displayName"},"email":{"custom_name":"email"},"email_verified":{"custom_name":"emailVerified"},"id":{"custom_name":"id"},"is_anonymous":{"custom_name":"isAnonymous"},"last_seen":{"custom_name":"lastSeen"},"locale":{"custom_name":"locale"},"new_email":{"custom_name":"newEmail"},"otp_hash":{"custom_name":"otpHash"},"otp_hash_expires_at":{"custom_name":"otpHashExpiresAt"},"otp_method_last_used":{"custom_name":"otpMethodLastUsed"},"password_hash":{"custom_name":"passwordHash"},"phone_number":{"custom_name":"phoneNumber"},"phone_number_verified":{"custom_name":"phoneNumberVerified"},"ticket":{"custom_name":"ticket"},"ticket_expires_at":{"custom_name":"ticketExpiresAt"},"totp_secret":{"custom_name":"totpSecret"},"updated_at":{"custom_name":"updatedAt"},"webauthn_current_challenge":{"custom_name":"currentChallenge"}},"custom_column_names":{"active_mfa_type":"activeMfaType","avatar_url":"avatarUrl","created_at":"createdAt","default_role":"defaultRole","disabled":"disabled","display_name":"displayName","email":"email","email_verified":"emailVerified","id":"id","is_anonymous":"isAnonymous","last_seen":"lastSeen","locale":"locale","new_email":"newEmail","otp_hash":"otpHash","otp_hash_expires_at":"otpHashExpiresAt","otp_method_last_used":"otpMethodLastUsed","password_hash":"passwordHash","phone_number":"phoneNumber","phone_number_verified":"phoneNumberVerified","ticket":"ticket","ticket_expires_at":"ticketExpiresAt","totp_secret":"totpSecret","updated_at":"updatedAt","webauthn_current_challenge":"currentChallenge"},"custom_name":"users","custom_root_fields":{"delete":"deleteUsers","delete_by_pk":"deleteUser","insert":"insertUsers","insert_one":"insertUser","select":"users","select_aggregate":"usersAggregate","select_by_pk":"user","update":"updateUsers","update_by_pk":"updateUser"}},"object_relationships":[{"name":"defaultRoleByRole","using":{"foreign_key_constraint_on":"default_role"}}],"table":{"name":"users","schema":"auth"}},{"array_relationships":[{"name":"piece_clays","using":{"foreign_key_constraint_on":{"column":"clay_body_id","table":{"name":"piece_clay","schema":"potterbase"}}}}],"insert_permissions":[{"comment":"","permission":{"check":{},"columns":["id","brand","name","notes"]},"role":"user"}],"select_permissions":[{"comment":"","permission":{"columns":["id","brand","name","notes"],"filter":{}},"role":"public"},{"comment":"","permission":{"columns":["id","brand","name","notes"],"filter":{}},"role":"user"}],"table":{"name":"clay_body","schema":"potterbase"}},{"array_relationships":[{"name":"piece_glazes","using":{"foreign_key_constraint_on":{"column":"glaze_id","table":{"name":"piece_glaze","schema":"potterbase"}}}}],"insert_permissions":[{"comment":"","permission":{"check":{},"columns":["brand","code","color","cone","finish","id","name","notes","series"]},"role":"user"}],"select_permissions":[{"comment":"","permission":{"columns":["code","display_name","finish","series","id","brand","color","cone","name","notes"],"filter":{}},"role":"public"},{"comment":"","permission":{"columns":["code","display_name","finish","series","id","brand","color","cone","name","notes"],"filter":{}},"role":"user"}],"table":{"name":"glaze","schema":"potterbase"},"update_permissions":[{"comment":"","permission":{"check":null,"columns":["brand","code","color","cone","finish","id","name","notes","series"],"filter":{}},"role":"user"}]},{"array_relationships":[{"name":"piece_clays","using":{"foreign_key_constraint_on":{"column":"piece_id","table":{"name":"piece_clay","schema":"potterbase"}}}},{"name":"piece_firings","using":{"foreign_key_constraint_on":{"column":"piece_id","table":{"name":"piece_firing","schema":"potterbase"}}}},{"name":"piece_glazes","using":{"foreign_key_constraint_on":{"column":"piece_id","table":{"name":"piece_glaze","schema":"potterbase"}}}},{"name":"piece_images","using":{"foreign_key_constraint_on":{"column":"piece_id","table":{"name":"piece_image","schema":"potterbase"}}}},{"name":"piece_stage_histories","using":{"foreign_key_constraint_on":{"column":"piece_id","table":{"name":"piece_stage_history","schema":"potterbase"}}}}],"delete_permissions":[{"comment":"","permission":{"filter":{"owner_id":{"_eq":"X-Hasura-User-Id"}}},"role":"user"}],"insert_permissions":[{"comment":"","permission":{"check":{"_or":[{"owner_id":{"_eq":"X-Hasura-User-Id"}},{"visibility":{"_eq":"Public"}}]},"columns":["created_at","id","notes","owner_id","title","updated_at","visibility"],"set":{"owner_id":"x-hasura-User-Id"}},"role":"user"}],"object_relationships":[{"name":"profile","using":{"manual_configuration":{"column_mapping":{"owner_id":"id"},"insertion_order":null,"remote_table":{"name":"profiles","schema":"potterbase"}}}}],"select_permissions":[{"comment":"","permission":{"columns":["id","stageDates","notes","stage","title","visibility","created_at","stageDate","updated_at","owner_id"],"filter":{}},"role":"anonymous"},{"comment":"","permission":{"allow_aggregations":true,"columns":["created_at","id","notes","owner_id","stage","stageDate","stageDates","title","updated_at","visibility"],"filter":{"visibility":{"_eq":"Public"}}},"role":"public"},{"comment":"","permission":{"columns":["created_at","id","notes","owner_id","title","updated_at","visibility"],"filter":{"_or":[{"owner_id":{"_eq":"X-Hasura-User-Id"}},{"visibility":{"_eq":"Public"}}]}},"role":"user"}],"table":{"name":"piece","schema":"potterbase"},"update_permissions":[{"comment":"","permission":{"check":{"owner_id":{"_eq":"X-Hasura-User-Id"}},"columns":["created_at","notes","owner_id","stage","stageDate","stageDates","title","updated_at","visibility"],"filter":{}},"role":"user"}]},{"delete_permissions":[{"comment":"","permission":{"filter":{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}}},"role":"user"}],"insert_permissions":[{"comment":"","permission":{"check":{"_or":[{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}},{"piece":{"visibility":{"_eq":"Public"}}}]},"columns":["clay_body_id","id","piece_id","notes"]},"role":"user"}],"object_relationships":[{"name":"clay_body","using":{"foreign_key_constraint_on":"clay_body_id"}},{"name":"piece","using":{"foreign_key_constraint_on":"piece_id"}}],"select_permissions":[{"comment":"","permission":{"columns":["clay_body_id","id","piece_id","notes"],"filter":{"piece":{"visibility":{"_eq":"Public"}}}},"role":"anonymous"},{"comment":"","permission":{"columns":["clay_body_id","id","piece_id","notes"],"filter":{"piece":{"visibility":{"_eq":"Public"}}}},"role":"public"},{"comment":"","permission":{"columns":["clay_body_id","id","piece_id","notes"],"filter":{"_or":[{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}},{"piece":{"visibility":{"_eq":"Public"}}}]}},"role":"user"}],"table":{"name":"piece_clay","schema":"potterbase"},"update_permissions":[{"comment":"","permission":{"check":null,"columns":["clay_body_id","id","piece_id","notes"],"filter":{"_or":[{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}},{"piece":{"visibility":{"_eq":"Public"}}}]}},"role":"user"}]},{"delete_permissions":[{"comment":"","permission":{"filter":{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}}},"role":"user"}],"insert_permissions":[{"comment":"","permission":{"check":{"_or":[{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}},{"piece":{"visibility":{"_eq":"Public"}}}]},"columns":["id","piece_id","temperature_f","cone","kiln_location","kiln_type","load_name","notes","date"]},"role":"user"}],"object_relationships":[{"name":"piece","using":{"foreign_key_constraint_on":"piece_id"}}],"select_permissions":[{"comment":"","permission":{"columns":["id","piece_id","temperature_f","cone","kiln_location","kiln_type","load_name","notes","date"],"filter":{"piece":{"visibility":{"_eq":"Public"}}}},"role":"anonymous"},{"comment":"","permission":{"columns":["id","piece_id","temperature_f","cone","kiln_location","kiln_type","load_name","notes","date"],"filter":{"piece":{"visibility":{"_eq":"Public"}}}},"role":"public"},{"comment":"","permission":{"columns":["id","piece_id","temperature_f","cone","kiln_location","kiln_type","load_name","notes","date"],"filter":{"_or":[{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}},{"piece":{"visibility":{"_eq":"Public"}}}]}},"role":"user"}],"table":{"name":"piece_firing","schema":"potterbase"},"update_permissions":[{"comment":"","permission":{"check":null,"columns":["id","piece_id","temperature_f","cone","kiln_location","kiln_type","load_name","notes","date"],"filter":{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}}},"role":"user"}]},{"delete_permissions":[{"comment":"","permission":{"filter":{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}}},"role":"user"}],"insert_permissions":[{"comment":"","permission":{"check":{"_or":[{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}},{"piece":{"visibility":{"_eq":"Public"}}}]},"columns":["glaze_id","id","layer_number","piece_id","application_method","notes"]},"role":"user"}],"object_relationships":[{"name":"glaze","using":{"foreign_key_constraint_on":"glaze_id"}},{"name":"piece","using":{"foreign_key_constraint_on":"piece_id"}}],"select_permissions":[{"comment":"","permission":{"columns":["glaze_id","id","layer_number","piece_id","application_method","notes"],"filter":{}},"role":"public"},{"comment":"","permission":{"columns":["glaze_id","id","layer_number","piece_id","application_method","notes"],"filter":{"_or":[{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}},{"piece":{"visibility":{"_eq":"Public"}}}]}},"role":"user"}],"table":{"name":"piece_glaze","schema":"potterbase"},"update_permissions":[{"comment":"","permission":{"check":{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}},"columns":["glaze_id","id","layer_number","piece_id","application_method","notes"],"filter":{"_or":[{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}},{"piece":{"visibility":{"_eq":"Public"}}}]}},"role":"user"}]},{"delete_permissions":[{"comment":"","permission":{"filter":{"_or":[{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}},{"piece":{"visibility":{"_eq":"Public"}}}]}},"role":"user"}],"insert_permissions":[{"comment":"","permission":{"check":{"_or":[{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}},{"piece":{"visibility":{"_eq":"Public"}}}]},"columns":["is_main","taken_at","piece_id","file_id","notes","stage","url","uploaded_at","id"]},"role":"user"}],"object_relationships":[{"name":"piece","using":{"foreign_key_constraint_on":"piece_id"}}],"select_permissions":[{"comment":"","permission":{"columns":["is_main","taken_at","piece_id","file_id","notes","stage","url","uploaded_at","id"],"filter":{}},"role":"anonymous"},{"comment":"","permission":{"columns":["is_main","taken_at","piece_id","file_id","notes","stage","url","uploaded_at","id"],"filter":{}},"role":"public"},{"comment":"","permission":{"columns":["is_main","taken_at","piece_id","file_id","notes","stage","url","uploaded_at","id"],"filter":{"_or":[{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}},{"piece":{"visibility":{"_eq":"Public"}}}]}},"role":"user"}],"table":{"name":"piece_image","schema":"potterbase"},"update_permissions":[{"comment":"","permission":{"check":null,"columns":["is_main","taken_at","piece_id","file_id","notes","stage","url","uploaded_at","id"],"filter":{"_or":[{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}},{"piece":{"visibility":{"_eq":"Public"}}}]}},"role":"user"}]},{"delete_permissions":[{"comment":"","permission":{"filter":{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}}},"role":"user"}],"insert_permissions":[{"comment":"","permission":{"check":{"_or":[{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}},{"piece":{"visibility":{"_eq":"Public"}}}]},"columns":["id","piece_id","height_cm","length_cm","weight_g","width_cm","location","stage","date"]},"role":"user"}],"object_relationships":[{"name":"piece","using":{"foreign_key_constraint_on":"piece_id"}}],"select_permissions":[{"comment":"","permission":{"columns":["id","piece_id","height_cm","length_cm","weight_g","width_cm","location","stage","date"],"filter":{}},"role":"public"},{"comment":"","permission":{"columns":["id","piece_id","height_cm","length_cm","weight_g","width_cm","location","stage","date"],"filter":{"_or":[{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}},{"piece":{"visibility":{"_eq":"Public"}}}]}},"role":"user"}],"table":{"name":"piece_stage_history","schema":"potterbase"},"update_permissions":[{"comment":"","permission":{"check":{},"columns":["id","piece_id","height_cm","length_cm","weight_g","width_cm","location","stage","date"],"filter":{"_or":[{"piece":{"owner_id":{"_eq":"X-Hasura-User-Id"}}},{"piece":{"visibility":{"_eq":"Public"}}}]}},"role":"user"}]},{"delete_permissions":[{"comment":"","permission":{"filter":{}},"role":"user"}],"insert_permissions":[{"comment":"","permission":{"check":{},"columns":["avatar_url","created_at","display_name","id","unit_preference","updated_at"]},"role":"user"}],"object_relationships":[{"name":"user","using":{"foreign_key_constraint_on":"id"}}],"select_permissions":[{"comment":"","permission":{"columns":["avatar_url","display_name","length_unit","unit_preference","weight_unit","created_at","updated_at","id"],"filter":{}},"role":"public"},{"comment":"","permission":{"columns":["avatar_url","display_name","length_unit","unit_preference","weight_unit","created_at","updated_at","id"],"filter":{}},"role":"user"}],"table":{"name":"profiles","schema":"potterbase"},"update_permissions":[{"comment":"","permission":{"check":{},"columns":["avatar_url","created_at","display_name","id","unit_preference","updated_at"],"filter":{}},"role":"user"}]},{"array_relationships":[{"name":"files","using":{"foreign_key_constraint_on":{"column":"bucket_id","table":{"name":"files","schema":"storage"}}}}],"configuration":{"column_config":{"cache_control":{"custom_name":"cacheControl"},"created_at":{"custom_name":"createdAt"},"download_expiration":{"custom_name":"downloadExpiration"},"id":{"custom_name":"id"},"max_upload_file_size":{"custom_name":"maxUploadFileSize"},"min_upload_file_size":{"custom_name":"minUploadFileSize"},"presigned_urls_enabled":{"custom_name":"presignedUrlsEnabled"},"updated_at":{"custom_name":"updatedAt"}},"custom_column_names":{"cache_control":"cacheControl","created_at":"createdAt","download_expiration":"downloadExpiration","id":"id","max_upload_file_size":"maxUploadFileSize","min_upload_file_size":"minUploadFileSize","presigned_urls_enabled":"presignedUrlsEnabled","updated_at":"updatedAt"},"custom_name":"buckets","custom_root_fields":{"delete":"deleteBuckets","delete_by_pk":"deleteBucket","insert":"insertBuckets","insert_one":"insertBucket","select":"buckets","select_aggregate":"bucketsAggregate","select_by_pk":"bucket","update":"updateBuckets","update_by_pk":"updateBucket"}},"delete_permissions":[{"comment":"","permission":{"filter":{}},"role":"public"},{"comment":"","permission":{"filter":{}},"role":"user"}],"insert_permissions":[{"comment":"","permission":{"check":{},"columns":["presigned_urls_enabled","download_expiration","max_upload_file_size","min_upload_file_size","cache_control","id","created_at","updated_at"]},"role":"public"},{"comment":"","permission":{"check":{},"columns":["presigned_urls_enabled","download_expiration","max_upload_file_size","min_upload_file_size","cache_control","id","created_at","updated_at"]},"role":"user"}],"select_permissions":[{"comment":"","permission":{"columns":["presigned_urls_enabled","download_expiration","max_upload_file_size","min_upload_file_size","cache_control","id","created_at","updated_at"],"filter":{}},"role":"public"},{"comment":"","permission":{"columns":["presigned_urls_enabled","download_expiration","max_upload_file_size","min_upload_file_size","cache_control","id","created_at","updated_at"],"filter":{}},"role":"user"}],"table":{"name":"buckets","schema":"storage"},"update_permissions":[{"comment":"","permission":{"check":{},"columns":["presigned_urls_enabled","download_expiration","max_upload_file_size","min_upload_file_size","cache_control","id","created_at","updated_at"],"filter":{}},"role":"public"},{"comment":"","permission":{"check":{},"columns":["presigned_urls_enabled","download_expiration","max_upload_file_size","min_upload_file_size","cache_control","id","created_at","updated_at"],"filter":{}},"role":"user"}]},{"configuration":{"column_config":{"bucket_id":{"custom_name":"bucketId"},"created_at":{"custom_name":"createdAt"},"etag":{"custom_name":"etag"},"id":{"custom_name":"id"},"is_uploaded":{"custom_name":"isUploaded"},"metadata":{"custom_name":"metadata"},"mime_type":{"custom_name":"mimeType"},"name":{"custom_name":"name"},"size":{"custom_name":"size"},"updated_at":{"custom_name":"updatedAt"},"uploaded_by_user_id":{"custom_name":"uploadedByUserId"}},"custom_column_names":{"bucket_id":"bucketId","created_at":"createdAt","etag":"etag","id":"id","is_uploaded":"isUploaded","metadata":"metadata","mime_type":"mimeType","name":"name","size":"size","updated_at":"updatedAt","uploaded_by_user_id":"uploadedByUserId"},"custom_name":"files","custom_root_fields":{"delete":"deleteFiles","delete_by_pk":"deleteFile","insert":"insertFiles","insert_one":"insertFile","select":"files","select_aggregate":"filesAggregate","select_by_pk":"file","update":"updateFiles","update_by_pk":"updateFile"}},"delete_permissions":[{"comment":"","permission":{"filter":{}},"role":"user"}],"insert_permissions":[{"comment":"","permission":{"check":{},"columns":["is_uploaded","size","metadata","bucket_id","etag","mime_type","name","created_at","updated_at","id","uploaded_by_user_id"]},"role":"public"},{"comment":"","permission":{"check":{},"columns":["is_uploaded","size","metadata","bucket_id","etag","mime_type","name","created_at","updated_at","id","uploaded_by_user_id"]},"role":"user"}],"object_relationships":[{"name":"bucket","using":{"foreign_key_constraint_on":"bucket_id"}}],"select_permissions":[{"comment":"","permission":{"columns":["is_uploaded","size","metadata","bucket_id","etag","mime_type","name","created_at","updated_at","id","uploaded_by_user_id"],"filter":{}},"role":"public"},{"comment":"","permission":{"columns":["is_uploaded","size","metadata","bucket_id","etag","mime_type","name","created_at","updated_at","id","uploaded_by_user_id"],"filter":{}},"role":"user"}],"table":{"name":"files","schema":"storage"},"update_permissions":[{"comment":"","permission":{"check":{},"columns":["is_uploaded","size","metadata","bucket_id","etag","mime_type","name","created_at","updated_at","id","uploaded_by_user_id"],"filter":{}},"role":"user"}]},{"configuration":{"column_config":{"created_at":{"custom_name":"createdAt"},"file_id":{"custom_name":"fileId"},"filename":{"custom_name":"filename"},"id":{"custom_name":"id"},"updated_at":{"custom_name":"updatedAt"},"user_session":{"custom_name":"userSession"},"virus":{"custom_name":"virus"}},"custom_column_names":{"created_at":"createdAt","file_id":"fileId","filename":"filename","id":"id","updated_at":"updatedAt","user_session":"userSession","virus":"virus"},"custom_name":"virus","custom_root_fields":{"delete":"deleteViruses","delete_by_pk":"deleteVirus","insert":"insertViruses","insert_one":"insertVirus","select":"viruses","select_aggregate":"virusesAggregate","select_by_pk":"virus","update":"updateViruses","update_by_pk":"updateVirus"}},"object_relationships":[{"name":"file","using":{"foreign_key_constraint_on":"file_id"}}],"table":{"name":"virus","schema":"storage"}}]}],"version":3}	207
\.


--
-- Data for Name: hdb_scheduled_event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: nhost_hasura
--

COPY hdb_catalog.hdb_scheduled_event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
\.


--
-- Data for Name: hdb_scheduled_events; Type: TABLE DATA; Schema: hdb_catalog; Owner: nhost_hasura
--

COPY hdb_catalog.hdb_scheduled_events (id, webhook_conf, scheduled_time, retry_conf, payload, header_conf, status, tries, created_at, next_retry_at, comment) FROM stdin;
\.


--
-- Data for Name: hdb_schema_notifications; Type: TABLE DATA; Schema: hdb_catalog; Owner: nhost_hasura
--

COPY hdb_catalog.hdb_schema_notifications (id, notification, resource_version, instance_id, updated_at) FROM stdin;
1	{"metadata":false,"remote_schemas":[],"sources":["default"],"data_connectors":[]}	207	84b4ab67-8eef-4289-8a5d-30b0af868dd9	2025-08-22 16:29:18.893448+00
\.


--
-- Data for Name: hdb_version; Type: TABLE DATA; Schema: hdb_catalog; Owner: nhost_hasura
--

COPY hdb_catalog.hdb_version (hasura_uuid, version, upgraded_on, cli_state, console_state, ee_client_id, ee_client_secret) FROM stdin;
8e83df2a-065a-4c91-9248-8aa03add755d	48	2025-08-22 16:28:59.253449+00	{"settings": {"migration_mode": "true"}, "migrations": {"default": {"1757602023758": false, "1757604061404": false, "1757681169771": false}}, "isStateCopyCompleted": false}	{}	\N	\N
\.


--
-- Data for Name: clay_body; Type: TABLE DATA; Schema: potterbase; Owner: nhost_hasura
--

COPY potterbase.clay_body (id, name, brand, notes) FROM stdin;
1	Stoneware Buff	Laguna	Cone 6 oxidation
2	B-Mix	\N	\N
6	B-Mix 5	\N	\N
7	B-Mix 10	\N	\N
8	Speckled Buff	\N	\N
9	Porcelain	\N	\N
10	Stoneware 5	\N	\N
11	Recycled Studio Mix	\N	\N
13	something	\N	\N
14	Brown Bear	\N	\N
\.


--
-- Data for Name: glaze; Type: TABLE DATA; Schema: potterbase; Owner: nhost_hasura
--

COPY potterbase.glaze (id, name, brand, cone, color, notes, code, series, finish) FROM stdin;
12	Tiger’s Eye	Mayco	5-10	Brown	\N	SW-112	Stoneware	Glossy
13	Stoned Denim	Mayco	5-10	Blue	\N	SW-101	Stoneware	Glossy
14	Opal Lustre	Mayco	5-10	Neutral	\N	SW-219	Stoneware	Glossy
15	Weathered Blue	Mayco	5-10	Blue	\N	SW-136	Stoneware	Glossy
16	Green Tea	Mayco	5-10	Green	\N	SW-108	Stoneware	Glossy
17	Tropical Teal	Mayco	5-10	Teal	\N	SW-224	Stoneware	Glossy
18	Rainforest	Mayco	5-10	Green	\N	SW-165	Stoneware	Glossy
19	Black Walnut	Mayco	5-10	Brown	\N	SW-104	Stoneware	Glossy
20	Obsidian	Amaco	5-10	Black	\N	C-1	Celadon	Glossy
21	Blue Rutile	Amaco	5-10	Blue	\N	PC-20	Potter’s Choice	Glossy
22	Power Turquoise	Coyote	5-6	Turquoise	\N	VC-108	Gloss Glaze	Glossy
23	Burnished Steel	Mayco	5-10	Metallic	\N	EL-119	Elements	Glossy
24	Deep Sea	Amaco	5-6	Blue	\N	C-29	Celadon	Glossy
25	Honey Flux	Amaco	5-6	Neutral	\N	PC-17	Potter's Choice	Glossy
\.


--
-- Data for Name: piece; Type: TABLE DATA; Schema: potterbase; Owner: nhost_hasura
--

COPY potterbase.piece (title, id, created_at, updated_at, owner_id, visibility, "stageDates", stage, "stageDate", notes) FROM stdin;
Glazey Urnwitch	44	2025-09-03 19:01:31.51628+00	2025-09-03 19:01:31.51628+00	005202a4-fd35-4761-8a91-4faf0f6b1009	private	{}	\N	\N	
Chalky Slipghost	78	2025-09-09 13:42:45.162661+00	2025-09-10 17:57:07.494093+00	2cdfd34c-369c-46ba-8e41-309c66f18ba2	private	{}	\N	\N	
Kilny Claymancer	49	2025-09-04 21:14:23.274871+00	2025-09-05 13:54:23.018323+00	005202a4-fd35-4761-8a91-4faf0f6b1009	public	{}	\N	\N	
Bubbly Wraith	46	2025-09-04 14:04:38.818632+00	2025-09-07 18:33:27.050497+00	005202a4-fd35-4761-8a91-4faf0f6b1009	Public	{}	\N	\N	
Raku Footringfox	47	2025-09-04 14:10:12.832695+00	2025-09-05 17:07:57.194084+00	005202a4-fd35-4761-8a91-4faf0f6b1009	private	{}	\N	\N	
Muddy Handlehog	73	2025-09-06 16:33:04.211844+00	2025-09-10 22:44:52.671496+00	2cdfd34c-369c-46ba-8e41-309c66f18ba2	private	{}	\N	\N	
Spinny Spoutsnake	63	2025-09-05 13:27:37.251179+00	2025-09-05 17:21:35.912095+00	005202a4-fd35-4761-8a91-4faf0f6b1009	Public	{}	\N	\N	
Crackly Kraken	43	2025-09-03 17:54:37.098333+00	2025-09-06 15:31:38.843439+00	005202a4-fd35-4761-8a91-4faf0f6b1009	private	{}	\N	\N	
Slippy Mudskipper	45	2025-09-04 13:59:52.851021+00	2025-09-06 15:32:03.004657+00	005202a4-fd35-4761-8a91-4faf0f6b1009	private	{}	\N	\N	
Smudgy Clayrat	72	2025-09-06 15:38:28.238012+00	2025-09-06 15:38:28.238012+00	005202a4-fd35-4761-8a91-4faf0f6b1009	private	{}	\N	\N	
Gritty Jugwight	77	2025-09-09 13:15:36.784244+00	2025-09-10 23:03:34.410425+00	2cdfd34c-369c-46ba-8e41-309c66f18ba2	private	{}	\N	\N	
Squishy Shardling	48	2025-09-04 19:27:15.400874+00	2025-09-06 15:38:52.200782+00	005202a4-fd35-4761-8a91-4faf0f6b1009	private	{}	\N	\N	THis is a note note
Sandy Jarwurm	79	2025-09-09 16:50:17.0114+00	2025-09-10 23:05:28.172014+00	2cdfd34c-369c-46ba-8e41-309c66f18ba2	private	{}	\N	\N	
\.


--
-- Data for Name: piece_clay; Type: TABLE DATA; Schema: potterbase; Owner: nhost_hasura
--

COPY potterbase.piece_clay (id, piece_id, clay_body_id, notes) FROM stdin;
57	44	2	
60	46	2	
61	46	11	
86	73	2	soupy
56	43	2	
85	73	14	mixed and marbled
91	77	2	\N
92	78	14	\N
93	79	2	\N
59	45	11	
68	47	2	
69	47	11	
70	46	9	
71	48	9	
72	49	11	
81	45	13	
82	72	9	\N
83	72	2	\N
84	63	2	
\.


--
-- Data for Name: piece_firing; Type: TABLE DATA; Schema: potterbase; Owner: nhost_hasura
--

COPY potterbase.piece_firing (id, piece_id, cone, temperature_f, kiln_type, kiln_location, load_name, date, notes) FROM stdin;
24	72	6	\N	\N	\N	\N	\N	\N
32	78	5	\N	\N	\N	\N	\N	\N
8	44	6	\N	\N	\N	\N	\N	\N
10	46	6	\N	\N	\N	\N	\N	\N
7	43	6	\N	\N	\N	\N	\N	\N
11	47	06	\N	\N	\N	\N	\N	\N
12	47	6	\N	\N	\N	\N	\N	\N
9	45	6	\N	\N	\N	\N	\N	\N
13	48	6	\N	\N	\N	\N	\N	\N
14	48	6	\N	\N	\N	\N	\N	\N
16	49	6	\N	\N	\N	\N	\N	\N
27	73	6	\N	Skutt	Missy's hose	\N	\N	10 minute hold
30	77	5	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: piece_glaze; Type: TABLE DATA; Schema: potterbase; Owner: nhost_hasura
--

COPY potterbase.piece_glaze (id, piece_id, glaze_id, layer_number, application_method, notes) FROM stdin;
71	77	19	2	Brush	\N
27	45	21	1	\N	
32	45	23	1	\N	
33	45	15	1	\N	
25	45	19	1	\N	
72	77	18	2	Brush	\N
73	77	25	1	Brush	Top 2/3rds
74	78	13	2	Brush	\N
75	78	25	2	Brush	Top 3/4ths
39	46	22	1	\N	
40	46	23	1	\N	
41	48	19	1	\N	
42	49	23	1	\N	
76	79	17	1	Brush	\N
77	79	20	2	Brush	\N
23	43	19	1	Spray	
24	44	23	1	\N	
29	46	21	1	\N	
30	47	19	1	\N	
63	72	19	2	brushed	stripes
64	73	25	2	Brush	Inside an outside
65	73	24	2	Brush	Outside and on rim
\.


--
-- Data for Name: piece_image; Type: TABLE DATA; Schema: potterbase; Owner: nhost_hasura
--

COPY potterbase.piece_image (id, piece_id, file_id, url, stage, is_main, uploaded_at, taken_at, notes) FROM stdin;
b496d0ba-5e37-4236-895f-5de520256888	43	e03aff0f-6f45-4457-86da-6f23e3f41b75	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/e03aff0f-6f45-4457-86da-6f23e3f41b75	\N	f	2025-09-03 18:50:29.761801+00	\N	\N
fdd92a00-d900-4351-b457-d753cf29a630	43	43bf7948-ff99-4ea7-a600-d0957091d7f9	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/43bf7948-ff99-4ea7-a600-d0957091d7f9	\N	t	2025-09-03 18:52:53.874724+00	\N	\N
fdf16224-97e5-4ee2-8422-50f92d5c19c2	43	d0df1805-c99c-41e4-a368-5255d7d13c4e	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/d0df1805-c99c-41e4-a368-5255d7d13c4e	\N	t	2025-09-04 16:26:57.661105+00	\N	
7e11301c-02ea-46ba-8dc5-956c88cd62bd	43	5be526ef-0667-4e10-ab4e-354c6c1afb74	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/5be526ef-0667-4e10-ab4e-354c6c1afb74	\N	f	2025-09-04 16:26:57.914982+00	\N	
a55c5c17-fd96-454f-8d78-59e1967dbc41	44	3b775529-c474-4cfb-8183-a5d913a898d4	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/3b775529-c474-4cfb-8183-a5d913a898d4	\N	t	2025-09-04 16:27:14.062801+00	\N	\N
2a4439b8-8e7b-45f4-a04d-1acc71f94b4c	45	9260de6a-7bce-4e50-a3d9-c2ffe8e606db	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/9260de6a-7bce-4e50-a3d9-c2ffe8e606db	\N	t	2025-09-04 16:27:17.585687+00	\N	\N
294f068d-7976-49db-afab-debd6484d7b0	46	56e1d351-042a-44e8-b668-861fb294fcf2	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/56e1d351-042a-44e8-b668-861fb294fcf2	\N	t	2025-09-04 16:27:21.582267+00	\N	\N
5e7268c6-defd-4b49-9813-c92bd4511a7c	47	f84124c8-2bbf-48f7-8cba-3985fa36c2ca	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/f84124c8-2bbf-48f7-8cba-3985fa36c2ca	\N	t	2025-09-04 16:27:27.069225+00	\N	\N
517e0e43-ea54-433b-a31f-f29cdfb01725	45	446befdd-2a77-4a84-99a9-4f9877ca78a5	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/446befdd-2a77-4a84-99a9-4f9877ca78a5	\N	f	2025-09-04 16:32:28.091997+00	\N	\N
a70408ee-4627-4df1-8e65-fbc71fdc0379	48	030dd373-5edf-4845-b570-6818a5f48d6f	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/030dd373-5edf-4845-b570-6818a5f48d6f	\N	t	2025-09-04 19:27:16.89243+00	\N	
f71789f5-5f10-497e-ac66-e2683e50b1bf	63	5ca13706-4e3a-46b5-9878-8f30abd47c96	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/5ca13706-4e3a-46b5-9878-8f30abd47c96	\N	t	2025-09-05 13:27:38.049883+00	\N	
854e1344-6e7e-4825-ab41-1e8f669b81a1	72	cc6a4cfe-fa90-46e8-b0d3-a89bb6032df2	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/cc6a4cfe-fa90-46e8-b0d3-a89bb6032df2	formed	t	2025-09-06 15:38:29.807888+00	\N	
84c6f029-8268-4d68-8ff2-114696ff9e6a	73	bd3ca16d-dd7a-4090-997e-f2b4a216abd2	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/bd3ca16d-dd7a-4090-997e-f2b4a216abd2	\N	t	2025-09-06 16:33:05.61256+00	\N	
3ede4874-e973-4c45-9230-0a6bf1d691f3	73	da4ee91a-9d57-40e0-9d2d-5c403ba79c9f	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/da4ee91a-9d57-40e0-9d2d-5c403ba79c9f	\N	f	2025-09-07 14:42:07.505244+00	\N	
0034a94c-e453-4a1e-a645-2f759741de33	73	fa740eb6-bd4a-41d6-9216-f0919ec71cf7	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/fa740eb6-bd4a-41d6-9216-f0919ec71cf7	\N	t	2025-09-07 14:42:07.74061+00	\N	
75b9b013-c4c5-41e4-aa62-a6433b2663eb	73	c6f56b42-1d1e-45f2-a267-d064fc2da759	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/c6f56b42-1d1e-45f2-a267-d064fc2da759	\N	f	2025-09-07 15:32:29.400423+00	\N	\N
f3302c4a-b1c4-4405-9fdc-d14d918ff21b	77	c3320934-6131-41a5-8d4a-ccfe3993706e	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/c3320934-6131-41a5-8d4a-ccfe3993706e	glazed	f	2025-09-09 13:15:38.705277+00	\N	
b216373f-ca27-49d4-b636-7ef3a5fffcaa	77	1fe7f8b0-7f72-4396-96ff-c85e263736a7	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/1fe7f8b0-7f72-4396-96ff-c85e263736a7	\N	t	2025-09-09 13:15:38.946307+00	\N	
cdcf1478-7e02-4453-a1ce-b43501f018f8	77	e6b30e48-6f7d-4828-a670-ae7846ce097a	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/e6b30e48-6f7d-4828-a670-ae7846ce097a	\N	f	2025-09-09 13:15:39.271134+00	\N	
bd09707a-1249-4095-af88-bae5fea9879a	78	37ff08be-0599-48b9-95b3-638dc41ae825	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/37ff08be-0599-48b9-95b3-638dc41ae825	glazed	f	2025-09-09 13:42:47.054256+00	\N	
d85b55d3-60df-4058-a74e-423226012702	78	2d794769-80f7-42e4-ba78-f895dc7cd6c9	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/2d794769-80f7-42e4-ba78-f895dc7cd6c9	fired	t	2025-09-09 13:42:47.470256+00	\N	
a0bf4af4-2d10-44d5-8dd7-f86b0b56a0f0	79	05ac1c17-bb36-4942-989f-6d633ce1eae0	https://tmrlxlwvkpqbgbgfoysh.storage.us-east-1.nhost.run/v1/files/05ac1c17-bb36-4942-989f-6d633ce1eae0	\N	t	2025-09-09 16:50:28.721896+00	\N	
\.


--
-- Data for Name: piece_stage_history; Type: TABLE DATA; Schema: potterbase; Owner: nhost_hasura
--

COPY potterbase.piece_stage_history (id, piece_id, stage, date, length_cm, width_cm, height_cm, weight_g, location) FROM stdin;
289	73	glazed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
77	43	lump	2025-09-03 00:00:00+00	\N	\N	\N	\N	\N
78	43	formed	2025-09-03 18:03:49.164+00	\N	\N	\N	\N	\N
79	43	lump	2025-09-03 18:03:52.703+00	\N	\N	\N	\N	\N
80	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
81	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
82	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
83	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
84	44	lump	2025-09-03 00:00:00+00	\N	\N	\N	\N	\N
85	45	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
86	46	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
87	47	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
88	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
89	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
90	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
91	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
92	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
93	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
94	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
95	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
96	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
97	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
98	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
99	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
100	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
101	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
102	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
103	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
104	47	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
105	47	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
106	47	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
107	47	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
108	43	glazed	2025-09-04 17:26:40.441+00	\N	\N	\N	\N	\N
109	43	trimmed	2025-09-04 17:26:42.245+00	\N	\N	\N	\N	\N
110	47	glazed	2025-09-04 17:26:45.445+00	\N	\N	\N	\N	\N
111	45	glazed	2025-09-04 17:26:46.649+00	\N	\N	\N	\N	\N
112	44	glazed	2025-09-04 17:26:48.7+00	\N	\N	\N	\N	\N
113	46	glazed	2025-09-04 17:26:50.655+00	\N	\N	\N	\N	\N
114	45	glazed	2025-09-04 17:26:46.649+00	\N	\N	\N	\N	\N
115	48	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
116	48	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
117	48	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
118	48	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
119	45	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
120	45	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
121	47	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
122	47	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
123	47	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
124	47	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
125	47	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
126	47	glazed	2025-09-04 17:26:45.445+00	\N	\N	\N	\N	\N
129	48	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
130	48	bisque	2025-09-04 20:25:55.81+00	\N	\N	\N	\N	\N
131	49	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
132	49	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
133	49	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
291	73	formed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
136	63	formed	2025-09-05 00:00:00+00	\N	\N	\N	\N	\N
292	73	trimmed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
293	73	bisque	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
298	73	formed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
299	73	trimmed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
300	73	bisque	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
301	73	glazed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
302	73	formed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
303	73	trimmed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
144	49	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
304	73	bisque	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
305	73	glazed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
310	63	trimmed	2025-09-06 18:18:07.271+00	\N	\N	\N	\N	\N
311	63	lump	2025-09-06 18:18:12+00	\N	\N	\N	\N	\N
374	73	fired	2025-09-07 00:00:00+00	11.4	8.9	12.1	371.9	Kitchen
155	63	formed	2025-09-05 00:00:00+00	\N	\N	\N	\N	\N
127	46	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
372	73	fired	2025-09-07 00:00:00+00	\N	\N	\N	\N	\N
128	46	glazed	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
379	77	lump	2025-09-09 00:00:00+00	\N	\N	\N	\N	\N
380	77	formed	2025-09-09 00:00:00+00	\N	\N	\N	\N	\N
423	77	fired	2025-09-10 23:03:12.215+00	\N	\N	\N	\N	\N
391	79	lump	2025-09-09 00:00:00+00	\N	\N	\N	\N	\N
290	73	lump	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
373	73	fired	2025-09-07 00:00:00+00	11.4	8.9	12.1	\N	Kitchen
392	79	formed	2025-09-09 00:00:00+00	\N	\N	\N	\N	\N
393	79	trimmed	2025-09-09 00:00:00+00	\N	\N	\N	\N	\N
394	79	bisque	2025-09-09 00:00:00+00	\N	\N	\N	\N	\N
395	79	glazed	2025-09-09 00:00:00+00	\N	\N	\N	\N	\N
403	78	fired	2025-09-10 00:00:00+00	\N	\N	\N	\N	\N
390	79	fired	2025-09-09 00:00:00+00	\N	\N	\N	\N	\N
419	79	fired	2025-09-10 23:01:45.477+00	\N	\N	\N	\N	\N
223	45	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
224	45	glazed	2025-09-04 17:26:46.649+00	\N	\N	\N	\N	\N
225	45	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
226	45	glazed	2025-09-04 17:26:46.649+00	\N	\N	\N	\N	\N
227	43	lump	2025-09-03 18:03:52.703+00	\N	\N	\N	\N	\N
228	43	formed	2025-09-03 18:03:49.164+00	\N	\N	\N	\N	\N
229	43	trimmed	2025-09-04 17:26:42.245+00	\N	\N	\N	\N	\N
230	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
231	43	glazed	2025-09-04 17:26:40.441+00	\N	\N	\N	\N	\N
232	43	lump	2025-09-03 18:03:52.703+00	\N	\N	\N	\N	\N
233	43	formed	2025-09-03 18:03:49.164+00	\N	\N	\N	\N	\N
234	43	trimmed	2025-09-04 17:26:42.245+00	\N	\N	\N	\N	\N
235	43	bisque	2025-09-03 18:03:54.561+00	\N	\N	\N	\N	\N
236	43	glazed	2025-09-04 17:26:40.441+00	\N	\N	\N	\N	\N
237	43	sold_posted	2025-09-05 16:43:58.444+00	\N	\N	\N	\N	\N
238	47	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
239	47	glazed	2025-09-04 17:26:45.445+00	\N	\N	\N	\N	\N
240	47	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
241	47	glazed	2025-09-04 17:26:45.445+00	\N	\N	\N	\N	\N
294	73	formed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
295	73	trimmed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
296	73	bisque	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
312	73	formed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
315	73	glazed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
268	63	formed	2025-09-05 00:00:00+00	\N	\N	\N	\N	\N
269	63	formed	2025-09-05 00:00:00+00	\N	\N	\N	\N	\N
270	43	lump	2025-09-03 00:00:00+00	\N	\N	\N	\N	\N
271	43	formed	2025-09-03 00:00:00+00	\N	\N	\N	\N	\N
272	43	trimmed	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
273	43	bisque	2025-09-03 00:00:00+00	\N	\N	\N	\N	\N
274	43	glazed	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
275	43	sold_posted	2025-09-05 00:00:00+00	\N	\N	\N	\N	\N
276	45	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
277	45	glazed	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
278	72	trimmed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
279	72	lump	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
280	72	formed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
284	48	lump	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
285	48	bisque	2025-09-04 00:00:00+00	\N	\N	\N	\N	\N
287	63	formed	2025-09-05 00:00:00+00	\N	\N	\N	\N	\N
288	47	fired	2025-09-06 15:41:04.188+00	\N	\N	\N	\N	\N
385	78	lump	2025-09-09 00:00:00+00	\N	\N	\N	\N	\N
386	78	formed	2025-09-09 00:00:00+00	\N	\N	\N	\N	\N
387	78	trimmed	2025-09-09 00:00:00+00	\N	\N	\N	\N	\N
388	78	bisque	2025-09-09 00:00:00+00	\N	\N	\N	\N	\N
306	73	formed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
389	78	glazed	2025-09-09 00:00:00+00	\N	\N	\N	\N	\N
313	73	trimmed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
308	73	bisque	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
297	73	glazed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
420	79	fired	2025-09-10 23:01:51.282+00	\N	\N	\N	\N	\N
421	79	sold_posted	2025-09-10 23:03:00.092+00	\N	\N	\N	\N	\N
307	73	trimmed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
314	73	bisque	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
309	73	glazed	2025-09-06 00:00:00+00	\N	\N	\N	\N	\N
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: potterbase; Owner: nhost_hasura
--

COPY potterbase.profiles (id, display_name, avatar_url, created_at, updated_at, unit_preference) FROM stdin;
bf079960-eed3-497e-adc2-480a2f91fe3f	1@2.com	\N	2025-09-06 18:54:19.557587+00	2025-09-06 18:54:19.557587+00	imperial
005202a4-fd35-4761-8a91-4faf0f6b1009	admin	\N	2025-09-06 18:54:19.557587+00	2025-09-06 18:54:19.557587+00	imperial
2cdfd34c-369c-46ba-8e41-309c66f18ba2	Ally	\N	2025-09-06 18:54:19.557587+00	2025-09-07 14:01:24.444969+00	imperial
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: nhost_storage_admin
--

COPY storage.buckets (id, created_at, updated_at, download_expiration, min_upload_file_size, max_upload_file_size, cache_control, presigned_urls_enabled) FROM stdin;
default	2025-08-22 16:29:11.622505+00	2025-08-22 16:29:11.622505+00	30	1	50000000	max-age=3600	t
\.


--
-- Data for Name: files; Type: TABLE DATA; Schema: storage; Owner: nhost_storage_admin
--

COPY storage.files (id, created_at, updated_at, bucket_id, name, size, mime_type, etag, is_uploaded, uploaded_by_user_id, metadata) FROM stdin;
ccf0e712-ab11-41d9-a3ed-86e95e735510	2025-09-02 13:42:12.400652+00	2025-09-02 13:42:12.640594+00	default	IMG_6293.JPG	2522621	image/jpeg	"2aba00f7f04cb0f08997308a5288f15b"	t	\N	\N
b66f4e6b-c95e-44e8-ada4-ad6e30b34d4a	2025-09-02 13:42:17.933775+00	2025-09-02 13:42:17.977386+00	default	IMG_6297.JPG	2175739	image/jpeg	"1743d1cc8bc4b87c58ba6efd7523f461"	t	\N	\N
ae1375f4-f59d-4667-84d7-742376d05d18	2025-09-02 13:50:29.550649+00	2025-09-02 13:50:29.636013+00	default	blob	86601	image/jpeg	"35a8759e2b4263881447fe4a15b51db0"	t	\N	\N
147fc282-3a0c-456d-a5f4-220284e874f6	2025-09-02 13:55:18.791866+00	2025-09-02 13:55:18.886414+00	default	blob	131968	image/jpeg	"922029323a84ca5a477c1674b4e7ac9d"	t	\N	\N
70f6aebc-f6e5-430a-9f35-7350fe8f5939	2025-09-02 13:56:37.572008+00	2025-09-02 13:56:37.653167+00	default	blob	131968	image/jpeg	"922029323a84ca5a477c1674b4e7ac9d"	t	\N	\N
d066942e-95d7-4eb9-b8dc-472f85805fe5	2025-09-02 13:59:35.687066+00	2025-09-02 13:59:35.772171+00	default	blob	119539	image/jpeg	"dfbe874c7e0615cd3fa674484275ddfb"	t	\N	\N
9930664b-2f4f-49d1-a515-29b3eb5b2544	2025-09-02 14:00:15.13371+00	2025-09-02 14:00:15.22527+00	default	blob	131968	image/jpeg	"922029323a84ca5a477c1674b4e7ac9d"	t	\N	\N
b84c8501-8fbb-49fe-9b8e-9eb07a7faeb1	2025-09-02 14:15:32.443333+00	2025-09-02 14:15:32.52029+00	default	blob	86601	image/jpeg	"35a8759e2b4263881447fe4a15b51db0"	t	\N	\N
369f3470-0ab3-4de6-a2ce-9fc188fc1cde	2025-09-02 14:20:43.217075+00	2025-09-02 14:20:43.300733+00	default	blob	119539	image/jpeg	"dfbe874c7e0615cd3fa674484275ddfb"	t	\N	\N
18c8caf6-20c4-42e1-907e-2204e13ee5dd	2025-09-02 18:43:21.045235+00	2025-09-02 18:43:21.278262+00	default	blob	86601	image/jpeg	"35a8759e2b4263881447fe4a15b51db0"	t	\N	\N
b30ca5c1-2345-42a3-a499-3a8771d3023d	2025-09-02 18:43:21.631299+00	2025-09-02 18:43:21.674466+00	default	blob	119539	image/jpeg	"dfbe874c7e0615cd3fa674484275ddfb"	t	\N	\N
6a148806-88a2-4199-bb2d-80c75352cfea	2025-09-02 22:17:49.392078+00	2025-09-02 22:17:49.596074+00	default	blob	31509	image/jpeg	"764160e885fee56414509c254aa28484"	t	\N	\N
c036662d-f110-400d-860e-b8718bb56b05	2025-09-03 16:05:36.925122+00	2025-09-03 16:05:37.010038+00	default	blob	86601	image/jpeg	"35a8759e2b4263881447fe4a15b51db0"	t	\N	\N
950cde90-4305-4fe4-a015-6485b668ca06	2025-09-03 17:54:37.887393+00	2025-09-03 17:54:38.092417+00	default	blob	86601	image/jpeg	"35a8759e2b4263881447fe4a15b51db0"	t	\N	\N
20907c60-70e9-43fe-9893-29e87605fc7b	2025-09-03 18:05:33.926932+00	2025-09-03 18:05:34.078725+00	default	blob	119539	image/jpeg	"dfbe874c7e0615cd3fa674484275ddfb"	t	\N	\N
e03aff0f-6f45-4457-86da-6f23e3f41b75	2025-09-03 18:50:29.484207+00	2025-09-03 18:50:29.692113+00	default	IMG_6296.JPG	2004240	image/jpeg	"2434fc9662a59ff3981e9a261877cec4"	t	\N	\N
43bf7948-ff99-4ea7-a600-d0957091d7f9	2025-09-03 18:52:53.579369+00	2025-09-03 18:52:53.758422+00	default	IMG_6294.JPG	2387480	image/jpeg	"ae1858e60477630c9e29e1025b04c8e9"	t	\N	\N
01f6bd56-a18e-493b-970c-c9309d5e204b	2025-09-04 15:23:00.182785+00	2025-09-04 15:23:00.374243+00	default	blob	177066	image/jpeg	"a4221b096aa7f96c4d40024f7dc66476"	t	\N	\N
d0df1805-c99c-41e4-a368-5255d7d13c4e	2025-09-04 16:26:57.39027+00	2025-09-04 16:26:57.606836+00	default	blob	181842	image/jpeg	"913043f2e3a0d5f7a0c6870ad36eeba3"	t	\N	\N
5be526ef-0667-4e10-ab4e-354c6c1afb74	2025-09-04 16:26:57.780922+00	2025-09-04 16:26:57.859626+00	default	blob	106542	image/jpeg	"1a0774f7f96b71bd4318139b67f12b73"	t	\N	\N
3b775529-c474-4cfb-8183-a5d913a898d4	2025-09-04 16:27:13.706546+00	2025-09-04 16:27:13.910643+00	default	IMG_6296.JPG	2004240	image/jpeg	"2434fc9662a59ff3981e9a261877cec4"	t	\N	\N
9260de6a-7bce-4e50-a3d9-c2ffe8e606db	2025-09-04 16:27:17.327435+00	2025-09-04 16:27:17.454954+00	default	IMG_6296.JPG	2004240	image/jpeg	"2434fc9662a59ff3981e9a261877cec4"	t	\N	\N
56e1d351-042a-44e8-b668-861fb294fcf2	2025-09-04 16:27:21.30931+00	2025-09-04 16:27:21.438519+00	default	IMG_6298.JPG	2089725	image/jpeg	"c54b36823d946b7fea2ab31494006fe7"	t	\N	\N
f84124c8-2bbf-48f7-8cba-3985fa36c2ca	2025-09-04 16:27:26.737252+00	2025-09-04 16:27:26.927105+00	default	IMG_6294.JPG	2387480	image/jpeg	"ae1858e60477630c9e29e1025b04c8e9"	t	\N	\N
446befdd-2a77-4a84-99a9-4f9877ca78a5	2025-09-04 16:32:27.724551+00	2025-09-04 16:32:27.925066+00	default	IMG_6296.JPG	2004240	image/jpeg	"2434fc9662a59ff3981e9a261877cec4"	t	\N	\N
030dd373-5edf-4845-b570-6818a5f48d6f	2025-09-04 19:27:16.586432+00	2025-09-04 19:27:16.830734+00	default	blob	181842	image/jpeg	"913043f2e3a0d5f7a0c6870ad36eeba3"	t	\N	\N
5ca13706-4e3a-46b5-9878-8f30abd47c96	2025-09-05 13:27:37.80607+00	2025-09-05 13:27:37.941401+00	default	blob	156214	image/jpeg	"affa0f8f20c640d5b72e890582d4af3a"	t	\N	\N
b2d607af-a061-4f21-b98f-a2856e2ccdce	2025-09-05 13:49:28.901828+00	2025-09-05 13:49:29.045683+00	default	IMG_6425.JPG	2074499	image/jpeg	"d68199cb4afef64a5f7fd2d8a5f1aee7"	t	\N	\N
3a86cf24-cf34-4802-973c-58169e712b22	2025-09-05 13:49:36.29551+00	2025-09-05 13:49:36.457044+00	default	IMG_6425.JPG	2074499	image/jpeg	"d68199cb4afef64a5f7fd2d8a5f1aee7"	t	\N	\N
cc6a4cfe-fa90-46e8-b0d3-a89bb6032df2	2025-09-06 15:38:29.551513+00	2025-09-06 15:38:29.649031+00	default	blob	156214	image/jpeg	"affa0f8f20c640d5b72e890582d4af3a"	t	\N	\N
33fdfd75-dd80-48a2-be99-99b998bddd9b	2025-09-06 15:39:15.5709+00	2025-09-06 15:39:15.70424+00	default	IMG_6425.JPG	2074499	image/jpeg	"d68199cb4afef64a5f7fd2d8a5f1aee7"	t	\N	\N
bd3ca16d-dd7a-4090-997e-f2b4a216abd2	2025-09-06 16:33:05.348356+00	2025-09-06 16:33:05.527777+00	default	blob	314631	image/jpeg	"5d9aa2c1141dbe2076e89a4a68970420"	t	\N	\N
da4ee91a-9d57-40e0-9d2d-5c403ba79c9f	2025-09-07 14:42:07.245048+00	2025-09-07 14:42:07.421107+00	default	blob	254425	image/jpeg	"5be09ff14e1dd77cfa984acfa054a3c1"	t	\N	\N
fa740eb6-bd4a-41d6-9216-f0919ec71cf7	2025-09-07 14:42:07.645628+00	2025-09-07 14:42:07.682811+00	default	blob	272674	image/jpeg	"a3ca74329ea067f5bdcca53a51633464"	t	\N	\N
c6f56b42-1d1e-45f2-a267-d064fc2da759	2025-09-07 15:32:29.159981+00	2025-09-07 15:32:29.31446+00	default	Screenshot 2025-09-07 at 11.32.00 AM.png	729792	image/png	"0f1c17d4ae3a994b37600bf33a7a6a77"	t	\N	\N
c3320934-6131-41a5-8d4a-ccfe3993706e	2025-09-09 13:15:38.446051+00	2025-09-09 13:15:38.57263+00	default	blob	181842	image/jpeg	"913043f2e3a0d5f7a0c6870ad36eeba3"	t	\N	\N
1fe7f8b0-7f72-4396-96ff-c85e263736a7	2025-09-09 13:15:38.856695+00	2025-09-09 13:15:38.889437+00	default	blob	277486	image/jpeg	"1c55da22f1090012a756e965242c0891"	t	\N	\N
e6b30e48-6f7d-4828-a670-ae7846ce097a	2025-09-09 13:15:39.179972+00	2025-09-09 13:15:39.214589+00	default	blob	339529	image/jpeg	"68f968dcb437b6a277a7e537223230dc"	t	\N	\N
37ff08be-0599-48b9-95b3-638dc41ae825	2025-09-09 13:42:46.858762+00	2025-09-09 13:42:46.958381+00	default	blob	119536	image/jpeg	"5b9df265eaf9b6bcfd94b8312049f0d1"	t	\N	\N
2d794769-80f7-42e4-ba78-f895dc7cd6c9	2025-09-09 13:42:47.363474+00	2025-09-09 13:42:47.404886+00	default	blob	235826	image/jpeg	"7fd1b21c2a9c0fe8eee90b96ada3da15"	t	\N	\N
05ac1c17-bb36-4942-989f-6d633ce1eae0	2025-09-09 16:50:28.354488+00	2025-09-09 16:50:28.576935+00	default	blob	177067	image/jpeg	"928444f7e98d991926cefd6d3b8f7771"	t	\N	\N
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: storage; Owner: nhost_storage_admin
--

COPY storage.schema_migrations (version, dirty) FROM stdin;
5	f
\.


--
-- Data for Name: virus; Type: TABLE DATA; Schema: storage; Owner: nhost_storage_admin
--

COPY storage.virus (id, created_at, updated_at, file_id, filename, virus, user_session) FROM stdin;
\.


--
-- Name: clay_body_id_seq; Type: SEQUENCE SET; Schema: potterbase; Owner: nhost_hasura
--

SELECT pg_catalog.setval('potterbase.clay_body_id_seq', 14, true);


--
-- Name: glaze_id_seq; Type: SEQUENCE SET; Schema: potterbase; Owner: nhost_hasura
--

SELECT pg_catalog.setval('potterbase.glaze_id_seq', 25, true);


--
-- Name: piece_clay_id_seq; Type: SEQUENCE SET; Schema: potterbase; Owner: nhost_hasura
--

SELECT pg_catalog.setval('potterbase.piece_clay_id_seq', 93, true);


--
-- Name: piece_firing_id_seq; Type: SEQUENCE SET; Schema: potterbase; Owner: nhost_hasura
--

SELECT pg_catalog.setval('potterbase.piece_firing_id_seq', 32, true);


--
-- Name: piece_glaze_id_seq; Type: SEQUENCE SET; Schema: potterbase; Owner: nhost_hasura
--

SELECT pg_catalog.setval('potterbase.piece_glaze_id_seq', 77, true);


--
-- Name: piece_id_seq; Type: SEQUENCE SET; Schema: potterbase; Owner: nhost_hasura
--

SELECT pg_catalog.setval('potterbase.piece_id_seq', 79, true);


--
-- Name: piece_stage_history_id_seq; Type: SEQUENCE SET; Schema: potterbase; Owner: nhost_hasura
--

SELECT pg_catalog.setval('potterbase.piece_stage_history_id_seq', 423, true);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: provider_requests provider_requests_pkey; Type: CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.provider_requests
    ADD CONSTRAINT provider_requests_pkey PRIMARY KEY (id);


--
-- Name: providers providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.providers
    ADD CONSTRAINT providers_pkey PRIMARY KEY (id);


--
-- Name: refresh_token_types refresh_token_types_pkey; Type: CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.refresh_token_types
    ADD CONSTRAINT refresh_token_types_pkey PRIMARY KEY (value);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role);


--
-- Name: user_providers user_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.user_providers
    ADD CONSTRAINT user_providers_pkey PRIMARY KEY (id);


--
-- Name: user_providers user_providers_provider_id_provider_user_id_key; Type: CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.user_providers
    ADD CONSTRAINT user_providers_provider_id_provider_user_id_key UNIQUE (provider_id, provider_user_id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_user_id_role_key; Type: CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.user_roles
    ADD CONSTRAINT user_roles_user_id_role_key UNIQUE (user_id, role);


--
-- Name: user_security_keys user_security_key_credential_id_key; Type: CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.user_security_keys
    ADD CONSTRAINT user_security_key_credential_id_key UNIQUE (credential_id);


--
-- Name: user_security_keys user_security_keys_pkey; Type: CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.user_security_keys
    ADD CONSTRAINT user_security_keys_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_number_key; Type: CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_number_key UNIQUE (phone_number);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: hdb_action_log hdb_action_log_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: nhost_hasura
--

ALTER TABLE ONLY hdb_catalog.hdb_action_log
    ADD CONSTRAINT hdb_action_log_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: nhost_hasura
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_events hdb_cron_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: nhost_hasura
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_events
    ADD CONSTRAINT hdb_cron_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: nhost_hasura
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_resource_version_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: nhost_hasura
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_resource_version_key UNIQUE (resource_version);


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: nhost_hasura
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_scheduled_events hdb_scheduled_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: nhost_hasura
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_events
    ADD CONSTRAINT hdb_scheduled_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_schema_notifications hdb_schema_notifications_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: nhost_hasura
--

ALTER TABLE ONLY hdb_catalog.hdb_schema_notifications
    ADD CONSTRAINT hdb_schema_notifications_pkey PRIMARY KEY (id);


--
-- Name: hdb_version hdb_version_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: nhost_hasura
--

ALTER TABLE ONLY hdb_catalog.hdb_version
    ADD CONSTRAINT hdb_version_pkey PRIMARY KEY (hasura_uuid);


--
-- Name: clay_body clay_body_pkey; Type: CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.clay_body
    ADD CONSTRAINT clay_body_pkey PRIMARY KEY (id);


--
-- Name: glaze glaze_pkey; Type: CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.glaze
    ADD CONSTRAINT glaze_pkey PRIMARY KEY (id);


--
-- Name: piece_clay piece_clay_piece_id_clay_body_id_key; Type: CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece_clay
    ADD CONSTRAINT piece_clay_piece_id_clay_body_id_key UNIQUE (piece_id, clay_body_id);


--
-- Name: piece_clay piece_clay_pkey; Type: CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece_clay
    ADD CONSTRAINT piece_clay_pkey PRIMARY KEY (id);


--
-- Name: piece_firing piece_firing_pkey; Type: CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece_firing
    ADD CONSTRAINT piece_firing_pkey PRIMARY KEY (id);


--
-- Name: piece_glaze piece_glaze_pkey; Type: CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece_glaze
    ADD CONSTRAINT piece_glaze_pkey PRIMARY KEY (id);


--
-- Name: piece_image piece_image_pkey; Type: CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece_image
    ADD CONSTRAINT piece_image_pkey PRIMARY KEY (id);


--
-- Name: piece piece_pkey; Type: CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece
    ADD CONSTRAINT piece_pkey PRIMARY KEY (id);


--
-- Name: piece_stage_history piece_stage_history_pkey; Type: CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece_stage_history
    ADD CONSTRAINT piece_stage_history_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: piece_glaze unique_piece_glaze; Type: CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece_glaze
    ADD CONSTRAINT unique_piece_glaze UNIQUE (piece_id, glaze_id, layer_number);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: nhost_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: files files_pkey; Type: CONSTRAINT; Schema: storage; Owner: nhost_storage_admin
--

ALTER TABLE ONLY storage.files
    ADD CONSTRAINT files_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: nhost_storage_admin
--

ALTER TABLE ONLY storage.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: virus virus_pkey; Type: CONSTRAINT; Schema: storage; Owner: nhost_storage_admin
--

ALTER TABLE ONLY storage.virus
    ADD CONSTRAINT virus_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens_refresh_token_hash_expires_at_user_id_idx; Type: INDEX; Schema: auth; Owner: nhost_auth_admin
--

CREATE INDEX refresh_tokens_refresh_token_hash_expires_at_user_id_idx ON auth.refresh_tokens USING btree (refresh_token_hash, expires_at, user_id);


--
-- Name: hdb_cron_event_invocation_event_id; Type: INDEX; Schema: hdb_catalog; Owner: nhost_hasura
--

CREATE INDEX hdb_cron_event_invocation_event_id ON hdb_catalog.hdb_cron_event_invocation_logs USING btree (event_id);


--
-- Name: hdb_cron_event_status; Type: INDEX; Schema: hdb_catalog; Owner: nhost_hasura
--

CREATE INDEX hdb_cron_event_status ON hdb_catalog.hdb_cron_events USING btree (status);


--
-- Name: hdb_cron_events_unique_scheduled; Type: INDEX; Schema: hdb_catalog; Owner: nhost_hasura
--

CREATE UNIQUE INDEX hdb_cron_events_unique_scheduled ON hdb_catalog.hdb_cron_events USING btree (trigger_name, scheduled_time) WHERE (status = 'scheduled'::text);


--
-- Name: hdb_scheduled_event_status; Type: INDEX; Schema: hdb_catalog; Owner: nhost_hasura
--

CREATE INDEX hdb_scheduled_event_status ON hdb_catalog.hdb_scheduled_events USING btree (status);


--
-- Name: hdb_version_one_row; Type: INDEX; Schema: hdb_catalog; Owner: nhost_hasura
--

CREATE UNIQUE INDEX hdb_version_one_row ON hdb_catalog.hdb_version USING btree (((version IS NOT NULL)));


--
-- Name: users on_user_created; Type: TRIGGER; Schema: auth; Owner: nhost_auth_admin
--

CREATE TRIGGER on_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION potterbase.create_profile_for_new_user();


--
-- Name: user_providers set_auth_user_providers_updated_at; Type: TRIGGER; Schema: auth; Owner: nhost_auth_admin
--

CREATE TRIGGER set_auth_user_providers_updated_at BEFORE UPDATE ON auth.user_providers FOR EACH ROW EXECUTE FUNCTION auth.set_current_timestamp_updated_at();


--
-- Name: users set_auth_users_updated_at; Type: TRIGGER; Schema: auth; Owner: nhost_auth_admin
--

CREATE TRIGGER set_auth_users_updated_at BEFORE UPDATE ON auth.users FOR EACH ROW EXECUTE FUNCTION auth.set_current_timestamp_updated_at();


--
-- Name: piece set_potterbase_piece_updated_at; Type: TRIGGER; Schema: potterbase; Owner: nhost_hasura
--

CREATE TRIGGER set_potterbase_piece_updated_at BEFORE UPDATE ON potterbase.piece FOR EACH ROW EXECUTE FUNCTION potterbase.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_potterbase_piece_updated_at ON piece; Type: COMMENT; Schema: potterbase; Owner: nhost_hasura
--

COMMENT ON TRIGGER set_potterbase_piece_updated_at ON potterbase.piece IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: profiles set_profiles_updated_at; Type: TRIGGER; Schema: potterbase; Owner: nhost_hasura
--

CREATE TRIGGER set_profiles_updated_at BEFORE UPDATE ON potterbase.profiles FOR EACH ROW EXECUTE FUNCTION potterbase.set_current_timestamp_updated_at();


--
-- Name: buckets check_default_bucket_delete; Type: TRIGGER; Schema: storage; Owner: nhost_storage_admin
--

CREATE TRIGGER check_default_bucket_delete BEFORE DELETE ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.protect_default_bucket_delete();


--
-- Name: buckets check_default_bucket_update; Type: TRIGGER; Schema: storage; Owner: nhost_storage_admin
--

CREATE TRIGGER check_default_bucket_update BEFORE UPDATE ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.protect_default_bucket_update();


--
-- Name: buckets set_storage_buckets_updated_at; Type: TRIGGER; Schema: storage; Owner: nhost_storage_admin
--

CREATE TRIGGER set_storage_buckets_updated_at BEFORE UPDATE ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.set_current_timestamp_updated_at();


--
-- Name: files set_storage_files_updated_at; Type: TRIGGER; Schema: storage; Owner: nhost_storage_admin
--

CREATE TRIGGER set_storage_files_updated_at BEFORE UPDATE ON storage.files FOR EACH ROW EXECUTE FUNCTION storage.set_current_timestamp_updated_at();


--
-- Name: virus set_storage_virus_updated_at; Type: TRIGGER; Schema: storage; Owner: nhost_storage_admin
--

CREATE TRIGGER set_storage_virus_updated_at BEFORE UPDATE ON storage.virus FOR EACH ROW EXECUTE FUNCTION storage.set_current_timestamp_updated_at();


--
-- Name: users fk_default_role; Type: FK CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT fk_default_role FOREIGN KEY (default_role) REFERENCES auth.roles(role) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: user_providers fk_provider; Type: FK CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.user_providers
    ADD CONSTRAINT fk_provider FOREIGN KEY (provider_id) REFERENCES auth.providers(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: user_roles fk_role; Type: FK CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.user_roles
    ADD CONSTRAINT fk_role FOREIGN KEY (role) REFERENCES auth.roles(role) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: user_providers fk_user; Type: FK CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.user_providers
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_roles fk_user; Type: FK CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.user_roles
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: refresh_tokens fk_user; Type: FK CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_security_keys fk_user; Type: FK CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.user_security_keys
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_types_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: nhost_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_types_fkey FOREIGN KEY (type) REFERENCES auth.refresh_token_types(value) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: nhost_hasura
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_cron_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: nhost_hasura
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_scheduled_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: piece_clay piece_clay_clay_body_id_fkey; Type: FK CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece_clay
    ADD CONSTRAINT piece_clay_clay_body_id_fkey FOREIGN KEY (clay_body_id) REFERENCES potterbase.clay_body(id) ON DELETE CASCADE;


--
-- Name: piece_clay piece_clay_piece_id_fkey; Type: FK CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece_clay
    ADD CONSTRAINT piece_clay_piece_id_fkey FOREIGN KEY (piece_id) REFERENCES potterbase.piece(id) ON DELETE CASCADE;


--
-- Name: piece_firing piece_firing_piece_id_fkey; Type: FK CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece_firing
    ADD CONSTRAINT piece_firing_piece_id_fkey FOREIGN KEY (piece_id) REFERENCES potterbase.piece(id) ON DELETE CASCADE;


--
-- Name: piece_glaze piece_glaze_glaze_id_fkey; Type: FK CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece_glaze
    ADD CONSTRAINT piece_glaze_glaze_id_fkey FOREIGN KEY (glaze_id) REFERENCES potterbase.glaze(id) ON DELETE CASCADE;


--
-- Name: piece_glaze piece_glaze_piece_id_fkey; Type: FK CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece_glaze
    ADD CONSTRAINT piece_glaze_piece_id_fkey FOREIGN KEY (piece_id) REFERENCES potterbase.piece(id) ON DELETE CASCADE;


--
-- Name: piece_image piece_image_piece_id_fkey; Type: FK CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece_image
    ADD CONSTRAINT piece_image_piece_id_fkey FOREIGN KEY (piece_id) REFERENCES potterbase.piece(id) ON DELETE CASCADE;


--
-- Name: piece_stage_history piece_stage_history_piece_id_fkey; Type: FK CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.piece_stage_history
    ADD CONSTRAINT piece_stage_history_piece_id_fkey FOREIGN KEY (piece_id) REFERENCES potterbase.piece(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: potterbase; Owner: nhost_hasura
--

ALTER TABLE ONLY potterbase.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: files fk_bucket; Type: FK CONSTRAINT; Schema: storage; Owner: nhost_storage_admin
--

ALTER TABLE ONLY storage.files
    ADD CONSTRAINT fk_bucket FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: virus virus_file_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: nhost_storage_admin
--

ALTER TABLE ONLY storage.virus
    ADD CONSTRAINT virus_file_id_fkey FOREIGN KEY (file_id) REFERENCES storage.files(id);


--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: nhost_admin
--

GRANT ALL ON SCHEMA auth TO nhost_auth_admin;
GRANT USAGE ON SCHEMA auth TO nhost_hasura;


--
-- Name: SCHEMA hdb_catalog; Type: ACL; Schema: -; Owner: nhost_hasura
--

GRANT ALL ON SCHEMA hdb_catalog TO nhost_auth_admin;
GRANT ALL ON SCHEMA hdb_catalog TO nhost_storage_admin;


--
-- Name: SCHEMA pgbouncer; Type: ACL; Schema: -; Owner: nhost_admin
--

GRANT USAGE ON SCHEMA pgbouncer TO pgbouncer;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;
GRANT USAGE ON SCHEMA public TO nhost_hasura;


--
-- Name: SCHEMA storage; Type: ACL; Schema: -; Owner: nhost_admin
--

GRANT ALL ON SCHEMA storage TO nhost_storage_admin;
GRANT USAGE ON SCHEMA storage TO nhost_hasura;


--
-- Name: FUNCTION gen_hasura_uuid(); Type: ACL; Schema: hdb_catalog; Owner: nhost_hasura
--

GRANT ALL ON FUNCTION hdb_catalog.gen_hasura_uuid() TO nhost_auth_admin;
GRANT ALL ON FUNCTION hdb_catalog.gen_hasura_uuid() TO nhost_storage_admin;


--
-- Name: FUNCTION user_lookup(i_username text, OUT uname text, OUT phash text); Type: ACL; Schema: pgbouncer; Owner: postgres
--

REVOKE ALL ON FUNCTION pgbouncer.user_lookup(i_username text, OUT uname text, OUT phash text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.user_lookup(i_username text, OUT uname text, OUT phash text) TO pgbouncer;


--
-- Name: TABLE migrations; Type: ACL; Schema: auth; Owner: nhost_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.migrations TO nhost_hasura;


--
-- Name: TABLE provider_requests; Type: ACL; Schema: auth; Owner: nhost_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.provider_requests TO nhost_hasura;


--
-- Name: TABLE providers; Type: ACL; Schema: auth; Owner: nhost_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.providers TO nhost_hasura;


--
-- Name: TABLE refresh_token_types; Type: ACL; Schema: auth; Owner: nhost_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.refresh_token_types TO nhost_hasura;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: nhost_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.refresh_tokens TO nhost_hasura;


--
-- Name: TABLE roles; Type: ACL; Schema: auth; Owner: nhost_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.roles TO nhost_hasura;


--
-- Name: TABLE user_providers; Type: ACL; Schema: auth; Owner: nhost_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.user_providers TO nhost_hasura;


--
-- Name: TABLE user_roles; Type: ACL; Schema: auth; Owner: nhost_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.user_roles TO nhost_hasura;


--
-- Name: TABLE user_security_keys; Type: ACL; Schema: auth; Owner: nhost_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.user_security_keys TO nhost_hasura;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: nhost_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.users TO nhost_hasura;


--
-- Name: TABLE hdb_action_log; Type: ACL; Schema: hdb_catalog; Owner: nhost_hasura
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE hdb_catalog.hdb_action_log TO nhost_auth_admin;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE hdb_catalog.hdb_action_log TO nhost_storage_admin;


--
-- Name: TABLE hdb_cron_event_invocation_logs; Type: ACL; Schema: hdb_catalog; Owner: nhost_hasura
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE hdb_catalog.hdb_cron_event_invocation_logs TO nhost_auth_admin;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE hdb_catalog.hdb_cron_event_invocation_logs TO nhost_storage_admin;


--
-- Name: TABLE hdb_cron_events; Type: ACL; Schema: hdb_catalog; Owner: nhost_hasura
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE hdb_catalog.hdb_cron_events TO nhost_auth_admin;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE hdb_catalog.hdb_cron_events TO nhost_storage_admin;


--
-- Name: TABLE hdb_metadata; Type: ACL; Schema: hdb_catalog; Owner: nhost_hasura
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE hdb_catalog.hdb_metadata TO nhost_auth_admin;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE hdb_catalog.hdb_metadata TO nhost_storage_admin;


--
-- Name: TABLE hdb_scheduled_event_invocation_logs; Type: ACL; Schema: hdb_catalog; Owner: nhost_hasura
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE hdb_catalog.hdb_scheduled_event_invocation_logs TO nhost_auth_admin;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE hdb_catalog.hdb_scheduled_event_invocation_logs TO nhost_storage_admin;


--
-- Name: TABLE hdb_scheduled_events; Type: ACL; Schema: hdb_catalog; Owner: nhost_hasura
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE hdb_catalog.hdb_scheduled_events TO nhost_auth_admin;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE hdb_catalog.hdb_scheduled_events TO nhost_storage_admin;


--
-- Name: TABLE hdb_schema_notifications; Type: ACL; Schema: hdb_catalog; Owner: nhost_hasura
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE hdb_catalog.hdb_schema_notifications TO nhost_auth_admin;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE hdb_catalog.hdb_schema_notifications TO nhost_storage_admin;


--
-- Name: TABLE hdb_version; Type: ACL; Schema: hdb_catalog; Owner: nhost_hasura
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE hdb_catalog.hdb_version TO nhost_auth_admin;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE hdb_catalog.hdb_version TO nhost_storage_admin;


--
-- Name: TABLE pg_aggregate; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_aggregate TO nhost_hasura;


--
-- Name: TABLE pg_am; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_am TO nhost_hasura;


--
-- Name: TABLE pg_amop; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_amop TO nhost_hasura;


--
-- Name: TABLE pg_amproc; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_amproc TO nhost_hasura;


--
-- Name: TABLE pg_attrdef; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_attrdef TO nhost_hasura;


--
-- Name: TABLE pg_attribute; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_attribute TO nhost_hasura;


--
-- Name: TABLE pg_auth_members; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_auth_members TO nhost_hasura;


--
-- Name: TABLE pg_authid; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_authid TO nhost_hasura;


--
-- Name: TABLE pg_available_extension_versions; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_available_extension_versions TO nhost_hasura;


--
-- Name: TABLE pg_available_extensions; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_available_extensions TO nhost_hasura;


--
-- Name: TABLE pg_backend_memory_contexts; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_backend_memory_contexts TO nhost_hasura;


--
-- Name: TABLE pg_cast; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_cast TO nhost_hasura;


--
-- Name: TABLE pg_class; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_class TO nhost_hasura;


--
-- Name: TABLE pg_collation; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_collation TO nhost_hasura;


--
-- Name: TABLE pg_config; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_config TO nhost_hasura;


--
-- Name: TABLE pg_constraint; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_constraint TO nhost_hasura;


--
-- Name: TABLE pg_conversion; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_conversion TO nhost_hasura;


--
-- Name: TABLE pg_cursors; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_cursors TO nhost_hasura;


--
-- Name: TABLE pg_database; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_database TO nhost_hasura;


--
-- Name: TABLE pg_db_role_setting; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_db_role_setting TO nhost_hasura;


--
-- Name: TABLE pg_default_acl; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_default_acl TO nhost_hasura;


--
-- Name: TABLE pg_depend; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_depend TO nhost_hasura;


--
-- Name: TABLE pg_description; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_description TO nhost_hasura;


--
-- Name: TABLE pg_enum; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_enum TO nhost_hasura;


--
-- Name: TABLE pg_event_trigger; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_event_trigger TO nhost_hasura;


--
-- Name: TABLE pg_extension; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_extension TO nhost_hasura;


--
-- Name: TABLE pg_file_settings; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_file_settings TO nhost_hasura;


--
-- Name: TABLE pg_foreign_data_wrapper; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_foreign_data_wrapper TO nhost_hasura;


--
-- Name: TABLE pg_foreign_server; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_foreign_server TO nhost_hasura;


--
-- Name: TABLE pg_foreign_table; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_foreign_table TO nhost_hasura;


--
-- Name: TABLE pg_group; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_group TO nhost_hasura;


--
-- Name: TABLE pg_hba_file_rules; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_hba_file_rules TO nhost_hasura;


--
-- Name: TABLE pg_index; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_index TO nhost_hasura;


--
-- Name: TABLE pg_indexes; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_indexes TO nhost_hasura;


--
-- Name: TABLE pg_inherits; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_inherits TO nhost_hasura;


--
-- Name: TABLE pg_init_privs; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_init_privs TO nhost_hasura;


--
-- Name: TABLE pg_language; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_language TO nhost_hasura;


--
-- Name: TABLE pg_largeobject; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_largeobject TO nhost_hasura;


--
-- Name: TABLE pg_largeobject_metadata; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_largeobject_metadata TO nhost_hasura;


--
-- Name: TABLE pg_locks; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_locks TO nhost_hasura;


--
-- Name: TABLE pg_matviews; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_matviews TO nhost_hasura;


--
-- Name: TABLE pg_namespace; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_namespace TO nhost_hasura;


--
-- Name: TABLE pg_opclass; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_opclass TO nhost_hasura;


--
-- Name: TABLE pg_operator; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_operator TO nhost_hasura;


--
-- Name: TABLE pg_opfamily; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_opfamily TO nhost_hasura;


--
-- Name: TABLE pg_partitioned_table; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_partitioned_table TO nhost_hasura;


--
-- Name: TABLE pg_policies; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_policies TO nhost_hasura;


--
-- Name: TABLE pg_policy; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_policy TO nhost_hasura;


--
-- Name: TABLE pg_prepared_statements; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_prepared_statements TO nhost_hasura;


--
-- Name: TABLE pg_prepared_xacts; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_prepared_xacts TO nhost_hasura;


--
-- Name: TABLE pg_proc; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_proc TO nhost_hasura;


--
-- Name: TABLE pg_publication; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_publication TO nhost_hasura;


--
-- Name: TABLE pg_publication_rel; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_publication_rel TO nhost_hasura;


--
-- Name: TABLE pg_publication_tables; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_publication_tables TO nhost_hasura;


--
-- Name: TABLE pg_range; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_range TO nhost_hasura;


--
-- Name: TABLE pg_replication_origin; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_replication_origin TO nhost_hasura;


--
-- Name: TABLE pg_replication_origin_status; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_replication_origin_status TO nhost_hasura;


--
-- Name: TABLE pg_replication_slots; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_replication_slots TO nhost_hasura;


--
-- Name: TABLE pg_rewrite; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_rewrite TO nhost_hasura;


--
-- Name: TABLE pg_roles; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_roles TO nhost_hasura;


--
-- Name: TABLE pg_rules; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_rules TO nhost_hasura;


--
-- Name: TABLE pg_seclabel; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_seclabel TO nhost_hasura;


--
-- Name: TABLE pg_seclabels; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_seclabels TO nhost_hasura;


--
-- Name: TABLE pg_sequence; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_sequence TO nhost_hasura;


--
-- Name: TABLE pg_sequences; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_sequences TO nhost_hasura;


--
-- Name: TABLE pg_settings; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_settings TO nhost_hasura;


--
-- Name: TABLE pg_shadow; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_shadow TO nhost_hasura;


--
-- Name: TABLE pg_shdepend; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_shdepend TO nhost_hasura;


--
-- Name: TABLE pg_shdescription; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_shdescription TO nhost_hasura;


--
-- Name: TABLE pg_shmem_allocations; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_shmem_allocations TO nhost_hasura;


--
-- Name: TABLE pg_shseclabel; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_shseclabel TO nhost_hasura;


--
-- Name: TABLE pg_stat_activity; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_activity TO nhost_hasura;


--
-- Name: TABLE pg_stat_all_indexes; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_all_indexes TO nhost_hasura;


--
-- Name: TABLE pg_stat_all_tables; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_all_tables TO nhost_hasura;


--
-- Name: TABLE pg_stat_archiver; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_archiver TO nhost_hasura;


--
-- Name: TABLE pg_stat_bgwriter; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_bgwriter TO nhost_hasura;


--
-- Name: TABLE pg_stat_database; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_database TO nhost_hasura;


--
-- Name: TABLE pg_stat_database_conflicts; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_database_conflicts TO nhost_hasura;


--
-- Name: TABLE pg_stat_gssapi; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_gssapi TO nhost_hasura;


--
-- Name: TABLE pg_stat_progress_analyze; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_analyze TO nhost_hasura;


--
-- Name: TABLE pg_stat_progress_basebackup; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_basebackup TO nhost_hasura;


--
-- Name: TABLE pg_stat_progress_cluster; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_cluster TO nhost_hasura;


--
-- Name: TABLE pg_stat_progress_copy; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_copy TO nhost_hasura;


--
-- Name: TABLE pg_stat_progress_create_index; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_create_index TO nhost_hasura;


--
-- Name: TABLE pg_stat_progress_vacuum; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_vacuum TO nhost_hasura;


--
-- Name: TABLE pg_stat_replication; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_replication TO nhost_hasura;


--
-- Name: TABLE pg_stat_replication_slots; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_replication_slots TO nhost_hasura;


--
-- Name: TABLE pg_stat_slru; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_slru TO nhost_hasura;


--
-- Name: TABLE pg_stat_ssl; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_ssl TO nhost_hasura;


--
-- Name: TABLE pg_stat_subscription; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_subscription TO nhost_hasura;


--
-- Name: TABLE pg_stat_sys_indexes; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_sys_indexes TO nhost_hasura;


--
-- Name: TABLE pg_stat_sys_tables; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_sys_tables TO nhost_hasura;


--
-- Name: TABLE pg_stat_user_functions; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_user_functions TO nhost_hasura;


--
-- Name: TABLE pg_stat_user_indexes; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_user_indexes TO nhost_hasura;


--
-- Name: TABLE pg_stat_user_tables; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_user_tables TO nhost_hasura;


--
-- Name: TABLE pg_stat_wal; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_wal TO nhost_hasura;


--
-- Name: TABLE pg_stat_wal_receiver; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_wal_receiver TO nhost_hasura;


--
-- Name: TABLE pg_stat_xact_all_tables; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_xact_all_tables TO nhost_hasura;


--
-- Name: TABLE pg_stat_xact_sys_tables; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_xact_sys_tables TO nhost_hasura;


--
-- Name: TABLE pg_stat_xact_user_functions; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_xact_user_functions TO nhost_hasura;


--
-- Name: TABLE pg_stat_xact_user_tables; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_xact_user_tables TO nhost_hasura;


--
-- Name: TABLE pg_statio_all_indexes; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_statio_all_indexes TO nhost_hasura;


--
-- Name: TABLE pg_statio_all_sequences; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_statio_all_sequences TO nhost_hasura;


--
-- Name: TABLE pg_statio_all_tables; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_statio_all_tables TO nhost_hasura;


--
-- Name: TABLE pg_statio_sys_indexes; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_statio_sys_indexes TO nhost_hasura;


--
-- Name: TABLE pg_statio_sys_sequences; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_statio_sys_sequences TO nhost_hasura;


--
-- Name: TABLE pg_statio_sys_tables; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_statio_sys_tables TO nhost_hasura;


--
-- Name: TABLE pg_statio_user_indexes; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_statio_user_indexes TO nhost_hasura;


--
-- Name: TABLE pg_statio_user_sequences; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_statio_user_sequences TO nhost_hasura;


--
-- Name: TABLE pg_statio_user_tables; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_statio_user_tables TO nhost_hasura;


--
-- Name: TABLE pg_statistic; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_statistic TO nhost_hasura;


--
-- Name: TABLE pg_statistic_ext; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_statistic_ext TO nhost_hasura;


--
-- Name: TABLE pg_statistic_ext_data; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_statistic_ext_data TO nhost_hasura;


--
-- Name: TABLE pg_stats; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stats TO nhost_hasura;


--
-- Name: TABLE pg_stats_ext; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stats_ext TO nhost_hasura;


--
-- Name: TABLE pg_stats_ext_exprs; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_stats_ext_exprs TO nhost_hasura;


--
-- Name: TABLE pg_subscription; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_subscription TO nhost_hasura;


--
-- Name: TABLE pg_subscription_rel; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_subscription_rel TO nhost_hasura;


--
-- Name: TABLE pg_tables; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_tables TO nhost_hasura;


--
-- Name: TABLE pg_tablespace; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_tablespace TO nhost_hasura;


--
-- Name: TABLE pg_timezone_abbrevs; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_timezone_abbrevs TO nhost_hasura;


--
-- Name: TABLE pg_timezone_names; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_timezone_names TO nhost_hasura;


--
-- Name: TABLE pg_transform; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_transform TO nhost_hasura;


--
-- Name: TABLE pg_trigger; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_trigger TO nhost_hasura;


--
-- Name: TABLE pg_ts_config; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_ts_config TO nhost_hasura;


--
-- Name: TABLE pg_ts_config_map; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_ts_config_map TO nhost_hasura;


--
-- Name: TABLE pg_ts_dict; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_ts_dict TO nhost_hasura;


--
-- Name: TABLE pg_ts_parser; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_ts_parser TO nhost_hasura;


--
-- Name: TABLE pg_ts_template; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_ts_template TO nhost_hasura;


--
-- Name: TABLE pg_type; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_type TO nhost_hasura;


--
-- Name: TABLE pg_user; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_user TO nhost_hasura;


--
-- Name: TABLE pg_user_mapping; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_user_mapping TO nhost_hasura;


--
-- Name: TABLE pg_user_mappings; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_user_mappings TO nhost_hasura;


--
-- Name: TABLE pg_views; Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT SELECT ON TABLE pg_catalog.pg_views TO nhost_hasura;


--
-- Name: TABLE buckets; Type: ACL; Schema: storage; Owner: nhost_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets TO nhost_hasura;


--
-- Name: TABLE files; Type: ACL; Schema: storage; Owner: nhost_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.files TO nhost_hasura;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: storage; Owner: nhost_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.schema_migrations TO nhost_hasura;


--
-- Name: TABLE virus; Type: ACL; Schema: storage; Owner: nhost_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.virus TO nhost_hasura;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: nhost_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE nhost_auth_admin IN SCHEMA auth GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO nhost_hasura;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: hdb_catalog; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA hdb_catalog GRANT ALL ON SEQUENCES TO nhost_auth_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA hdb_catalog GRANT ALL ON SEQUENCES TO nhost_storage_admin;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: hdb_catalog; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA hdb_catalog GRANT ALL ON FUNCTIONS TO nhost_auth_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA hdb_catalog GRANT ALL ON FUNCTIONS TO nhost_storage_admin;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: hdb_catalog; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA hdb_catalog GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO nhost_auth_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA hdb_catalog GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO nhost_storage_admin;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: nhost_storage_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE nhost_storage_admin IN SCHEMA storage GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO nhost_hasura;


--
-- PostgreSQL database dump complete
--

\unrestrict lcKnt3ChbVNprnez7nleH9KLwdAHLx1o7CzZ9wXGzCFN9yS2Fyh8Vqr77OJ9l5e

