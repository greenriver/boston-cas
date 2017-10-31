--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.6
-- Dumped by pg_dump version 9.5.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: building_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE building_contacts (
    id integer NOT NULL,
    building_id integer NOT NULL,
    contact_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: building_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE building_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: building_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE building_contacts_id_seq OWNED BY building_contacts.id;


--
-- Name: building_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE building_services (
    id integer NOT NULL,
    building_id integer,
    service_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: building_services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE building_services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: building_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE building_services_id_seq OWNED BY building_services.id;


--
-- Name: buildings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE buildings (
    id integer NOT NULL,
    name character varying,
    building_type character varying,
    subgrantee_id integer,
    id_in_data_source integer,
    federal_program_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_source_id integer,
    data_source_id_column_name character varying,
    address character varying,
    city character varying,
    state character varying,
    zip_code character varying,
    geo_code character varying
);


--
-- Name: buildings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE buildings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: buildings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE buildings_id_seq OWNED BY buildings.id;


--
-- Name: client_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE client_contacts (
    id integer NOT NULL,
    client_id integer NOT NULL,
    contact_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    shelter_agency boolean DEFAULT false NOT NULL,
    regular boolean DEFAULT false NOT NULL
);


--
-- Name: client_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE client_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE client_contacts_id_seq OWNED BY client_contacts.id;


--
-- Name: client_opportunity_match_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE client_opportunity_match_contacts (
    id integer NOT NULL,
    match_id integer NOT NULL,
    contact_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    dnd_staff boolean DEFAULT false NOT NULL,
    housing_subsidy_admin boolean DEFAULT false NOT NULL,
    client boolean DEFAULT false NOT NULL,
    housing_search_worker boolean DEFAULT false NOT NULL,
    shelter_agency boolean DEFAULT false NOT NULL,
    ssp boolean DEFAULT false NOT NULL,
    hsp boolean DEFAULT false NOT NULL
);


--
-- Name: client_opportunity_match_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE client_opportunity_match_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_opportunity_match_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE client_opportunity_match_contacts_id_seq OWNED BY client_opportunity_match_contacts.id;


--
-- Name: client_opportunity_matches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE client_opportunity_matches (
    id integer NOT NULL,
    score integer,
    client_id integer NOT NULL,
    opportunity_id integer NOT NULL,
    contact_id integer,
    proposed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    selected boolean,
    active boolean DEFAULT false NOT NULL,
    closed boolean DEFAULT false NOT NULL,
    closed_reason character varying,
    universe_state json,
    custom_expiration_length integer,
    shelter_expiration date
);


--
-- Name: client_opportunity_matches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE client_opportunity_matches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_opportunity_matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE client_opportunity_matches_id_seq OWNED BY client_opportunity_matches.id;


--
-- Name: clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE clients (
    id integer NOT NULL,
    first_name character varying,
    middle_name character varying,
    last_name character varying,
    name_suffix character varying,
    name_quality character varying(4),
    ssn character varying(9),
    date_of_birth date,
    gender_other character varying(50),
    veteran boolean DEFAULT false,
    chronic_homeless boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    merged_into integer,
    split_from integer,
    ssn_quality integer,
    date_of_birth_quality integer,
    race_id integer,
    ethnicity_id integer,
    gender_id integer,
    veteran_status_id integer,
    developmental_disability integer,
    domestic_violence integer,
    calculated_first_homeless_night date,
    available boolean DEFAULT true NOT NULL,
    available_candidate boolean DEFAULT true,
    homephone character varying,
    cellphone character varying,
    workphone character varying,
    pager character varying,
    email character varying,
    hiv_aids boolean DEFAULT false,
    chronic_health_problem boolean DEFAULT false,
    mental_health_problem boolean DEFAULT false,
    substance_abuse_problem boolean DEFAULT false,
    physical_disability boolean DEFAULT false,
    disabling_condition boolean DEFAULT false,
    release_of_information timestamp without time zone,
    prevent_matching_until date,
    dmh_eligible boolean DEFAULT false NOT NULL,
    va_eligible boolean DEFAULT false NOT NULL,
    hues_eligible boolean DEFAULT false NOT NULL,
    disability_verified_on timestamp without time zone,
    housing_assistance_network_released_on timestamp without time zone,
    sync_with_cas boolean DEFAULT false NOT NULL,
    income_total_monthly double precision,
    income_total_monthly_last_collected timestamp without time zone,
    confidential boolean DEFAULT false NOT NULL,
    hiv_positive boolean DEFAULT false NOT NULL,
    housing_release_status character varying,
    vispdat_score integer,
    ineligible_immigrant boolean DEFAULT false NOT NULL,
    family_member boolean DEFAULT false NOT NULL,
    child_in_household boolean DEFAULT false NOT NULL,
    us_citizen boolean DEFAULT false NOT NULL,
    asylee boolean DEFAULT false NOT NULL,
    lifetime_sex_offender boolean DEFAULT false NOT NULL,
    meth_production_conviction boolean DEFAULT false NOT NULL,
    days_homeless integer,
    ha_eligible boolean DEFAULT false NOT NULL,
    days_homeless_in_last_three_years integer,
    vispdat_priority_score integer DEFAULT 0,
    vispdat_length_homeless_in_days integer DEFAULT 0 NOT NULL
);


--
-- Name: clients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE clients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE clients_id_seq OWNED BY clients.id;


--
-- Name: configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE configs (
    id integer NOT NULL,
    stalled_interval integer NOT NULL,
    dnd_interval integer NOT NULL,
    warehouse_url character varying NOT NULL,
    engine_mode character varying DEFAULT 'first-date-homeless'::character varying NOT NULL
);


--
-- Name: configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE configs_id_seq OWNED BY configs.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE contacts (
    id integer NOT NULL,
    email character varying,
    phone character varying,
    first_name character varying,
    last_name character varying,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    role character varying,
    id_in_data_source integer,
    data_source_id integer,
    data_source_id_column_name character varying,
    role_id integer,
    role_in_organization character varying,
    cell_phone character varying,
    middle_name character varying
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contacts_id_seq OWNED BY contacts.id;


--
-- Name: data_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE data_sources (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    db_itentifier character varying
);


--
-- Name: data_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE data_sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: data_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE data_sources_id_seq OWNED BY data_sources.id;


--
-- Name: date_of_birth_quality_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE date_of_birth_quality_codes (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: date_of_birth_quality_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE date_of_birth_quality_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: date_of_birth_quality_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE date_of_birth_quality_codes_id_seq OWNED BY date_of_birth_quality_codes.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: disabling_conditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE disabling_conditions (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: disabling_conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE disabling_conditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disabling_conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE disabling_conditions_id_seq OWNED BY disabling_conditions.id;


--
-- Name: discharge_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE discharge_statuses (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: discharge_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE discharge_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: discharge_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE discharge_statuses_id_seq OWNED BY discharge_statuses.id;


--
-- Name: domestic_violence_survivors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE domestic_violence_survivors (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: domestic_violence_survivors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE domestic_violence_survivors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: domestic_violence_survivors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE domestic_violence_survivors_id_seq OWNED BY domestic_violence_survivors.id;


--
-- Name: ethnicities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ethnicities (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ethnicities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ethnicities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ethnicities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ethnicities_id_seq OWNED BY ethnicities.id;


--
-- Name: file_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_tags (
    id integer NOT NULL,
    sub_program_id integer NOT NULL,
    name character varying,
    tag_id integer
);


--
-- Name: file_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_tags_id_seq OWNED BY file_tags.id;


--
-- Name: funding_source_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE funding_source_services (
    id integer NOT NULL,
    funding_source_id integer,
    service_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: funding_source_services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE funding_source_services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: funding_source_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE funding_source_services_id_seq OWNED BY funding_source_services.id;


--
-- Name: funding_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE funding_sources (
    id integer NOT NULL,
    name character varying,
    abbreviation character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    id_in_data_source integer,
    data_source_id integer,
    data_source_id_column_name character varying,
    deleted_at timestamp without time zone
);


--
-- Name: funding_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE funding_sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: funding_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE funding_sources_id_seq OWNED BY funding_sources.id;


--
-- Name: genders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE genders (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: genders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE genders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE genders_id_seq OWNED BY genders.id;


--
-- Name: has_developmental_disabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE has_developmental_disabilities (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: has_developmental_disabilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE has_developmental_disabilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: has_developmental_disabilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE has_developmental_disabilities_id_seq OWNED BY has_developmental_disabilities.id;


--
-- Name: has_hivaids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE has_hivaids (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: has_hivaids_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE has_hivaids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: has_hivaids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE has_hivaids_id_seq OWNED BY has_hivaids.id;


--
-- Name: has_mental_health_problems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE has_mental_health_problems (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: has_mental_health_problems_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE has_mental_health_problems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: has_mental_health_problems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE has_mental_health_problems_id_seq OWNED BY has_mental_health_problems.id;


--
-- Name: letsencrypt_plugin_challenges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE letsencrypt_plugin_challenges (
    id integer NOT NULL,
    response text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: letsencrypt_plugin_challenges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE letsencrypt_plugin_challenges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: letsencrypt_plugin_challenges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE letsencrypt_plugin_challenges_id_seq OWNED BY letsencrypt_plugin_challenges.id;


--
-- Name: letsencrypt_plugin_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE letsencrypt_plugin_settings (
    id integer NOT NULL,
    private_key text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: letsencrypt_plugin_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE letsencrypt_plugin_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: letsencrypt_plugin_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE letsencrypt_plugin_settings_id_seq OWNED BY letsencrypt_plugin_settings.id;


--
-- Name: match_decision_reasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE match_decision_reasons (
    id integer NOT NULL,
    name character varying NOT NULL,
    type character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    active boolean DEFAULT true NOT NULL
);


--
-- Name: match_decision_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE match_decision_reasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_decision_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE match_decision_reasons_id_seq OWNED BY match_decision_reasons.id;


--
-- Name: match_decisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE match_decisions (
    id integer NOT NULL,
    match_id integer,
    type character varying,
    status character varying,
    contact_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    client_last_seen_date timestamp without time zone,
    criminal_hearing_date timestamp without time zone,
    client_move_in_date timestamp without time zone,
    decline_reason_id integer,
    decline_reason_other_explanation text,
    not_working_with_client_reason_id integer,
    not_working_with_client_reason_other_explanation text,
    client_spoken_with_services_agency boolean DEFAULT false,
    cori_release_form_submitted boolean DEFAULT false,
    deleted_at timestamp without time zone,
    administrative_cancel_reason_id integer
);


--
-- Name: match_decisions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE match_decisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_decisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE match_decisions_id_seq OWNED BY match_decisions.id;


--
-- Name: match_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE match_events (
    id integer NOT NULL,
    type character varying,
    match_id integer,
    notification_id integer,
    decision_id integer,
    contact_id integer,
    action character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    note text,
    deleted_at timestamp without time zone,
    not_working_with_client_reason_id integer,
    client_last_seen_date date,
    admin_note boolean DEFAULT false NOT NULL
);


--
-- Name: match_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE match_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE match_events_id_seq OWNED BY match_events.id;


--
-- Name: match_progress_updates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE match_progress_updates (
    id integer NOT NULL,
    type character varying NOT NULL,
    match_id integer NOT NULL,
    notification_id integer,
    contact_id integer NOT NULL,
    decision_id integer,
    notification_number integer,
    requested_at timestamp without time zone,
    submitted_at timestamp without time zone,
    dnd_notified_at timestamp without time zone,
    response character varying,
    note text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    client_last_seen date
);


--
-- Name: match_progress_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE match_progress_updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_progress_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE match_progress_updates_id_seq OWNED BY match_progress_updates.id;


--
-- Name: name_quality_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE name_quality_codes (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: name_quality_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE name_quality_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: name_quality_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE name_quality_codes_id_seq OWNED BY name_quality_codes.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE notifications (
    id integer NOT NULL,
    type character varying,
    code character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    client_opportunity_match_id integer,
    recipient_id integer,
    expires_at timestamp without time zone
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: opportunities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE opportunities (
    id integer NOT NULL,
    name character varying,
    available boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    unit_id integer,
    matchability double precision,
    available_candidate boolean DEFAULT true,
    voucher_id integer,
    success boolean DEFAULT false
);


--
-- Name: opportunities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE opportunities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: opportunities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE opportunities_id_seq OWNED BY opportunities.id;


--
-- Name: opportunity_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE opportunity_contacts (
    id integer NOT NULL,
    opportunity_id integer NOT NULL,
    contact_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    housing_subsidy_admin boolean DEFAULT false NOT NULL
);


--
-- Name: opportunity_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE opportunity_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: opportunity_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE opportunity_contacts_id_seq OWNED BY opportunity_contacts.id;


--
-- Name: opportunity_properties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE opportunity_properties (
    id integer NOT NULL,
    opportunity_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: opportunity_properties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE opportunity_properties_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: opportunity_properties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE opportunity_properties_id_seq OWNED BY opportunity_properties.id;


--
-- Name: physical_disabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE physical_disabilities (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: physical_disabilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE physical_disabilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: physical_disabilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE physical_disabilities_id_seq OWNED BY physical_disabilities.id;


--
-- Name: primary_races; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE primary_races (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: primary_races_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE primary_races_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: primary_races_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE primary_races_id_seq OWNED BY primary_races.id;


--
-- Name: program_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE program_services (
    id integer NOT NULL,
    program_id integer,
    service_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: program_services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE program_services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: program_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE program_services_id_seq OWNED BY program_services.id;


--
-- Name: programs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE programs (
    id integer NOT NULL,
    name character varying,
    contract_start_date character varying,
    funding_source_id integer,
    subgrantee_id integer,
    contact_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    confidential boolean DEFAULT false NOT NULL
);


--
-- Name: programs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE programs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: programs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE programs_id_seq OWNED BY programs.id;


--
-- Name: project_clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE project_clients (
    id integer NOT NULL,
    first_name character varying,
    last_name character varying,
    ssn character varying,
    date_of_birth date,
    veteran_status character varying,
    substance_abuse_problem character varying,
    entry_date date,
    exit_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    clientguid uuid,
    middle_name character varying,
    ssn_quality_code integer,
    dob_quality_code integer,
    primary_race character varying,
    secondary_race character varying,
    gender integer,
    ethnicity integer,
    disabling_condition integer,
    hud_chronic_homelessness integer,
    calculated_chronic_homelessness integer,
    chronic_health_condition integer,
    physical_disability integer,
    hivaids_status integer,
    mental_health_problem integer,
    domestic_violence integer,
    discharge_type integer,
    developmental_disability integer,
    us_citizen boolean DEFAULT false NOT NULL,
    asylee boolean DEFAULT false NOT NULL,
    lifetime_sex_offender boolean DEFAULT false NOT NULL,
    meth_production_conviction boolean DEFAULT false NOT NULL,
    id_in_data_source integer,
    calculated_first_homeless_night date,
    calculated_last_homeless_night date,
    source_last_changed timestamp without time zone,
    data_source_id integer,
    data_source_id_column_name character varying,
    client_id integer,
    homephone character varying,
    cellphone character varying,
    workphone character varying,
    pager character varying,
    email character varying,
    dmh_eligible boolean DEFAULT false NOT NULL,
    va_eligible boolean DEFAULT false NOT NULL,
    hues_eligible boolean DEFAULT false NOT NULL,
    disability_verified_on timestamp without time zone,
    housing_assistance_network_released_on timestamp without time zone,
    sync_with_cas boolean DEFAULT false NOT NULL,
    income_total_monthly double precision,
    income_total_monthly_last_collected timestamp without time zone,
    hiv_positive boolean DEFAULT false NOT NULL,
    housing_release_status character varying,
    needs_update boolean DEFAULT false NOT NULL,
    vispdat_score integer,
    ineligible_immigrant boolean DEFAULT false NOT NULL,
    family_member boolean DEFAULT false NOT NULL,
    child_in_household boolean DEFAULT false NOT NULL,
    days_homeless integer,
    ha_eligible boolean DEFAULT false NOT NULL,
    days_homeless_in_last_three_years integer,
    vispdat_length_homeless_in_days integer DEFAULT 0 NOT NULL
);


--
-- Name: project_clients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_clients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_clients_id_seq OWNED BY project_clients.id;


--
-- Name: project_programs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE project_programs (
    id integer NOT NULL,
    id_in_data_source character varying,
    program_name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_source_id integer,
    data_source_id_column_name character varying
);


--
-- Name: project_programs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_programs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_programs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_programs_id_seq OWNED BY project_programs.id;


--
-- Name: reissue_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE reissue_requests (
    id integer NOT NULL,
    notification_id integer,
    reissued_by integer,
    reissued_at timestamp without time zone,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    request_sent_at timestamp without time zone
);


--
-- Name: reissue_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reissue_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reissue_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reissue_requests_id_seq OWNED BY reissue_requests.id;


--
-- Name: rejected_matches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rejected_matches (
    id integer NOT NULL,
    client_id integer NOT NULL,
    opportunity_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: rejected_matches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rejected_matches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rejected_matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rejected_matches_id_seq OWNED BY rejected_matches.id;


--
-- Name: requirements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE requirements (
    id integer NOT NULL,
    rule_id integer,
    requirer_id integer,
    requirer_type character varying,
    positive boolean,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: requirements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE requirements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: requirements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE requirements_id_seq OWNED BY requirements.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    can_view_all_clients boolean DEFAULT false,
    can_edit_all_clients boolean DEFAULT false,
    can_participate_in_matches boolean DEFAULT false,
    can_view_all_matches boolean DEFAULT false,
    can_view_own_closed_matches boolean DEFAULT false,
    can_see_alternate_matches boolean DEFAULT false,
    can_edit_match_contacts boolean DEFAULT false,
    can_approve_matches boolean DEFAULT false,
    can_reject_matches boolean DEFAULT false,
    can_act_on_behalf_of_match_contacts boolean DEFAULT false,
    can_view_reports boolean DEFAULT false,
    can_edit_roles boolean DEFAULT false,
    can_edit_users boolean DEFAULT false,
    can_view_full_ssn boolean DEFAULT false,
    can_view_full_dob boolean DEFAULT false,
    can_view_dmh_eligibility boolean DEFAULT false,
    can_view_va_eligibility boolean DEFAULT false,
    can_view_hues_eligibility boolean DEFAULT false,
    can_view_hiv_positive_eligibility boolean DEFAULT false,
    can_view_client_confidentiality boolean DEFAULT false,
    can_view_buildings boolean DEFAULT false,
    can_edit_buildings boolean DEFAULT false,
    can_view_funding_sources boolean DEFAULT false,
    can_edit_funding_sources boolean DEFAULT false,
    can_view_subgrantees boolean DEFAULT false,
    can_edit_subgrantees boolean DEFAULT false,
    can_view_vouchers boolean DEFAULT false,
    can_edit_vouchers boolean DEFAULT false,
    can_view_programs boolean DEFAULT false,
    can_edit_programs boolean DEFAULT false,
    can_view_opportunities boolean DEFAULT false,
    can_edit_opportunities boolean DEFAULT false,
    can_reissue_notifications boolean DEFAULT false,
    can_view_units boolean DEFAULT false,
    can_edit_units boolean DEFAULT false,
    can_add_vacancies boolean DEFAULT false,
    can_view_contacts boolean DEFAULT false,
    can_edit_contacts boolean DEFAULT false,
    can_view_rule_list boolean DEFAULT false,
    can_edit_rule_list boolean DEFAULT false,
    can_view_available_services boolean DEFAULT false,
    can_edit_available_services boolean DEFAULT false,
    can_assign_services boolean DEFAULT false,
    can_assign_requirements boolean DEFAULT false,
    can_become_other_users boolean DEFAULT false,
    can_edit_translations boolean DEFAULT false,
    can_view_vspdats boolean DEFAULT false,
    can_manage_config boolean DEFAULT false
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rules (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    type character varying,
    verb character varying
);


--
-- Name: rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rules_id_seq OWNED BY rules.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: secondary_races; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE secondary_races (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: secondary_races_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE secondary_races_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: secondary_races_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE secondary_races_id_seq OWNED BY secondary_races.id;


--
-- Name: service_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE service_rules (
    id integer NOT NULL,
    rule_id integer,
    service_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: service_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE service_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: service_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE service_rules_id_seq OWNED BY service_rules.id;


--
-- Name: services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE services (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE services_id_seq OWNED BY services.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sessions (
    id integer NOT NULL,
    session_id character varying NOT NULL,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: social_security_number_quality_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE social_security_number_quality_codes (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: social_security_number_quality_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE social_security_number_quality_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: social_security_number_quality_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE social_security_number_quality_codes_id_seq OWNED BY social_security_number_quality_codes.id;


--
-- Name: sub_programs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sub_programs (
    id integer NOT NULL,
    program_type character varying,
    program_id integer,
    building_id integer,
    subgrantee_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    matched integer DEFAULT 0,
    in_progress integer DEFAULT 0,
    vacancies integer DEFAULT 0,
    name character varying,
    sub_contractor_id integer,
    hsa_id integer,
    voucher_count integer DEFAULT 0,
    confidential boolean DEFAULT false NOT NULL,
    eligibility_requirement_notes text
);


--
-- Name: sub_programs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sub_programs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sub_programs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sub_programs_id_seq OWNED BY sub_programs.id;


--
-- Name: subgrantee_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE subgrantee_contacts (
    id integer NOT NULL,
    subgrantee_id integer NOT NULL,
    contact_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: subgrantee_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subgrantee_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subgrantee_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subgrantee_contacts_id_seq OWNED BY subgrantee_contacts.id;


--
-- Name: subgrantee_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE subgrantee_services (
    id integer NOT NULL,
    subgrantee_id integer,
    service_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: subgrantee_services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subgrantee_services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subgrantee_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subgrantee_services_id_seq OWNED BY subgrantee_services.id;


--
-- Name: subgrantees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE subgrantees (
    id integer NOT NULL,
    name character varying,
    abbreviation character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    id_in_data_source integer,
    disabled integer,
    data_source_id integer,
    data_source_id_column_name character varying,
    deleted_at timestamp without time zone
);


--
-- Name: subgrantees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subgrantees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subgrantees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subgrantees_id_seq OWNED BY subgrantees.id;


--
-- Name: translation_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE translation_keys (
    id integer NOT NULL,
    key character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: translation_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE translation_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: translation_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE translation_keys_id_seq OWNED BY translation_keys.id;


--
-- Name: translation_texts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE translation_texts (
    id integer NOT NULL,
    text text,
    locale character varying,
    translation_key_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: translation_texts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE translation_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: translation_texts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE translation_texts_id_seq OWNED BY translation_texts.id;


--
-- Name: units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE units (
    id integer NOT NULL,
    id_in_data_source integer,
    name character varying,
    available boolean,
    target_population_a character varying,
    target_population_b character varying,
    mc_kinney_vento boolean,
    chronic integer,
    veteran integer,
    adult_only integer,
    family integer,
    child_only integer,
    building_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    data_source_id integer,
    data_source_id_column_name character varying
);


--
-- Name: units_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE units_id_seq OWNED BY units.id;


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_roles (
    id integer NOT NULL,
    role_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_roles_id_seq OWNED BY user_roles.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp without time zone,
    invitation_token character varying,
    invitation_created_at timestamp without time zone,
    invitation_sent_at timestamp without time zone,
    invitation_accepted_at timestamp without time zone,
    invitation_limit integer,
    invited_by_id integer,
    invited_by_type character varying,
    invitations_count integer DEFAULT 0,
    receive_initial_notification boolean DEFAULT false,
    first_name character varying,
    last_name character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp without time zone,
    user_id integer,
    session_id character varying,
    request_id character varying,
    notification_code character varying
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: veteran_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE veteran_statuses (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: veteran_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE veteran_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: veteran_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE veteran_statuses_id_seq OWNED BY veteran_statuses.id;


--
-- Name: vouchers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vouchers (
    id integer NOT NULL,
    available boolean,
    date_available date,
    sub_program_id integer,
    unit_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    user_id integer
);


--
-- Name: vouchers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vouchers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vouchers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vouchers_id_seq OWNED BY vouchers.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY building_contacts ALTER COLUMN id SET DEFAULT nextval('building_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY building_services ALTER COLUMN id SET DEFAULT nextval('building_services_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY buildings ALTER COLUMN id SET DEFAULT nextval('buildings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY client_contacts ALTER COLUMN id SET DEFAULT nextval('client_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY client_opportunity_match_contacts ALTER COLUMN id SET DEFAULT nextval('client_opportunity_match_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY client_opportunity_matches ALTER COLUMN id SET DEFAULT nextval('client_opportunity_matches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY clients ALTER COLUMN id SET DEFAULT nextval('clients_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY configs ALTER COLUMN id SET DEFAULT nextval('configs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts ALTER COLUMN id SET DEFAULT nextval('contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY data_sources ALTER COLUMN id SET DEFAULT nextval('data_sources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY date_of_birth_quality_codes ALTER COLUMN id SET DEFAULT nextval('date_of_birth_quality_codes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY disabling_conditions ALTER COLUMN id SET DEFAULT nextval('disabling_conditions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY discharge_statuses ALTER COLUMN id SET DEFAULT nextval('discharge_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY domestic_violence_survivors ALTER COLUMN id SET DEFAULT nextval('domestic_violence_survivors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ethnicities ALTER COLUMN id SET DEFAULT nextval('ethnicities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_tags ALTER COLUMN id SET DEFAULT nextval('file_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY funding_source_services ALTER COLUMN id SET DEFAULT nextval('funding_source_services_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY funding_sources ALTER COLUMN id SET DEFAULT nextval('funding_sources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY genders ALTER COLUMN id SET DEFAULT nextval('genders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY has_developmental_disabilities ALTER COLUMN id SET DEFAULT nextval('has_developmental_disabilities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY has_hivaids ALTER COLUMN id SET DEFAULT nextval('has_hivaids_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY has_mental_health_problems ALTER COLUMN id SET DEFAULT nextval('has_mental_health_problems_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY letsencrypt_plugin_challenges ALTER COLUMN id SET DEFAULT nextval('letsencrypt_plugin_challenges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY letsencrypt_plugin_settings ALTER COLUMN id SET DEFAULT nextval('letsencrypt_plugin_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY match_decision_reasons ALTER COLUMN id SET DEFAULT nextval('match_decision_reasons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY match_decisions ALTER COLUMN id SET DEFAULT nextval('match_decisions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY match_events ALTER COLUMN id SET DEFAULT nextval('match_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY match_progress_updates ALTER COLUMN id SET DEFAULT nextval('match_progress_updates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_quality_codes ALTER COLUMN id SET DEFAULT nextval('name_quality_codes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY opportunities ALTER COLUMN id SET DEFAULT nextval('opportunities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY opportunity_contacts ALTER COLUMN id SET DEFAULT nextval('opportunity_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY opportunity_properties ALTER COLUMN id SET DEFAULT nextval('opportunity_properties_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY physical_disabilities ALTER COLUMN id SET DEFAULT nextval('physical_disabilities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY primary_races ALTER COLUMN id SET DEFAULT nextval('primary_races_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY program_services ALTER COLUMN id SET DEFAULT nextval('program_services_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY programs ALTER COLUMN id SET DEFAULT nextval('programs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_clients ALTER COLUMN id SET DEFAULT nextval('project_clients_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_programs ALTER COLUMN id SET DEFAULT nextval('project_programs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reissue_requests ALTER COLUMN id SET DEFAULT nextval('reissue_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rejected_matches ALTER COLUMN id SET DEFAULT nextval('rejected_matches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY requirements ALTER COLUMN id SET DEFAULT nextval('requirements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rules ALTER COLUMN id SET DEFAULT nextval('rules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY secondary_races ALTER COLUMN id SET DEFAULT nextval('secondary_races_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY service_rules ALTER COLUMN id SET DEFAULT nextval('service_rules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY services ALTER COLUMN id SET DEFAULT nextval('services_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY social_security_number_quality_codes ALTER COLUMN id SET DEFAULT nextval('social_security_number_quality_codes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sub_programs ALTER COLUMN id SET DEFAULT nextval('sub_programs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY subgrantee_contacts ALTER COLUMN id SET DEFAULT nextval('subgrantee_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY subgrantee_services ALTER COLUMN id SET DEFAULT nextval('subgrantee_services_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY subgrantees ALTER COLUMN id SET DEFAULT nextval('subgrantees_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY translation_keys ALTER COLUMN id SET DEFAULT nextval('translation_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY translation_texts ALTER COLUMN id SET DEFAULT nextval('translation_texts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY units ALTER COLUMN id SET DEFAULT nextval('units_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_roles ALTER COLUMN id SET DEFAULT nextval('user_roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY veteran_statuses ALTER COLUMN id SET DEFAULT nextval('veteran_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vouchers ALTER COLUMN id SET DEFAULT nextval('vouchers_id_seq'::regclass);


--
-- Name: building_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY building_contacts
    ADD CONSTRAINT building_contacts_pkey PRIMARY KEY (id);


--
-- Name: building_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY building_services
    ADD CONSTRAINT building_services_pkey PRIMARY KEY (id);


--
-- Name: buildings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY buildings
    ADD CONSTRAINT buildings_pkey PRIMARY KEY (id);


--
-- Name: client_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY client_contacts
    ADD CONSTRAINT client_contacts_pkey PRIMARY KEY (id);


--
-- Name: client_opportunity_match_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY client_opportunity_match_contacts
    ADD CONSTRAINT client_opportunity_match_contacts_pkey PRIMARY KEY (id);


--
-- Name: client_opportunity_matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY client_opportunity_matches
    ADD CONSTRAINT client_opportunity_matches_pkey PRIMARY KEY (id);


--
-- Name: clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY configs
    ADD CONSTRAINT configs_pkey PRIMARY KEY (id);


--
-- Name: contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: data_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY data_sources
    ADD CONSTRAINT data_sources_pkey PRIMARY KEY (id);


--
-- Name: date_of_birth_quality_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY date_of_birth_quality_codes
    ADD CONSTRAINT date_of_birth_quality_codes_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: disabling_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY disabling_conditions
    ADD CONSTRAINT disabling_conditions_pkey PRIMARY KEY (id);


--
-- Name: discharge_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discharge_statuses
    ADD CONSTRAINT discharge_statuses_pkey PRIMARY KEY (id);


--
-- Name: domestic_violence_survivors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY domestic_violence_survivors
    ADD CONSTRAINT domestic_violence_survivors_pkey PRIMARY KEY (id);


--
-- Name: ethnicities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ethnicities
    ADD CONSTRAINT ethnicities_pkey PRIMARY KEY (id);


--
-- Name: file_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_tags
    ADD CONSTRAINT file_tags_pkey PRIMARY KEY (id);


--
-- Name: funding_source_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY funding_source_services
    ADD CONSTRAINT funding_source_services_pkey PRIMARY KEY (id);


--
-- Name: funding_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY funding_sources
    ADD CONSTRAINT funding_sources_pkey PRIMARY KEY (id);


--
-- Name: genders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY genders
    ADD CONSTRAINT genders_pkey PRIMARY KEY (id);


--
-- Name: has_developmental_disabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY has_developmental_disabilities
    ADD CONSTRAINT has_developmental_disabilities_pkey PRIMARY KEY (id);


--
-- Name: has_hivaids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY has_hivaids
    ADD CONSTRAINT has_hivaids_pkey PRIMARY KEY (id);


--
-- Name: has_mental_health_problems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY has_mental_health_problems
    ADD CONSTRAINT has_mental_health_problems_pkey PRIMARY KEY (id);


--
-- Name: letsencrypt_plugin_challenges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY letsencrypt_plugin_challenges
    ADD CONSTRAINT letsencrypt_plugin_challenges_pkey PRIMARY KEY (id);


--
-- Name: letsencrypt_plugin_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY letsencrypt_plugin_settings
    ADD CONSTRAINT letsencrypt_plugin_settings_pkey PRIMARY KEY (id);


--
-- Name: match_decision_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY match_decision_reasons
    ADD CONSTRAINT match_decision_reasons_pkey PRIMARY KEY (id);


--
-- Name: match_decisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY match_decisions
    ADD CONSTRAINT match_decisions_pkey PRIMARY KEY (id);


--
-- Name: match_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY match_events
    ADD CONSTRAINT match_events_pkey PRIMARY KEY (id);


--
-- Name: match_progress_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY match_progress_updates
    ADD CONSTRAINT match_progress_updates_pkey PRIMARY KEY (id);


--
-- Name: name_quality_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_quality_codes
    ADD CONSTRAINT name_quality_codes_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: opportunities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY opportunities
    ADD CONSTRAINT opportunities_pkey PRIMARY KEY (id);


--
-- Name: opportunity_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY opportunity_contacts
    ADD CONSTRAINT opportunity_contacts_pkey PRIMARY KEY (id);


--
-- Name: opportunity_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY opportunity_properties
    ADD CONSTRAINT opportunity_properties_pkey PRIMARY KEY (id);


--
-- Name: physical_disabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY physical_disabilities
    ADD CONSTRAINT physical_disabilities_pkey PRIMARY KEY (id);


--
-- Name: primary_races_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY primary_races
    ADD CONSTRAINT primary_races_pkey PRIMARY KEY (id);


--
-- Name: program_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY program_services
    ADD CONSTRAINT program_services_pkey PRIMARY KEY (id);


--
-- Name: programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY programs
    ADD CONSTRAINT programs_pkey PRIMARY KEY (id);


--
-- Name: project_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_clients
    ADD CONSTRAINT project_clients_pkey PRIMARY KEY (id);


--
-- Name: project_programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_programs
    ADD CONSTRAINT project_programs_pkey PRIMARY KEY (id);


--
-- Name: reissue_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reissue_requests
    ADD CONSTRAINT reissue_requests_pkey PRIMARY KEY (id);


--
-- Name: rejected_matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rejected_matches
    ADD CONSTRAINT rejected_matches_pkey PRIMARY KEY (id);


--
-- Name: requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY requirements
    ADD CONSTRAINT requirements_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rules
    ADD CONSTRAINT rules_pkey PRIMARY KEY (id);


--
-- Name: secondary_races_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY secondary_races
    ADD CONSTRAINT secondary_races_pkey PRIMARY KEY (id);


--
-- Name: service_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY service_rules
    ADD CONSTRAINT service_rules_pkey PRIMARY KEY (id);


--
-- Name: services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: social_security_number_quality_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY social_security_number_quality_codes
    ADD CONSTRAINT social_security_number_quality_codes_pkey PRIMARY KEY (id);


--
-- Name: sub_programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sub_programs
    ADD CONSTRAINT sub_programs_pkey PRIMARY KEY (id);


--
-- Name: subgrantee_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY subgrantee_contacts
    ADD CONSTRAINT subgrantee_contacts_pkey PRIMARY KEY (id);


--
-- Name: subgrantee_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY subgrantee_services
    ADD CONSTRAINT subgrantee_services_pkey PRIMARY KEY (id);


--
-- Name: subgrantees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY subgrantees
    ADD CONSTRAINT subgrantees_pkey PRIMARY KEY (id);


--
-- Name: translation_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY translation_keys
    ADD CONSTRAINT translation_keys_pkey PRIMARY KEY (id);


--
-- Name: translation_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY translation_texts
    ADD CONSTRAINT translation_texts_pkey PRIMARY KEY (id);


--
-- Name: units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY units
    ADD CONSTRAINT units_pkey PRIMARY KEY (id);


--
-- Name: user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: veteran_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY veteran_statuses
    ADD CONSTRAINT veteran_statuses_pkey PRIMARY KEY (id);


--
-- Name: vouchers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vouchers
    ADD CONSTRAINT vouchers_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: index_building_contacts_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_building_contacts_on_building_id ON building_contacts USING btree (building_id);


--
-- Name: index_building_contacts_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_building_contacts_on_contact_id ON building_contacts USING btree (contact_id);


--
-- Name: index_building_contacts_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_building_contacts_on_deleted_at ON building_contacts USING btree (deleted_at);


--
-- Name: index_building_services_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_building_services_on_building_id ON building_services USING btree (building_id);


--
-- Name: index_building_services_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_building_services_on_deleted_at ON building_services USING btree (deleted_at);


--
-- Name: index_building_services_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_building_services_on_service_id ON building_services USING btree (service_id);


--
-- Name: index_buildings_on_id_in_data_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_on_id_in_data_source ON buildings USING btree (id_in_data_source);


--
-- Name: index_buildings_on_subgrantee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_on_subgrantee_id ON buildings USING btree (subgrantee_id);


--
-- Name: index_client_contacts_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_contacts_on_client_id ON client_contacts USING btree (client_id);


--
-- Name: index_client_contacts_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_contacts_on_contact_id ON client_contacts USING btree (contact_id);


--
-- Name: index_client_contacts_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_contacts_on_deleted_at ON client_contacts USING btree (deleted_at);


--
-- Name: index_client_opportunity_match_contacts_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_match_contacts_on_contact_id ON client_opportunity_match_contacts USING btree (contact_id);


--
-- Name: index_client_opportunity_match_contacts_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_match_contacts_on_deleted_at ON client_opportunity_match_contacts USING btree (deleted_at);


--
-- Name: index_client_opportunity_match_contacts_on_match_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_match_contacts_on_match_id ON client_opportunity_match_contacts USING btree (match_id);


--
-- Name: index_client_opportunity_matches_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_matches_on_active ON client_opportunity_matches USING btree (active);


--
-- Name: index_client_opportunity_matches_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_matches_on_client_id ON client_opportunity_matches USING btree (client_id);


--
-- Name: index_client_opportunity_matches_on_closed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_matches_on_closed ON client_opportunity_matches USING btree (closed);


--
-- Name: index_client_opportunity_matches_on_closed_reason; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_matches_on_closed_reason ON client_opportunity_matches USING btree (closed_reason);


--
-- Name: index_client_opportunity_matches_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_matches_on_contact_id ON client_opportunity_matches USING btree (contact_id);


--
-- Name: index_client_opportunity_matches_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_matches_on_deleted_at ON client_opportunity_matches USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: index_client_opportunity_matches_on_opportunity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_matches_on_opportunity_id ON client_opportunity_matches USING btree (opportunity_id);


--
-- Name: index_clients_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_deleted_at ON clients USING btree (deleted_at);


--
-- Name: index_contacts_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_deleted_at ON contacts USING btree (deleted_at);


--
-- Name: index_contacts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_user_id ON contacts USING btree (user_id);


--
-- Name: index_funding_source_services_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_funding_source_services_on_deleted_at ON funding_source_services USING btree (deleted_at);


--
-- Name: index_funding_source_services_on_funding_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_funding_source_services_on_funding_source_id ON funding_source_services USING btree (funding_source_id);


--
-- Name: index_funding_source_services_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_funding_source_services_on_service_id ON funding_source_services USING btree (service_id);


--
-- Name: index_match_decision_reasons_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_decision_reasons_on_type ON match_decision_reasons USING btree (type);


--
-- Name: index_match_decisions_on_administrative_cancel_reason_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_decisions_on_administrative_cancel_reason_id ON match_decisions USING btree (administrative_cancel_reason_id);


--
-- Name: index_match_decisions_on_decline_reason_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_decisions_on_decline_reason_id ON match_decisions USING btree (decline_reason_id);


--
-- Name: index_match_decisions_on_match_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_decisions_on_match_id ON match_decisions USING btree (match_id);


--
-- Name: index_match_decisions_on_not_working_with_client_reason_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_decisions_on_not_working_with_client_reason_id ON match_decisions USING btree (not_working_with_client_reason_id);


--
-- Name: index_match_events_on_decision_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_events_on_decision_id ON match_events USING btree (decision_id);


--
-- Name: index_match_events_on_match_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_events_on_match_id ON match_events USING btree (match_id);


--
-- Name: index_match_events_on_not_working_with_client_reason_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_events_on_not_working_with_client_reason_id ON match_events USING btree (not_working_with_client_reason_id);


--
-- Name: index_match_events_on_notification_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_events_on_notification_id ON match_events USING btree (notification_id);


--
-- Name: index_match_progress_updates_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_progress_updates_on_contact_id ON match_progress_updates USING btree (contact_id);


--
-- Name: index_match_progress_updates_on_decision_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_progress_updates_on_decision_id ON match_progress_updates USING btree (decision_id);


--
-- Name: index_match_progress_updates_on_match_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_progress_updates_on_match_id ON match_progress_updates USING btree (match_id);


--
-- Name: index_match_progress_updates_on_notification_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_progress_updates_on_notification_id ON match_progress_updates USING btree (notification_id);


--
-- Name: index_match_progress_updates_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_progress_updates_on_type ON match_progress_updates USING btree (type);


--
-- Name: index_opportunities_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_opportunities_on_deleted_at ON opportunities USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: index_opportunities_on_unit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_opportunities_on_unit_id ON opportunities USING btree (unit_id);


--
-- Name: index_opportunities_on_voucher_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_opportunities_on_voucher_id ON opportunities USING btree (voucher_id);


--
-- Name: index_opportunity_contacts_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_opportunity_contacts_on_contact_id ON opportunity_contacts USING btree (contact_id);


--
-- Name: index_opportunity_contacts_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_opportunity_contacts_on_deleted_at ON opportunity_contacts USING btree (deleted_at);


--
-- Name: index_opportunity_contacts_on_opportunity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_opportunity_contacts_on_opportunity_id ON opportunity_contacts USING btree (opportunity_id);


--
-- Name: index_opportunity_properties_on_opportunity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_opportunity_properties_on_opportunity_id ON opportunity_properties USING btree (opportunity_id);


--
-- Name: index_program_services_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_program_services_on_deleted_at ON program_services USING btree (deleted_at);


--
-- Name: index_program_services_on_program_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_program_services_on_program_id ON program_services USING btree (program_id);


--
-- Name: index_program_services_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_program_services_on_service_id ON program_services USING btree (service_id);


--
-- Name: index_programs_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_programs_on_contact_id ON programs USING btree (contact_id);


--
-- Name: index_programs_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_programs_on_deleted_at ON programs USING btree (deleted_at);


--
-- Name: index_programs_on_funding_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_programs_on_funding_source_id ON programs USING btree (funding_source_id);


--
-- Name: index_programs_on_subgrantee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_programs_on_subgrantee_id ON programs USING btree (subgrantee_id);


--
-- Name: index_project_clients_on_calculated_chronic_homelessness; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_clients_on_calculated_chronic_homelessness ON project_clients USING btree (calculated_chronic_homelessness);


--
-- Name: index_project_clients_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_clients_on_client_id ON project_clients USING btree (client_id);


--
-- Name: index_project_clients_on_date_of_birth; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_clients_on_date_of_birth ON project_clients USING btree (date_of_birth);


--
-- Name: index_project_clients_on_source_last_changed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_clients_on_source_last_changed ON project_clients USING btree (source_last_changed);


--
-- Name: index_reissue_requests_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reissue_requests_on_deleted_at ON reissue_requests USING btree (deleted_at);


--
-- Name: index_reissue_requests_on_notification_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reissue_requests_on_notification_id ON reissue_requests USING btree (notification_id);


--
-- Name: index_reissue_requests_on_reissued_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reissue_requests_on_reissued_by ON reissue_requests USING btree (reissued_by);


--
-- Name: index_rejected_matches_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rejected_matches_on_client_id ON rejected_matches USING btree (client_id);


--
-- Name: index_rejected_matches_on_opportunity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rejected_matches_on_opportunity_id ON rejected_matches USING btree (opportunity_id);


--
-- Name: index_requirements_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requirements_on_deleted_at ON requirements USING btree (deleted_at);


--
-- Name: index_requirements_on_requirer_type_and_requirer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requirements_on_requirer_type_and_requirer_id ON requirements USING btree (requirer_type, requirer_id);


--
-- Name: index_requirements_on_rule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requirements_on_rule_id ON requirements USING btree (rule_id);


--
-- Name: index_roles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_name ON roles USING btree (name);


--
-- Name: index_rules_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rules_on_deleted_at ON rules USING btree (deleted_at);


--
-- Name: index_service_rules_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_service_rules_on_deleted_at ON service_rules USING btree (deleted_at);


--
-- Name: index_service_rules_on_rule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_service_rules_on_rule_id ON service_rules USING btree (rule_id);


--
-- Name: index_service_rules_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_service_rules_on_service_id ON service_rules USING btree (service_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_sessions_on_session_id ON sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_updated_at ON sessions USING btree (updated_at);


--
-- Name: index_sub_programs_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sub_programs_on_building_id ON sub_programs USING btree (building_id);


--
-- Name: index_sub_programs_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sub_programs_on_deleted_at ON sub_programs USING btree (deleted_at);


--
-- Name: index_sub_programs_on_program_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sub_programs_on_program_id ON sub_programs USING btree (program_id);


--
-- Name: index_sub_programs_on_subgrantee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sub_programs_on_subgrantee_id ON sub_programs USING btree (subgrantee_id);


--
-- Name: index_subgrantee_contacts_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subgrantee_contacts_on_contact_id ON subgrantee_contacts USING btree (contact_id);


--
-- Name: index_subgrantee_contacts_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subgrantee_contacts_on_deleted_at ON subgrantee_contacts USING btree (deleted_at);


--
-- Name: index_subgrantee_contacts_on_subgrantee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subgrantee_contacts_on_subgrantee_id ON subgrantee_contacts USING btree (subgrantee_id);


--
-- Name: index_subgrantee_services_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subgrantee_services_on_deleted_at ON subgrantee_services USING btree (deleted_at);


--
-- Name: index_subgrantee_services_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subgrantee_services_on_service_id ON subgrantee_services USING btree (service_id);


--
-- Name: index_subgrantee_services_on_subgrantee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subgrantee_services_on_subgrantee_id ON subgrantee_services USING btree (subgrantee_id);


--
-- Name: index_translation_keys_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_translation_keys_on_key ON translation_keys USING btree (key);


--
-- Name: index_translation_texts_on_translation_key_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_translation_texts_on_translation_key_id ON translation_texts USING btree (translation_key_id);


--
-- Name: index_units_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_units_on_building_id ON units USING btree (building_id);


--
-- Name: index_units_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_units_on_deleted_at ON units USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: index_units_on_id_in_data_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_units_on_id_in_data_source ON units USING btree (id_in_data_source);


--
-- Name: index_user_roles_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_roles_on_role_id ON user_roles USING btree (role_id);


--
-- Name: index_user_roles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_roles_on_user_id ON user_roles USING btree (user_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_invitation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_invitation_token ON users USING btree (invitation_token);


--
-- Name: index_users_on_invitations_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invitations_count ON users USING btree (invitations_count);


--
-- Name: index_users_on_invited_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invited_by_id ON users USING btree (invited_by_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON users USING btree (unlock_token);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: index_vouchers_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vouchers_on_deleted_at ON vouchers USING btree (deleted_at);


--
-- Name: index_vouchers_on_sub_program_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vouchers_on_sub_program_id ON vouchers USING btree (sub_program_id);


--
-- Name: index_vouchers_on_unit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vouchers_on_unit_id ON vouchers USING btree (unit_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_rails_08099961f4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sub_programs
    ADD CONSTRAINT fk_rails_08099961f4 FOREIGN KEY (program_id) REFERENCES programs(id);


--
-- Name: fk_rails_1c9726a2f9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sub_programs
    ADD CONSTRAINT fk_rails_1c9726a2f9 FOREIGN KEY (hsa_id) REFERENCES subgrantees(id);


--
-- Name: fk_rails_318345354e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT fk_rails_318345354e FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_rails_3369e0d5fc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT fk_rails_3369e0d5fc FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE;


--
-- Name: fk_rails_3938619bb0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vouchers
    ADD CONSTRAINT fk_rails_3938619bb0 FOREIGN KEY (sub_program_id) REFERENCES sub_programs(id);


--
-- Name: fk_rails_3e6ca7b204; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vouchers
    ADD CONSTRAINT fk_rails_3e6ca7b204 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_5502b5ba7e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reissue_requests
    ADD CONSTRAINT fk_rails_5502b5ba7e FOREIGN KEY (reissued_by) REFERENCES users(id);


--
-- Name: fk_rails_6a0a1e6411; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY programs
    ADD CONSTRAINT fk_rails_6a0a1e6411 FOREIGN KEY (subgrantee_id) REFERENCES subgrantees(id);


--
-- Name: fk_rails_7aa5978182; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sub_programs
    ADD CONSTRAINT fk_rails_7aa5978182 FOREIGN KEY (building_id) REFERENCES buildings(id);


--
-- Name: fk_rails_7f153cde04; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reissue_requests
    ADD CONSTRAINT fk_rails_7f153cde04 FOREIGN KEY (notification_id) REFERENCES notifications(id);


--
-- Name: fk_rails_90139b441c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY opportunities
    ADD CONSTRAINT fk_rails_90139b441c FOREIGN KEY (voucher_id) REFERENCES vouchers(id);


--
-- Name: fk_rails_9d29596bf8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY programs
    ADD CONSTRAINT fk_rails_9d29596bf8 FOREIGN KEY (funding_source_id) REFERENCES funding_sources(id);


--
-- Name: fk_rails_b7b36b70ab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vouchers
    ADD CONSTRAINT fk_rails_b7b36b70ab FOREIGN KEY (unit_id) REFERENCES units(id);


--
-- Name: fk_rails_b8163bf251; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sub_programs
    ADD CONSTRAINT fk_rails_b8163bf251 FOREIGN KEY (subgrantee_id) REFERENCES subgrantees(id);


--
-- Name: fk_rails_c0d5ae3683; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY programs
    ADD CONSTRAINT fk_rails_c0d5ae3683 FOREIGN KEY (contact_id) REFERENCES contacts(id);


--
-- Name: fk_rails_f92c6a12a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sub_programs
    ADD CONSTRAINT fk_rails_f92c6a12a3 FOREIGN KEY (sub_contractor_id) REFERENCES subgrantees(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20160212185654');

INSERT INTO schema_migrations (version) VALUES ('20160223173233');

INSERT INTO schema_migrations (version) VALUES ('20160302182826');

INSERT INTO schema_migrations (version) VALUES ('20160302193733');

INSERT INTO schema_migrations (version) VALUES ('20160304185448');

INSERT INTO schema_migrations (version) VALUES ('20160306003655');

INSERT INTO schema_migrations (version) VALUES ('20160307013645');

INSERT INTO schema_migrations (version) VALUES ('20160307164647');

INSERT INTO schema_migrations (version) VALUES ('20160307192631');

INSERT INTO schema_migrations (version) VALUES ('20160308204935');

INSERT INTO schema_migrations (version) VALUES ('20160308212348');

INSERT INTO schema_migrations (version) VALUES ('20160310204713');

INSERT INTO schema_migrations (version) VALUES ('20160311185352');

INSERT INTO schema_migrations (version) VALUES ('20160311203425');

INSERT INTO schema_migrations (version) VALUES ('20160311213859');

INSERT INTO schema_migrations (version) VALUES ('20160311215729');

INSERT INTO schema_migrations (version) VALUES ('20160311221109');

INSERT INTO schema_migrations (version) VALUES ('20160311221118');

INSERT INTO schema_migrations (version) VALUES ('20160314125643');

INSERT INTO schema_migrations (version) VALUES ('20160314125723');

INSERT INTO schema_migrations (version) VALUES ('20160314125734');

INSERT INTO schema_migrations (version) VALUES ('20160314125742');

INSERT INTO schema_migrations (version) VALUES ('20160314125809');

INSERT INTO schema_migrations (version) VALUES ('20160314125825');

INSERT INTO schema_migrations (version) VALUES ('20160314125837');

INSERT INTO schema_migrations (version) VALUES ('20160314125858');

INSERT INTO schema_migrations (version) VALUES ('20160314125911');

INSERT INTO schema_migrations (version) VALUES ('20160314125925');

INSERT INTO schema_migrations (version) VALUES ('20160314125955');

INSERT INTO schema_migrations (version) VALUES ('20160314130009');

INSERT INTO schema_migrations (version) VALUES ('20160314130026');

INSERT INTO schema_migrations (version) VALUES ('20160314170902');

INSERT INTO schema_migrations (version) VALUES ('20160314180117');

INSERT INTO schema_migrations (version) VALUES ('20160314181828');

INSERT INTO schema_migrations (version) VALUES ('20160315174252');

INSERT INTO schema_migrations (version) VALUES ('20160315181816');

INSERT INTO schema_migrations (version) VALUES ('20160316140845');

INSERT INTO schema_migrations (version) VALUES ('20160317154933');

INSERT INTO schema_migrations (version) VALUES ('20160317155559');

INSERT INTO schema_migrations (version) VALUES ('20160317172840');

INSERT INTO schema_migrations (version) VALUES ('20160317174943');

INSERT INTO schema_migrations (version) VALUES ('20160317182939');

INSERT INTO schema_migrations (version) VALUES ('20160317194643');

INSERT INTO schema_migrations (version) VALUES ('20160318123052');

INSERT INTO schema_migrations (version) VALUES ('20160318182521');

INSERT INTO schema_migrations (version) VALUES ('20160321145517');

INSERT INTO schema_migrations (version) VALUES ('20160321154527');

INSERT INTO schema_migrations (version) VALUES ('20160322003154');

INSERT INTO schema_migrations (version) VALUES ('20160322003840');

INSERT INTO schema_migrations (version) VALUES ('20160322010236');

INSERT INTO schema_migrations (version) VALUES ('20160322124148');

INSERT INTO schema_migrations (version) VALUES ('20160324160916');

INSERT INTO schema_migrations (version) VALUES ('20160324193620');

INSERT INTO schema_migrations (version) VALUES ('20160324204527');

INSERT INTO schema_migrations (version) VALUES ('20160325160053');

INSERT INTO schema_migrations (version) VALUES ('20160325183212');

INSERT INTO schema_migrations (version) VALUES ('20160325200752');

INSERT INTO schema_migrations (version) VALUES ('20160325200844');

INSERT INTO schema_migrations (version) VALUES ('20160328015127');

INSERT INTO schema_migrations (version) VALUES ('20160328015510');

INSERT INTO schema_migrations (version) VALUES ('20160328124526');

INSERT INTO schema_migrations (version) VALUES ('20160328174238');

INSERT INTO schema_migrations (version) VALUES ('20160328194812');

INSERT INTO schema_migrations (version) VALUES ('20160328200741');

INSERT INTO schema_migrations (version) VALUES ('20160329142615');

INSERT INTO schema_migrations (version) VALUES ('20160329183607');

INSERT INTO schema_migrations (version) VALUES ('20160329183922');

INSERT INTO schema_migrations (version) VALUES ('20160329184000');

INSERT INTO schema_migrations (version) VALUES ('20160330135219');

INSERT INTO schema_migrations (version) VALUES ('20160330190745');

INSERT INTO schema_migrations (version) VALUES ('20160331000512');

INSERT INTO schema_migrations (version) VALUES ('20160331164934');

INSERT INTO schema_migrations (version) VALUES ('20160331191107');

INSERT INTO schema_migrations (version) VALUES ('20160401121404');

INSERT INTO schema_migrations (version) VALUES ('20160401154333');

INSERT INTO schema_migrations (version) VALUES ('20160401194603');

INSERT INTO schema_migrations (version) VALUES ('20160404123859');

INSERT INTO schema_migrations (version) VALUES ('20160404202155');

INSERT INTO schema_migrations (version) VALUES ('20160405155325');

INSERT INTO schema_migrations (version) VALUES ('20160406160729');

INSERT INTO schema_migrations (version) VALUES ('20160406163059');

INSERT INTO schema_migrations (version) VALUES ('20160406180128');

INSERT INTO schema_migrations (version) VALUES ('20160407171741');

INSERT INTO schema_migrations (version) VALUES ('20160407191141');

INSERT INTO schema_migrations (version) VALUES ('20160407201337');

INSERT INTO schema_migrations (version) VALUES ('20160408134113');

INSERT INTO schema_migrations (version) VALUES ('20160408185513');

INSERT INTO schema_migrations (version) VALUES ('20160408202750');

INSERT INTO schema_migrations (version) VALUES ('20160409183228');

INSERT INTO schema_migrations (version) VALUES ('20160411134641');

INSERT INTO schema_migrations (version) VALUES ('20160411145222');

INSERT INTO schema_migrations (version) VALUES ('20160411152547');

INSERT INTO schema_migrations (version) VALUES ('20160411175935');

INSERT INTO schema_migrations (version) VALUES ('20160411176836');

INSERT INTO schema_migrations (version) VALUES ('20160412153745');

INSERT INTO schema_migrations (version) VALUES ('20160414122427');

INSERT INTO schema_migrations (version) VALUES ('20160414142903');

INSERT INTO schema_migrations (version) VALUES ('20160420152827');

INSERT INTO schema_migrations (version) VALUES ('20160423194726');

INSERT INTO schema_migrations (version) VALUES ('20160424003441');

INSERT INTO schema_migrations (version) VALUES ('20160424005155');

INSERT INTO schema_migrations (version) VALUES ('20160424134405');

INSERT INTO schema_migrations (version) VALUES ('20160425123612');

INSERT INTO schema_migrations (version) VALUES ('20160425153957');

INSERT INTO schema_migrations (version) VALUES ('20160425154223');

INSERT INTO schema_migrations (version) VALUES ('20160425190640');

INSERT INTO schema_migrations (version) VALUES ('20160426195634');

INSERT INTO schema_migrations (version) VALUES ('20160426195948');

INSERT INTO schema_migrations (version) VALUES ('20160427124030');

INSERT INTO schema_migrations (version) VALUES ('20160427154813');

INSERT INTO schema_migrations (version) VALUES ('20160428172106');

INSERT INTO schema_migrations (version) VALUES ('20160428180615');

INSERT INTO schema_migrations (version) VALUES ('20160429132941');

INSERT INTO schema_migrations (version) VALUES ('20160429163105');

INSERT INTO schema_migrations (version) VALUES ('20160429164547');

INSERT INTO schema_migrations (version) VALUES ('20160502234117');

INSERT INTO schema_migrations (version) VALUES ('20160503172539');

INSERT INTO schema_migrations (version) VALUES ('20160519170917');

INSERT INTO schema_migrations (version) VALUES ('20160519171133');

INSERT INTO schema_migrations (version) VALUES ('20160519173925');

INSERT INTO schema_migrations (version) VALUES ('20160520160418');

INSERT INTO schema_migrations (version) VALUES ('20160520183310');

INSERT INTO schema_migrations (version) VALUES ('20160524191935');

INSERT INTO schema_migrations (version) VALUES ('20160525130236');

INSERT INTO schema_migrations (version) VALUES ('20160525201537');

INSERT INTO schema_migrations (version) VALUES ('20160602190355');

INSERT INTO schema_migrations (version) VALUES ('20160610192904');

INSERT INTO schema_migrations (version) VALUES ('20160611010706');

INSERT INTO schema_migrations (version) VALUES ('20160622175241');

INSERT INTO schema_migrations (version) VALUES ('20160622193037');

INSERT INTO schema_migrations (version) VALUES ('20160809193948');

INSERT INTO schema_migrations (version) VALUES ('20160817172520');

INSERT INTO schema_migrations (version) VALUES ('20160901201841');

INSERT INTO schema_migrations (version) VALUES ('20160902143546');

INSERT INTO schema_migrations (version) VALUES ('20161017132353');

INSERT INTO schema_migrations (version) VALUES ('20161017144713');

INSERT INTO schema_migrations (version) VALUES ('20161021171808');

INSERT INTO schema_migrations (version) VALUES ('20161108203825');

INSERT INTO schema_migrations (version) VALUES ('20161117152709');

INSERT INTO schema_migrations (version) VALUES ('20161117155843');

INSERT INTO schema_migrations (version) VALUES ('20161117162449');

INSERT INTO schema_migrations (version) VALUES ('20161130173742');

INSERT INTO schema_migrations (version) VALUES ('20161205190843');

INSERT INTO schema_migrations (version) VALUES ('20170103172116');

INSERT INTO schema_migrations (version) VALUES ('20170201135646');

INSERT INTO schema_migrations (version) VALUES ('20170213180945');

INSERT INTO schema_migrations (version) VALUES ('20170213195031');

INSERT INTO schema_migrations (version) VALUES ('20170302202943');

INSERT INTO schema_migrations (version) VALUES ('20170314162953');

INSERT INTO schema_migrations (version) VALUES ('20170315124419');

INSERT INTO schema_migrations (version) VALUES ('20170315125413');

INSERT INTO schema_migrations (version) VALUES ('20170322155734');

INSERT INTO schema_migrations (version) VALUES ('20170326234009');

INSERT INTO schema_migrations (version) VALUES ('20170329122422');

INSERT INTO schema_migrations (version) VALUES ('20170421142554');

INSERT INTO schema_migrations (version) VALUES ('20170421163530');

INSERT INTO schema_migrations (version) VALUES ('20170428201839');

INSERT INTO schema_migrations (version) VALUES ('20170505125855');

INSERT INTO schema_migrations (version) VALUES ('20170505170358');

INSERT INTO schema_migrations (version) VALUES ('20170511192828');

INSERT INTO schema_migrations (version) VALUES ('20170511194721');

INSERT INTO schema_migrations (version) VALUES ('20170524180811');

INSERT INTO schema_migrations (version) VALUES ('20170524180812');

INSERT INTO schema_migrations (version) VALUES ('20170605162924');

INSERT INTO schema_migrations (version) VALUES ('20170619000309');

INSERT INTO schema_migrations (version) VALUES ('20170621184202');

INSERT INTO schema_migrations (version) VALUES ('20170623171917');

INSERT INTO schema_migrations (version) VALUES ('20170629144505');

INSERT INTO schema_migrations (version) VALUES ('20170713125233');

INSERT INTO schema_migrations (version) VALUES ('20170724182052');

INSERT INTO schema_migrations (version) VALUES ('20170725203814');

INSERT INTO schema_migrations (version) VALUES ('20170818202458');

INSERT INTO schema_migrations (version) VALUES ('20170821132203');

INSERT INTO schema_migrations (version) VALUES ('20170823175246');

INSERT INTO schema_migrations (version) VALUES ('20170823182320');

INSERT INTO schema_migrations (version) VALUES ('20170827114049');

INSERT INTO schema_migrations (version) VALUES ('20170901180331');

INSERT INTO schema_migrations (version) VALUES ('20170904161926');

INSERT INTO schema_migrations (version) VALUES ('20170904173248');

INSERT INTO schema_migrations (version) VALUES ('20170904175515');

INSERT INTO schema_migrations (version) VALUES ('20170904203345');

INSERT INTO schema_migrations (version) VALUES ('20170906162452');

INSERT INTO schema_migrations (version) VALUES ('20170907122041');

INSERT INTO schema_migrations (version) VALUES ('20170914195045');

INSERT INTO schema_migrations (version) VALUES ('20170921150901');

INSERT INTO schema_migrations (version) VALUES ('20170925155224');

INSERT INTO schema_migrations (version) VALUES ('20170925170636');

INSERT INTO schema_migrations (version) VALUES ('20171002184557');

INSERT INTO schema_migrations (version) VALUES ('20171023185614');

INSERT INTO schema_migrations (version) VALUES ('20171025030616');

INSERT INTO schema_migrations (version) VALUES ('20171025194209');

INSERT INTO schema_migrations (version) VALUES ('20171030152636');

