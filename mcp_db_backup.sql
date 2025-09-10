--
-- PostgreSQL database dump
--

\restrict LRRe1v3bRhtY2091XQwBDbfhmjHFsrOwS2PUz77iJYV7kIhgBmkIUpOcvg2xGAq

-- Dumped from database version 14.19 (Debian 14.19-1.pgdg13+1)
-- Dumped by pg_dump version 14.19 (Debian 14.19-1.pgdg13+1)

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

--
-- Name: deploymentstatus; Type: TYPE; Schema: public; Owner: mcpuser
--

CREATE TYPE public.deploymentstatus AS ENUM (
    'CREATED',
    'PLANNED',
    'AWAITING_APPROVAL',
    'APPLYING',
    'APPLIED',
    'FAILED',
    'DESTROYING',
    'DESTROYED'
);


ALTER TYPE public.deploymentstatus OWNER TO mcpuser;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: datasources; Type: TABLE; Schema: public; Owner: mcpuser
--

CREATE TABLE public.datasources (
    id integer NOT NULL,
    name character varying NOT NULL,
    provider character varying NOT NULL,
    data_type character varying NOT NULL,
    config json NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.datasources OWNER TO mcpuser;

--
-- Name: datasources_id_seq; Type: SEQUENCE; Schema: public; Owner: mcpuser
--

CREATE SEQUENCE public.datasources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.datasources_id_seq OWNER TO mcpuser;

--
-- Name: datasources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mcpuser
--

ALTER SEQUENCE public.datasources_id_seq OWNED BY public.datasources.id;


--
-- Name: deployments; Type: TABLE; Schema: public; Owner: mcpuser
--

CREATE TABLE public.deployments (
    id integer NOT NULL,
    name character varying,
    cloud character varying,
    module character varying,
    vars json,
    status public.deploymentstatus,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    terraform_plan_output text,
    terraform_apply_log text,
    gemini_review_summary text,
    gemini_review_issues json
);


ALTER TABLE public.deployments OWNER TO mcpuser;

--
-- Name: deployments_id_seq; Type: SEQUENCE; Schema: public; Owner: mcpuser
--

CREATE SEQUENCE public.deployments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.deployments_id_seq OWNER TO mcpuser;

--
-- Name: deployments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mcpuser
--

ALTER SEQUENCE public.deployments_id_seq OWNED BY public.deployments.id;


--
-- Name: kb_document_versions; Type: TABLE; Schema: public; Owner: mcpuser
--

CREATE TABLE public.kb_document_versions (
    id integer NOT NULL,
    document_id integer NOT NULL,
    version_no integer NOT NULL,
    content text NOT NULL,
    message character varying,
    author character varying NOT NULL,
    size_bytes integer,
    created_at timestamp without time zone
);


ALTER TABLE public.kb_document_versions OWNER TO mcpuser;

--
-- Name: kb_document_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: mcpuser
--

CREATE SEQUENCE public.kb_document_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kb_document_versions_id_seq OWNER TO mcpuser;

--
-- Name: kb_document_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mcpuser
--

ALTER SEQUENCE public.kb_document_versions_id_seq OWNED BY public.kb_document_versions.id;


--
-- Name: kb_documents; Type: TABLE; Schema: public; Owner: mcpuser
--

CREATE TABLE public.kb_documents (
    id integer NOT NULL,
    path character varying NOT NULL,
    title character varying,
    tags json,
    latest_version_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.kb_documents OWNER TO mcpuser;

--
-- Name: kb_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: mcpuser
--

CREATE SEQUENCE public.kb_documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kb_documents_id_seq OWNER TO mcpuser;

--
-- Name: kb_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mcpuser
--

ALTER SEQUENCE public.kb_documents_id_seq OWNED BY public.kb_documents.id;


--
-- Name: kb_tasks; Type: TABLE; Schema: public; Owner: mcpuser
--

CREATE TABLE public.kb_tasks (
    id character varying NOT NULL,
    type character varying,
    status character varying,
    stage character varying,
    progress integer,
    input json,
    output json,
    error text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.kb_tasks OWNER TO mcpuser;

--
-- Name: trending_categories; Type: TABLE; Schema: public; Owner: mcpuser
--

CREATE TABLE public.trending_categories (
    id integer NOT NULL,
    name character varying NOT NULL,
    query character varying NOT NULL,
    enabled integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.trending_categories OWNER TO mcpuser;

--
-- Name: trending_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: mcpuser
--

CREATE SEQUENCE public.trending_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trending_categories_id_seq OWNER TO mcpuser;

--
-- Name: trending_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mcpuser
--

ALTER SEQUENCE public.trending_categories_id_seq OWNED BY public.trending_categories.id;


--
-- Name: user_certs; Type: TABLE; Schema: public; Owner: mcpuser
--

CREATE TABLE public.user_certs (
    id integer NOT NULL,
    user_id integer NOT NULL,
    name character varying NOT NULL,
    encrypted_value bytea NOT NULL,
    fingerprint character varying,
    expires_at timestamp without time zone,
    created_at timestamp without time zone
);


ALTER TABLE public.user_certs OWNER TO mcpuser;

--
-- Name: user_certs_id_seq; Type: SEQUENCE; Schema: public; Owner: mcpuser
--

CREATE SEQUENCE public.user_certs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_certs_id_seq OWNER TO mcpuser;

--
-- Name: user_certs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mcpuser
--

ALTER SEQUENCE public.user_certs_id_seq OWNED BY public.user_certs.id;


--
-- Name: user_keys; Type: TABLE; Schema: public; Owner: mcpuser
--

CREATE TABLE public.user_keys (
    id integer NOT NULL,
    user_id integer NOT NULL,
    name character varying NOT NULL,
    platform character varying NOT NULL,
    encrypted_value bytea NOT NULL,
    fingerprint character varying,
    expires_at timestamp without time zone,
    created_at timestamp without time zone
);


ALTER TABLE public.user_keys OWNER TO mcpuser;

--
-- Name: user_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: mcpuser
--

CREATE SEQUENCE public.user_keys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_keys_id_seq OWNER TO mcpuser;

--
-- Name: user_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mcpuser
--

ALTER SEQUENCE public.user_keys_id_seq OWNED BY public.user_keys.id;


--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: mcpuser
--

CREATE TABLE public.user_profiles (
    id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.user_profiles OWNER TO mcpuser;

--
-- Name: user_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: mcpuser
--

CREATE SEQUENCE public.user_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_profiles_id_seq OWNER TO mcpuser;

--
-- Name: user_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mcpuser
--

ALTER SEQUENCE public.user_profiles_id_seq OWNED BY public.user_profiles.id;


--
-- Name: user_subscriptions; Type: TABLE; Schema: public; Owner: mcpuser
--

CREATE TABLE public.user_subscriptions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    stripe_customer_id character varying,
    stripe_subscription_id character varying,
    plan_id character varying,
    status character varying,
    current_period_start timestamp without time zone,
    current_period_end timestamp without time zone,
    cancel_at_period_end boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.user_subscriptions OWNER TO mcpuser;

--
-- Name: user_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: mcpuser
--

CREATE SEQUENCE public.user_subscriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_subscriptions_id_seq OWNER TO mcpuser;

--
-- Name: user_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mcpuser
--

ALTER SEQUENCE public.user_subscriptions_id_seq OWNED BY public.user_subscriptions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: mcpuser
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying NOT NULL,
    full_name character varying,
    role character varying NOT NULL,
    picture_url character varying,
    password_hash character varying,
    is_active boolean NOT NULL,
    email_verification_token character varying,
    email_verified_at timestamp without time zone,
    last_login_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.users OWNER TO mcpuser;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: mcpuser
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO mcpuser;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mcpuser
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: datasources id; Type: DEFAULT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.datasources ALTER COLUMN id SET DEFAULT nextval('public.datasources_id_seq'::regclass);


--
-- Name: deployments id; Type: DEFAULT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.deployments ALTER COLUMN id SET DEFAULT nextval('public.deployments_id_seq'::regclass);


--
-- Name: kb_document_versions id; Type: DEFAULT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.kb_document_versions ALTER COLUMN id SET DEFAULT nextval('public.kb_document_versions_id_seq'::regclass);


--
-- Name: kb_documents id; Type: DEFAULT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.kb_documents ALTER COLUMN id SET DEFAULT nextval('public.kb_documents_id_seq'::regclass);


--
-- Name: trending_categories id; Type: DEFAULT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.trending_categories ALTER COLUMN id SET DEFAULT nextval('public.trending_categories_id_seq'::regclass);


--
-- Name: user_certs id; Type: DEFAULT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.user_certs ALTER COLUMN id SET DEFAULT nextval('public.user_certs_id_seq'::regclass);


--
-- Name: user_keys id; Type: DEFAULT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.user_keys ALTER COLUMN id SET DEFAULT nextval('public.user_keys_id_seq'::regclass);


--
-- Name: user_profiles id; Type: DEFAULT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.user_profiles ALTER COLUMN id SET DEFAULT nextval('public.user_profiles_id_seq'::regclass);


--
-- Name: user_subscriptions id; Type: DEFAULT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.user_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.user_subscriptions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: datasources; Type: TABLE DATA; Schema: public; Owner: mcpuser
--

COPY public.datasources (id, name, provider, data_type, config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: deployments; Type: TABLE DATA; Schema: public; Owner: mcpuser
--

COPY public.deployments (id, name, cloud, module, vars, status, created_at, updated_at, terraform_plan_output, terraform_apply_log, gemini_review_summary, gemini_review_issues) FROM stdin;
\.


--
-- Data for Name: kb_document_versions; Type: TABLE DATA; Schema: public; Owner: mcpuser
--

COPY public.kb_document_versions (id, document_id, version_no, content, message, author, size_bytes, created_at) FROM stdin;
\.


--
-- Data for Name: kb_documents; Type: TABLE DATA; Schema: public; Owner: mcpuser
--

COPY public.kb_documents (id, path, title, tags, latest_version_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: kb_tasks; Type: TABLE DATA; Schema: public; Owner: mcpuser
--

COPY public.kb_tasks (id, type, status, stage, progress, input, output, error, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: trending_categories; Type: TABLE DATA; Schema: public; Owner: mcpuser
--

COPY public.trending_categories (id, name, query, enabled, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: user_certs; Type: TABLE DATA; Schema: public; Owner: mcpuser
--

COPY public.user_certs (id, user_id, name, encrypted_value, fingerprint, expires_at, created_at) FROM stdin;
\.


--
-- Data for Name: user_keys; Type: TABLE DATA; Schema: public; Owner: mcpuser
--

COPY public.user_keys (id, user_id, name, platform, encrypted_value, fingerprint, expires_at, created_at) FROM stdin;
\.


--
-- Data for Name: user_profiles; Type: TABLE DATA; Schema: public; Owner: mcpuser
--

COPY public.user_profiles (id, user_id) FROM stdin;
\.


--
-- Data for Name: user_subscriptions; Type: TABLE DATA; Schema: public; Owner: mcpuser
--

COPY public.user_subscriptions (id, user_id, stripe_customer_id, stripe_subscription_id, plan_id, status, current_period_start, current_period_end, cancel_at_period_end, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: mcpuser
--

COPY public.users (id, email, full_name, role, picture_url, password_hash, is_active, email_verification_token, email_verified_at, last_login_at, created_at, updated_at) FROM stdin;
14	swspcompany@gmail.com	jhong	student	\N	$2b$12$nRo2ZGUgoMikutwPd1vKCuYK1vH2Uwtj94etbu8mH72MhtBaj6NUi	t	\N	2025-09-02 04:13:56.085627	2025-09-02 04:14:07.12447	2025-09-02 04:12:23.288269	2025-09-02 04:14:07.125349
11	sdgkadfja2@gmail.com	GBSA	student	\N	$2b$12$DdWym3qQAKPkoSc1klSNDuxhIcQdmTX8ZVFqs0Dpk.BiMw3LV/Kky	t	\N	2025-09-02 04:13:17.20115	2025-09-02 04:14:13.102242	2025-09-02 04:11:44.926211	2025-09-02 04:14:13.104595
5	malibu7777@gmail.com	\N	student	\N	$2b$12$IDntwsfdywpwj8UvA.Fk2OWWlEgOowC7qWTvdmW1HnCuOVDGjJ5mu	f	PeUWWnVCZW-p2dG2wD1dHIgWZuUxhoDwXV0_CC7_Y4Y	\N	2025-09-02 04:05:34.677982	2025-09-02 04:05:34.678538	2025-09-02 04:05:34.678541
12	edenism79@gmail.com	\N	student	\N	$2b$12$NI.NOYHTBhvKSlPNWGZVnuMOYVBEjmAdYs42BDIlIizTmEXTE7B1G	t	\N	2025-09-02 04:14:06.910424	2025-09-02 04:14:21.111119	2025-09-02 04:11:50.751588	2025-09-02 04:14:21.112083
1	inhwan.jung@gmail.com	관리자	admin	\N	$2b$12$vY3h8u61cJ3k4n.h962ao.scTEbX196taIBatnz6M03AGmwO1mgze	t	\N	2025-09-02 03:29:07.665002	2025-09-02 04:06:55.775811	2025-09-02 03:27:50.96081	2025-09-02 04:06:55.776321
8	hslyu@woodlov3r.com	류화실	student	\N	$2b$12$VnPst8SLABKbZRpMaiD/Vem2SgsVp6nOckEv5NuwMkunnncrP6Mxm	t	\N	2025-09-02 04:23:20.907823	2025-09-02 04:23:51.806653	2025-09-02 04:06:31.510582	2025-09-02 04:23:51.807206
6	norbert@norbertmobility.com	Norbert 	student	\N	$2b$12$mNuOkG4TIWCHJ/ksG6TzVejjICcQcYC.No9JH/HcSfaI1p8BgLFhm	t	\N	2025-09-02 04:07:16.681704	2025-09-02 04:07:41.020686	2025-09-02 04:05:46.84968	2025-09-02 04:07:41.021185
4	stormrider.park@gmail.com	John	student	\N	$2b$12$jqeGJMmyMEL1UpfeTDrsv.DtnsAVewRP3IMMu2x0HbvhJhRQlt.RO	t	\N	2025-09-02 04:07:53.284355	2025-09-02 04:09:31.590678	2025-09-02 04:05:31.060561	2025-09-02 04:09:31.591272
7	chloe.green0508@gmail.com	이초록	student	\N	$2b$12$QPgulZZ59KniR94tPSdEoOM99jl4Eu9ZpaLUjnrctMHW6WmeKt0R2	t	\N	2025-09-02 04:09:34.776477	2025-09-02 04:09:47.776242	2025-09-02 04:06:13.605159	2025-09-02 04:09:47.776963
13	ljh791126@gmail.com	\N	student	\N	$2b$12$jZodLcHFJ3s77.OY2fOiV.yMmGW2VaTUTnR9W3Hc4RyXfYcOzI6DS	t	\N	2025-09-02 04:13:21.06961	2025-09-02 04:13:25.422534	2025-09-02 04:12:06.397625	2025-09-02 04:13:25.423058
15	hancin01@gmail.com	김한신	student	\N	$2b$12$DwTLqB5i0mejXw20YhY6ru0ZjPzVRfFenW9tD2tKBcRunEJyPUbPy	f	ul0fOEcvoBPSh_papx4S2uKD1jvox71Kejysy-AFRmY	\N	2025-09-02 04:13:28.469481	2025-09-02 04:13:28.470271	2025-09-02 04:13:28.470275
18	keymantiger@gmail.com	keyman	student	\N	$2b$12$zzLuHBio7xBSX1qDP3FB0.RJKWh5peSk.mHHZbHc2TDGjbF8p3p52	t	\N	2025-09-02 04:15:34.274435	2025-09-02 04:15:52.736039	2025-09-02 04:14:29.000565	2025-09-02 04:15:52.736745
16	ginakimth@gmail.com	김태현	student	\N	$2b$12$j6p43k7q.4wwHUeJdNLi9OJi5kkHHy799CWnK3SqQwmyWdc7NrhdK	t	\N	2025-09-02 04:16:57.385605	2025-09-02 04:17:08.340096	2025-09-02 04:14:15.188275	2025-09-02 04:17:08.340792
19	hyeonmo9@gmail.com	구현모	student	\N	$2b$12$nhQlnJKeY.uCyXcV3zgzRuFTeHUlkEDO6cirqvs83lJpnVh/RO05m	t	\N	2025-09-02 04:19:43.875429	2025-09-02 04:19:51.463306	2025-09-02 04:19:07.110969	2025-09-02 04:19:51.463917
9	hancin011@gmail.com	김한신	student	\N	$2b$12$PFkxjuapnhQxHXmHC3zgA.QyDs4XvehxrHknmY9q/RdQAXHAYKAfq	t	\N	2025-09-02 04:14:41.445541	2025-09-02 04:20:34.417033	2025-09-02 04:06:54.714974	2025-09-02 04:20:34.417671
20	h_y@naver.com	김희영	student	\N	$2b$12$H/xDHZGbg.kDh9CuFYC9deqwnf9rgr0sdBoS6U0EoxkH8CUXpoYFO	t	\N	2025-09-02 04:21:30.187468	2025-09-02 04:21:02.153402	2025-09-02 04:21:02.15423	2025-09-02 04:21:30.188013
10	yunissoft25@gmail.com	yunis	student	\N	$2b$12$kBHQD4wBYMZ5qzI/kwP2xOUGDpfapF5DEiH2lD0nYO3UEj2xMj4tO	t	\N	2025-09-02 04:14:24.945612	2025-09-02 04:21:32.65004	2025-09-02 04:07:11.84577	2025-09-02 04:21:32.650892
22	stephen4@naver.com	\N	student	\N	$2b$12$3sihkBw4u5YFGW5WWF4PRelAySCt9JbaxApUIeqeVFI3YezJb26mi	t	\N	2025-09-02 04:37:06.808546	2025-09-02 04:37:29.755889	2025-09-02 04:36:40.366809	2025-09-02 04:37:29.756622
2	chlgudals65@gmail.com	최형민	student	\N	$2b$12$FADGIhVcyHvIXT8j5/40ZOyMLEFcyFZYmu7XJ9RDYKgeQYpgornRG	t	\N	2025-09-02 04:13:36.799155	2025-09-02 05:01:26.239172	2025-09-02 04:03:42.070322	2025-09-02 05:01:26.24009
23	leejihyun935@gmail.com	irich	student	\N	$2b$12$P8kYroaNMlpHwQudAkWG9e/nOzig7HFIX2/Ceelo.drOifYGFJ9UC	t	\N	2025-09-02 05:55:46.823704	2025-09-02 05:54:27.656171	2025-09-02 05:54:27.657277	2025-09-02 05:55:46.82491
17	leejihyun93535@gmail.com	jihyun lee	student	\N	$2b$12$GN19HaH1p1ONu.uoVy.DOew8UC/IFx6PqM6ImwUzrpCsNipmRZ/p2	t	\N	2025-09-02 05:57:22.279831	2025-09-02 05:57:35.453953	2025-09-02 04:14:26.423203	2025-09-02 05:57:35.454517
3	wdbswo@outlook.com	YJ	student	\N	$2b$12$azBpDN5elOwNVYzAreRJK.gOQFA7irkweWnQujTaNfeUk6if47pxK	t	\N	2025-09-02 04:04:54.205978	2025-09-02 06:44:45.37828	2025-09-02 04:04:27.540528	2025-09-02 06:44:45.378718
21	kmalibu@outlook.kr	malibu	student	\N	$2b$12$snvr27BoLIHudpPkJAwi0.8w9ig5EnHfbsP.Xt5bB/g6x3so1duTC	t	\N	2025-09-02 04:26:11.977618	2025-09-02 07:05:06.288154	2025-09-02 04:25:53.644799	2025-09-02 07:05:06.289194
\.


--
-- Name: datasources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mcpuser
--

SELECT pg_catalog.setval('public.datasources_id_seq', 1, false);


--
-- Name: deployments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mcpuser
--

SELECT pg_catalog.setval('public.deployments_id_seq', 1, false);


--
-- Name: kb_document_versions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mcpuser
--

SELECT pg_catalog.setval('public.kb_document_versions_id_seq', 1, false);


--
-- Name: kb_documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mcpuser
--

SELECT pg_catalog.setval('public.kb_documents_id_seq', 1, false);


--
-- Name: trending_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mcpuser
--

SELECT pg_catalog.setval('public.trending_categories_id_seq', 1, false);


--
-- Name: user_certs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mcpuser
--

SELECT pg_catalog.setval('public.user_certs_id_seq', 1, false);


--
-- Name: user_keys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mcpuser
--

SELECT pg_catalog.setval('public.user_keys_id_seq', 1, false);


--
-- Name: user_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mcpuser
--

SELECT pg_catalog.setval('public.user_profiles_id_seq', 1, false);


--
-- Name: user_subscriptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mcpuser
--

SELECT pg_catalog.setval('public.user_subscriptions_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mcpuser
--

SELECT pg_catalog.setval('public.users_id_seq', 23, true);


--
-- Name: datasources datasources_pkey; Type: CONSTRAINT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.datasources
    ADD CONSTRAINT datasources_pkey PRIMARY KEY (id);


--
-- Name: deployments deployments_pkey; Type: CONSTRAINT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.deployments
    ADD CONSTRAINT deployments_pkey PRIMARY KEY (id);


--
-- Name: kb_document_versions kb_document_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.kb_document_versions
    ADD CONSTRAINT kb_document_versions_pkey PRIMARY KEY (id);


--
-- Name: kb_documents kb_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.kb_documents
    ADD CONSTRAINT kb_documents_pkey PRIMARY KEY (id);


--
-- Name: kb_tasks kb_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.kb_tasks
    ADD CONSTRAINT kb_tasks_pkey PRIMARY KEY (id);


--
-- Name: trending_categories trending_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.trending_categories
    ADD CONSTRAINT trending_categories_pkey PRIMARY KEY (id);


--
-- Name: user_certs user_certs_pkey; Type: CONSTRAINT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.user_certs
    ADD CONSTRAINT user_certs_pkey PRIMARY KEY (id);


--
-- Name: user_keys user_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.user_keys
    ADD CONSTRAINT user_keys_pkey PRIMARY KEY (id);


--
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);


--
-- Name: user_profiles user_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_user_id_key UNIQUE (user_id);


--
-- Name: user_subscriptions user_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.user_subscriptions
    ADD CONSTRAINT user_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: user_subscriptions user_subscriptions_user_id_key; Type: CONSTRAINT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.user_subscriptions
    ADD CONSTRAINT user_subscriptions_user_id_key UNIQUE (user_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ix_datasources_id; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE INDEX ix_datasources_id ON public.datasources USING btree (id);


--
-- Name: ix_datasources_name; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE UNIQUE INDEX ix_datasources_name ON public.datasources USING btree (name);


--
-- Name: ix_deployments_id; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE INDEX ix_deployments_id ON public.deployments USING btree (id);


--
-- Name: ix_deployments_name; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE INDEX ix_deployments_name ON public.deployments USING btree (name);


--
-- Name: ix_kb_document_versions_document_id; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE INDEX ix_kb_document_versions_document_id ON public.kb_document_versions USING btree (document_id);


--
-- Name: ix_kb_document_versions_id; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE INDEX ix_kb_document_versions_id ON public.kb_document_versions USING btree (id);


--
-- Name: ix_kb_document_versions_version_no; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE INDEX ix_kb_document_versions_version_no ON public.kb_document_versions USING btree (version_no);


--
-- Name: ix_kb_documents_id; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE INDEX ix_kb_documents_id ON public.kb_documents USING btree (id);


--
-- Name: ix_kb_documents_path; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE UNIQUE INDEX ix_kb_documents_path ON public.kb_documents USING btree (path);


--
-- Name: ix_kb_tasks_id; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE INDEX ix_kb_tasks_id ON public.kb_tasks USING btree (id);


--
-- Name: ix_kb_tasks_status; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE INDEX ix_kb_tasks_status ON public.kb_tasks USING btree (status);


--
-- Name: ix_kb_tasks_type; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE INDEX ix_kb_tasks_type ON public.kb_tasks USING btree (type);


--
-- Name: ix_trending_categories_id; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE INDEX ix_trending_categories_id ON public.trending_categories USING btree (id);


--
-- Name: ix_trending_categories_name; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE UNIQUE INDEX ix_trending_categories_name ON public.trending_categories USING btree (name);


--
-- Name: ix_user_subscriptions_stripe_customer_id; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE UNIQUE INDEX ix_user_subscriptions_stripe_customer_id ON public.user_subscriptions USING btree (stripe_customer_id);


--
-- Name: ix_user_subscriptions_stripe_subscription_id; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE UNIQUE INDEX ix_user_subscriptions_stripe_subscription_id ON public.user_subscriptions USING btree (stripe_subscription_id);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_email_verification_token; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE INDEX ix_users_email_verification_token ON public.users USING btree (email_verification_token);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: mcpuser
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: user_certs user_certs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.user_certs
    ADD CONSTRAINT user_certs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_keys user_keys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.user_keys
    ADD CONSTRAINT user_keys_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_profiles user_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_subscriptions user_subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mcpuser
--

ALTER TABLE ONLY public.user_subscriptions
    ADD CONSTRAINT user_subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict LRRe1v3bRhtY2091XQwBDbfhmjHFsrOwS2PUz77iJYV7kIhgBmkIUpOcvg2xGAq

