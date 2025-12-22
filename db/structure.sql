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
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: coupon_value_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.coupon_value_type AS ENUM (
    'free_tickets',
    'credit'
);


--
-- Name: gender; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.gender AS ENUM (
    'female',
    'male',
    'diverse'
);


--
-- Name: newsletter_newsletter_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.newsletter_newsletter_status AS ENUM (
    'draft',
    'review',
    'sent'
);


--
-- Name: permission; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.permission AS ENUM (
    'permissions_read',
    'permissions_update',
    'members_read',
    'members_update',
    'members_destroy',
    'newsletters_read',
    'newsletters_update',
    'newsletters_approve',
    'internet_access_sessions_create',
    'ticketing_events_read',
    'ticketing_events_update',
    'wasserwerk_read',
    'wasserwerk_update'
);


--
-- Name: ticketing_check_in_medium; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ticketing_check_in_medium AS ENUM (
    'unknown',
    'web',
    'retail',
    'passbook',
    'box_office',
    'box_office_direct'
);


--
-- Name: ticketing_order_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ticketing_order_type AS ENUM (
    'Ticketing::Web::Order',
    'Ticketing::Retail::Order',
    'Ticketing::BoxOffice::Order'
);


--
-- Name: ticketing_pay_method; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ticketing_pay_method AS ENUM (
    'charge',
    'transfer',
    'cash',
    'box_office',
    'stripe'
);


--
-- Name: ticketing_stripe_payment_method; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ticketing_stripe_payment_method AS ENUM (
    'apple_pay',
    'google_pay'
);


--
-- Name: ticketing_stripe_transaction_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ticketing_stripe_transaction_type AS ENUM (
    'payment_intent',
    'refund'
);


--
-- Name: ticketing_ticket_type_availability; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ticketing_ticket_type_availability AS ENUM (
    'universal',
    'exclusive',
    'box_office'
);


--
-- Name: ticketing_vat_rate; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ticketing_vat_rate AS ENUM (
    'standard',
    'reduced',
    'zero'
);


