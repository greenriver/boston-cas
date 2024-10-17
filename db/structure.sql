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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activity_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_logs (
    id bigint NOT NULL,
    item_model character varying,
    item_id integer,
    title character varying,
    user_id integer NOT NULL,
    controller_name character varying NOT NULL,
    action_name character varying NOT NULL,
    method character varying,
    path character varying,
    ip_address character varying NOT NULL,
    session_hash character varying,
    referrer text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: activity_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activity_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activity_logs_id_seq OWNED BY public.activity_logs.id;


--
-- Name: agencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agencies (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: agencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.agencies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.agencies_id_seq OWNED BY public.agencies.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: building_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.building_contacts (
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

CREATE SEQUENCE public.building_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: building_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.building_contacts_id_seq OWNED BY public.building_contacts.id;


--
-- Name: building_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.building_services (
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

CREATE SEQUENCE public.building_services_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: building_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.building_services_id_seq OWNED BY public.building_services.id;


--
-- Name: buildings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.buildings (
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

CREATE SEQUENCE public.buildings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: buildings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.buildings_id_seq OWNED BY public.buildings.id;


--
-- Name: client_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_contacts (
    id integer NOT NULL,
    client_id integer NOT NULL,
    contact_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    shelter_agency boolean DEFAULT false NOT NULL,
    regular boolean DEFAULT false NOT NULL,
    dnd_staff boolean DEFAULT false NOT NULL,
    housing_subsidy_admin boolean DEFAULT false NOT NULL,
    ssp boolean DEFAULT false NOT NULL,
    hsp boolean DEFAULT false NOT NULL,
    "do" boolean DEFAULT false NOT NULL
);


--
-- Name: client_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.client_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.client_contacts_id_seq OWNED BY public.client_contacts.id;


--
-- Name: client_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_notes (
    id integer NOT NULL,
    user_id integer NOT NULL,
    client_id integer NOT NULL,
    note character varying,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: client_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.client_notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.client_notes_id_seq OWNED BY public.client_notes.id;


--
-- Name: client_opportunity_match_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_opportunity_match_contacts (
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
    hsp boolean DEFAULT false NOT NULL,
    "do" boolean DEFAULT false NOT NULL,
    contact_order integer
);


--
-- Name: client_opportunity_match_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.client_opportunity_match_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_opportunity_match_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.client_opportunity_match_contacts_id_seq OWNED BY public.client_opportunity_match_contacts.id;


--
-- Name: client_opportunity_matches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_opportunity_matches (
    id integer NOT NULL,
    score integer,
    client_id integer NOT NULL,
    opportunity_id integer NOT NULL,
    contact_id integer,
    proposed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    active boolean DEFAULT false NOT NULL,
    closed boolean DEFAULT false NOT NULL,
    closed_reason character varying,
    selected boolean,
    universe_state json,
    custom_expiration_length integer,
    shelter_expiration date,
    stall_date date,
    stall_contacts_notified timestamp without time zone,
    dnd_notified timestamp without time zone,
    match_route_id integer
);


--
-- Name: client_opportunity_matches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.client_opportunity_matches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_opportunity_matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.client_opportunity_matches_id_seq OWNED BY public.client_opportunity_matches.id;


--
-- Name: clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clients (
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
    vispdat_length_homeless_in_days integer DEFAULT 0 NOT NULL,
    cspech_eligible boolean DEFAULT false,
    alternate_names character varying,
    calculated_last_homeless_night date,
    congregate_housing boolean DEFAULT false,
    sober_housing boolean DEFAULT false,
    enrolled_project_ids jsonb,
    active_cohort_ids jsonb,
    client_identifier character varying,
    assessment_score integer DEFAULT 0 NOT NULL,
    ssvf_eligible boolean DEFAULT false NOT NULL,
    rrh_desired boolean DEFAULT false NOT NULL,
    youth_rrh_desired boolean DEFAULT false NOT NULL,
    rrh_assessment_contact_info character varying,
    rrh_assessment_collected_at timestamp without time zone,
    enrolled_in_th boolean DEFAULT false NOT NULL,
    enrolled_in_es boolean DEFAULT false NOT NULL,
    enrolled_in_sh boolean DEFAULT false NOT NULL,
    enrolled_in_so boolean DEFAULT false NOT NULL,
    days_literally_homeless_in_last_three_years integer DEFAULT 0,
    requires_wheelchair_accessibility boolean DEFAULT false,
    required_number_of_bedrooms integer DEFAULT 1,
    required_minimum_occupancy integer DEFAULT 1,
    requires_elevator_access boolean DEFAULT false,
    neighborhood_interests jsonb DEFAULT '[]'::jsonb NOT NULL,
    date_days_homeless_verified date,
    who_verified_days_homeless character varying,
    tie_breaker double precision,
    interested_in_set_asides boolean DEFAULT false,
    tags jsonb,
    case_manager_contact_info character varying,
    vash_eligible boolean,
    pregnancy_status boolean DEFAULT false,
    income_maximization_assistance_requested boolean DEFAULT false,
    pending_subsidized_housing_placement boolean DEFAULT false,
    rrh_th_desired boolean DEFAULT false,
    sro_ok boolean DEFAULT false,
    evicted boolean DEFAULT false,
    dv_rrh_desired boolean DEFAULT false,
    health_prioritized boolean DEFAULT false,
    is_currently_youth boolean DEFAULT false NOT NULL,
    older_than_65 boolean,
    holds_voucher_on date,
    holds_internal_cas_voucher boolean,
    assessment_name character varying,
    entry_date date,
    financial_assistance_end_date date,
    enrolled_in_rrh boolean DEFAULT false,
    enrolled_in_psh boolean DEFAULT false,
    enrolled_in_ph boolean DEFAULT false,
    address character varying,
    majority_sheltered boolean,
    tie_breaker_date date,
    strengths jsonb DEFAULT '[]'::jsonb,
    challenges jsonb DEFAULT '[]'::jsonb,
    foster_care boolean DEFAULT false,
    open_case boolean DEFAULT false,
    housing_for_formerly_homeless boolean DEFAULT false,
    drug_test boolean DEFAULT false,
    heavy_drug_use boolean DEFAULT false,
    sober boolean DEFAULT false,
    willing_case_management boolean DEFAULT false,
    employed_three_months boolean DEFAULT false,
    living_wage boolean DEFAULT false,
    send_emails boolean DEFAULT false,
    need_daily_assistance boolean DEFAULT false,
    full_time_employed boolean DEFAULT false,
    can_work_full_time boolean DEFAULT false,
    willing_to_work_full_time boolean DEFAULT false,
    rrh_successful_exit boolean DEFAULT false,
    th_desired boolean DEFAULT false,
    site_case_management_required boolean DEFAULT false,
    currently_fleeing boolean DEFAULT false,
    dv_date date,
    assessor_first_name character varying,
    assessor_last_name character varying,
    assessor_email character varying,
    assessor_phone character varying,
    hmis_days_homeless_all_time integer,
    hmis_days_homeless_last_three_years integer,
    match_group integer,
    encampment_decomissioned boolean DEFAULT false,
    pregnant_under_28_weeks boolean DEFAULT false,
    am_ind_ak_native boolean DEFAULT false,
    asian boolean DEFAULT false,
    black_af_american boolean DEFAULT false,
    native_hi_pacific boolean DEFAULT false,
    white boolean DEFAULT false,
    female boolean DEFAULT false,
    male boolean DEFAULT false,
    no_single_gender boolean DEFAULT false,
    transgender boolean DEFAULT false,
    questioning boolean DEFAULT false,
    ongoing_case_management_required boolean DEFAULT false,
    file_tags jsonb DEFAULT '{}'::jsonb,
    housing_barrier boolean DEFAULT false,
    service_need boolean DEFAULT false,
    additional_homeless_nights_sheltered integer DEFAULT 0,
    additional_homeless_nights_unsheltered integer DEFAULT 0,
    total_homeless_nights_unsheltered integer DEFAULT 0,
    calculated_homeless_nights_sheltered integer DEFAULT 0,
    calculated_homeless_nights_unsheltered integer DEFAULT 0,
    total_homeless_nights_sheltered integer DEFAULT 0,
    enrolled_in_ph_pre_move_in boolean DEFAULT false NOT NULL,
    enrolled_in_psh_pre_move_in boolean DEFAULT false NOT NULL,
    enrolled_in_rrh_pre_move_in boolean DEFAULT false NOT NULL,
    ongoing_es_enrollments jsonb,
    ongoing_so_enrollments jsonb,
    last_seen_projects jsonb,
    federal_benefits boolean
);


--
-- Name: clients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.clients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.clients_id_seq OWNED BY public.clients.id;


--
-- Name: configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.configs (
    id integer NOT NULL,
    dnd_interval integer NOT NULL,
    warehouse_url character varying NOT NULL,
    require_cori_release boolean DEFAULT true,
    ami integer DEFAULT 66600 NOT NULL,
    vispdat_prioritization_scheme character varying DEFAULT 'length_of_time'::character varying,
    non_hmis_fields text,
    unavailable_for_length integer DEFAULT 0,
    deidentified_client_assessment character varying DEFAULT 'DeidentifiedClientAssessment'::character varying,
    identified_client_assessment character varying DEFAULT 'IdentifiedClientAssessment'::character varying,
    lock_days integer DEFAULT 0 NOT NULL,
    lock_grace_days integer DEFAULT 0 NOT NULL,
    limit_client_names_on_matches boolean DEFAULT true,
    include_note_in_email_default boolean,
    notify_all_on_progress_update boolean DEFAULT false,
    send_match_summary_email_on integer
);


--
-- Name: configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.configs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.configs_id_seq OWNED BY public.configs.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contacts (
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

CREATE SEQUENCE public.contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: data_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_sources (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    db_identifier character varying,
    client_url character varying
);


--
-- Name: data_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.data_sources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: data_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.data_sources_id_seq OWNED BY public.data_sources.id;


--
-- Name: date_of_birth_quality_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.date_of_birth_quality_codes (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: date_of_birth_quality_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.date_of_birth_quality_codes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: date_of_birth_quality_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.date_of_birth_quality_codes_id_seq OWNED BY public.date_of_birth_quality_codes.id;


--
-- Name: deidentified_clients_xlsxes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deidentified_clients_xlsxes (
    id integer NOT NULL,
    filename character varying,
    user_id integer,
    content_type character varying,
    content bytea,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    file text
);


--
-- Name: deidentified_clients_xlsxes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deidentified_clients_xlsxes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deidentified_clients_xlsxes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deidentified_clients_xlsxes_id_seq OWNED BY public.deidentified_clients_xlsxes.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
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

CREATE SEQUENCE public.delayed_jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


--
-- Name: disabling_conditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disabling_conditions (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: disabling_conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.disabling_conditions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disabling_conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.disabling_conditions_id_seq OWNED BY public.disabling_conditions.id;


--
-- Name: discharge_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.discharge_statuses (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: discharge_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.discharge_statuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: discharge_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.discharge_statuses_id_seq OWNED BY public.discharge_statuses.id;


--
-- Name: domestic_violence_survivors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.domestic_violence_survivors (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: domestic_violence_survivors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.domestic_violence_survivors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: domestic_violence_survivors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.domestic_violence_survivors_id_seq OWNED BY public.domestic_violence_survivors.id;


--
-- Name: entity_view_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity_view_permissions (
    id integer NOT NULL,
    user_id integer,
    entity_id integer NOT NULL,
    entity_type character varying NOT NULL,
    editable boolean,
    deleted_at timestamp without time zone,
    agency_id bigint
);


--
-- Name: entity_view_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.entity_view_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entity_view_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.entity_view_permissions_id_seq OWNED BY public.entity_view_permissions.id;


--
-- Name: ethnicities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ethnicities (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ethnicities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ethnicities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ethnicities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ethnicities_id_seq OWNED BY public.ethnicities.id;


--
-- Name: external_referrals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_referrals (
    id bigint NOT NULL,
    client_id bigint NOT NULL,
    user_id bigint NOT NULL,
    referred_on date NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: external_referrals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.external_referrals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_referrals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.external_referrals_id_seq OWNED BY public.external_referrals.id;


--
-- Name: file_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_tags (
    id integer NOT NULL,
    sub_program_id integer NOT NULL,
    name character varying,
    tag_id integer
);


--
-- Name: file_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_tags_id_seq OWNED BY public.file_tags.id;


--
-- Name: funding_source_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.funding_source_services (
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

CREATE SEQUENCE public.funding_source_services_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: funding_source_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.funding_source_services_id_seq OWNED BY public.funding_source_services.id;


--
-- Name: funding_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.funding_sources (
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

CREATE SEQUENCE public.funding_sources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: funding_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.funding_sources_id_seq OWNED BY public.funding_sources.id;


--
-- Name: has_developmental_disabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.has_developmental_disabilities (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: has_developmental_disabilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.has_developmental_disabilities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: has_developmental_disabilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.has_developmental_disabilities_id_seq OWNED BY public.has_developmental_disabilities.id;


--
-- Name: has_hivaids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.has_hivaids (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: has_hivaids_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.has_hivaids_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: has_hivaids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.has_hivaids_id_seq OWNED BY public.has_hivaids.id;


--
-- Name: has_mental_health_problems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.has_mental_health_problems (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: has_mental_health_problems_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.has_mental_health_problems_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: has_mental_health_problems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.has_mental_health_problems_id_seq OWNED BY public.has_mental_health_problems.id;


--
-- Name: helps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.helps (
    id bigint NOT NULL,
    controller_path character varying NOT NULL,
    action_name character varying NOT NULL,
    external_url character varying,
    title character varying NOT NULL,
    content text NOT NULL,
    location character varying DEFAULT 'internal'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: helps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.helps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: helps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.helps_id_seq OWNED BY public.helps.id;


--
-- Name: housing_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.housing_attributes (
    id bigint NOT NULL,
    housingable_type character varying,
    housingable_id bigint,
    name character varying,
    value character varying,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: housing_attributes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.housing_attributes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: housing_attributes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.housing_attributes_id_seq OWNED BY public.housing_attributes.id;


--
-- Name: housing_media_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.housing_media_links (
    id bigint NOT NULL,
    housingable_type character varying,
    housingable_id bigint,
    label character varying,
    url character varying,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: housing_media_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.housing_media_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: housing_media_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.housing_media_links_id_seq OWNED BY public.housing_media_links.id;


--
-- Name: imported_clients_csvs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.imported_clients_csvs (
    id integer NOT NULL,
    filename character varying,
    user_id integer,
    content_type character varying,
    content character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    file text
);


--
-- Name: imported_clients_csvs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.imported_clients_csvs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: imported_clients_csvs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.imported_clients_csvs_id_seq OWNED BY public.imported_clients_csvs.id;


--
-- Name: letsencrypt_plugin_challenges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.letsencrypt_plugin_challenges (
    id integer NOT NULL,
    response text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: letsencrypt_plugin_challenges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.letsencrypt_plugin_challenges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: letsencrypt_plugin_challenges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.letsencrypt_plugin_challenges_id_seq OWNED BY public.letsencrypt_plugin_challenges.id;


--
-- Name: letsencrypt_plugin_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.letsencrypt_plugin_settings (
    id integer NOT NULL,
    private_key text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: letsencrypt_plugin_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.letsencrypt_plugin_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: letsencrypt_plugin_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.letsencrypt_plugin_settings_id_seq OWNED BY public.letsencrypt_plugin_settings.id;


--
-- Name: login_activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.login_activities (
    id integer NOT NULL,
    scope character varying,
    strategy character varying,
    identity character varying,
    success boolean,
    failure_reason character varying,
    user_type character varying,
    user_id integer,
    context character varying,
    ip character varying,
    user_agent text,
    referrer text,
    city character varying,
    region character varying,
    country character varying,
    created_at timestamp without time zone
);


--
-- Name: login_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.login_activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: login_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.login_activities_id_seq OWNED BY public.login_activities.id;


--
-- Name: match_census; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.match_census (
    id integer NOT NULL,
    date date NOT NULL,
    opportunity_id integer NOT NULL,
    match_id integer,
    program_name character varying,
    sub_program_name character varying,
    prioritized_client_ids jsonb DEFAULT '[]'::jsonb NOT NULL,
    active_client_id integer,
    requirements jsonb DEFAULT '[]'::jsonb NOT NULL,
    match_prioritization_id integer,
    active_client_prioritization_value integer,
    prioritization_method_used character varying
);


--
-- Name: match_census_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.match_census_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_census_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.match_census_id_seq OWNED BY public.match_census.id;


--
-- Name: match_decision_reasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.match_decision_reasons (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    active boolean DEFAULT true NOT NULL,
    ineligible_in_warehouse boolean DEFAULT false NOT NULL,
    referral_result integer,
    limited boolean DEFAULT false,
    deleted_at timestamp(6) without time zone
);


--
-- Name: match_decision_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.match_decision_reasons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_decision_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.match_decision_reasons_id_seq OWNED BY public.match_decision_reasons.id;


--
-- Name: match_decisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.match_decisions (
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
    administrative_cancel_reason_id integer,
    administrative_cancel_reason_other_explanation character varying,
    disable_opportunity boolean DEFAULT false,
    application_date date,
    external_software_used boolean DEFAULT false NOT NULL,
    address character varying,
    include_note_in_email boolean,
    date_voucher_issued timestamp without time zone,
    manager character varying,
    criminal_hearing_outcome_recorded boolean
);


--
-- Name: match_decisions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.match_decisions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_decisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.match_decisions_id_seq OWNED BY public.match_decisions.id;


--
-- Name: match_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.match_events (
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
    admin_note boolean DEFAULT false NOT NULL,
    client_id integer
);


--
-- Name: match_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.match_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.match_events_id_seq OWNED BY public.match_events.id;


--
-- Name: match_mitigation_reasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.match_mitigation_reasons (
    id bigint NOT NULL,
    client_opportunity_match_id bigint,
    mitigation_reason_id bigint,
    addressed boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: match_mitigation_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.match_mitigation_reasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_mitigation_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.match_mitigation_reasons_id_seq OWNED BY public.match_mitigation_reasons.id;


--
-- Name: match_prioritizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.match_prioritizations (
    id integer NOT NULL,
    type character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    weight integer DEFAULT 10 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: match_prioritizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.match_prioritizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_prioritizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.match_prioritizations_id_seq OWNED BY public.match_prioritizations.id;


--
-- Name: match_progress_updates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.match_progress_updates (
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

CREATE SEQUENCE public.match_progress_updates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_progress_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.match_progress_updates_id_seq OWNED BY public.match_progress_updates.id;


--
-- Name: match_routes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.match_routes (
    id integer NOT NULL,
    type character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    weight integer DEFAULT 10 NOT NULL,
    contacts_editable_by_hsa boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    stalled_interval integer DEFAULT 7 NOT NULL,
    match_prioritization_id integer DEFAULT 6 NOT NULL,
    should_cancel_other_matches boolean DEFAULT true NOT NULL,
    should_activate_match boolean DEFAULT true NOT NULL,
    should_prevent_multiple_matches_per_client boolean DEFAULT true NOT NULL,
    allow_multiple_active_matches boolean DEFAULT false NOT NULL,
    default_shelter_agency_contacts_from_project_client boolean DEFAULT false NOT NULL,
    tag_id integer,
    show_default_contact_types boolean DEFAULT true,
    send_notifications boolean DEFAULT true,
    housing_type character varying,
    send_notes_by_default boolean DEFAULT false NOT NULL,
    expects_roi boolean DEFAULT true,
    prioritized_client_columns text,
    show_referral_source boolean DEFAULT false,
    show_move_in_date boolean DEFAULT false,
    show_address_field boolean DEFAULT false,
    routes_parked_on_active_match text,
    routes_parked_on_successful_match text
);


--
-- Name: match_routes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.match_routes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_routes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.match_routes_id_seq OWNED BY public.match_routes.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
    id integer NOT NULL,
    "from" character varying NOT NULL,
    subject character varying NOT NULL,
    body text NOT NULL,
    html boolean DEFAULT false NOT NULL,
    seen_at timestamp without time zone,
    sent_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    contact_id integer NOT NULL
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: mitigation_reasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mitigation_reasons (
    id bigint NOT NULL,
    name character varying,
    active boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mitigation_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mitigation_reasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mitigation_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mitigation_reasons_id_seq OWNED BY public.mitigation_reasons.id;


--
-- Name: name_quality_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.name_quality_codes (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: name_quality_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.name_quality_codes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: name_quality_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.name_quality_codes_id_seq OWNED BY public.name_quality_codes.id;


--
-- Name: neighborhood_interests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.neighborhood_interests (
    id integer NOT NULL,
    client_id integer,
    neighborhood_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: neighborhood_interests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.neighborhood_interests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: neighborhood_interests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.neighborhood_interests_id_seq OWNED BY public.neighborhood_interests.id;


--
-- Name: neighborhoods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.neighborhoods (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: neighborhoods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.neighborhoods_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: neighborhoods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.neighborhoods_id_seq OWNED BY public.neighborhoods.id;


--
-- Name: non_hmis_assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.non_hmis_assessments (
    id integer NOT NULL,
    non_hmis_client_id integer,
    type character varying,
    assessment_score integer,
    days_homeless_in_the_last_three_years integer,
    veteran boolean DEFAULT false,
    rrh_desired boolean DEFAULT false,
    youth_rrh_desired boolean DEFAULT false NOT NULL,
    rrh_assessment_contact_info text,
    income_maximization_assistance_requested boolean DEFAULT false NOT NULL,
    pending_subsidized_housing_placement boolean DEFAULT false,
    requires_wheelchair_accessibility boolean DEFAULT false NOT NULL,
    required_number_of_bedrooms integer,
    required_minimum_occupancy integer,
    requires_elevator_access boolean DEFAULT false NOT NULL,
    family_member boolean DEFAULT false NOT NULL,
    calculated_chronic_homelessness integer,
    neighborhood_interests json DEFAULT '[]'::json,
    income_total_monthly double precision,
    disabling_condition boolean DEFAULT false NOT NULL,
    physical_disability boolean DEFAULT false NOT NULL,
    developmental_disability boolean DEFAULT false NOT NULL,
    date_days_homeless_verified date,
    who_verified_days_homeless character varying,
    domestic_violence boolean DEFAULT false,
    interested_in_set_asides boolean DEFAULT false NOT NULL,
    set_asides_housing_status character varying,
    set_asides_resident boolean,
    shelter_name character varying,
    entry_date date,
    case_manager_contact_info character varying,
    phone_number character varying,
    have_tenant_voucher boolean,
    children_info character varying,
    studio_ok boolean,
    one_br_ok boolean,
    sro_ok boolean,
    fifty_five_plus boolean,
    sixty_two_plus boolean,
    voucher_agency character varying,
    interested_in_disabled_housing boolean,
    chronic_health_condition boolean,
    mental_health_problem boolean,
    substance_abuse_problem boolean,
    vispdat_score integer,
    vispdat_priority_score integer,
    imported_timestamp timestamp without time zone,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ssvf_eligible boolean DEFAULT false,
    veteran_rrh_desired boolean DEFAULT false,
    rrh_th_desired boolean DEFAULT false,
    dv_rrh_desired boolean DEFAULT false,
    income_total_annual integer DEFAULT 0,
    other_accessibility boolean DEFAULT false,
    disabled_housing boolean DEFAULT false,
    actively_homeless boolean DEFAULT false NOT NULL,
    user_id integer,
    evicted boolean DEFAULT false,
    documented_disability boolean DEFAULT false,
    health_prioritized boolean DEFAULT false,
    hiv_aids boolean DEFAULT false,
    is_currently_youth boolean DEFAULT false NOT NULL,
    older_than_65 boolean,
    email_addresses character varying,
    mailing_address character varying,
    day_locations text,
    night_locations text,
    other_contact text,
    household_size integer,
    hoh_age character varying,
    current_living_situation character varying,
    pending_housing_placement_type character varying,
    pending_housing_placement_type_other character varying,
    maximum_possible_monthly_rent integer,
    possible_housing_situation character varying,
    possible_housing_situation_other character varying,
    no_rrh_desired_reason character varying,
    no_rrh_desired_reason_other character varying,
    provider_agency_preference jsonb,
    accessibility_other character varying,
    hiv_housing character varying,
    affordable_housing jsonb,
    high_covid_risk jsonb,
    service_need_indicators jsonb,
    medical_care_last_six_months integer,
    intensive_needs jsonb,
    intensive_needs_other character varying,
    background_check_issues jsonb,
    additional_homeless_nights integer,
    homeless_night_range character varying,
    notes text,
    veteran_status character varying,
    agency_id bigint,
    assessment_type character varying,
    household_members jsonb,
    financial_assistance_end_date date,
    wait_times_ack boolean DEFAULT false NOT NULL,
    not_matched_ack boolean DEFAULT false NOT NULL,
    matched_process_ack boolean DEFAULT false NOT NULL,
    response_time_ack boolean DEFAULT false NOT NULL,
    automatic_approval_ack boolean DEFAULT false NOT NULL,
    times_moved character varying,
    health_severity character varying,
    ever_experienced_dv character varying,
    eviction_risk character varying,
    need_daily_assistance character varying,
    any_income character varying,
    income_source character varying,
    positive_relationship character varying,
    legal_concerns character varying,
    healthcare_coverage character varying,
    childcare character varying,
    setting character varying,
    outreach_name character varying,
    denial_required character varying,
    locked_until date,
    assessment_name character varying,
    hud_assessment_location integer,
    hud_assessment_type integer,
    staff_name character varying,
    staff_email character varying,
    enrolled_in_es boolean DEFAULT false NOT NULL,
    enrolled_in_so boolean DEFAULT false NOT NULL,
    additional_homeless_nights_sheltered integer DEFAULT 0,
    homeless_nights_sheltered integer DEFAULT 0,
    additional_homeless_nights_unsheltered integer DEFAULT 0,
    homeless_nights_unsheltered integer DEFAULT 0,
    tc_hat_assessment_level integer,
    tc_hat_household_type character varying,
    ongoing_support_reason text,
    ongoing_support_housing_type character varying,
    strengths jsonb,
    challenges jsonb,
    lifetime_sex_offender boolean DEFAULT false,
    state_id boolean DEFAULT false,
    birth_certificate boolean DEFAULT false,
    social_security_card boolean DEFAULT false,
    has_tax_id boolean DEFAULT false,
    tax_id character varying,
    roommate_ok boolean DEFAULT false,
    full_time_employed boolean DEFAULT false,
    can_work_full_time boolean DEFAULT false,
    willing_to_work_full_time boolean DEFAULT false,
    why_not_working character varying,
    rrh_successful_exit boolean DEFAULT false,
    th_desired boolean DEFAULT false,
    drug_test boolean DEFAULT false,
    heavy_drug_use boolean DEFAULT false,
    sober boolean DEFAULT false,
    willing_case_management boolean DEFAULT false,
    employed_three_months boolean DEFAULT false,
    living_wage boolean DEFAULT false,
    site_case_management_required boolean DEFAULT false,
    tc_hat_client_history jsonb,
    open_case boolean DEFAULT false,
    foster_care boolean DEFAULT false,
    currently_fleeing boolean DEFAULT false,
    dv_date date,
    tc_hat_ed_visits boolean DEFAULT false,
    tc_hat_hospitalizations boolean DEFAULT false,
    sixty_plus boolean DEFAULT false,
    cirrhosis boolean DEFAULT false,
    end_stage_renal_disease boolean DEFAULT false,
    heat_stroke boolean DEFAULT false,
    blind boolean DEFAULT false,
    tri_morbidity boolean DEFAULT false,
    high_potential_for_victimization boolean DEFAULT false,
    self_harm boolean DEFAULT false,
    medical_condition boolean DEFAULT false,
    psychiatric_condition boolean DEFAULT false,
    housing_preferences jsonb,
    housing_preferences_other character varying,
    housing_rejected_preferences jsonb,
    tc_hat_apartment integer,
    tc_hat_tiny_home integer,
    tc_hat_rv integer,
    tc_hat_house integer,
    tc_hat_mobile_home integer,
    tc_hat_total_housing_rank integer,
    days_homeless integer,
    pregnancy_status boolean DEFAULT false,
    jail_caused_episode boolean DEFAULT false,
    income_caused_episode boolean DEFAULT false,
    ipv_caused_episode boolean DEFAULT false,
    violence_caused_episode boolean DEFAULT false,
    chronic_health_caused_episode boolean DEFAULT false,
    acute_health_caused_episode boolean DEFAULT false,
    idd_caused_episode boolean DEFAULT false,
    pregnant boolean DEFAULT false,
    pregnant_under_28_weeks boolean DEFAULT false,
    ongoing_case_management_required boolean DEFAULT false,
    self_reported_days_verified boolean DEFAULT false,
    tc_hat_single_parent_child_over_ten boolean DEFAULT false,
    tc_hat_legal_custody boolean,
    tc_hat_will_gain_legal_custody boolean,
    housing_barrier boolean DEFAULT false,
    service_need boolean DEFAULT false,
    agency_name text,
    agency_day_contact_info text,
    agency_night_contact_info text,
    pregnant_or_parent boolean,
    partner_warehouse_id text,
    partner_name text,
    share_information_permission boolean,
    federal_benefits boolean
);


--
-- Name: non_hmis_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.non_hmis_assessments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: non_hmis_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.non_hmis_assessments_id_seq OWNED BY public.non_hmis_assessments.id;


--
-- Name: non_hmis_clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.non_hmis_clients (
    id integer NOT NULL,
    client_identifier character varying,
    assessment_score integer,
    deprecated_agency character varying,
    first_name character varying,
    last_name character varying,
    active_cohort_ids jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    identified boolean,
    date_of_birth date,
    ssn character varying,
    days_homeless_in_the_last_three_years integer,
    veteran boolean DEFAULT false NOT NULL,
    rrh_desired boolean DEFAULT false NOT NULL,
    youth_rrh_desired boolean DEFAULT false NOT NULL,
    rrh_assessment_contact_info text,
    income_maximization_assistance_requested boolean DEFAULT false NOT NULL,
    pending_subsidized_housing_placement boolean DEFAULT false NOT NULL,
    full_release_on_file boolean DEFAULT false NOT NULL,
    requires_wheelchair_accessibility boolean DEFAULT false NOT NULL,
    required_number_of_bedrooms integer DEFAULT 1,
    required_minimum_occupancy integer DEFAULT 1,
    requires_elevator_access boolean DEFAULT false NOT NULL,
    family_member boolean DEFAULT false NOT NULL,
    middle_name character varying,
    calculated_chronic_homelessness integer,
    type character varying,
    available boolean DEFAULT true NOT NULL,
    neighborhood_interests json DEFAULT '[]'::json,
    income_total_monthly double precision,
    disabling_condition boolean DEFAULT false,
    physical_disability boolean DEFAULT false,
    developmental_disability boolean DEFAULT false,
    date_days_homeless_verified date,
    who_verified_days_homeless character varying,
    domestic_violence boolean DEFAULT false NOT NULL,
    interested_in_set_asides boolean DEFAULT false,
    tags jsonb,
    imported_timestamp timestamp without time zone,
    set_asides_housing_status character varying,
    set_asides_resident boolean,
    shelter_name character varying,
    entry_date date,
    case_manager_contact_info character varying,
    phone_number character varying,
    email character varying,
    have_tenant_voucher boolean,
    children_info character varying,
    studio_ok boolean,
    one_br_ok boolean,
    sro_ok boolean,
    fifty_five_plus boolean,
    sixty_two_plus boolean,
    warehouse_client_id integer,
    voucher_agency character varying,
    interested_in_disabled_housing boolean,
    chronic_health_condition boolean,
    mental_health_problem boolean,
    substance_abuse_problem boolean,
    agency_id integer,
    contact_id integer,
    vispdat_score integer DEFAULT 0,
    vispdat_priority_score integer DEFAULT 0,
    actively_homeless boolean DEFAULT false NOT NULL,
    limited_release_on_file boolean DEFAULT false NOT NULL,
    active_client boolean DEFAULT true NOT NULL,
    eligible_for_matching boolean DEFAULT true NOT NULL,
    available_date timestamp without time zone,
    available_reason character varying,
    is_currently_youth boolean DEFAULT false NOT NULL,
    assessed_at timestamp without time zone,
    health_prioritized boolean DEFAULT false,
    hiv_aids boolean DEFAULT false,
    older_than_65 boolean,
    ssn_refused boolean DEFAULT false,
    ethnicity integer,
    days_homeless integer,
    sixty_plus boolean,
    pregnancy_status boolean DEFAULT false,
    pregnant_under_28_weeks boolean DEFAULT false,
    am_ind_ak_native boolean DEFAULT false,
    asian boolean DEFAULT false,
    black_af_american boolean DEFAULT false,
    native_hi_pacific boolean DEFAULT false,
    white boolean DEFAULT false,
    female boolean DEFAULT false,
    male boolean DEFAULT false,
    no_single_gender boolean DEFAULT false,
    transgender boolean DEFAULT false,
    questioning boolean DEFAULT false,
    federal_benefits boolean
);


--
-- Name: non_hmis_clients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.non_hmis_clients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: non_hmis_clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.non_hmis_clients_id_seq OWNED BY public.non_hmis_clients.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    type character varying,
    code character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    client_opportunity_match_id integer,
    recipient_id integer,
    expires_at timestamp without time zone,
    include_content boolean DEFAULT true
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: opportunities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.opportunities (
    id integer NOT NULL,
    name character varying,
    available boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    unit_id integer,
    available_candidate boolean DEFAULT true,
    voucher_id integer,
    matchability double precision,
    success boolean DEFAULT false
);


--
-- Name: opportunities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.opportunities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: opportunities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.opportunities_id_seq OWNED BY public.opportunities.id;


--
-- Name: opportunity_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.opportunity_contacts (
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

CREATE SEQUENCE public.opportunity_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: opportunity_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.opportunity_contacts_id_seq OWNED BY public.opportunity_contacts.id;


--
-- Name: opportunity_properties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.opportunity_properties (
    id integer NOT NULL,
    opportunity_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: opportunity_properties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.opportunity_properties_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: opportunity_properties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.opportunity_properties_id_seq OWNED BY public.opportunity_properties.id;


--
-- Name: outreach_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outreach_histories (
    id bigint NOT NULL,
    non_hmis_client_id bigint NOT NULL,
    user_id bigint NOT NULL,
    outreach_name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: outreach_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.outreach_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outreach_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.outreach_histories_id_seq OWNED BY public.outreach_histories.id;


--
-- Name: physical_disabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.physical_disabilities (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: physical_disabilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.physical_disabilities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: physical_disabilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.physical_disabilities_id_seq OWNED BY public.physical_disabilities.id;


--
-- Name: program_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.program_contacts (
    id integer NOT NULL,
    program_id integer NOT NULL,
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
    hsp boolean DEFAULT false NOT NULL,
    "do" boolean DEFAULT false NOT NULL
);


--
-- Name: program_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.program_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: program_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.program_contacts_id_seq OWNED BY public.program_contacts.id;


--
-- Name: program_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.program_services (
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

CREATE SEQUENCE public.program_services_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: program_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.program_services_id_seq OWNED BY public.program_services.id;


--
-- Name: programs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.programs (
    id integer NOT NULL,
    name character varying,
    contract_start_date character varying,
    funding_source_id integer,
    subgrantee_id integer,
    contact_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    confidential boolean DEFAULT false NOT NULL,
    match_route_id integer DEFAULT 1,
    description text
);


--
-- Name: programs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.programs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: programs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.programs_id_seq OWNED BY public.programs.id;


--
-- Name: project_clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_clients (
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
    vispdat_length_homeless_in_days integer DEFAULT 0 NOT NULL,
    cspech_eligible boolean DEFAULT false,
    alternate_names character varying,
    congregate_housing boolean DEFAULT false,
    sober_housing boolean DEFAULT false,
    enrolled_project_ids jsonb,
    active_cohort_ids jsonb,
    vispdat_priority_score integer DEFAULT 0,
    client_identifier character varying,
    assessment_score integer DEFAULT 0 NOT NULL,
    ssvf_eligible boolean DEFAULT false NOT NULL,
    rrh_desired boolean DEFAULT false NOT NULL,
    youth_rrh_desired boolean DEFAULT false NOT NULL,
    rrh_assessment_contact_info character varying,
    rrh_assessment_collected_at timestamp without time zone,
    enrolled_in_th boolean DEFAULT false NOT NULL,
    enrolled_in_es boolean DEFAULT false NOT NULL,
    enrolled_in_sh boolean DEFAULT false NOT NULL,
    enrolled_in_so boolean DEFAULT false NOT NULL,
    days_literally_homeless_in_last_three_years integer DEFAULT 0,
    requires_wheelchair_accessibility boolean DEFAULT false,
    required_number_of_bedrooms integer DEFAULT 1,
    required_minimum_occupancy integer DEFAULT 1,
    requires_elevator_access boolean DEFAULT false,
    neighborhood_interests jsonb DEFAULT '[]'::jsonb NOT NULL,
    date_days_homeless_verified date,
    who_verified_days_homeless character varying,
    interested_in_set_asides boolean DEFAULT false,
    default_shelter_agency_contacts jsonb,
    tags jsonb,
    case_manager_contact_info character varying,
    non_hmis_client_identifier character varying,
    vash_eligible boolean,
    pregnancy_status boolean DEFAULT false,
    income_maximization_assistance_requested boolean DEFAULT false,
    pending_subsidized_housing_placement boolean DEFAULT false,
    rrh_th_desired boolean DEFAULT false,
    sro_ok boolean DEFAULT false,
    evicted boolean DEFAULT false,
    dv_rrh_desired boolean DEFAULT false,
    health_prioritized boolean DEFAULT false,
    is_currently_youth boolean DEFAULT false NOT NULL,
    older_than_65 boolean,
    holds_voucher_on date,
    assessment_name character varying,
    financial_assistance_end_date date,
    enrolled_in_rrh boolean DEFAULT false,
    enrolled_in_psh boolean DEFAULT false,
    enrolled_in_ph boolean DEFAULT false,
    address character varying,
    majority_sheltered boolean,
    tie_breaker_date date,
    strengths jsonb DEFAULT '[]'::jsonb,
    challenges jsonb DEFAULT '[]'::jsonb,
    foster_care boolean DEFAULT false,
    open_case boolean DEFAULT false,
    housing_for_formerly_homeless boolean DEFAULT false,
    drug_test boolean DEFAULT false,
    heavy_drug_use boolean DEFAULT false,
    sober boolean DEFAULT false,
    willing_case_management boolean DEFAULT false,
    employed_three_months boolean DEFAULT false,
    living_wage boolean DEFAULT false,
    need_daily_assistance boolean DEFAULT false,
    full_time_employed boolean DEFAULT false,
    can_work_full_time boolean DEFAULT false,
    willing_to_work_full_time boolean DEFAULT false,
    rrh_successful_exit boolean DEFAULT false,
    th_desired boolean DEFAULT false,
    site_case_management_required boolean DEFAULT false,
    currently_fleeing boolean DEFAULT false,
    dv_date date,
    assessor_first_name character varying,
    assessor_last_name character varying,
    assessor_email character varying,
    assessor_phone character varying,
    hmis_days_homeless_all_time integer,
    hmis_days_homeless_last_three_years integer,
    match_group integer,
    force_remove_unavailable_fors boolean DEFAULT false,
    encampment_decomissioned boolean DEFAULT false,
    pregnant_under_28_weeks boolean DEFAULT false,
    am_ind_ak_native boolean DEFAULT false,
    asian boolean DEFAULT false,
    black_af_american boolean DEFAULT false,
    native_hi_pacific boolean DEFAULT false,
    white boolean DEFAULT false,
    female boolean DEFAULT false,
    male boolean DEFAULT false,
    no_single_gender boolean DEFAULT false,
    transgender boolean DEFAULT false,
    questioning boolean DEFAULT false,
    ongoing_case_management_required boolean DEFAULT false,
    file_tags jsonb DEFAULT '{}'::jsonb,
    housing_barrier boolean DEFAULT false,
    service_need boolean DEFAULT false,
    additional_homeless_nights_sheltered integer DEFAULT 0,
    additional_homeless_nights_unsheltered integer DEFAULT 0,
    total_homeless_nights_unsheltered integer DEFAULT 0,
    calculated_homeless_nights_sheltered integer DEFAULT 0,
    calculated_homeless_nights_unsheltered integer DEFAULT 0,
    total_homeless_nights_sheltered integer DEFAULT 0,
    enrolled_in_ph_pre_move_in boolean DEFAULT false NOT NULL,
    enrolled_in_psh_pre_move_in boolean DEFAULT false NOT NULL,
    enrolled_in_rrh_pre_move_in boolean DEFAULT false NOT NULL,
    ongoing_es_enrollments jsonb,
    ongoing_so_enrollments jsonb,
    last_seen_projects jsonb,
    federal_benefits boolean
);


--
-- Name: project_clients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_clients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_clients_id_seq OWNED BY public.project_clients.id;


--
-- Name: project_programs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_programs (
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

CREATE SEQUENCE public.project_programs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_programs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_programs_id_seq OWNED BY public.project_programs.id;


--
-- Name: reissue_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reissue_requests (
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

CREATE SEQUENCE public.reissue_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reissue_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reissue_requests_id_seq OWNED BY public.reissue_requests.id;


--
-- Name: rejected_matches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rejected_matches (
    id integer NOT NULL,
    client_id integer NOT NULL,
    opportunity_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: rejected_matches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rejected_matches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rejected_matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rejected_matches_id_seq OWNED BY public.rejected_matches.id;


--
-- Name: report_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_definitions (
    id bigint NOT NULL,
    report_group character varying,
    url character varying,
    name character varying NOT NULL,
    description character varying,
    weight integer DEFAULT 0 NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    limitable boolean DEFAULT true
);


--
-- Name: report_definitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.report_definitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: report_definitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.report_definitions_id_seq OWNED BY public.report_definitions.id;


--
-- Name: reporting_decisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reporting_decisions (
    id bigint NOT NULL,
    client_id integer,
    match_id integer NOT NULL,
    decision_id integer NOT NULL,
    decision_order integer NOT NULL,
    match_step character varying NOT NULL,
    decision_status character varying NOT NULL,
    current_step boolean DEFAULT false NOT NULL,
    active_match boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    elapsed_days integer NOT NULL,
    client_last_seen_date timestamp without time zone,
    criminal_hearing_date timestamp without time zone,
    decline_reason character varying,
    not_working_with_client_reason character varying,
    administrative_cancel_reason character varying,
    client_spoken_with_services_agency boolean,
    cori_release_form_submitted boolean,
    match_started_at timestamp without time zone,
    program_type character varying,
    shelter_agency_contacts json,
    hsa_contacts json,
    ssp_contacts json,
    admin_contacts json,
    client_contacts json,
    hsp_contacts json,
    program_name character varying NOT NULL,
    sub_program_name character varying NOT NULL,
    terminal_status character varying,
    match_route character varying NOT NULL,
    cas_client_id integer NOT NULL,
    client_move_in_date date,
    source_data_source character varying,
    event_contact character varying,
    event_contact_agency character varying,
    vacancy_id integer NOT NULL,
    housing_type character varying,
    ineligible_in_warehouse boolean DEFAULT false NOT NULL,
    actor_type character varying,
    confidential boolean DEFAULT false,
    current_status character varying,
    step_tag character varying
);


--
-- Name: reporting_decisions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reporting_decisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reporting_decisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reporting_decisions_id_seq OWNED BY public.reporting_decisions.id;


--
-- Name: requirements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.requirements (
    id integer NOT NULL,
    rule_id integer,
    requirer_id integer,
    requirer_type character varying,
    positive boolean,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    variable character varying
);


--
-- Name: requirements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.requirements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: requirements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.requirements_id_seq OWNED BY public.requirements.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    can_view_all_clients boolean DEFAULT false,
    can_edit_all_clients boolean DEFAULT false,
    can_participate_in_matches boolean DEFAULT false,
    can_view_all_matches boolean DEFAULT false,
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
    can_view_dmh_eligibility boolean DEFAULT false,
    can_view_va_eligibility boolean DEFAULT false NOT NULL,
    can_view_hues_eligibility boolean DEFAULT false NOT NULL,
    can_become_other_users boolean DEFAULT false,
    can_view_client_confidentiality boolean DEFAULT false NOT NULL,
    can_view_hiv_positive_eligibility boolean DEFAULT false,
    can_view_own_closed_matches boolean DEFAULT false,
    can_edit_translations boolean DEFAULT false,
    can_view_vspdats boolean DEFAULT false,
    can_manage_config boolean DEFAULT false,
    can_create_overall_note boolean DEFAULT false,
    can_enter_deidentified_clients boolean DEFAULT false,
    can_manage_deidentified_clients boolean DEFAULT false,
    can_add_cohorts_to_deidentified_clients boolean DEFAULT false,
    can_delete_client_notes boolean DEFAULT false,
    can_enter_identified_clients boolean DEFAULT false,
    can_manage_identified_clients boolean DEFAULT false,
    can_add_cohorts_to_identified_clients boolean DEFAULT false,
    can_manage_neighborhoods boolean DEFAULT false,
    can_view_assigned_programs boolean DEFAULT false,
    can_edit_assigned_programs boolean DEFAULT false,
    can_export_deidentified_clients boolean DEFAULT false,
    can_export_identified_clients boolean DEFAULT false,
    can_manage_tags boolean DEFAULT false,
    can_manage_imported_clients boolean DEFAULT false,
    can_edit_clients_based_on_rules boolean DEFAULT false,
    can_send_notes_via_email boolean DEFAULT false,
    can_upload_deidentified_clients boolean DEFAULT false,
    can_delete_matches boolean DEFAULT false,
    can_reopen_matches boolean DEFAULT false,
    can_see_all_alternate_matches boolean DEFAULT false,
    can_edit_help boolean DEFAULT false,
    can_audit_users boolean DEFAULT false,
    can_view_all_covid_pathways boolean DEFAULT false,
    can_manage_sessions boolean DEFAULT false,
    can_edit_voucher_rules boolean DEFAULT false,
    can_manage_all_deidentified_clients boolean DEFAULT false,
    can_manage_all_identified_clients boolean DEFAULT false
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rules (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    type character varying,
    verb character varying,
    alternate_name character varying
);


--
-- Name: rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rules_id_seq OWNED BY public.rules.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: service_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.service_rules (
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

CREATE SEQUENCE public.service_rules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: service_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.service_rules_id_seq OWNED BY public.service_rules.id;


--
-- Name: services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.services (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.services_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.services_id_seq OWNED BY public.services.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id integer NOT NULL,
    session_id character varying NOT NULL,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: shelter_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shelter_histories (
    id bigint NOT NULL,
    non_hmis_client_id bigint NOT NULL,
    user_id bigint NOT NULL,
    shelter_name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: shelter_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shelter_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shelter_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shelter_histories_id_seq OWNED BY public.shelter_histories.id;


--
-- Name: social_security_number_quality_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.social_security_number_quality_codes (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: social_security_number_quality_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.social_security_number_quality_codes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: social_security_number_quality_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.social_security_number_quality_codes_id_seq OWNED BY public.social_security_number_quality_codes.id;


--
-- Name: stalled_responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stalled_responses (
    id integer NOT NULL,
    client_engaging boolean DEFAULT true NOT NULL,
    reason character varying NOT NULL,
    decision_type character varying NOT NULL,
    requires_note boolean DEFAULT false NOT NULL,
    active boolean DEFAULT true NOT NULL,
    weight integer DEFAULT 0 NOT NULL
);


--
-- Name: stalled_responses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stalled_responses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stalled_responses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stalled_responses_id_seq OWNED BY public.stalled_responses.id;


--
-- Name: sub_program_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sub_program_contacts (
    id bigint NOT NULL,
    sub_program_id bigint NOT NULL,
    contact_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    dnd_staff boolean DEFAULT false NOT NULL,
    housing_subsidy_admin boolean DEFAULT false NOT NULL,
    client boolean DEFAULT false NOT NULL,
    housing_search_worker boolean DEFAULT false NOT NULL,
    shelter_agency boolean DEFAULT false NOT NULL,
    ssp boolean DEFAULT false NOT NULL,
    hsp boolean DEFAULT false NOT NULL,
    "do" boolean DEFAULT false NOT NULL
);


--
-- Name: sub_program_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sub_program_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sub_program_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sub_program_contacts_id_seq OWNED BY public.sub_program_contacts.id;


--
-- Name: sub_programs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sub_programs (
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
    eligibility_requirement_notes text,
    closed boolean DEFAULT false,
    event integer,
    weighting_rules_active boolean DEFAULT true,
    cori_hearing_required boolean,
    match_prioritization_id bigint
);


--
-- Name: sub_programs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sub_programs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sub_programs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sub_programs_id_seq OWNED BY public.sub_programs.id;


--
-- Name: subgrantee_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subgrantee_contacts (
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

CREATE SEQUENCE public.subgrantee_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subgrantee_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subgrantee_contacts_id_seq OWNED BY public.subgrantee_contacts.id;


--
-- Name: subgrantee_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subgrantee_services (
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

CREATE SEQUENCE public.subgrantee_services_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subgrantee_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subgrantee_services_id_seq OWNED BY public.subgrantee_services.id;


--
-- Name: subgrantees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subgrantees (
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

CREATE SEQUENCE public.subgrantees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subgrantees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subgrantees_id_seq OWNED BY public.subgrantees.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    rrh_assessment_trigger boolean DEFAULT false NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: translation_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.translation_keys (
    id integer NOT NULL,
    key character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: translation_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.translation_keys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: translation_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.translation_keys_id_seq OWNED BY public.translation_keys.id;


--
-- Name: translation_texts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.translation_texts (
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

CREATE SEQUENCE public.translation_texts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: translation_texts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.translation_texts_id_seq OWNED BY public.translation_texts.id;


--
-- Name: translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.translations (
    id bigint NOT NULL,
    key character varying,
    text character varying,
    common boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.translations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.translations_id_seq OWNED BY public.translations.id;


--
-- Name: unavailable_as_candidate_fors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.unavailable_as_candidate_fors (
    id integer NOT NULL,
    client_id integer NOT NULL,
    match_route_type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone,
    user_id bigint,
    match_id bigint,
    reason character varying
);


--
-- Name: unavailable_as_candidate_fors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.unavailable_as_candidate_fors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: unavailable_as_candidate_fors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.unavailable_as_candidate_fors_id_seq OWNED BY public.unavailable_as_candidate_fors.id;


--
-- Name: units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.units (
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
    data_source_id_column_name character varying,
    elevator_accessible boolean DEFAULT false NOT NULL,
    active boolean DEFAULT true NOT NULL
);


--
-- Name: units_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.units_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.units_id_seq OWNED BY public.units.id;


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_roles (
    id integer NOT NULL,
    role_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_roles_id_seq OWNED BY public.user_roles.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
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
    last_name character varying,
    email_schedule character varying DEFAULT 'immediate'::character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    deprecated_agency character varying,
    agency_id integer,
    exclude_from_directory boolean DEFAULT false,
    exclude_phone_from_directory boolean DEFAULT false,
    unique_session_id character varying,
    receive_weekly_match_summary_email boolean DEFAULT true
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
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
    notification_code character varying,
    referenced_user_id integer,
    referenced_entity_name character varying
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: veteran_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.veteran_statuses (
    id integer NOT NULL,
    "numeric" integer,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: veteran_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.veteran_statuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: veteran_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.veteran_statuses_id_seq OWNED BY public.veteran_statuses.id;


--
-- Name: vouchers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vouchers (
    id integer NOT NULL,
    available boolean,
    date_available date,
    sub_program_id integer,
    unit_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    user_id integer,
    made_available_at timestamp without time zone,
    archived_at timestamp without time zone
);


--
-- Name: vouchers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vouchers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vouchers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vouchers_id_seq OWNED BY public.vouchers.id;


--
-- Name: weighting_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.weighting_rules (
    id bigint NOT NULL,
    route_id bigint,
    requirement_id bigint,
    applied_to integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: weighting_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.weighting_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: weighting_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.weighting_rules_id_seq OWNED BY public.weighting_rules.id;


--
-- Name: activity_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_logs ALTER COLUMN id SET DEFAULT nextval('public.activity_logs_id_seq'::regclass);


--
-- Name: agencies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agencies ALTER COLUMN id SET DEFAULT nextval('public.agencies_id_seq'::regclass);


--
-- Name: building_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_contacts ALTER COLUMN id SET DEFAULT nextval('public.building_contacts_id_seq'::regclass);


--
-- Name: building_services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_services ALTER COLUMN id SET DEFAULT nextval('public.building_services_id_seq'::regclass);


--
-- Name: buildings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings ALTER COLUMN id SET DEFAULT nextval('public.buildings_id_seq'::regclass);


--
-- Name: client_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_contacts ALTER COLUMN id SET DEFAULT nextval('public.client_contacts_id_seq'::regclass);


--
-- Name: client_notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_notes ALTER COLUMN id SET DEFAULT nextval('public.client_notes_id_seq'::regclass);


--
-- Name: client_opportunity_match_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_opportunity_match_contacts ALTER COLUMN id SET DEFAULT nextval('public.client_opportunity_match_contacts_id_seq'::regclass);


--
-- Name: client_opportunity_matches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_opportunity_matches ALTER COLUMN id SET DEFAULT nextval('public.client_opportunity_matches_id_seq'::regclass);


--
-- Name: clients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients ALTER COLUMN id SET DEFAULT nextval('public.clients_id_seq'::regclass);


--
-- Name: configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configs ALTER COLUMN id SET DEFAULT nextval('public.configs_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: data_sources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_sources ALTER COLUMN id SET DEFAULT nextval('public.data_sources_id_seq'::regclass);


--
-- Name: date_of_birth_quality_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_of_birth_quality_codes ALTER COLUMN id SET DEFAULT nextval('public.date_of_birth_quality_codes_id_seq'::regclass);


--
-- Name: deidentified_clients_xlsxes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deidentified_clients_xlsxes ALTER COLUMN id SET DEFAULT nextval('public.deidentified_clients_xlsxes_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


--
-- Name: disabling_conditions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disabling_conditions ALTER COLUMN id SET DEFAULT nextval('public.disabling_conditions_id_seq'::regclass);


--
-- Name: discharge_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discharge_statuses ALTER COLUMN id SET DEFAULT nextval('public.discharge_statuses_id_seq'::regclass);


--
-- Name: domestic_violence_survivors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.domestic_violence_survivors ALTER COLUMN id SET DEFAULT nextval('public.domestic_violence_survivors_id_seq'::regclass);


--
-- Name: entity_view_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_view_permissions ALTER COLUMN id SET DEFAULT nextval('public.entity_view_permissions_id_seq'::regclass);


--
-- Name: ethnicities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ethnicities ALTER COLUMN id SET DEFAULT nextval('public.ethnicities_id_seq'::regclass);


--
-- Name: external_referrals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_referrals ALTER COLUMN id SET DEFAULT nextval('public.external_referrals_id_seq'::regclass);


--
-- Name: file_tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_tags ALTER COLUMN id SET DEFAULT nextval('public.file_tags_id_seq'::regclass);


--
-- Name: funding_source_services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_source_services ALTER COLUMN id SET DEFAULT nextval('public.funding_source_services_id_seq'::regclass);


--
-- Name: funding_sources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_sources ALTER COLUMN id SET DEFAULT nextval('public.funding_sources_id_seq'::regclass);


--
-- Name: has_developmental_disabilities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.has_developmental_disabilities ALTER COLUMN id SET DEFAULT nextval('public.has_developmental_disabilities_id_seq'::regclass);


--
-- Name: has_hivaids id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.has_hivaids ALTER COLUMN id SET DEFAULT nextval('public.has_hivaids_id_seq'::regclass);


--
-- Name: has_mental_health_problems id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.has_mental_health_problems ALTER COLUMN id SET DEFAULT nextval('public.has_mental_health_problems_id_seq'::regclass);


--
-- Name: helps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.helps ALTER COLUMN id SET DEFAULT nextval('public.helps_id_seq'::regclass);


--
-- Name: housing_attributes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.housing_attributes ALTER COLUMN id SET DEFAULT nextval('public.housing_attributes_id_seq'::regclass);


--
-- Name: housing_media_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.housing_media_links ALTER COLUMN id SET DEFAULT nextval('public.housing_media_links_id_seq'::regclass);


--
-- Name: imported_clients_csvs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imported_clients_csvs ALTER COLUMN id SET DEFAULT nextval('public.imported_clients_csvs_id_seq'::regclass);


--
-- Name: letsencrypt_plugin_challenges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.letsencrypt_plugin_challenges ALTER COLUMN id SET DEFAULT nextval('public.letsencrypt_plugin_challenges_id_seq'::regclass);


--
-- Name: letsencrypt_plugin_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.letsencrypt_plugin_settings ALTER COLUMN id SET DEFAULT nextval('public.letsencrypt_plugin_settings_id_seq'::regclass);


--
-- Name: login_activities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_activities ALTER COLUMN id SET DEFAULT nextval('public.login_activities_id_seq'::regclass);


--
-- Name: match_census id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_census ALTER COLUMN id SET DEFAULT nextval('public.match_census_id_seq'::regclass);


--
-- Name: match_decision_reasons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_decision_reasons ALTER COLUMN id SET DEFAULT nextval('public.match_decision_reasons_id_seq'::regclass);


--
-- Name: match_decisions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_decisions ALTER COLUMN id SET DEFAULT nextval('public.match_decisions_id_seq'::regclass);


--
-- Name: match_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_events ALTER COLUMN id SET DEFAULT nextval('public.match_events_id_seq'::regclass);


--
-- Name: match_mitigation_reasons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_mitigation_reasons ALTER COLUMN id SET DEFAULT nextval('public.match_mitigation_reasons_id_seq'::regclass);


--
-- Name: match_prioritizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_prioritizations ALTER COLUMN id SET DEFAULT nextval('public.match_prioritizations_id_seq'::regclass);


--
-- Name: match_progress_updates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_progress_updates ALTER COLUMN id SET DEFAULT nextval('public.match_progress_updates_id_seq'::regclass);


--
-- Name: match_routes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_routes ALTER COLUMN id SET DEFAULT nextval('public.match_routes_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: mitigation_reasons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mitigation_reasons ALTER COLUMN id SET DEFAULT nextval('public.mitigation_reasons_id_seq'::regclass);


--
-- Name: name_quality_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.name_quality_codes ALTER COLUMN id SET DEFAULT nextval('public.name_quality_codes_id_seq'::regclass);


--
-- Name: neighborhood_interests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.neighborhood_interests ALTER COLUMN id SET DEFAULT nextval('public.neighborhood_interests_id_seq'::regclass);


--
-- Name: neighborhoods id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.neighborhoods ALTER COLUMN id SET DEFAULT nextval('public.neighborhoods_id_seq'::regclass);


--
-- Name: non_hmis_assessments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.non_hmis_assessments ALTER COLUMN id SET DEFAULT nextval('public.non_hmis_assessments_id_seq'::regclass);


--
-- Name: non_hmis_clients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.non_hmis_clients ALTER COLUMN id SET DEFAULT nextval('public.non_hmis_clients_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: opportunities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opportunities ALTER COLUMN id SET DEFAULT nextval('public.opportunities_id_seq'::regclass);


--
-- Name: opportunity_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opportunity_contacts ALTER COLUMN id SET DEFAULT nextval('public.opportunity_contacts_id_seq'::regclass);


--
-- Name: opportunity_properties id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opportunity_properties ALTER COLUMN id SET DEFAULT nextval('public.opportunity_properties_id_seq'::regclass);


--
-- Name: outreach_histories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outreach_histories ALTER COLUMN id SET DEFAULT nextval('public.outreach_histories_id_seq'::regclass);


--
-- Name: physical_disabilities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.physical_disabilities ALTER COLUMN id SET DEFAULT nextval('public.physical_disabilities_id_seq'::regclass);


--
-- Name: program_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.program_contacts ALTER COLUMN id SET DEFAULT nextval('public.program_contacts_id_seq'::regclass);


--
-- Name: program_services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.program_services ALTER COLUMN id SET DEFAULT nextval('public.program_services_id_seq'::regclass);


--
-- Name: programs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.programs ALTER COLUMN id SET DEFAULT nextval('public.programs_id_seq'::regclass);


--
-- Name: project_clients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_clients ALTER COLUMN id SET DEFAULT nextval('public.project_clients_id_seq'::regclass);


--
-- Name: project_programs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_programs ALTER COLUMN id SET DEFAULT nextval('public.project_programs_id_seq'::regclass);


--
-- Name: reissue_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reissue_requests ALTER COLUMN id SET DEFAULT nextval('public.reissue_requests_id_seq'::regclass);


--
-- Name: rejected_matches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rejected_matches ALTER COLUMN id SET DEFAULT nextval('public.rejected_matches_id_seq'::regclass);


--
-- Name: report_definitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_definitions ALTER COLUMN id SET DEFAULT nextval('public.report_definitions_id_seq'::regclass);


--
-- Name: reporting_decisions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reporting_decisions ALTER COLUMN id SET DEFAULT nextval('public.reporting_decisions_id_seq'::regclass);


--
-- Name: requirements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requirements ALTER COLUMN id SET DEFAULT nextval('public.requirements_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: rules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rules ALTER COLUMN id SET DEFAULT nextval('public.rules_id_seq'::regclass);


--
-- Name: service_rules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_rules ALTER COLUMN id SET DEFAULT nextval('public.service_rules_id_seq'::regclass);


--
-- Name: services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services ALTER COLUMN id SET DEFAULT nextval('public.services_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: shelter_histories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shelter_histories ALTER COLUMN id SET DEFAULT nextval('public.shelter_histories_id_seq'::regclass);


--
-- Name: social_security_number_quality_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.social_security_number_quality_codes ALTER COLUMN id SET DEFAULT nextval('public.social_security_number_quality_codes_id_seq'::regclass);


--
-- Name: stalled_responses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stalled_responses ALTER COLUMN id SET DEFAULT nextval('public.stalled_responses_id_seq'::regclass);


--
-- Name: sub_program_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_program_contacts ALTER COLUMN id SET DEFAULT nextval('public.sub_program_contacts_id_seq'::regclass);


--
-- Name: sub_programs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_programs ALTER COLUMN id SET DEFAULT nextval('public.sub_programs_id_seq'::regclass);


--
-- Name: subgrantee_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subgrantee_contacts ALTER COLUMN id SET DEFAULT nextval('public.subgrantee_contacts_id_seq'::regclass);


--
-- Name: subgrantee_services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subgrantee_services ALTER COLUMN id SET DEFAULT nextval('public.subgrantee_services_id_seq'::regclass);


--
-- Name: subgrantees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subgrantees ALTER COLUMN id SET DEFAULT nextval('public.subgrantees_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: translation_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.translation_keys ALTER COLUMN id SET DEFAULT nextval('public.translation_keys_id_seq'::regclass);


--
-- Name: translation_texts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.translation_texts ALTER COLUMN id SET DEFAULT nextval('public.translation_texts_id_seq'::regclass);


--
-- Name: translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.translations ALTER COLUMN id SET DEFAULT nextval('public.translations_id_seq'::regclass);


--
-- Name: unavailable_as_candidate_fors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unavailable_as_candidate_fors ALTER COLUMN id SET DEFAULT nextval('public.unavailable_as_candidate_fors_id_seq'::regclass);


--
-- Name: units id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units ALTER COLUMN id SET DEFAULT nextval('public.units_id_seq'::regclass);


--
-- Name: user_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles ALTER COLUMN id SET DEFAULT nextval('public.user_roles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: veteran_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.veteran_statuses ALTER COLUMN id SET DEFAULT nextval('public.veteran_statuses_id_seq'::regclass);


--
-- Name: vouchers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vouchers ALTER COLUMN id SET DEFAULT nextval('public.vouchers_id_seq'::regclass);


--
-- Name: weighting_rules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weighting_rules ALTER COLUMN id SET DEFAULT nextval('public.weighting_rules_id_seq'::regclass);


--
-- Name: activity_logs activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_logs
    ADD CONSTRAINT activity_logs_pkey PRIMARY KEY (id);


--
-- Name: agencies agencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agencies
    ADD CONSTRAINT agencies_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: building_contacts building_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_contacts
    ADD CONSTRAINT building_contacts_pkey PRIMARY KEY (id);


--
-- Name: building_services building_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_services
    ADD CONSTRAINT building_services_pkey PRIMARY KEY (id);


--
-- Name: buildings buildings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings
    ADD CONSTRAINT buildings_pkey PRIMARY KEY (id);


--
-- Name: client_contacts client_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_contacts
    ADD CONSTRAINT client_contacts_pkey PRIMARY KEY (id);


--
-- Name: client_notes client_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_notes
    ADD CONSTRAINT client_notes_pkey PRIMARY KEY (id);


--
-- Name: client_opportunity_match_contacts client_opportunity_match_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_opportunity_match_contacts
    ADD CONSTRAINT client_opportunity_match_contacts_pkey PRIMARY KEY (id);


--
-- Name: client_opportunity_matches client_opportunity_matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_opportunity_matches
    ADD CONSTRAINT client_opportunity_matches_pkey PRIMARY KEY (id);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: configs configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configs
    ADD CONSTRAINT configs_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: data_sources data_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_sources
    ADD CONSTRAINT data_sources_pkey PRIMARY KEY (id);


--
-- Name: date_of_birth_quality_codes date_of_birth_quality_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_of_birth_quality_codes
    ADD CONSTRAINT date_of_birth_quality_codes_pkey PRIMARY KEY (id);


--
-- Name: deidentified_clients_xlsxes deidentified_clients_xlsxes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deidentified_clients_xlsxes
    ADD CONSTRAINT deidentified_clients_xlsxes_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: disabling_conditions disabling_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disabling_conditions
    ADD CONSTRAINT disabling_conditions_pkey PRIMARY KEY (id);


--
-- Name: discharge_statuses discharge_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discharge_statuses
    ADD CONSTRAINT discharge_statuses_pkey PRIMARY KEY (id);


--
-- Name: domestic_violence_survivors domestic_violence_survivors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.domestic_violence_survivors
    ADD CONSTRAINT domestic_violence_survivors_pkey PRIMARY KEY (id);


--
-- Name: entity_view_permissions entity_view_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_view_permissions
    ADD CONSTRAINT entity_view_permissions_pkey PRIMARY KEY (id);


--
-- Name: ethnicities ethnicities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ethnicities
    ADD CONSTRAINT ethnicities_pkey PRIMARY KEY (id);


--
-- Name: external_referrals external_referrals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_referrals
    ADD CONSTRAINT external_referrals_pkey PRIMARY KEY (id);


--
-- Name: file_tags file_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_tags
    ADD CONSTRAINT file_tags_pkey PRIMARY KEY (id);


--
-- Name: funding_source_services funding_source_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_source_services
    ADD CONSTRAINT funding_source_services_pkey PRIMARY KEY (id);


--
-- Name: funding_sources funding_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_sources
    ADD CONSTRAINT funding_sources_pkey PRIMARY KEY (id);


--
-- Name: has_developmental_disabilities has_developmental_disabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.has_developmental_disabilities
    ADD CONSTRAINT has_developmental_disabilities_pkey PRIMARY KEY (id);


--
-- Name: has_hivaids has_hivaids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.has_hivaids
    ADD CONSTRAINT has_hivaids_pkey PRIMARY KEY (id);


--
-- Name: has_mental_health_problems has_mental_health_problems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.has_mental_health_problems
    ADD CONSTRAINT has_mental_health_problems_pkey PRIMARY KEY (id);


--
-- Name: helps helps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.helps
    ADD CONSTRAINT helps_pkey PRIMARY KEY (id);


--
-- Name: housing_attributes housing_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.housing_attributes
    ADD CONSTRAINT housing_attributes_pkey PRIMARY KEY (id);


--
-- Name: housing_media_links housing_media_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.housing_media_links
    ADD CONSTRAINT housing_media_links_pkey PRIMARY KEY (id);


--
-- Name: imported_clients_csvs imported_clients_csvs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imported_clients_csvs
    ADD CONSTRAINT imported_clients_csvs_pkey PRIMARY KEY (id);


--
-- Name: letsencrypt_plugin_challenges letsencrypt_plugin_challenges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.letsencrypt_plugin_challenges
    ADD CONSTRAINT letsencrypt_plugin_challenges_pkey PRIMARY KEY (id);


--
-- Name: letsencrypt_plugin_settings letsencrypt_plugin_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.letsencrypt_plugin_settings
    ADD CONSTRAINT letsencrypt_plugin_settings_pkey PRIMARY KEY (id);


--
-- Name: login_activities login_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_activities
    ADD CONSTRAINT login_activities_pkey PRIMARY KEY (id);


--
-- Name: match_census match_census_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_census
    ADD CONSTRAINT match_census_pkey PRIMARY KEY (id);


--
-- Name: match_decision_reasons match_decision_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_decision_reasons
    ADD CONSTRAINT match_decision_reasons_pkey PRIMARY KEY (id);


--
-- Name: match_decisions match_decisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_decisions
    ADD CONSTRAINT match_decisions_pkey PRIMARY KEY (id);


--
-- Name: match_events match_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_events
    ADD CONSTRAINT match_events_pkey PRIMARY KEY (id);


--
-- Name: match_mitigation_reasons match_mitigation_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_mitigation_reasons
    ADD CONSTRAINT match_mitigation_reasons_pkey PRIMARY KEY (id);


--
-- Name: match_prioritizations match_prioritizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_prioritizations
    ADD CONSTRAINT match_prioritizations_pkey PRIMARY KEY (id);


--
-- Name: match_progress_updates match_progress_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_progress_updates
    ADD CONSTRAINT match_progress_updates_pkey PRIMARY KEY (id);


--
-- Name: match_routes match_routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_routes
    ADD CONSTRAINT match_routes_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: mitigation_reasons mitigation_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mitigation_reasons
    ADD CONSTRAINT mitigation_reasons_pkey PRIMARY KEY (id);


--
-- Name: name_quality_codes name_quality_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.name_quality_codes
    ADD CONSTRAINT name_quality_codes_pkey PRIMARY KEY (id);


--
-- Name: neighborhood_interests neighborhood_interests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.neighborhood_interests
    ADD CONSTRAINT neighborhood_interests_pkey PRIMARY KEY (id);


--
-- Name: neighborhoods neighborhoods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.neighborhoods
    ADD CONSTRAINT neighborhoods_pkey PRIMARY KEY (id);


--
-- Name: non_hmis_assessments non_hmis_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.non_hmis_assessments
    ADD CONSTRAINT non_hmis_assessments_pkey PRIMARY KEY (id);


--
-- Name: non_hmis_clients non_hmis_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.non_hmis_clients
    ADD CONSTRAINT non_hmis_clients_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: opportunities opportunities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opportunities
    ADD CONSTRAINT opportunities_pkey PRIMARY KEY (id);


--
-- Name: opportunity_contacts opportunity_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opportunity_contacts
    ADD CONSTRAINT opportunity_contacts_pkey PRIMARY KEY (id);


--
-- Name: opportunity_properties opportunity_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opportunity_properties
    ADD CONSTRAINT opportunity_properties_pkey PRIMARY KEY (id);


--
-- Name: outreach_histories outreach_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outreach_histories
    ADD CONSTRAINT outreach_histories_pkey PRIMARY KEY (id);


--
-- Name: physical_disabilities physical_disabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.physical_disabilities
    ADD CONSTRAINT physical_disabilities_pkey PRIMARY KEY (id);


--
-- Name: program_contacts program_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.program_contacts
    ADD CONSTRAINT program_contacts_pkey PRIMARY KEY (id);


--
-- Name: program_services program_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.program_services
    ADD CONSTRAINT program_services_pkey PRIMARY KEY (id);


--
-- Name: programs programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.programs
    ADD CONSTRAINT programs_pkey PRIMARY KEY (id);


--
-- Name: project_clients project_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_clients
    ADD CONSTRAINT project_clients_pkey PRIMARY KEY (id);


--
-- Name: project_programs project_programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_programs
    ADD CONSTRAINT project_programs_pkey PRIMARY KEY (id);


--
-- Name: reissue_requests reissue_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reissue_requests
    ADD CONSTRAINT reissue_requests_pkey PRIMARY KEY (id);


--
-- Name: rejected_matches rejected_matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rejected_matches
    ADD CONSTRAINT rejected_matches_pkey PRIMARY KEY (id);


--
-- Name: report_definitions report_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_definitions
    ADD CONSTRAINT report_definitions_pkey PRIMARY KEY (id);


--
-- Name: reporting_decisions reporting_decisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reporting_decisions
    ADD CONSTRAINT reporting_decisions_pkey PRIMARY KEY (id);


--
-- Name: requirements requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requirements
    ADD CONSTRAINT requirements_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: rules rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rules
    ADD CONSTRAINT rules_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: service_rules service_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_rules
    ADD CONSTRAINT service_rules_pkey PRIMARY KEY (id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: shelter_histories shelter_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shelter_histories
    ADD CONSTRAINT shelter_histories_pkey PRIMARY KEY (id);


--
-- Name: social_security_number_quality_codes social_security_number_quality_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.social_security_number_quality_codes
    ADD CONSTRAINT social_security_number_quality_codes_pkey PRIMARY KEY (id);


--
-- Name: stalled_responses stalled_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stalled_responses
    ADD CONSTRAINT stalled_responses_pkey PRIMARY KEY (id);


--
-- Name: sub_program_contacts sub_program_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_program_contacts
    ADD CONSTRAINT sub_program_contacts_pkey PRIMARY KEY (id);


--
-- Name: sub_programs sub_programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_programs
    ADD CONSTRAINT sub_programs_pkey PRIMARY KEY (id);


--
-- Name: subgrantee_contacts subgrantee_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subgrantee_contacts
    ADD CONSTRAINT subgrantee_contacts_pkey PRIMARY KEY (id);


--
-- Name: subgrantee_services subgrantee_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subgrantee_services
    ADD CONSTRAINT subgrantee_services_pkey PRIMARY KEY (id);


--
-- Name: subgrantees subgrantees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subgrantees
    ADD CONSTRAINT subgrantees_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: translation_keys translation_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.translation_keys
    ADD CONSTRAINT translation_keys_pkey PRIMARY KEY (id);


--
-- Name: translation_texts translation_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.translation_texts
    ADD CONSTRAINT translation_texts_pkey PRIMARY KEY (id);


--
-- Name: translations translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.translations
    ADD CONSTRAINT translations_pkey PRIMARY KEY (id);


--
-- Name: unavailable_as_candidate_fors unavailable_as_candidate_fors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unavailable_as_candidate_fors
    ADD CONSTRAINT unavailable_as_candidate_fors_pkey PRIMARY KEY (id);


--
-- Name: units units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: veteran_statuses veteran_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.veteran_statuses
    ADD CONSTRAINT veteran_statuses_pkey PRIMARY KEY (id);


--
-- Name: vouchers vouchers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vouchers
    ADD CONSTRAINT vouchers_pkey PRIMARY KEY (id);


--
-- Name: weighting_rules weighting_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weighting_rules
    ADD CONSTRAINT weighting_rules_pkey PRIMARY KEY (id);


--
-- Name: activity_logs_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX activity_logs_created_at_idx ON public.activity_logs USING brin (created_at);


--
-- Name: created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX created_at_idx ON public.activity_logs USING brin (created_at);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON public.delayed_jobs USING btree (priority, run_at);


--
-- Name: index_activity_logs_on_controller_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_logs_on_controller_name ON public.activity_logs USING btree (controller_name);


--
-- Name: index_activity_logs_on_created_at_and_item_model_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_logs_on_created_at_and_item_model_and_user_id ON public.activity_logs USING btree (created_at, item_model, user_id);


--
-- Name: index_activity_logs_on_item_model; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_logs_on_item_model ON public.activity_logs USING btree (item_model);


--
-- Name: index_activity_logs_on_item_model_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_logs_on_item_model_and_user_id ON public.activity_logs USING btree (item_model, user_id);


--
-- Name: index_activity_logs_on_item_model_and_user_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_logs_on_item_model_and_user_id_and_created_at ON public.activity_logs USING btree (item_model, user_id, created_at);


--
-- Name: index_activity_logs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_logs_on_user_id ON public.activity_logs USING btree (user_id);


--
-- Name: index_activity_logs_on_user_id_and_item_model_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_logs_on_user_id_and_item_model_and_created_at ON public.activity_logs USING btree (user_id, item_model, created_at);


--
-- Name: index_building_contacts_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_building_contacts_on_building_id ON public.building_contacts USING btree (building_id);


--
-- Name: index_building_contacts_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_building_contacts_on_contact_id ON public.building_contacts USING btree (contact_id);


--
-- Name: index_building_contacts_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_building_contacts_on_deleted_at ON public.building_contacts USING btree (deleted_at);


--
-- Name: index_building_services_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_building_services_on_building_id ON public.building_services USING btree (building_id);


--
-- Name: index_building_services_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_building_services_on_deleted_at ON public.building_services USING btree (deleted_at);


--
-- Name: index_building_services_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_building_services_on_service_id ON public.building_services USING btree (service_id);


--
-- Name: index_buildings_on_id_in_data_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_on_id_in_data_source ON public.buildings USING btree (id_in_data_source);


--
-- Name: index_buildings_on_subgrantee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_on_subgrantee_id ON public.buildings USING btree (subgrantee_id);


--
-- Name: index_client_contacts_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_contacts_on_client_id ON public.client_contacts USING btree (client_id);


--
-- Name: index_client_contacts_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_contacts_on_contact_id ON public.client_contacts USING btree (contact_id);


--
-- Name: index_client_contacts_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_contacts_on_deleted_at ON public.client_contacts USING btree (deleted_at);


--
-- Name: index_client_opportunity_match_contacts_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_match_contacts_on_contact_id ON public.client_opportunity_match_contacts USING btree (contact_id);


--
-- Name: index_client_opportunity_match_contacts_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_match_contacts_on_deleted_at ON public.client_opportunity_match_contacts USING btree (deleted_at);


--
-- Name: index_client_opportunity_match_contacts_on_match_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_match_contacts_on_match_id ON public.client_opportunity_match_contacts USING btree (match_id);


--
-- Name: index_client_opportunity_matches_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_matches_on_active ON public.client_opportunity_matches USING btree (active);


--
-- Name: index_client_opportunity_matches_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_matches_on_client_id ON public.client_opportunity_matches USING btree (client_id);


--
-- Name: index_client_opportunity_matches_on_closed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_matches_on_closed ON public.client_opportunity_matches USING btree (closed);


--
-- Name: index_client_opportunity_matches_on_closed_reason; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_matches_on_closed_reason ON public.client_opportunity_matches USING btree (closed_reason);


--
-- Name: index_client_opportunity_matches_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_matches_on_contact_id ON public.client_opportunity_matches USING btree (contact_id);


--
-- Name: index_client_opportunity_matches_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_matches_on_deleted_at ON public.client_opportunity_matches USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: index_client_opportunity_matches_on_opportunity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_client_opportunity_matches_on_opportunity_id ON public.client_opportunity_matches USING btree (opportunity_id);


--
-- Name: index_clients_on_active_cohort_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_active_cohort_ids ON public.clients USING btree (active_cohort_ids);


--
-- Name: index_clients_on_available; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_available ON public.clients USING btree (available);


--
-- Name: index_clients_on_calculated_last_homeless_night; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_calculated_last_homeless_night ON public.clients USING btree (calculated_last_homeless_night);


--
-- Name: index_clients_on_date_of_birth; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_date_of_birth ON public.clients USING btree (date_of_birth);


--
-- Name: index_clients_on_days_homeless_in_last_three_years; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_days_homeless_in_last_three_years ON public.clients USING btree (days_homeless_in_last_three_years);


--
-- Name: index_clients_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_deleted_at ON public.clients USING btree (deleted_at);


--
-- Name: index_clients_on_disabling_condition; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_disabling_condition ON public.clients USING btree (disabling_condition);


--
-- Name: index_clients_on_enrolled_project_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_enrolled_project_ids ON public.clients USING btree (enrolled_project_ids);


--
-- Name: index_clients_on_family_member; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_family_member ON public.clients USING btree (family_member);


--
-- Name: index_clients_on_health_prioritized; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_health_prioritized ON public.clients USING btree (health_prioritized);


--
-- Name: index_clients_on_vispdat_priority_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_vispdat_priority_score ON public.clients USING btree (vispdat_priority_score);


--
-- Name: index_clients_on_vispdat_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_vispdat_score ON public.clients USING btree (vispdat_score);


--
-- Name: index_contacts_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_deleted_at ON public.contacts USING btree (deleted_at);


--
-- Name: index_contacts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_user_id ON public.contacts USING btree (user_id);


--
-- Name: index_entity_view_permissions_on_agency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_view_permissions_on_agency_id ON public.entity_view_permissions USING btree (agency_id);


--
-- Name: index_entity_view_permissions_on_entity_type_and_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_view_permissions_on_entity_type_and_entity_id ON public.entity_view_permissions USING btree (entity_type, entity_id);


--
-- Name: index_entity_view_permissions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_view_permissions_on_user_id ON public.entity_view_permissions USING btree (user_id);


--
-- Name: index_external_referrals_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_external_referrals_on_client_id ON public.external_referrals USING btree (client_id);


--
-- Name: index_external_referrals_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_external_referrals_on_created_at ON public.external_referrals USING btree (created_at);


--
-- Name: index_external_referrals_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_external_referrals_on_updated_at ON public.external_referrals USING btree (updated_at);


--
-- Name: index_external_referrals_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_external_referrals_on_user_id ON public.external_referrals USING btree (user_id);


--
-- Name: index_funding_source_services_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_funding_source_services_on_deleted_at ON public.funding_source_services USING btree (deleted_at);


--
-- Name: index_funding_source_services_on_funding_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_funding_source_services_on_funding_source_id ON public.funding_source_services USING btree (funding_source_id);


--
-- Name: index_funding_source_services_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_funding_source_services_on_service_id ON public.funding_source_services USING btree (service_id);


--
-- Name: index_helps_on_controller_path_and_action_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_helps_on_controller_path_and_action_name ON public.helps USING btree (controller_path, action_name);


--
-- Name: index_helps_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_helps_on_created_at ON public.helps USING btree (created_at);


--
-- Name: index_helps_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_helps_on_updated_at ON public.helps USING btree (updated_at);


--
-- Name: index_housing_attributes_on_housingable_type_and_housingable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_housing_attributes_on_housingable_type_and_housingable_id ON public.housing_attributes USING btree (housingable_type, housingable_id);


--
-- Name: index_housing_media_links_on_housingable_type_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_housing_media_links_on_housingable_type_and_id ON public.housing_media_links USING btree (housingable_type, housingable_id);


--
-- Name: index_login_activities_on_identity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_login_activities_on_identity ON public.login_activities USING btree (identity);


--
-- Name: index_login_activities_on_ip; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_login_activities_on_ip ON public.login_activities USING btree (ip);


--
-- Name: index_match_census_on_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_census_on_date ON public.match_census USING btree (date);


--
-- Name: index_match_census_on_match_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_census_on_match_id ON public.match_census USING btree (match_id);


--
-- Name: index_match_census_on_match_prioritization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_census_on_match_prioritization_id ON public.match_census USING btree (match_prioritization_id);


--
-- Name: index_match_census_on_opportunity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_census_on_opportunity_id ON public.match_census USING btree (opportunity_id);


--
-- Name: index_match_decisions_on_administrative_cancel_reason_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_decisions_on_administrative_cancel_reason_id ON public.match_decisions USING btree (administrative_cancel_reason_id);


--
-- Name: index_match_decisions_on_decline_reason_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_decisions_on_decline_reason_id ON public.match_decisions USING btree (decline_reason_id);


--
-- Name: index_match_decisions_on_match_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_decisions_on_match_id ON public.match_decisions USING btree (match_id);


--
-- Name: index_match_decisions_on_not_working_with_client_reason_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_decisions_on_not_working_with_client_reason_id ON public.match_decisions USING btree (not_working_with_client_reason_id);


--
-- Name: index_match_events_on_decision_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_events_on_decision_id ON public.match_events USING btree (decision_id);


--
-- Name: index_match_events_on_match_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_events_on_match_id ON public.match_events USING btree (match_id);


--
-- Name: index_match_events_on_not_working_with_client_reason_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_events_on_not_working_with_client_reason_id ON public.match_events USING btree (not_working_with_client_reason_id);


--
-- Name: index_match_events_on_notification_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_events_on_notification_id ON public.match_events USING btree (notification_id);


--
-- Name: index_match_mitigation_reasons_on_client_opportunity_match_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_mitigation_reasons_on_client_opportunity_match_id ON public.match_mitigation_reasons USING btree (client_opportunity_match_id);


--
-- Name: index_match_mitigation_reasons_on_mitigation_reason_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_mitigation_reasons_on_mitigation_reason_id ON public.match_mitigation_reasons USING btree (mitigation_reason_id);


--
-- Name: index_match_progress_updates_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_progress_updates_on_contact_id ON public.match_progress_updates USING btree (contact_id);


--
-- Name: index_match_progress_updates_on_decision_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_progress_updates_on_decision_id ON public.match_progress_updates USING btree (decision_id);


--
-- Name: index_match_progress_updates_on_match_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_progress_updates_on_match_id ON public.match_progress_updates USING btree (match_id);


--
-- Name: index_match_progress_updates_on_notification_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_progress_updates_on_notification_id ON public.match_progress_updates USING btree (notification_id);


--
-- Name: index_match_progress_updates_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_progress_updates_on_type ON public.match_progress_updates USING btree (type);


--
-- Name: index_match_routes_on_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_routes_on_tag_id ON public.match_routes USING btree (tag_id);


--
-- Name: index_non_hmis_assessments_on_agency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_non_hmis_assessments_on_agency_id ON public.non_hmis_assessments USING btree (agency_id);


--
-- Name: index_non_hmis_assessments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_non_hmis_assessments_on_user_id ON public.non_hmis_assessments USING btree (user_id);


--
-- Name: index_non_hmis_clients_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_non_hmis_clients_on_deleted_at ON public.non_hmis_clients USING btree (deleted_at);


--
-- Name: index_opportunities_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_opportunities_on_deleted_at ON public.opportunities USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: index_opportunities_on_unit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_opportunities_on_unit_id ON public.opportunities USING btree (unit_id);


--
-- Name: index_opportunities_on_voucher_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_opportunities_on_voucher_id ON public.opportunities USING btree (voucher_id);


--
-- Name: index_opportunity_contacts_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_opportunity_contacts_on_contact_id ON public.opportunity_contacts USING btree (contact_id);


--
-- Name: index_opportunity_contacts_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_opportunity_contacts_on_deleted_at ON public.opportunity_contacts USING btree (deleted_at);


--
-- Name: index_opportunity_contacts_on_opportunity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_opportunity_contacts_on_opportunity_id ON public.opportunity_contacts USING btree (opportunity_id);


--
-- Name: index_opportunity_properties_on_opportunity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_opportunity_properties_on_opportunity_id ON public.opportunity_properties USING btree (opportunity_id);


--
-- Name: index_outreach_histories_on_non_hmis_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outreach_histories_on_non_hmis_client_id ON public.outreach_histories USING btree (non_hmis_client_id);


--
-- Name: index_outreach_histories_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outreach_histories_on_user_id ON public.outreach_histories USING btree (user_id);


--
-- Name: index_program_contacts_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_program_contacts_on_contact_id ON public.program_contacts USING btree (contact_id);


--
-- Name: index_program_contacts_on_program_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_program_contacts_on_program_id ON public.program_contacts USING btree (program_id);


--
-- Name: index_program_services_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_program_services_on_deleted_at ON public.program_services USING btree (deleted_at);


--
-- Name: index_program_services_on_program_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_program_services_on_program_id ON public.program_services USING btree (program_id);


--
-- Name: index_program_services_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_program_services_on_service_id ON public.program_services USING btree (service_id);


--
-- Name: index_programs_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_programs_on_contact_id ON public.programs USING btree (contact_id);


--
-- Name: index_programs_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_programs_on_deleted_at ON public.programs USING btree (deleted_at);


--
-- Name: index_programs_on_funding_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_programs_on_funding_source_id ON public.programs USING btree (funding_source_id);


--
-- Name: index_programs_on_subgrantee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_programs_on_subgrantee_id ON public.programs USING btree (subgrantee_id);


--
-- Name: index_project_clients_on_calculated_chronic_homelessness; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_clients_on_calculated_chronic_homelessness ON public.project_clients USING btree (calculated_chronic_homelessness);


--
-- Name: index_project_clients_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_clients_on_client_id ON public.project_clients USING btree (client_id);


--
-- Name: index_project_clients_on_date_of_birth; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_clients_on_date_of_birth ON public.project_clients USING btree (date_of_birth);


--
-- Name: index_project_clients_on_source_last_changed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_clients_on_source_last_changed ON public.project_clients USING btree (source_last_changed);


--
-- Name: index_reissue_requests_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reissue_requests_on_deleted_at ON public.reissue_requests USING btree (deleted_at);


--
-- Name: index_reissue_requests_on_notification_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reissue_requests_on_notification_id ON public.reissue_requests USING btree (notification_id);


--
-- Name: index_reissue_requests_on_reissued_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reissue_requests_on_reissued_by ON public.reissue_requests USING btree (reissued_by);


--
-- Name: index_rejected_matches_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rejected_matches_on_client_id ON public.rejected_matches USING btree (client_id);


--
-- Name: index_rejected_matches_on_opportunity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rejected_matches_on_opportunity_id ON public.rejected_matches USING btree (opportunity_id);


--
-- Name: index_reporting_decisions_c_m_d; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_reporting_decisions_c_m_d ON public.reporting_decisions USING btree (client_id, match_id, decision_id);


--
-- Name: index_requirements_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requirements_on_deleted_at ON public.requirements USING btree (deleted_at);


--
-- Name: index_requirements_on_requirer_type_and_requirer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requirements_on_requirer_type_and_requirer_id ON public.requirements USING btree (requirer_type, requirer_id);


--
-- Name: index_requirements_on_rule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requirements_on_rule_id ON public.requirements USING btree (rule_id);


--
-- Name: index_roles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_name ON public.roles USING btree (name);


--
-- Name: index_rules_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rules_on_deleted_at ON public.rules USING btree (deleted_at);


--
-- Name: index_service_rules_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_service_rules_on_deleted_at ON public.service_rules USING btree (deleted_at);


--
-- Name: index_service_rules_on_rule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_service_rules_on_rule_id ON public.service_rules USING btree (rule_id);


--
-- Name: index_service_rules_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_service_rules_on_service_id ON public.service_rules USING btree (service_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_sessions_on_session_id ON public.sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_updated_at ON public.sessions USING btree (updated_at);


--
-- Name: index_shelter_histories_on_non_hmis_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shelter_histories_on_non_hmis_client_id ON public.shelter_histories USING btree (non_hmis_client_id);


--
-- Name: index_shelter_histories_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shelter_histories_on_user_id ON public.shelter_histories USING btree (user_id);


--
-- Name: index_sub_program_contacts_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sub_program_contacts_on_contact_id ON public.sub_program_contacts USING btree (contact_id);


--
-- Name: index_sub_program_contacts_on_sub_program_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sub_program_contacts_on_sub_program_id ON public.sub_program_contacts USING btree (sub_program_id);


--
-- Name: index_sub_programs_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sub_programs_on_building_id ON public.sub_programs USING btree (building_id);


--
-- Name: index_sub_programs_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sub_programs_on_deleted_at ON public.sub_programs USING btree (deleted_at);


--
-- Name: index_sub_programs_on_match_prioritization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sub_programs_on_match_prioritization_id ON public.sub_programs USING btree (match_prioritization_id);


--
-- Name: index_sub_programs_on_program_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sub_programs_on_program_id ON public.sub_programs USING btree (program_id);


--
-- Name: index_sub_programs_on_subgrantee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sub_programs_on_subgrantee_id ON public.sub_programs USING btree (subgrantee_id);


--
-- Name: index_subgrantee_contacts_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subgrantee_contacts_on_contact_id ON public.subgrantee_contacts USING btree (contact_id);


--
-- Name: index_subgrantee_contacts_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subgrantee_contacts_on_deleted_at ON public.subgrantee_contacts USING btree (deleted_at);


--
-- Name: index_subgrantee_contacts_on_subgrantee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subgrantee_contacts_on_subgrantee_id ON public.subgrantee_contacts USING btree (subgrantee_id);


--
-- Name: index_subgrantee_services_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subgrantee_services_on_deleted_at ON public.subgrantee_services USING btree (deleted_at);


--
-- Name: index_subgrantee_services_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subgrantee_services_on_service_id ON public.subgrantee_services USING btree (service_id);


--
-- Name: index_subgrantee_services_on_subgrantee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subgrantee_services_on_subgrantee_id ON public.subgrantee_services USING btree (subgrantee_id);


--
-- Name: index_translation_keys_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_translation_keys_on_key ON public.translation_keys USING btree (key);


--
-- Name: index_translation_texts_on_translation_key_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_translation_texts_on_translation_key_id ON public.translation_texts USING btree (translation_key_id);


--
-- Name: index_translations_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_translations_on_key ON public.translations USING btree (key);


--
-- Name: index_unavailable_as_candidate_fors_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_unavailable_as_candidate_fors_on_client_id ON public.unavailable_as_candidate_fors USING btree (client_id);


--
-- Name: index_unavailable_as_candidate_fors_on_match_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_unavailable_as_candidate_fors_on_match_id ON public.unavailable_as_candidate_fors USING btree (match_id);


--
-- Name: index_unavailable_as_candidate_fors_on_match_route_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_unavailable_as_candidate_fors_on_match_route_type ON public.unavailable_as_candidate_fors USING btree (match_route_type);


--
-- Name: index_unavailable_as_candidate_fors_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_unavailable_as_candidate_fors_on_user_id ON public.unavailable_as_candidate_fors USING btree (user_id);


--
-- Name: index_units_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_units_on_building_id ON public.units USING btree (building_id);


--
-- Name: index_units_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_units_on_deleted_at ON public.units USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: index_units_on_id_in_data_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_units_on_id_in_data_source ON public.units USING btree (id_in_data_source);


--
-- Name: index_user_roles_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_roles_on_role_id ON public.user_roles USING btree (role_id);


--
-- Name: index_user_roles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_roles_on_user_id ON public.user_roles USING btree (user_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_invitation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_invitation_token ON public.users USING btree (invitation_token);


--
-- Name: index_users_on_invitations_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invitations_count ON public.users USING btree (invitations_count);


--
-- Name: index_users_on_invited_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invited_by_id ON public.users USING btree (invited_by_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON public.users USING btree (unlock_token);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON public.versions USING btree (item_type, item_id);


--
-- Name: index_vouchers_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vouchers_on_deleted_at ON public.vouchers USING btree (deleted_at);


--
-- Name: index_vouchers_on_sub_program_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vouchers_on_sub_program_id ON public.vouchers USING btree (sub_program_id);


--
-- Name: index_vouchers_on_unit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vouchers_on_unit_id ON public.vouchers USING btree (unit_id);


--
-- Name: index_weighting_rules_on_requirement_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_weighting_rules_on_requirement_id ON public.weighting_rules USING btree (requirement_id);


--
-- Name: index_weighting_rules_on_route_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_weighting_rules_on_route_id ON public.weighting_rules USING btree (route_id);


--
-- Name: non_hmis_assessments non_hmis_assessments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.non_hmis_assessments
    ADD CONSTRAINT non_hmis_assessments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: opportunities opportunities_voucher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opportunities
    ADD CONSTRAINT opportunities_voucher_id_fkey FOREIGN KEY (voucher_id) REFERENCES public.vouchers(id);


--
-- Name: programs programs_contact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.programs
    ADD CONSTRAINT programs_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES public.contacts(id);


--
-- Name: programs programs_funding_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.programs
    ADD CONSTRAINT programs_funding_source_id_fkey FOREIGN KEY (funding_source_id) REFERENCES public.funding_sources(id);


--
-- Name: programs programs_subgrantee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.programs
    ADD CONSTRAINT programs_subgrantee_id_fkey FOREIGN KEY (subgrantee_id) REFERENCES public.subgrantees(id);


--
-- Name: reissue_requests reissue_requests_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reissue_requests
    ADD CONSTRAINT reissue_requests_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.notifications(id);


--
-- Name: reissue_requests reissue_requests_reissued_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reissue_requests
    ADD CONSTRAINT reissue_requests_reissued_by_fkey FOREIGN KEY (reissued_by) REFERENCES public.users(id);


--
-- Name: sub_programs sub_programs_building_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_programs
    ADD CONSTRAINT sub_programs_building_id_fkey FOREIGN KEY (building_id) REFERENCES public.buildings(id);


--
-- Name: sub_programs sub_programs_hsa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_programs
    ADD CONSTRAINT sub_programs_hsa_id_fkey FOREIGN KEY (hsa_id) REFERENCES public.subgrantees(id);


--
-- Name: sub_programs sub_programs_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_programs
    ADD CONSTRAINT sub_programs_program_id_fkey FOREIGN KEY (program_id) REFERENCES public.programs(id);


--
-- Name: sub_programs sub_programs_sub_contractor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_programs
    ADD CONSTRAINT sub_programs_sub_contractor_id_fkey FOREIGN KEY (sub_contractor_id) REFERENCES public.subgrantees(id);


--
-- Name: sub_programs sub_programs_subgrantee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_programs
    ADD CONSTRAINT sub_programs_subgrantee_id_fkey FOREIGN KEY (subgrantee_id) REFERENCES public.subgrantees(id);


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: vouchers vouchers_sub_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vouchers
    ADD CONSTRAINT vouchers_sub_program_id_fkey FOREIGN KEY (sub_program_id) REFERENCES public.sub_programs(id);


--
-- Name: vouchers vouchers_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vouchers
    ADD CONSTRAINT vouchers_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units(id);


--
-- Name: vouchers vouchers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vouchers
    ADD CONSTRAINT vouchers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20160212185654'),
('20160223173233'),
('20160302182826'),
('20160302193733'),
('20160304185448'),
('20160306003655'),
('20160307013645'),
('20160307164647'),
('20160307192631'),
('20160308204935'),
('20160308212348'),
('20160310204713'),
('20160311185352'),
('20160311203425'),
('20160311213859'),
('20160311215729'),
('20160311221109'),
('20160311221118'),
('20160314125643'),
('20160314125723'),
('20160314125734'),
('20160314125742'),
('20160314125809'),
('20160314125825'),
('20160314125837'),
('20160314125858'),
('20160314125911'),
('20160314125925'),
('20160314125955'),
('20160314130009'),
('20160314130026'),
('20160314170902'),
('20160314180117'),
('20160314181828'),
('20160315174252'),
('20160315181816'),
('20160316140845'),
('20160317154933'),
('20160317155559'),
('20160317172840'),
('20160317174943'),
('20160317182939'),
('20160317194643'),
('20160318123052'),
('20160318182521'),
('20160321145517'),
('20160321154527'),
('20160322003154'),
('20160322003840'),
('20160322010236'),
('20160322124148'),
('20160324160916'),
('20160324193620'),
('20160324204527'),
('20160325160053'),
('20160325183212'),
('20160325200752'),
('20160325200844'),
('20160328015127'),
('20160328015510'),
('20160328124526'),
('20160328174238'),
('20160328194812'),
('20160328200741'),
('20160329142615'),
('20160329183607'),
('20160329183922'),
('20160329184000'),
('20160330135219'),
('20160330190745'),
('20160331000512'),
('20160331164934'),
('20160331191107'),
('20160401121404'),
('20160401154333'),
('20160401194603'),
('20160404123859'),
('20160404202155'),
('20160405155325'),
('20160406160729'),
('20160406163059'),
('20160406180128'),
('20160407171741'),
('20160407191141'),
('20160407201337'),
('20160408134113'),
('20160408185513'),
('20160408202750'),
('20160409183228'),
('20160411134641'),
('20160411145222'),
('20160411152547'),
('20160411175935'),
('20160411176836'),
('20160412153745'),
('20160414122427'),
('20160414142903'),
('20160420152827'),
('20160423194726'),
('20160424003441'),
('20160424005155'),
('20160424134405'),
('20160425123612'),
('20160425153957'),
('20160425154223'),
('20160425190640'),
('20160426195634'),
('20160426195948'),
('20160427124030'),
('20160427154813'),
('20160428172106'),
('20160428180615'),
('20160429132941'),
('20160429163105'),
('20160429164547'),
('20160502234117'),
('20160503172539'),
('20160519170917'),
('20160519171133'),
('20160519173925'),
('20160520160418'),
('20160520183310'),
('20160524191935'),
('20160525130236'),
('20160525201537'),
('20160602190355'),
('20160610192904'),
('20160611010706'),
('20160622175241'),
('20160622193037'),
('20160809193948'),
('20160817172520'),
('20160901201841'),
('20160902143546'),
('20161017132353'),
('20161017144713'),
('20161021171808'),
('20161108203825'),
('20161117152709'),
('20161117155843'),
('20161117162449'),
('20161130173742'),
('20161205190843'),
('20170103172116'),
('20170201135646'),
('20170213180945'),
('20170213195031'),
('20170302202943'),
('20170314162953'),
('20170315124419'),
('20170315125413'),
('20170322155734'),
('20170326234009'),
('20170329122422'),
('20170421142554'),
('20170421163530'),
('20170428201839'),
('20170505125855'),
('20170505170358'),
('20170511192828'),
('20170511194721'),
('20170524180727'),
('20170524180728'),
('20170524180811'),
('20170524180812'),
('20170605162924'),
('20170619000309'),
('20170621184202'),
('20170623171917'),
('20170629144505'),
('20170713125233'),
('20170724182052'),
('20170725203814'),
('20170818202458'),
('20170821132203'),
('20170823175246'),
('20170823182320'),
('20170827114049'),
('20170901180331'),
('20170904161926'),
('20170904173248'),
('20170904175515'),
('20170904203345'),
('20170906162452'),
('20170907122041'),
('20170914195045'),
('20170921150901'),
('20170925155224'),
('20170925170636'),
('20171002184557'),
('20171023185614'),
('20171025030616'),
('20171025194209'),
('20171030152636'),
('20171109210347'),
('20171110005511'),
('20171116160451'),
('20171122203909'),
('20171127164318'),
('20171129144446'),
('20171206140458'),
('20171206140644'),
('20171212210614'),
('20171213135320'),
('20180309203726'),
('20180309204058'),
('20180315161438'),
('20180327181025'),
('20180327182442'),
('20180331011801'),
('20180413155737'),
('20180418194751'),
('20180423140316'),
('20180423183534'),
('20180423184549'),
('20180424124203'),
('20180424143819'),
('20180424151233'),
('20180424152927'),
('20180424163313'),
('20180425130152'),
('20180425140747'),
('20180426133718'),
('20180426174303'),
('20180426174448'),
('20180427234333'),
('20180428121025'),
('20180430154941'),
('20180504202048'),
('20180505235920'),
('20180511075720'),
('20180511081334'),
('20180529134126'),
('20180529161403'),
('20180703150318'),
('20180703192307'),
('20180703193012'),
('20180710125552'),
('20180801141411'),
('20180815132103'),
('20180909155739'),
('20180912131907'),
('20180912154643'),
('20180912155337'),
('20180914190333'),
('20180914235523'),
('20181008141707'),
('20181011134859'),
('20181018174118'),
('20181019124944'),
('20181019154323'),
('20181024123259'),
('20181024180401'),
('20181024232716'),
('20181115180005'),
('20181212183412'),
('20181214004032'),
('20181220165125'),
('20181220171827'),
('20181221143527'),
('20181221153251'),
('20181227205845'),
('20181227212216'),
('20181227220951'),
('20181228164135'),
('20181228183546'),
('20181228202641'),
('20181231180419'),
('20181231191641'),
('20190121144954'),
('20190227194216'),
('20190228160136'),
('20190228163002'),
('20190228165352'),
('20190301210931'),
('20190304213833'),
('20190311182518'),
('20190312162603'),
('20190312164357'),
('20190314172444'),
('20190328155452'),
('20190328160354'),
('20190408151724'),
('20190408152907'),
('20190408153531'),
('20190411183854'),
('20190418182829'),
('20190423200343'),
('20190425134921'),
('20190515173043'),
('20190516141555'),
('20190520184428'),
('20190521144717'),
('20190521154725'),
('20190521202957'),
('20190522181548'),
('20190523150841'),
('20190708181554'),
('20190710155706'),
('20190726125407'),
('20190823132735'),
('20190826180204'),
('20190828132912'),
('20190828133322'),
('20190828185110'),
('20190828194347'),
('20190829142655'),
('20190911135358'),
('20190912195103'),
('20190912201023'),
('20190925195307'),
('20190927195501'),
('20191001174803'),
('20191001183520'),
('20191002201201'),
('20191009133059'),
('20191016174457'),
('20191101163237'),
('20191101184424'),
('20191113174716'),
('20191121211804'),
('20191121212710'),
('20191125194604'),
('20191125201212'),
('20191129174702'),
('20191129174912'),
('20191205010912'),
('20191205145915'),
('20191206143217'),
('20191209185632'),
('20191209201917'),
('20191216160930'),
('20191216162908'),
('20191216204509'),
('20191223145558'),
('20200108155100'),
('20200110174939'),
('20200113152559'),
('20200116165109'),
('20200117183615'),
('20200117184252'),
('20200117202108'),
('20200120191332'),
('20200125014549'),
('20200127144929'),
('20200129144239'),
('20200129175121'),
('20200207230944'),
('20200214143103'),
('20200217154122'),
('20200220153234'),
('20200220190012'),
('20200220192018'),
('20200221183551'),
('20200221185223'),
('20200226201037'),
('20200226201437'),
('20200228150023'),
('20200302164113'),
('20200303195105'),
('20200304143851'),
('20200310001320'),
('20200311145208'),
('20200312133258'),
('20200312144826'),
('20200312172917'),
('20200506200723'),
('20200507121847'),
('20200610140958'),
('20200901131100'),
('20200909122858'),
('20200922220349'),
('20200922223813'),
('20201018124843'),
('20201025185542'),
('20201029132201'),
('20201124204349'),
('20210115142722'),
('20210115175051'),
('20210119200902'),
('20210119201534'),
('20210122132325'),
('20210205142520'),
('20210304140037'),
('20210304141837'),
('20210324154221'),
('20210401173423'),
('20210401175418'),
('20210406201139'),
('20210407181347'),
('20210416132847'),
('20210416133245'),
('20210428205931'),
('20210507141030'),
('20210519175343'),
('20210524143842'),
('20210611163027'),
('20210621125138'),
('20210621131519'),
('20210621204303'),
('20210621204604'),
('20210625133457'),
('20210625175014'),
('20210625185817'),
('20210818003940'),
('20210823134810'),
('20210902113133'),
('20210914171237'),
('20210915154901'),
('20210917180753'),
('20210920175504'),
('20211020150747'),
('20211027134707'),
('20211027170803'),
('20211115133847'),
('20211122204003'),
('20211129190937'),
('20211129191957'),
('20211202141612'),
('20211206141319'),
('20211206205159'),
('20211207133821'),
('20211207194639'),
('20211208123438'),
('20211208123707'),
('20211222184513'),
('20220111202913'),
('20220204163601'),
('20220207143947'),
('20220209202102'),
('20220210135302'),
('20220215214217'),
('20220221193231'),
('20220224174712'),
('20220302211912'),
('20220321123835'),
('20220324155051'),
('20220413132343'),
('20220427204926'),
('20220525200137'),
('20220624201419'),
('20220721125102'),
('20220817143219'),
('20220824194138'),
('20220830184031'),
('20220915202202'),
('20221005133804'),
('20221005185642'),
('20221006142256'),
('20221006175635'),
('20221025170741'),
('20221115174445'),
('20221121214935'),
('20221122204546'),
('20221130152603'),
('20221130160214'),
('20221215170224'),
('20221215174817'),
('20221215174818'),
('20221221195906'),
('20231030212931'),
('20231031225917'),
('20231103194209'),
('20231106003238'),
('20231214141207'),
('20240105133456'),
('20240105212255'),
('20240108143931'),
('20240112140254'),
('20240123130412'),
('20240130195037'),
('20240202142811'),
('20240207154441'),
('20240207195944'),
('20240207200027'),
('20240212143240'),
('20240220202037'),
('20240226132534'),
('20240305213939'),
('20240405165545'),
('20240417172150'),
('20240422044709'),
('20240508140355'),
('20240610132826'),
('20240610185742'),
('20240708180516'),
('20240731130949'),
('20240805131951'),
('20240805133313'),
('20240807193023'),
('20240807193306'),
('20240807201535'),
('20240816134210'),
('20240816163828'),
('20240822155547'),
('20240827172144'),
('20241010194153');


