--
-- PostgreSQL database dump
--

\restrict nDTex7ChcKce3dEgy3QbRkXU7Qe5XONG3XVxnnDGb1N7U4PIYff2brZvyJ7L4uv

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

SET default_tablespace = '';

SET default_table_access_method = heap;

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
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;
GRANT USAGE ON SCHEMA public TO nhost_hasura;


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
-- PostgreSQL database dump complete
--

\unrestrict nDTex7ChcKce3dEgy3QbRkXU7Qe5XONG3XVxnnDGb1N7U4PIYff2brZvyJ7L4uv