--
-- Name: user_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_type AS ENUM (
    'User',
    'Members::Member',
    'Ticketing::Retail::User'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

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
-- Name: galleries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.galleries (
    id bigint NOT NULL,
    title character varying,
    disclaimer character varying,
    "position" integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: galleries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.galleries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: galleries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.galleries_id_seq OWNED BY public.galleries.id;


--
-- Name: members_exclusive_ticket_type_credit_spendings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members_exclusive_ticket_type_credit_spendings (
    id bigint NOT NULL,
    member_id bigint,
    ticket_type_id bigint,
    order_id bigint,
    value integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: members_exclusive_ticket_type_credit_spendings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.members_exclusive_ticket_type_credit_spendings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: members_exclusive_ticket_type_credit_spendings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.members_exclusive_ticket_type_credit_spendings_id_seq OWNED BY public.members_exclusive_ticket_type_credit_spendings.id;


--
-- Name: members_exclusive_ticket_type_credits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members_exclusive_ticket_type_credits (
    id bigint NOT NULL,
    ticket_type_id bigint,
    value integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: members_exclusive_ticket_type_credits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.members_exclusive_ticket_type_credits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: members_exclusive_ticket_type_credits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.members_exclusive_ticket_type_credits_id_seq OWNED BY public.members_exclusive_ticket_type_credits.id;


--
-- Name: members_families; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members_families (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: members_families_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.members_families_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: members_families_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.members_families_id_seq OWNED BY public.members_families.id;


--
-- Name: members_membership_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members_membership_applications (
    id bigint NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    title character varying,
    gender public.gender NOT NULL,
    email character varying,
    street character varying NOT NULL,
    plz character varying NOT NULL,
    city character varying NOT NULL,
    birthday date NOT NULL,
    phone character varying,
    debtor_name character varying NOT NULL,
    iban character varying NOT NULL,
    member_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: members_membership_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.members_membership_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: members_membership_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.members_membership_applications_id_seq OWNED BY public.members_membership_applications.id;


--
-- Name: members_membership_fee_debit_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members_membership_fee_debit_submissions (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    ebics_response jsonb
);


--
-- Name: members_membership_fee_debit_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.members_membership_fee_debit_submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: members_membership_fee_debit_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.members_membership_fee_debit_submissions_id_seq OWNED BY public.members_membership_fee_debit_submissions.id;


--
-- Name: members_membership_fee_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members_membership_fee_payments (
    id bigint NOT NULL,
    member_id bigint NOT NULL,
    amount numeric NOT NULL,
    paid_until date NOT NULL,
    debit_submission_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    failed boolean DEFAULT false NOT NULL
);


--
-- Name: members_membership_fee_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.members_membership_fee_payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: members_membership_fee_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.members_membership_fee_payments_id_seq OWNED BY public.members_membership_fee_payments.id;


--
-- Name: members_sepa_mandates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members_sepa_mandates (
    id bigint NOT NULL,
    debtor_name character varying,
    iban character varying(34),
    number integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    issued_on date NOT NULL
);


--
-- Name: members_sepa_mandates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.members_sepa_mandates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: members_sepa_mandates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.members_sepa_mandates_id_seq OWNED BY public.members_sepa_mandates.id;


--
-- Name: newsletter_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newsletter_images (
    id bigint NOT NULL,
    image_file_name character varying,
    image_content_type character varying,
    image_file_size bigint,
    image_updated_at timestamp without time zone,
    newsletter_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: newsletter_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.newsletter_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: newsletter_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.newsletter_images_id_seq OWNED BY public.newsletter_images.id;


--
-- Name: newsletter_newsletters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newsletter_newsletters (
    id bigint NOT NULL,
    subject character varying,
    body_html text,
    body_text text,
    sent_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    status public.newsletter_newsletter_status DEFAULT 'draft'::public.newsletter_newsletter_status
);


--
-- Name: newsletter_newsletters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.newsletter_newsletters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: newsletter_newsletters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.newsletter_newsletters_id_seq OWNED BY public.newsletter_newsletters.id;


--
-- Name: newsletter_newsletters_subscriber_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newsletter_newsletters_subscriber_lists (
    newsletter_id bigint,
    subscriber_list_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: newsletter_subscriber_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newsletter_subscriber_lists (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: newsletter_subscriber_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.newsletter_subscriber_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: newsletter_subscriber_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.newsletter_subscriber_lists_id_seq OWNED BY public.newsletter_subscriber_lists.id;


--
-- Name: newsletter_subscribers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newsletter_subscribers (
    id bigint NOT NULL,
    email character varying,
    token character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    gender integer,
    last_name character varying,
    subscriber_list_id bigint DEFAULT 1 NOT NULL,
    confirmed_at timestamp without time zone
);


--
-- Name: newsletter_subscribers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.newsletter_subscribers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: newsletter_subscribers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.newsletter_subscribers_id_seq OWNED BY public.newsletter_subscribers.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_grants (
    id bigint NOT NULL,
    resource_owner_id bigint NOT NULL,
    application_id bigint NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    revoked_at timestamp(6) without time zone
);


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_grants_id_seq OWNED BY public.oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_tokens (
    id bigint NOT NULL,
    resource_owner_id bigint,
    application_id bigint NOT NULL,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    scopes character varying,
    created_at timestamp(6) without time zone NOT NULL,
    revoked_at timestamp(6) without time zone
);


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_tokens_id_seq OWNED BY public.oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_applications (
    id bigint NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    confidential boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_applications_id_seq OWNED BY public.oauth_applications.id;


--
-- Name: passbook_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.passbook_devices (
    id bigint NOT NULL,
    device_id character varying,
    push_token character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: passbook_devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.passbook_devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: passbook_devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.passbook_devices_id_seq OWNED BY public.passbook_devices.id;


--
-- Name: passbook_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.passbook_logs (
    id bigint NOT NULL,
    message text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: passbook_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.passbook_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: passbook_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.passbook_logs_id_seq OWNED BY public.passbook_logs.id;


--
-- Name: passbook_passes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.passbook_passes (
    id bigint NOT NULL,
    type_id character varying,
    serial_number character varying,
    auth_token character varying,
    filename character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    assignable_id bigint,
    assignable_type character varying
);


--
-- Name: passbook_passes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.passbook_passes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: passbook_passes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.passbook_passes_id_seq OWNED BY public.passbook_passes.id;


--
-- Name: passbook_registrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.passbook_registrations (
    id bigint NOT NULL,
    pass_id bigint,
    device_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: passbook_registrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.passbook_registrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: passbook_registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.passbook_registrations_id_seq OWNED BY public.passbook_registrations.id;


--
-- Name: photos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.photos (
    id bigint NOT NULL,
    text text,
    "position" integer,
    gallery_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    image_file_name character varying,
    image_content_type character varying,
    image_file_size bigint,
    image_updated_at timestamp(6) without time zone,
    image_width smallint,
    image_height smallint
);


--
-- Name: photos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.photos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.photos_id_seq OWNED BY public.photos.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: shared_email_account_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shared_email_account_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ticketing_bank_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_bank_submissions (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    ebics_response jsonb
);


--
-- Name: ticketing_bank_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_bank_submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_bank_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_bank_submissions_id_seq OWNED BY public.ticketing_bank_submissions.id;


--
-- Name: ticketing_bank_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_bank_transactions (
    id bigint NOT NULL,
    name character varying,
    iban character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    submission_id bigint,
    amount numeric DEFAULT 0.0 NOT NULL,
    anonymized_at timestamp without time zone,
    camt_source jsonb
);


--
-- Name: ticketing_bank_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_bank_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_bank_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_bank_transactions_id_seq OWNED BY public.ticketing_bank_transactions.id;


--
-- Name: ticketing_bank_transactions_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_bank_transactions_orders (
    bank_transaction_id bigint,
    order_id bigint
);


--
-- Name: ticketing_billing_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_billing_accounts (
    id bigint NOT NULL,
    balance numeric DEFAULT 0.0 NOT NULL,
    billable_type character varying NOT NULL,
    billable_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ticketing_billing_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_billing_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_billing_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_billing_accounts_id_seq OWNED BY public.ticketing_billing_accounts.id;


--
-- Name: ticketing_billing_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_billing_transactions (
    id bigint NOT NULL,
    amount numeric DEFAULT 0.0 NOT NULL,
    note_key character varying,
    account_id bigint NOT NULL,
    participant_id bigint,
    reverse_transaction_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ticketing_billing_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_billing_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_billing_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_billing_transactions_id_seq OWNED BY public.ticketing_billing_transactions.id;


--
-- Name: ticketing_blocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_blocks (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    seating_id bigint DEFAULT 1 NOT NULL,
    entrance character varying
);


--
-- Name: ticketing_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_blocks_id_seq OWNED BY public.ticketing_blocks.id;


--
-- Name: ticketing_box_office_box_offices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_box_office_box_offices (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    tse_client_id character varying
);


--
-- Name: ticketing_box_office_box_offices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_box_office_box_offices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_box_office_box_offices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_box_office_box_offices_id_seq OWNED BY public.ticketing_box_office_box_offices.id;


--
-- Name: ticketing_box_office_checkpoints; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_box_office_checkpoints (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ticketing_box_office_checkpoints_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_box_office_checkpoints_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_box_office_checkpoints_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_box_office_checkpoints_id_seq OWNED BY public.ticketing_box_office_checkpoints.id;


--
-- Name: ticketing_box_office_order_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_box_office_order_payments (
    id bigint NOT NULL,
    amount numeric DEFAULT 0.0 NOT NULL,
    order_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ticketing_box_office_order_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_box_office_order_payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_box_office_order_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_box_office_order_payments_id_seq OWNED BY public.ticketing_box_office_order_payments.id;


--
-- Name: ticketing_box_office_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_box_office_products (
    id bigint NOT NULL,
    name character varying NOT NULL,
    price numeric(8,2) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    vat_rate public.ticketing_vat_rate NOT NULL
);


--
-- Name: ticketing_box_office_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_box_office_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_box_office_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_box_office_products_id_seq OWNED BY public.ticketing_box_office_products.id;


--
-- Name: ticketing_box_office_purchase_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_box_office_purchase_items (
    id bigint NOT NULL,
    purchase_id bigint,
    purchasable_id bigint,
    purchasable_type character varying,
    total double precision,
    number integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ticketing_box_office_purchase_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_box_office_purchase_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_box_office_purchase_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_box_office_purchase_items_id_seq OWNED BY public.ticketing_box_office_purchase_items.id;


--
-- Name: ticketing_box_office_purchases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_box_office_purchases (
    id bigint NOT NULL,
    box_office_id bigint,
    total double precision,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    pay_method character varying,
    tse_info jsonb,
    tse_device_id bigint,
    receipt_token uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: ticketing_box_office_purchases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_box_office_purchases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_box_office_purchases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_box_office_purchases_id_seq OWNED BY public.ticketing_box_office_purchases.id;


--
-- Name: ticketing_cancellations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_cancellations (
    id bigint NOT NULL,
    reason character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ticketing_cancellations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_cancellations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_cancellations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_cancellations_id_seq OWNED BY public.ticketing_cancellations.id;


--
-- Name: ticketing_check_ins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_check_ins (
    id bigint NOT NULL,
    ticket_id bigint,
    checkpoint_id bigint,
    medium public.ticketing_check_in_medium NOT NULL,
    date timestamp without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ticketing_check_ins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_check_ins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_check_ins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_check_ins_id_seq OWNED BY public.ticketing_check_ins.id;


--
-- Name: ticketing_coupon_redemptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_coupon_redemptions (
    id bigint NOT NULL,
    coupon_id bigint NOT NULL,
    order_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ticketing_coupon_redemptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_coupon_redemptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_coupon_redemptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_coupon_redemptions_id_seq OWNED BY public.ticketing_coupon_redemptions.id;


--
-- Name: ticketing_coupons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_coupons (
    id bigint NOT NULL,
    code character varying,
    expires_at timestamp without time zone,
    recipient character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    affiliation character varying,
    purchased_with_order_id bigint,
    value_type public.coupon_value_type NOT NULL
);


--
-- Name: ticketing_coupons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_coupons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_coupons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_coupons_id_seq OWNED BY public.ticketing_coupons.id;


--
-- Name: ticketing_event_dates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_event_dates (
    id bigint NOT NULL,
    date timestamp without time zone,
    event_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    cancellation_id bigint
);


--
-- Name: ticketing_event_dates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_event_dates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_event_dates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_event_dates_id_seq OWNED BY public.ticketing_event_dates.id;


--
-- Name: ticketing_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_events (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    identifier character varying NOT NULL,
    sale_start timestamp without time zone,
    seating_id bigint,
    slug character varying NOT NULL,
    sale_disabled_message character varying,
    assets_identifier character varying NOT NULL,
    admission_duration integer NOT NULL,
    location_id bigint NOT NULL,
    ticketing_enabled boolean DEFAULT true NOT NULL,
    info jsonb DEFAULT '{}'::jsonb NOT NULL,
    number_of_seats integer
);


--
-- Name: ticketing_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_events_id_seq OWNED BY public.ticketing_events.id;


--
-- Name: ticketing_geolocations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_geolocations (
    id bigint NOT NULL,
    coordinates point NOT NULL,
    postcode character varying NOT NULL,
    cities character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    districts character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ticketing_geolocations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_geolocations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_geolocations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_geolocations_id_seq OWNED BY public.ticketing_geolocations.id;


--
-- Name: ticketing_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_locations (
    id bigint NOT NULL,
    name character varying NOT NULL,
    street character varying NOT NULL,
    postcode character varying NOT NULL,
    city character varying NOT NULL,
    coordinates point NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ticketing_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_locations_id_seq OWNED BY public.ticketing_locations.id;


--
-- Name: ticketing_log_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_log_events (
    id bigint NOT NULL,
    action integer NOT NULL,
    user_id bigint,
    loggable_type character varying NOT NULL,
    loggable_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    info jsonb
);


--
-- Name: ticketing_log_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_log_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_log_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_log_events_id_seq OWNED BY public.ticketing_log_events.id;


--
-- Name: ticketing_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_orders (
    id bigint NOT NULL,
    number integer,
    paid boolean DEFAULT false NOT NULL,
    total numeric DEFAULT 0.0 NOT NULL,
    email character varying,
    first_name character varying,
    last_name character varying,
    gender integer,
    phone character varying,
    plz character varying,
    pay_method public.ticketing_pay_method,
    store_id bigint,
    type public.ticketing_order_type,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    box_office_id bigint,
    date_id bigint,
    affiliation character varying,
    anonymized_at timestamp without time zone,
    last_pay_reminder_sent_at timestamp(6) without time zone
);


--
-- Name: ticketing_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_orders_id_seq OWNED BY public.ticketing_orders.id;


--
-- Name: ticketing_push_notifications_web_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_push_notifications_web_subscriptions (
    id bigint NOT NULL,
    endpoint character varying NOT NULL,
    p256dh character varying NOT NULL,
    auth character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: ticketing_push_notifications_web_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_push_notifications_web_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_push_notifications_web_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_push_notifications_web_subscriptions_id_seq OWNED BY public.ticketing_push_notifications_web_subscriptions.id;


--
-- Name: ticketing_reservation_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_reservation_groups (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ticketing_reservation_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_reservation_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_reservation_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_reservation_groups_id_seq OWNED BY public.ticketing_reservation_groups.id;


--
-- Name: ticketing_reservations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_reservations (
    id bigint NOT NULL,
    expires timestamp without time zone,
    date_id bigint,
    seat_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    group_id bigint
);


--
-- Name: ticketing_reservations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_reservations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_reservations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_reservations_id_seq OWNED BY public.ticketing_reservations.id;


--
-- Name: ticketing_retail_stores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_retail_stores (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    sale_enabled boolean DEFAULT false NOT NULL
);


--
-- Name: ticketing_retail_stores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_retail_stores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_retail_stores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_retail_stores_id_seq OWNED BY public.ticketing_retail_stores.id;


--
-- Name: ticketing_seatings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_seatings (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    name character varying,
    plan_file_name character varying,
    plan_content_type character varying,
    plan_file_size bigint,
    plan_updated_at timestamp(6) without time zone
);


--
-- Name: ticketing_seatings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_seatings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_seatings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_seatings_id_seq OWNED BY public.ticketing_seatings.id;


--
-- Name: ticketing_seats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_seats (
    id bigint NOT NULL,
    number integer,
    "row" integer,
    block_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ticketing_seats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_seats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_seats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_seats_id_seq OWNED BY public.ticketing_seats.id;


--
-- Name: ticketing_signing_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_signing_keys (
    id bigint NOT NULL,
    secret character varying(32) DEFAULT ''::character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ticketing_signing_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_signing_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_signing_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_signing_keys_id_seq OWNED BY public.ticketing_signing_keys.id;


--
-- Name: ticketing_stripe_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_stripe_transactions (
    id bigint NOT NULL,
    order_id bigint,
    type public.ticketing_stripe_transaction_type NOT NULL,
    stripe_id character varying NOT NULL,
    amount numeric NOT NULL,
    method public.ticketing_stripe_payment_method,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ticketing_stripe_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_stripe_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_stripe_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_stripe_transactions_id_seq OWNED BY public.ticketing_stripe_transactions.id;


--
-- Name: ticketing_ticket_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_ticket_types (
    id bigint NOT NULL,
    name character varying,
    price numeric DEFAULT 0.0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    info character varying,
    availability public.ticketing_ticket_type_availability DEFAULT 'universal'::public.ticketing_ticket_type_availability,
    event_id bigint,
    vat_rate public.ticketing_vat_rate NOT NULL
);


--
-- Name: ticketing_ticket_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_ticket_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_ticket_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_ticket_types_id_seq OWNED BY public.ticketing_ticket_types.id;


--
-- Name: ticketing_tickets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_tickets (
    id bigint NOT NULL,
    price numeric DEFAULT 0.0 NOT NULL,
    order_id bigint,
    cancellation_id bigint,
    type_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    seat_id bigint,
    date_id bigint,
    picked_up boolean DEFAULT false,
    resale boolean DEFAULT false,
    invalidated boolean DEFAULT false,
    order_index integer DEFAULT 0 NOT NULL,
    exceptionally_customer_cancellable boolean DEFAULT false NOT NULL
);


--
-- Name: ticketing_tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_tickets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_tickets_id_seq OWNED BY public.ticketing_tickets.id;


--
-- Name: ticketing_tse_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_tse_devices (
    id bigint NOT NULL,
    serial_number character varying NOT NULL,
    public_key text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ticketing_tse_devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_tse_devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_tse_devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_tse_devices_id_seq OWNED BY public.ticketing_tse_devices.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying,
    password_digest character varying NOT NULL,
    first_name character varying,
    last_name character varying,
    "group" integer DEFAULT 0,
    last_login timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    birthday date,
    nickname character varying,
    family_id bigint,
    type public.user_type,
    street character varying,
    plz character varying,
    city character varying,
    phone character varying,
    joined_at date,
    sepa_mandate_id bigint,
    number integer,
    membership_fee numeric,
    title character varying,
    membership_fee_paid_until date,
    ticketing_retail_store_id bigint,
    membership_terminates_on date,
    permissions public.permission[],
    shared_email_accounts_authorized_for character varying[],
    gender public.gender,
    membership_fee_payments_paused boolean DEFAULT false NOT NULL,
    webauthn_id character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
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
-- Name: web_authn_credentials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.web_authn_credentials (
    id character varying NOT NULL,
    user_id bigint NOT NULL,
    public_key bytea NOT NULL,
    aaguid character varying,
    sign_count integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: galleries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.galleries ALTER COLUMN id SET DEFAULT nextval('public.galleries_id_seq'::regclass);


--
-- Name: members_exclusive_ticket_type_credit_spendings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_exclusive_ticket_type_credit_spendings ALTER COLUMN id SET DEFAULT nextval('public.members_exclusive_ticket_type_credit_spendings_id_seq'::regclass);


--
-- Name: members_exclusive_ticket_type_credits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_exclusive_ticket_type_credits ALTER COLUMN id SET DEFAULT nextval('public.members_exclusive_ticket_type_credits_id_seq'::regclass);


--
-- Name: members_families id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_families ALTER COLUMN id SET DEFAULT nextval('public.members_families_id_seq'::regclass);


--
-- Name: members_membership_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_membership_applications ALTER COLUMN id SET DEFAULT nextval('public.members_membership_applications_id_seq'::regclass);


--
-- Name: members_membership_fee_debit_submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_membership_fee_debit_submissions ALTER COLUMN id SET DEFAULT nextval('public.members_membership_fee_debit_submissions_id_seq'::regclass);


--
-- Name: members_membership_fee_payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_membership_fee_payments ALTER COLUMN id SET DEFAULT nextval('public.members_membership_fee_payments_id_seq'::regclass);


--
-- Name: members_sepa_mandates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_sepa_mandates ALTER COLUMN id SET DEFAULT nextval('public.members_sepa_mandates_id_seq'::regclass);


--
-- Name: newsletter_images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_images ALTER COLUMN id SET DEFAULT nextval('public.newsletter_images_id_seq'::regclass);


--
-- Name: newsletter_newsletters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_newsletters ALTER COLUMN id SET DEFAULT nextval('public.newsletter_newsletters_id_seq'::regclass);


--
-- Name: newsletter_subscriber_lists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_subscriber_lists ALTER COLUMN id SET DEFAULT nextval('public.newsletter_subscriber_lists_id_seq'::regclass);


--
-- Name: newsletter_subscribers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_subscribers ALTER COLUMN id SET DEFAULT nextval('public.newsletter_subscribers_id_seq'::regclass);


--
-- Name: oauth_access_grants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_grants_id_seq'::regclass);


--
-- Name: oauth_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_tokens_id_seq'::regclass);


--
-- Name: oauth_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications ALTER COLUMN id SET DEFAULT nextval('public.oauth_applications_id_seq'::regclass);


--
-- Name: passbook_devices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passbook_devices ALTER COLUMN id SET DEFAULT nextval('public.passbook_devices_id_seq'::regclass);


--
-- Name: passbook_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passbook_logs ALTER COLUMN id SET DEFAULT nextval('public.passbook_logs_id_seq'::regclass);


--
-- Name: passbook_passes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passbook_passes ALTER COLUMN id SET DEFAULT nextval('public.passbook_passes_id_seq'::regclass);


--
-- Name: passbook_registrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passbook_registrations ALTER COLUMN id SET DEFAULT nextval('public.passbook_registrations_id_seq'::regclass);


--
-- Name: photos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photos ALTER COLUMN id SET DEFAULT nextval('public.photos_id_seq'::regclass);


--
-- Name: ticketing_bank_submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_bank_submissions ALTER COLUMN id SET DEFAULT nextval('public.ticketing_bank_submissions_id_seq'::regclass);


--
-- Name: ticketing_bank_transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_bank_transactions ALTER COLUMN id SET DEFAULT nextval('public.ticketing_bank_transactions_id_seq'::regclass);


--
-- Name: ticketing_billing_accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_billing_accounts ALTER COLUMN id SET DEFAULT nextval('public.ticketing_billing_accounts_id_seq'::regclass);


--
-- Name: ticketing_billing_transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_billing_transactions ALTER COLUMN id SET DEFAULT nextval('public.ticketing_billing_transactions_id_seq'::regclass);


--
-- Name: ticketing_blocks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_blocks ALTER COLUMN id SET DEFAULT nextval('public.ticketing_blocks_id_seq'::regclass);


--
-- Name: ticketing_box_office_box_offices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_box_office_box_offices ALTER COLUMN id SET DEFAULT nextval('public.ticketing_box_office_box_offices_id_seq'::regclass);


--
-- Name: ticketing_box_office_checkpoints id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_box_office_checkpoints ALTER COLUMN id SET DEFAULT nextval('public.ticketing_box_office_checkpoints_id_seq'::regclass);


--
-- Name: ticketing_box_office_order_payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_box_office_order_payments ALTER COLUMN id SET DEFAULT nextval('public.ticketing_box_office_order_payments_id_seq'::regclass);


--
-- Name: ticketing_box_office_products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_box_office_products ALTER COLUMN id SET DEFAULT nextval('public.ticketing_box_office_products_id_seq'::regclass);


--
-- Name: ticketing_box_office_purchase_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_box_office_purchase_items ALTER COLUMN id SET DEFAULT nextval('public.ticketing_box_office_purchase_items_id_seq'::regclass);


--
-- Name: ticketing_box_office_purchases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_box_office_purchases ALTER COLUMN id SET DEFAULT nextval('public.ticketing_box_office_purchases_id_seq'::regclass);


--
-- Name: ticketing_cancellations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_cancellations ALTER COLUMN id SET DEFAULT nextval('public.ticketing_cancellations_id_seq'::regclass);


--
-- Name: ticketing_check_ins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_check_ins ALTER COLUMN id SET DEFAULT nextval('public.ticketing_check_ins_id_seq'::regclass);


--
-- Name: ticketing_coupon_redemptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_coupon_redemptions ALTER COLUMN id SET DEFAULT nextval('public.ticketing_coupon_redemptions_id_seq'::regclass);


--
-- Name: ticketing_coupons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_coupons ALTER COLUMN id SET DEFAULT nextval('public.ticketing_coupons_id_seq'::regclass);


--
-- Name: ticketing_event_dates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_event_dates ALTER COLUMN id SET DEFAULT nextval('public.ticketing_event_dates_id_seq'::regclass);


--
-- Name: ticketing_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_events ALTER COLUMN id SET DEFAULT nextval('public.ticketing_events_id_seq'::regclass);


--
-- Name: ticketing_geolocations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_geolocations ALTER COLUMN id SET DEFAULT nextval('public.ticketing_geolocations_id_seq'::regclass);


--
-- Name: ticketing_locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_locations ALTER COLUMN id SET DEFAULT nextval('public.ticketing_locations_id_seq'::regclass);


--
-- Name: ticketing_log_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_log_events ALTER COLUMN id SET DEFAULT nextval('public.ticketing_log_events_id_seq'::regclass);


--
-- Name: ticketing_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_orders ALTER COLUMN id SET DEFAULT nextval('public.ticketing_orders_id_seq'::regclass);


--
-- Name: ticketing_push_notifications_web_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_push_notifications_web_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.ticketing_push_notifications_web_subscriptions_id_seq'::regclass);


--
-- Name: ticketing_reservation_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_reservation_groups ALTER COLUMN id SET DEFAULT nextval('public.ticketing_reservation_groups_id_seq'::regclass);


--
-- Name: ticketing_reservations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_reservations ALTER COLUMN id SET DEFAULT nextval('public.ticketing_reservations_id_seq'::regclass);


--
-- Name: ticketing_retail_stores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_retail_stores ALTER COLUMN id SET DEFAULT nextval('public.ticketing_retail_stores_id_seq'::regclass);


--
-- Name: ticketing_seatings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_seatings ALTER COLUMN id SET DEFAULT nextval('public.ticketing_seatings_id_seq'::regclass);


--
-- Name: ticketing_seats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_seats ALTER COLUMN id SET DEFAULT nextval('public.ticketing_seats_id_seq'::regclass);


--
-- Name: ticketing_signing_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_signing_keys ALTER COLUMN id SET DEFAULT nextval('public.ticketing_signing_keys_id_seq'::regclass);


--
-- Name: ticketing_stripe_transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_stripe_transactions ALTER COLUMN id SET DEFAULT nextval('public.ticketing_stripe_transactions_id_seq'::regclass);


--
-- Name: ticketing_ticket_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_ticket_types ALTER COLUMN id SET DEFAULT nextval('public.ticketing_ticket_types_id_seq'::regclass);


--
-- Name: ticketing_tickets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_tickets ALTER COLUMN id SET DEFAULT nextval('public.ticketing_tickets_id_seq'::regclass);


--
-- Name: ticketing_tse_devices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_tse_devices ALTER COLUMN id SET DEFAULT nextval('public.ticketing_tse_devices_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: galleries galleries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.galleries
    ADD CONSTRAINT galleries_pkey PRIMARY KEY (id);


--
-- Name: members_exclusive_ticket_type_credit_spendings members_exclusive_ticket_type_credit_spendings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_exclusive_ticket_type_credit_spendings
    ADD CONSTRAINT members_exclusive_ticket_type_credit_spendings_pkey PRIMARY KEY (id);


--
-- Name: members_exclusive_ticket_type_credits members_exclusive_ticket_type_credits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_exclusive_ticket_type_credits
    ADD CONSTRAINT members_exclusive_ticket_type_credits_pkey PRIMARY KEY (id);


--
-- Name: members_families members_families_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_families
    ADD CONSTRAINT members_families_pkey PRIMARY KEY (id);


--
-- Name: members_membership_applications members_membership_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_membership_applications
    ADD CONSTRAINT members_membership_applications_pkey PRIMARY KEY (id);


--
-- Name: members_membership_fee_debit_submissions members_membership_fee_debit_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_membership_fee_debit_submissions
    ADD CONSTRAINT members_membership_fee_debit_submissions_pkey PRIMARY KEY (id);


--
-- Name: members_membership_fee_payments members_membership_fee_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_membership_fee_payments
    ADD CONSTRAINT members_membership_fee_payments_pkey PRIMARY KEY (id);


--
-- Name: members_sepa_mandates members_sepa_mandates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_sepa_mandates
    ADD CONSTRAINT members_sepa_mandates_pkey PRIMARY KEY (id);


--
-- Name: newsletter_images newsletter_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_images
    ADD CONSTRAINT newsletter_images_pkey PRIMARY KEY (id);


--
-- Name: newsletter_newsletters newsletter_newsletters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_newsletters
    ADD CONSTRAINT newsletter_newsletters_pkey PRIMARY KEY (id);


--
-- Name: newsletter_subscriber_lists newsletter_subscriber_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_subscriber_lists
    ADD CONSTRAINT newsletter_subscriber_lists_pkey PRIMARY KEY (id);


--
-- Name: newsletter_subscribers newsletter_subscribers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_subscribers
    ADD CONSTRAINT newsletter_subscribers_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: passbook_devices passbook_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passbook_devices
    ADD CONSTRAINT passbook_devices_pkey PRIMARY KEY (id);


--
-- Name: passbook_logs passbook_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passbook_logs
    ADD CONSTRAINT passbook_logs_pkey PRIMARY KEY (id);


--
-- Name: passbook_passes passbook_passes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passbook_passes
    ADD CONSTRAINT passbook_passes_pkey PRIMARY KEY (id);


--
-- Name: passbook_registrations passbook_registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passbook_registrations
    ADD CONSTRAINT passbook_registrations_pkey PRIMARY KEY (id);


--
-- Name: photos photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photos
    ADD CONSTRAINT photos_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: shared_email_account_tokens shared_email_account_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shared_email_account_tokens
    ADD CONSTRAINT shared_email_account_tokens_pkey PRIMARY KEY (id);


--
-- Name: ticketing_bank_submissions ticketing_bank_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_bank_submissions
    ADD CONSTRAINT ticketing_bank_submissions_pkey PRIMARY KEY (id);


--
-- Name: ticketing_bank_transactions ticketing_bank_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_bank_transactions
    ADD CONSTRAINT ticketing_bank_transactions_pkey PRIMARY KEY (id);


--
-- Name: ticketing_billing_accounts ticketing_billing_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_billing_accounts
    ADD CONSTRAINT ticketing_billing_accounts_pkey PRIMARY KEY (id);


--
-- Name: ticketing_billing_transactions ticketing_billing_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_billing_transactions
    ADD CONSTRAINT ticketing_billing_transactions_pkey PRIMARY KEY (id);


--
-- Name: ticketing_blocks ticketing_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_blocks
    ADD CONSTRAINT ticketing_blocks_pkey PRIMARY KEY (id);


--
-- Name: ticketing_box_office_box_offices ticketing_box_office_box_offices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_box_office_box_offices
    ADD CONSTRAINT ticketing_box_office_box_offices_pkey PRIMARY KEY (id);


--
-- Name: ticketing_box_office_checkpoints ticketing_box_office_checkpoints_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_box_office_checkpoints
    ADD CONSTRAINT ticketing_box_office_checkpoints_pkey PRIMARY KEY (id);


--
-- Name: ticketing_box_office_order_payments ticketing_box_office_order_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_box_office_order_payments
    ADD CONSTRAINT ticketing_box_office_order_payments_pkey PRIMARY KEY (id);


--
-- Name: ticketing_box_office_products ticketing_box_office_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_box_office_products
    ADD CONSTRAINT ticketing_box_office_products_pkey PRIMARY KEY (id);


--
-- Name: ticketing_box_office_purchase_items ticketing_box_office_purchase_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_box_office_purchase_items
    ADD CONSTRAINT ticketing_box_office_purchase_items_pkey PRIMARY KEY (id);


--
-- Name: ticketing_box_office_purchases ticketing_box_office_purchases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_box_office_purchases
    ADD CONSTRAINT ticketing_box_office_purchases_pkey PRIMARY KEY (id);


--
-- Name: ticketing_cancellations ticketing_cancellations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_cancellations
    ADD CONSTRAINT ticketing_cancellations_pkey PRIMARY KEY (id);


--
-- Name: ticketing_check_ins ticketing_check_ins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_check_ins
    ADD CONSTRAINT ticketing_check_ins_pkey PRIMARY KEY (id);


--
-- Name: ticketing_coupon_redemptions ticketing_coupon_redemptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_coupon_redemptions
    ADD CONSTRAINT ticketing_coupon_redemptions_pkey PRIMARY KEY (id);


--
-- Name: ticketing_coupons ticketing_coupons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_coupons
    ADD CONSTRAINT ticketing_coupons_pkey PRIMARY KEY (id);


--
-- Name: ticketing_event_dates ticketing_event_dates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_event_dates
    ADD CONSTRAINT ticketing_event_dates_pkey PRIMARY KEY (id);


--
-- Name: ticketing_events ticketing_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_events
    ADD CONSTRAINT ticketing_events_pkey PRIMARY KEY (id);


--
-- Name: ticketing_geolocations ticketing_geolocations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_geolocations
    ADD CONSTRAINT ticketing_geolocations_pkey PRIMARY KEY (id);


--
-- Name: ticketing_locations ticketing_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_locations
    ADD CONSTRAINT ticketing_locations_pkey PRIMARY KEY (id);


--
-- Name: ticketing_log_events ticketing_log_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_log_events
    ADD CONSTRAINT ticketing_log_events_pkey PRIMARY KEY (id);


--
-- Name: ticketing_orders ticketing_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_orders
    ADD CONSTRAINT ticketing_orders_pkey PRIMARY KEY (id);


--
-- Name: ticketing_push_notifications_web_subscriptions ticketing_push_notifications_web_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_push_notifications_web_subscriptions
    ADD CONSTRAINT ticketing_push_notifications_web_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: ticketing_reservation_groups ticketing_reservation_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_reservation_groups
    ADD CONSTRAINT ticketing_reservation_groups_pkey PRIMARY KEY (id);


--
-- Name: ticketing_reservations ticketing_reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_reservations
    ADD CONSTRAINT ticketing_reservations_pkey PRIMARY KEY (id);


--
-- Name: ticketing_retail_stores ticketing_retail_stores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_retail_stores
    ADD CONSTRAINT ticketing_retail_stores_pkey PRIMARY KEY (id);


--
-- Name: ticketing_seatings ticketing_seatings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_seatings
    ADD CONSTRAINT ticketing_seatings_pkey PRIMARY KEY (id);


--
-- Name: ticketing_seats ticketing_seats_number_uniqueness; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_seats
    ADD CONSTRAINT ticketing_seats_number_uniqueness UNIQUE (block_id, number) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: ticketing_seats ticketing_seats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_seats
    ADD CONSTRAINT ticketing_seats_pkey PRIMARY KEY (id);


--
-- Name: ticketing_signing_keys ticketing_signing_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_signing_keys
    ADD CONSTRAINT ticketing_signing_keys_pkey PRIMARY KEY (id);


--
-- Name: ticketing_stripe_transactions ticketing_stripe_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_stripe_transactions
    ADD CONSTRAINT ticketing_stripe_transactions_pkey PRIMARY KEY (id);


--
-- Name: ticketing_ticket_types ticketing_ticket_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_ticket_types
    ADD CONSTRAINT ticketing_ticket_types_pkey PRIMARY KEY (id);


--
-- Name: ticketing_tickets ticketing_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_tickets
    ADD CONSTRAINT ticketing_tickets_pkey PRIMARY KEY (id);


--
-- Name: ticketing_tse_devices ticketing_tse_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_tse_devices
    ADD CONSTRAINT ticketing_tse_devices_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: web_authn_credentials web_authn_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_authn_credentials
    ADD CONSTRAINT web_authn_credentials_pkey PRIMARY KEY (id);


--
-- Name: idx_on_bank_transaction_id_f424773570; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_bank_transaction_id_f424773570 ON public.ticketing_bank_transactions_orders USING btree (bank_transaction_id);


--
-- Name: idx_on_order_id_bank_transaction_id_3b510bd977; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_order_id_bank_transaction_id_3b510bd977 ON public.ticketing_bank_transactions_orders USING btree (order_id, bank_transaction_id);


--
-- Name: index_billing_acounts_on_id_and_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billing_acounts_on_id_and_type ON public.ticketing_billing_accounts USING btree (billable_type, billable_id);


--
-- Name: index_members_exclusive_ticket_type_credit_spndngs_on_member; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_members_exclusive_ticket_type_credit_spndngs_on_member ON public.members_exclusive_ticket_type_credit_spendings USING btree (member_id);


--
-- Name: index_members_exclusive_ticket_type_credit_spndngs_on_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_members_exclusive_ticket_type_credit_spndngs_on_order ON public.members_exclusive_ticket_type_credit_spendings USING btree (order_id);


--
-- Name: index_members_exclusive_ticket_type_credit_spndngs_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_members_exclusive_ticket_type_credit_spndngs_on_type ON public.members_exclusive_ticket_type_credit_spendings USING btree (ticket_type_id);


--
-- Name: index_members_exclusive_ticket_type_credits_on_ticket_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_members_exclusive_ticket_type_credits_on_ticket_type_id ON public.members_exclusive_ticket_type_credits USING btree (ticket_type_id);


--
-- Name: index_members_membership_applications_on_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_members_membership_applications_on_member_id ON public.members_membership_applications USING btree (member_id);


--
-- Name: index_members_membership_fee_payments_on_debit_submission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_members_membership_fee_payments_on_debit_submission_id ON public.members_membership_fee_payments USING btree (debit_submission_id);


--
-- Name: index_members_membership_fee_payments_on_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_members_membership_fee_payments_on_member_id ON public.members_membership_fee_payments USING btree (member_id);


--
-- Name: index_newsletter_images_on_newsletter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_newsletter_images_on_newsletter_id ON public.newsletter_images USING btree (newsletter_id);


--
-- Name: index_newsletter_newsletters_subscriber_lists_on_letter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_newsletter_newsletters_subscriber_lists_on_letter_id ON public.newsletter_newsletters_subscriber_lists USING btree (newsletter_id);


--
-- Name: index_newsletter_newsletters_subscriber_lists_on_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_newsletter_newsletters_subscriber_lists_on_list_id ON public.newsletter_newsletters_subscriber_lists USING btree (subscriber_list_id);


--
-- Name: index_newsletter_subscribers_on_lower_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_newsletter_subscribers_on_lower_email ON public.newsletter_subscribers USING btree (lower((email)::text));


--
-- Name: index_newsletter_subscribers_on_subscriber_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_newsletter_subscribers_on_subscriber_list_id ON public.newsletter_subscribers USING btree (subscriber_list_id);


--
-- Name: index_newsletter_subscribers_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_newsletter_subscribers_on_token ON public.newsletter_subscribers USING btree (token);


--
-- Name: index_oauth_access_grants_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_application_id ON public.oauth_access_grants USING btree (application_id);


--
-- Name: index_oauth_access_grants_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_resource_owner_id ON public.oauth_access_grants USING btree (resource_owner_id);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON public.oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_application_id ON public.oauth_access_tokens USING btree (application_id);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON public.oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON public.oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON public.oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON public.oauth_applications USING btree (uid);


--
-- Name: index_passbook_devices_on_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_passbook_devices_on_device_id ON public.passbook_devices USING btree (device_id);


--
-- Name: index_passbook_passes_on_assignable_id_and_assignable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_passbook_passes_on_assignable_id_and_assignable_type ON public.passbook_passes USING btree (assignable_id, assignable_type);


--
-- Name: index_passbook_passes_on_type_id_and_serial_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_passbook_passes_on_type_id_and_serial_number ON public.passbook_passes USING btree (type_id, serial_number);


--
-- Name: index_passbook_registrations_on_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_passbook_registrations_on_device_id ON public.passbook_registrations USING btree (device_id);


--
-- Name: index_passbook_registrations_on_pass_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_passbook_registrations_on_pass_id ON public.passbook_registrations USING btree (pass_id);


--
-- Name: index_photos_on_gallery_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_photos_on_gallery_id ON public.photos USING btree (gallery_id);


--
-- Name: index_ticketing_bank_transactions_on_camt_source_AcctSvcrRef; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "index_ticketing_bank_transactions_on_camt_source_AcctSvcrRef" ON public.ticketing_bank_transactions USING btree (((camt_source ->> 'AcctSvcrRef'::text)));


--
-- Name: index_ticketing_bank_transactions_on_submission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_bank_transactions_on_submission_id ON public.ticketing_bank_transactions USING btree (submission_id);


--
-- Name: index_ticketing_bank_transactions_orders_on_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_bank_transactions_orders_on_order_id ON public.ticketing_bank_transactions_orders USING btree (order_id);


--
-- Name: index_ticketing_billing_transactions_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_billing_transactions_on_account_id ON public.ticketing_billing_transactions USING btree (account_id);


--
-- Name: index_ticketing_billing_transactions_on_participant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_billing_transactions_on_participant_id ON public.ticketing_billing_transactions USING btree (participant_id);


--
-- Name: index_ticketing_billing_transactions_on_reverse_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_billing_transactions_on_reverse_transaction_id ON public.ticketing_billing_transactions USING btree (reverse_transaction_id);


--
-- Name: index_ticketing_blocks_on_seating_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_blocks_on_seating_id ON public.ticketing_blocks USING btree (seating_id);


--
-- Name: index_ticketing_box_office_box_offices_on_tse_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticketing_box_office_box_offices_on_tse_client_id ON public.ticketing_box_office_box_offices USING btree (tse_client_id);


--
-- Name: index_ticketing_box_office_order_payments_on_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_box_office_order_payments_on_order_id ON public.ticketing_box_office_order_payments USING btree (order_id);


--
-- Name: index_ticketing_box_office_purchase_items_on_purchasable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_box_office_purchase_items_on_purchasable ON public.ticketing_box_office_purchase_items USING btree (purchasable_id, purchasable_type);


--
-- Name: index_ticketing_box_office_purchase_items_on_purchase_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_box_office_purchase_items_on_purchase_id ON public.ticketing_box_office_purchase_items USING btree (purchase_id);


--
-- Name: index_ticketing_box_office_purchases_on_box_office_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_box_office_purchases_on_box_office_id ON public.ticketing_box_office_purchases USING btree (box_office_id);


--
-- Name: index_ticketing_box_office_purchases_on_receipt_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_box_office_purchases_on_receipt_token ON public.ticketing_box_office_purchases USING btree (receipt_token);


--
-- Name: index_ticketing_box_office_purchases_on_tse_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_box_office_purchases_on_tse_device_id ON public.ticketing_box_office_purchases USING btree (tse_device_id);


--
-- Name: index_ticketing_check_ins_on_checkpoint_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_check_ins_on_checkpoint_id ON public.ticketing_check_ins USING btree (checkpoint_id);


--
-- Name: index_ticketing_check_ins_on_medium; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_check_ins_on_medium ON public.ticketing_check_ins USING btree (medium);


--
-- Name: index_ticketing_check_ins_on_ticket_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_check_ins_on_ticket_id ON public.ticketing_check_ins USING btree (ticket_id);


--
-- Name: index_ticketing_coupon_redemptions_on_coupon_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_coupon_redemptions_on_coupon_id ON public.ticketing_coupon_redemptions USING btree (coupon_id);


--
-- Name: index_ticketing_coupon_redemptions_on_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_coupon_redemptions_on_order_id ON public.ticketing_coupon_redemptions USING btree (order_id);


--
-- Name: index_ticketing_coupons_on_purchased_with_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_coupons_on_purchased_with_order_id ON public.ticketing_coupons USING btree (purchased_with_order_id);


--
-- Name: index_ticketing_event_dates_on_cancellation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_event_dates_on_cancellation_id ON public.ticketing_event_dates USING btree (cancellation_id);


--
-- Name: index_ticketing_event_dates_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_event_dates_on_event_id ON public.ticketing_event_dates USING btree (event_id);


--
-- Name: index_ticketing_events_on_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticketing_events_on_identifier ON public.ticketing_events USING btree (identifier);


--
-- Name: index_ticketing_events_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_events_on_location_id ON public.ticketing_events USING btree (location_id);


--
-- Name: index_ticketing_events_on_seating_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_events_on_seating_id ON public.ticketing_events USING btree (seating_id);


--
-- Name: index_ticketing_events_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticketing_events_on_slug ON public.ticketing_events USING btree (slug);


--
-- Name: index_ticketing_events_on_ticketing_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_events_on_ticketing_enabled ON public.ticketing_events USING btree (ticketing_enabled);


--
-- Name: index_ticketing_geolocations_on_postcode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_geolocations_on_postcode ON public.ticketing_geolocations USING btree (postcode);


--
-- Name: index_ticketing_log_events_on_loggable_id_and_loggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_log_events_on_loggable_id_and_loggable_type ON public.ticketing_log_events USING btree (loggable_id, loggable_type);


--
-- Name: index_ticketing_log_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_log_events_on_user_id ON public.ticketing_log_events USING btree (user_id);


--
-- Name: index_ticketing_orders_on_box_office_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_orders_on_box_office_id ON public.ticketing_orders USING btree (box_office_id);


--
-- Name: index_ticketing_orders_on_date_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_orders_on_date_id ON public.ticketing_orders USING btree (date_id);


--
-- Name: index_ticketing_orders_on_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticketing_orders_on_number ON public.ticketing_orders USING btree (number);


--
-- Name: index_ticketing_orders_on_paid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_orders_on_paid ON public.ticketing_orders USING btree (paid);


--
-- Name: index_ticketing_orders_on_store_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_orders_on_store_id ON public.ticketing_orders USING btree (store_id);


--
-- Name: index_ticketing_orders_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_orders_on_type ON public.ticketing_orders USING btree (type);


--
-- Name: index_ticketing_push_notifications_web_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_push_notifications_web_subscriptions_on_user_id ON public.ticketing_push_notifications_web_subscriptions USING btree (user_id);


--
-- Name: index_ticketing_reservations_on_date_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_reservations_on_date_id ON public.ticketing_reservations USING btree (date_id);


--
-- Name: index_ticketing_reservations_on_date_id_and_seat_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_reservations_on_date_id_and_seat_id ON public.ticketing_reservations USING btree (date_id, seat_id);


--
-- Name: index_ticketing_reservations_on_date_seat_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticketing_reservations_on_date_seat_group_id ON public.ticketing_reservations USING btree (date_id, seat_id, group_id);


--
-- Name: index_ticketing_reservations_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_reservations_on_group_id ON public.ticketing_reservations USING btree (group_id);


--
-- Name: index_ticketing_reservations_on_seat_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_reservations_on_seat_id ON public.ticketing_reservations USING btree (seat_id);


--
-- Name: index_ticketing_seats_on_block_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_seats_on_block_id ON public.ticketing_seats USING btree (block_id);


--
-- Name: index_ticketing_signing_keys_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_signing_keys_on_active ON public.ticketing_signing_keys USING btree (active);


--
-- Name: index_ticketing_stripe_transactions_on_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_stripe_transactions_on_order_id ON public.ticketing_stripe_transactions USING btree (order_id);


--
-- Name: index_ticketing_ticket_types_on_availability; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_ticket_types_on_availability ON public.ticketing_ticket_types USING btree (availability);


--
-- Name: index_ticketing_ticket_types_on_availability_and_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_ticket_types_on_availability_and_event_id ON public.ticketing_ticket_types USING btree (availability, event_id);


--
-- Name: index_ticketing_ticket_types_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_ticket_types_on_event_id ON public.ticketing_ticket_types USING btree (event_id);


--
-- Name: index_ticketing_tickets_on_date_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_tickets_on_date_id ON public.ticketing_tickets USING btree (date_id);


--
-- Name: index_ticketing_tickets_on_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_tickets_on_order_id ON public.ticketing_tickets USING btree (order_id);


--
-- Name: index_ticketing_tickets_on_order_id_and_order_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticketing_tickets_on_order_id_and_order_index ON public.ticketing_tickets USING btree (order_id, order_index);


--
-- Name: index_ticketing_tickets_on_seat_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_tickets_on_seat_id ON public.ticketing_tickets USING btree (seat_id);


--
-- Name: index_ticketing_tickets_on_seat_id_and_date_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_tickets_on_seat_id_and_date_id ON public.ticketing_tickets USING btree (seat_id, date_id);


--
-- Name: index_ticketing_tickets_on_seat_id_and_date_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticketing_tickets_on_seat_id_and_date_id_unique ON public.ticketing_tickets USING btree (seat_id, date_id) WHERE (NOT invalidated);


--
-- Name: index_ticketing_tickets_on_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_tickets_on_type_id ON public.ticketing_tickets USING btree (type_id);


--
-- Name: index_ticketing_tse_devices_on_serial_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticketing_tse_devices_on_serial_number ON public.ticketing_tse_devices USING btree (serial_number);


--
-- Name: index_users_on_family_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_family_id ON public.users USING btree (family_id);


--
-- Name: index_users_on_lower_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_lower_email ON public.users USING btree (lower((email)::text));


--
-- Name: index_users_on_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_number ON public.users USING btree (number);


--
-- Name: index_users_on_sepa_mandate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_sepa_mandate_id ON public.users USING btree (sepa_mandate_id);


--
-- Name: index_users_on_ticketing_retail_store_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_ticketing_retail_store_id ON public.users USING btree (ticketing_retail_store_id);


--
-- Name: index_users_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_type ON public.users USING btree (type);


--
-- Name: index_web_authn_credentials_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_web_authn_credentials_on_user_id ON public.web_authn_credentials USING btree (user_id);


--
-- Name: newsletter_images fk_rails_038053fe4b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_images
    ADD CONSTRAINT fk_rails_038053fe4b FOREIGN KEY (newsletter_id) REFERENCES public.newsletter_newsletters(id);


--
-- Name: ticketing_billing_transactions fk_rails_071c9c9aef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_billing_transactions
    ADD CONSTRAINT fk_rails_071c9c9aef FOREIGN KEY (participant_id) REFERENCES public.ticketing_billing_accounts(id);


--
-- Name: ticketing_tickets fk_rails_07949eb95a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_tickets
    ADD CONSTRAINT fk_rails_07949eb95a FOREIGN KEY (order_id) REFERENCES public.ticketing_orders(id);


--
-- Name: ticketing_reservations fk_rails_09a15f85eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_reservations
    ADD CONSTRAINT fk_rails_09a15f85eb FOREIGN KEY (date_id) REFERENCES public.ticketing_event_dates(id);


--
-- Name: ticketing_seats fk_rails_0cf00b9300; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_seats
    ADD CONSTRAINT fk_rails_0cf00b9300 FOREIGN KEY (block_id) REFERENCES public.ticketing_blocks(id);


--
-- Name: ticketing_box_office_order_payments fk_rails_12b50a5dac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_box_office_order_payments
    ADD CONSTRAINT fk_rails_12b50a5dac FOREIGN KEY (order_id) REFERENCES public.ticketing_orders(id);


--
-- Name: ticketing_billing_transactions fk_rails_17a5504e18; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_billing_transactions
    ADD CONSTRAINT fk_rails_17a5504e18 FOREIGN KEY (account_id) REFERENCES public.ticketing_billing_accounts(id);


--
-- Name: users fk_rails_19e933b1d8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_19e933b1d8 FOREIGN KEY (sepa_mandate_id) REFERENCES public.members_sepa_mandates(id);


--
-- Name: ticketing_blocks fk_rails_2112d99715; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_blocks
    ADD CONSTRAINT fk_rails_2112d99715 FOREIGN KEY (seating_id) REFERENCES public.ticketing_seatings(id);


--
-- Name: ticketing_orders fk_rails_23af722925; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_orders
    ADD CONSTRAINT fk_rails_23af722925 FOREIGN KEY (store_id) REFERENCES public.ticketing_retail_stores(id);


--
-- Name: ticketing_coupon_redemptions fk_rails_2a116592a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_coupon_redemptions
    ADD CONSTRAINT fk_rails_2a116592a3 FOREIGN KEY (order_id) REFERENCES public.ticketing_orders(id);


--
-- Name: ticketing_event_dates fk_rails_2d70980864; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_event_dates
    ADD CONSTRAINT fk_rails_2d70980864 FOREIGN KEY (event_id) REFERENCES public.ticketing_events(id);


--
-- Name: photos fk_rails_2e5d9f85e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photos
    ADD CONSTRAINT fk_rails_2e5d9f85e5 FOREIGN KEY (gallery_id) REFERENCES public.galleries(id);


--
-- Name: ticketing_coupon_redemptions fk_rails_2fe1e89c78; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_coupon_redemptions
    ADD CONSTRAINT fk_rails_2fe1e89c78 FOREIGN KEY (coupon_id) REFERENCES public.ticketing_coupons(id);


--
-- Name: passbook_registrations fk_rails_309b53ad35; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passbook_registrations
    ADD CONSTRAINT fk_rails_309b53ad35 FOREIGN KEY (pass_id) REFERENCES public.passbook_passes(id);


--
-- Name: oauth_access_grants fk_rails_330c32d8d9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_rails_330c32d8d9 FOREIGN KEY (resource_owner_id) REFERENCES public.users(id);


--
-- Name: ticketing_tickets fk_rails_350e062b4f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_tickets
    ADD CONSTRAINT fk_rails_350e062b4f FOREIGN KEY (seat_id) REFERENCES public.ticketing_seats(id);


--
-- Name: members_exclusive_ticket_type_credits fk_rails_3e7429e082; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_exclusive_ticket_type_credits
    ADD CONSTRAINT fk_rails_3e7429e082 FOREIGN KEY (ticket_type_id) REFERENCES public.ticketing_ticket_types(id);


--
-- Name: users fk_rails_3f109a998e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_3f109a998e FOREIGN KEY (ticketing_retail_store_id) REFERENCES public.ticketing_retail_stores(id);


--
-- Name: ticketing_billing_transactions fk_rails_50c9e4ab50; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_billing_transactions
    ADD CONSTRAINT fk_rails_50c9e4ab50 FOREIGN KEY (reverse_transaction_id) REFERENCES public.ticketing_billing_transactions(id);


--
-- Name: members_membership_fee_payments fk_rails_55946908e0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_membership_fee_payments
    ADD CONSTRAINT fk_rails_55946908e0 FOREIGN KEY (member_id) REFERENCES public.users(id);


--
-- Name: ticketing_reservations fk_rails_5bb0448e6a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_reservations
    ADD CONSTRAINT fk_rails_5bb0448e6a FOREIGN KEY (seat_id) REFERENCES public.ticketing_seats(id);


--
-- Name: newsletter_newsletters_subscriber_lists fk_rails_601a027ad9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_newsletters_subscriber_lists
    ADD CONSTRAINT fk_rails_601a027ad9 FOREIGN KEY (subscriber_list_id) REFERENCES public.newsletter_subscriber_lists(id);


--
-- Name: ticketing_coupons fk_rails_60a997c6d1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_coupons
    ADD CONSTRAINT fk_rails_60a997c6d1 FOREIGN KEY (purchased_with_order_id) REFERENCES public.ticketing_orders(id);


--
-- Name: ticketing_stripe_transactions fk_rails_60cdbbba1f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_stripe_transactions
    ADD CONSTRAINT fk_rails_60cdbbba1f FOREIGN KEY (order_id) REFERENCES public.ticketing_orders(id);


--
-- Name: ticketing_tickets fk_rails_61a0f2a65f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_tickets
    ADD CONSTRAINT fk_rails_61a0f2a65f FOREIGN KEY (cancellation_id) REFERENCES public.ticketing_cancellations(id);


--
-- Name: ticketing_log_events fk_rails_66b7b3cc72; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_log_events
    ADD CONSTRAINT fk_rails_66b7b3cc72 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ticketing_bank_transactions_orders fk_rails_67f7ebba22; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_bank_transactions_orders
    ADD CONSTRAINT fk_rails_67f7ebba22 FOREIGN KEY (order_id) REFERENCES public.ticketing_orders(id);


--
-- Name: ticketing_bank_transactions fk_rails_684a6280d2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_bank_transactions
    ADD CONSTRAINT fk_rails_684a6280d2 FOREIGN KEY (submission_id) REFERENCES public.ticketing_bank_submissions(id);


--
-- Name: ticketing_box_office_purchases fk_rails_704ee856cc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_box_office_purchases
    ADD CONSTRAINT fk_rails_704ee856cc FOREIGN KEY (tse_device_id) REFERENCES public.ticketing_tse_devices(id);


--
-- Name: passbook_registrations fk_rails_7231cc423e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passbook_registrations
    ADD CONSTRAINT fk_rails_7231cc423e FOREIGN KEY (device_id) REFERENCES public.passbook_devices(id);


--
-- Name: oauth_access_tokens fk_rails_732cb83ab7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_rails_732cb83ab7 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: members_membership_applications fk_rails_74f91f8594; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_membership_applications
    ADD CONSTRAINT fk_rails_74f91f8594 FOREIGN KEY (member_id) REFERENCES public.users(id);


--
-- Name: users fk_rails_87dbf420c1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_87dbf420c1 FOREIGN KEY (family_id) REFERENCES public.members_families(id);


--
-- Name: ticketing_reservations fk_rails_8d62c0ae66; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_reservations
    ADD CONSTRAINT fk_rails_8d62c0ae66 FOREIGN KEY (group_id) REFERENCES public.ticketing_reservation_groups(id);


--
-- Name: newsletter_subscribers fk_rails_90e3bf0a5f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_subscribers
    ADD CONSTRAINT fk_rails_90e3bf0a5f FOREIGN KEY (subscriber_list_id) REFERENCES public.newsletter_subscriber_lists(id);


--
-- Name: newsletter_newsletters_subscriber_lists fk_rails_985b265b1c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_newsletters_subscriber_lists
    ADD CONSTRAINT fk_rails_985b265b1c FOREIGN KEY (newsletter_id) REFERENCES public.newsletter_newsletters(id);


--
-- Name: ticketing_orders fk_rails_9b78da5a2e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_orders
    ADD CONSTRAINT fk_rails_9b78da5a2e FOREIGN KEY (date_id) REFERENCES public.ticketing_event_dates(id);


--
-- Name: members_exclusive_ticket_type_credit_spendings fk_rails_a1412571c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_exclusive_ticket_type_credit_spendings
    ADD CONSTRAINT fk_rails_a1412571c0 FOREIGN KEY (ticket_type_id) REFERENCES public.ticketing_ticket_types(id);


--
-- Name: ticketing_tickets fk_rails_a1c4e34d0c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_tickets
    ADD CONSTRAINT fk_rails_a1c4e34d0c FOREIGN KEY (type_id) REFERENCES public.ticketing_ticket_types(id);


--
-- Name: ticketing_events fk_rails_a8bcf8f505; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_events
    ADD CONSTRAINT fk_rails_a8bcf8f505 FOREIGN KEY (seating_id) REFERENCES public.ticketing_seatings(id);


--
-- Name: ticketing_box_office_purchases fk_rails_aaed8504ca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_box_office_purchases
    ADD CONSTRAINT fk_rails_aaed8504ca FOREIGN KEY (box_office_id) REFERENCES public.ticketing_box_office_box_offices(id);


--
-- Name: oauth_access_grants fk_rails_b4b53e07b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_rails_b4b53e07b8 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: ticketing_check_ins fk_rails_b90de633b4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_check_ins
    ADD CONSTRAINT fk_rails_b90de633b4 FOREIGN KEY (checkpoint_id) REFERENCES public.ticketing_box_office_checkpoints(id);


--
-- Name: members_membership_fee_payments fk_rails_c286dafae5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_membership_fee_payments
    ADD CONSTRAINT fk_rails_c286dafae5 FOREIGN KEY (debit_submission_id) REFERENCES public.members_membership_fee_debit_submissions(id);


--
-- Name: ticketing_events fk_rails_c3b480c2c6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_events
    ADD CONSTRAINT fk_rails_c3b480c2c6 FOREIGN KEY (location_id) REFERENCES public.ticketing_locations(id);


--
-- Name: members_exclusive_ticket_type_credit_spendings fk_rails_c6eb01b535; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_exclusive_ticket_type_credit_spendings
    ADD CONSTRAINT fk_rails_c6eb01b535 FOREIGN KEY (member_id) REFERENCES public.users(id);


--
-- Name: ticketing_push_notifications_web_subscriptions fk_rails_d59495030f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_push_notifications_web_subscriptions
    ADD CONSTRAINT fk_rails_d59495030f FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ticketing_box_office_purchase_items fk_rails_d8c37e6117; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_box_office_purchase_items
    ADD CONSTRAINT fk_rails_d8c37e6117 FOREIGN KEY (purchase_id) REFERENCES public.ticketing_box_office_purchases(id);


--
-- Name: ticketing_ticket_types fk_rails_dd05fc3c95; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_ticket_types
    ADD CONSTRAINT fk_rails_dd05fc3c95 FOREIGN KEY (event_id) REFERENCES public.ticketing_events(id);


--
-- Name: ticketing_tickets fk_rails_df38ae1276; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_tickets
    ADD CONSTRAINT fk_rails_df38ae1276 FOREIGN KEY (date_id) REFERENCES public.ticketing_event_dates(id);


--
-- Name: ticketing_bank_transactions_orders fk_rails_df673aff4d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_bank_transactions_orders
    ADD CONSTRAINT fk_rails_df673aff4d FOREIGN KEY (bank_transaction_id) REFERENCES public.ticketing_bank_transactions(id);


--
-- Name: ticketing_orders fk_rails_dfaebcd775; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_orders
    ADD CONSTRAINT fk_rails_dfaebcd775 FOREIGN KEY (box_office_id) REFERENCES public.ticketing_box_office_box_offices(id);


--
-- Name: web_authn_credentials fk_rails_e4426b25a8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_authn_credentials
    ADD CONSTRAINT fk_rails_e4426b25a8 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ticketing_check_ins fk_rails_e666ea82e7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_check_ins
    ADD CONSTRAINT fk_rails_e666ea82e7 FOREIGN KEY (ticket_id) REFERENCES public.ticketing_tickets(id);


--
-- Name: oauth_access_tokens fk_rails_ee63f25419; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_rails_ee63f25419 FOREIGN KEY (resource_owner_id) REFERENCES public.users(id);


--
-- Name: members_exclusive_ticket_type_credit_spendings fk_rails_fd5ef33d87; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_exclusive_ticket_type_credit_spendings
    ADD CONSTRAINT fk_rails_fd5ef33d87 FOREIGN KEY (order_id) REFERENCES public.ticketing_orders(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20251222110358'),
('20250926193854'),
('20250617185930'),
('20250121223540'),
('20250103121117'),
('20250101155130'),
('20240727192449'),
('20240620212248'),
('20240515083436'),
('20240511152059'),
('20231226151739'),
('20231120203220'),
('20230903173126'),
('20230817211816'),
('20230809215027'),
('20230808221947'),
('20230805121011'),
('20230804094229'),
('20230803205151'),
('20230726175845'),
('20230716104339'),
('20230715084859'),
('20230713220945'),
('20221013141610'),
('20220821145609'),
('20220730095639'),
('20220729061721'),
('20220729060500'),
('20220702154140'),
('20220604133306'),
('20220602124536'),
('20220601123414'),
('20220530153820'),
('20220526162603'),
('20220526150631'),
('20211229183000'),
('20210730155259'),
('20210715171413'),
('20210628190951'),
('20210624094725'),
('20210622203354'),
('20210515212141'),
('20210512210607'),
('20210409193803'),
('20210408155502'),
('20210320180321'),
('20210313212839'),
('20210213132820'),
('20210212151229'),
('20210211163535'),
('20210206182618'),
('20210128200247'),
('20210113210947'),
('20210110175421'),
('20201230175154'),
('20201213211837'),
('20201126192338'),
('20201126191323'),
('20201125212834'),
('20201107030155'),
('20201106213153'),
('20201106031019'),
('20200830115812'),
('20200815175134'),
('20200814205319'),
('20200813192343'),
('20200616104936'),
('20200615213727'),
('20200327213527'),
('20200315115826'),
('20200222144644'),
('20200213133157'),
('20200210221526'),
('20200210184433'),
('20200206143022'),
('20200129150306'),
('20200127111237'),
('20200126224058'),
('20200106104452'),
('20191217195300'),
('20191214215830'),
('20191009195115'),
('20191002095906'),
('20190930212209'),
('20190901170312'),
('20190901143224'),
('20190828194326'),
('20190826203751'),
('20190823175242'),
('20190821231434'),
('20190821221505'),
('20190821201506'),
('20190814170321'),
('20190814122151'),
('20190503125200'),
('20190428010037'),
('20190321134259'),
('20190220181856'),
('20190118164859'),
('20190115165147'),
('20190110215510'),
('20181223214432'),
('20181218184943'),
('20181109155509'),
('20181029200609'),
('20181024161610'),
('20181020134814'),
('20181017205841'),
('20181017201602'),
('20181016195210'),
('20181015153927'),
('20180714113618'),
('20180705202900'),
('20180612105436'),
('20180521105047'),
('20180119163716'),
('20170624162514'),
('20160721123404'),
('20160607170525'),
('20160604163914'),
('20160604102137'),
('20160522211522'),
('20160522172027'),
('20151006141228'),
('20151003130228'),
('20150723170442'),
('20150712120955'),
('20150530125204'),
('20150528135311'),
('20150524120013'),
('20150517175321'),
('20140718123334'),
('20140621215652'),
('20140621112735'),
('20140610172922'),
('20140610080742'),
('20140604112905'),
('20140601121240'),
('20140530084810'),
('20140505135554'),
('20140503224535'),
('20140502002733'),
('20140430231032'),
('20140425131530'),
('20140204130359'),
('20131128230237'),
('20130816094618'),
('20130813132756'),
('20130811212035'),
('20130807131502'),
('20130801171926'),
('20130730163544'),
('20130730134519'),
('20130722201703'),
('20130722082802'),
('20130623172717'),
('20130622173109'),
('20130616122643'),
('20130530172608'),
('20130512173100'),
('20130502180534'),
('20130423182152'),
('20130413142754'),
('20130409194228'),
('20130406183834'),
('20130404163731'),
('20130325133347'),
('20130324134443'),
('20130323143146'),
('20130322111948'),
('20130320181238'),
('20130317210339'),
('20130310175856'),
('20130225205413'),
('20130225204749'),
('20130225202949'),
('20130217162638'),
('20130215184140'),
('20130214205556'),
('20130212145740'),
('20130212141758'),
('20130212141649'),
('20130212141331'),
('20130211234854'),
('20130211234734'),
('20130211234708'),
('20130211234157'),
('20130211234021'),
('20130208194309'),
('20130128193500'),
('20130127110550'),
('20130126225210'),
('20130126224240'),
('20130116124919');

