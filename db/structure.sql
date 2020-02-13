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
-- Name: newsletter_newsletter_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.newsletter_newsletter_status AS ENUM (
    'draft',
    'review',
    'sent'
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
    'box_office'
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
-- Name: user_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_type AS ENUM (
    'User',
    'Members::Member',
    'Ticketing::Retail::User'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents (
    id bigint NOT NULL,
    title character varying,
    description character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    file_file_name character varying,
    file_content_type character varying,
    file_file_size integer,
    file_updated_at timestamp without time zone,
    members_group integer DEFAULT 0
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: galleries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.galleries (
    id bigint NOT NULL,
    title character varying,
    disclaimer character varying,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
-- Name: members_dates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members_dates (
    id bigint NOT NULL,
    datetime timestamp with time zone,
    info text,
    location character varying,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    title character varying
);


--
-- Name: members_dates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.members_dates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: members_dates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.members_dates_id_seq OWNED BY public.members_dates.id;


--
-- Name: members_exclusive_ticket_type_credit_spendings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members_exclusive_ticket_type_credit_spendings (
    id bigint NOT NULL,
    member_id bigint,
    ticket_type_id bigint,
    order_id bigint,
    value integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: members_membership_fee_debit_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members_membership_fee_debit_submissions (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
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
    updated_at timestamp(6) without time zone NOT NULL
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
    image_file_size integer,
    image_updated_at timestamp without time zone,
    newsletter_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
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
    subscriber_list_id bigint
);


--
-- Name: newsletter_subscriber_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newsletter_subscriber_lists (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
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
-- Name: passbook_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.passbook_devices (
    id bigint NOT NULL,
    device_id character varying,
    push_token character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    image_file_name character varying,
    image_content_type character varying,
    image_file_size integer,
    image_updated_at timestamp without time zone
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
-- Name: ticketing_bank_charges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_bank_charges (
    id bigint NOT NULL,
    name character varying,
    iban character varying,
    chargeable_type character varying,
    chargeable_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    approved boolean DEFAULT false,
    submission_id bigint,
    amount numeric DEFAULT 0.0 NOT NULL
);


--
-- Name: ticketing_bank_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_bank_charges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_bank_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_bank_charges_id_seq OWNED BY public.ticketing_bank_charges.id;


--
-- Name: ticketing_bank_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_bank_submissions (
    id bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
-- Name: ticketing_billing_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_billing_accounts (
    id bigint NOT NULL,
    balance numeric DEFAULT 0.0 NOT NULL,
    billable_id bigint NOT NULL,
    billable_type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: ticketing_billing_transfers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_billing_transfers (
    id bigint NOT NULL,
    amount numeric DEFAULT 0.0 NOT NULL,
    note_key character varying,
    account_id bigint NOT NULL,
    participant_id bigint,
    reverse_transfer_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ticketing_billing_transfers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_billing_transfers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_billing_transfers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_billing_transfers_id_seq OWNED BY public.ticketing_billing_transfers.id;


--
-- Name: ticketing_blocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_blocks (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    name character varying,
    price double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pay_method character varying
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    medium public.ticketing_check_in_medium,
    date timestamp without time zone
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
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    expires timestamp without time zone,
    recipient character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    free_tickets integer DEFAULT 0,
    affiliation character varying
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
-- Name: ticketing_coupons_reservation_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_coupons_reservation_groups (
    coupon_id bigint,
    reservation_group_id bigint
);


--
-- Name: ticketing_event_dates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_event_dates (
    id bigint NOT NULL,
    date timestamp without time zone,
    event_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    identifier character varying NOT NULL,
    sale_start timestamp without time zone,
    seating_id bigint DEFAULT 1 NOT NULL,
    location character varying,
    slug character varying NOT NULL,
    archived boolean DEFAULT false,
    sale_disabled_message character varying,
    subtitle character varying,
    assets_identifier character varying NOT NULL
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
-- Name: ticketing_log_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_log_events (
    id bigint NOT NULL,
    name character varying,
    info character varying,
    user_id bigint,
    loggable_type character varying,
    loggable_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    box_office_id bigint,
    date_id bigint,
    affiliation character varying
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
-- Name: ticketing_push_notifications_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_push_notifications_devices (
    id bigint NOT NULL,
    token character varying,
    app character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    settings text
);


--
-- Name: ticketing_push_notifications_devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketing_push_notifications_devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketing_push_notifications_devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketing_push_notifications_devices_id_seq OWNED BY public.ticketing_push_notifications_devices.id;


--
-- Name: ticketing_reservation_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_reservation_groups (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
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
    number_of_seats integer DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    stripped_plan_digest character varying,
    name character varying
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
-- Name: ticketing_ticket_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketing_ticket_types (
    id bigint NOT NULL,
    name character varying,
    price numeric DEFAULT 0.0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    info character varying,
    availability public.ticketing_ticket_type_availability DEFAULT 'universal'::public.ticketing_ticket_type_availability,
    event_id bigint
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    seat_id bigint,
    date_id bigint,
    picked_up boolean DEFAULT false,
    resale boolean DEFAULT false,
    invalidated boolean DEFAULT false,
    order_index integer DEFAULT 0 NOT NULL
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
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying,
    password_digest character varying,
    first_name character varying,
    last_name character varying,
    "group" integer DEFAULT 0,
    last_login timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    activation_code character varying,
    birthday date,
    nickname character varying,
    family_id bigint,
    type public.user_type,
    street character varying,
    plz integer,
    city character varying,
    phone character varying,
    joined_at date,
    sepa_mandate_id bigint,
    number integer,
    membership_fee numeric,
    title character varying,
    membership_fee_paid_until date,
    ticketing_retail_store_id bigint
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
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: galleries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.galleries ALTER COLUMN id SET DEFAULT nextval('public.galleries_id_seq'::regclass);


--
-- Name: members_dates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_dates ALTER COLUMN id SET DEFAULT nextval('public.members_dates_id_seq'::regclass);


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
-- Name: ticketing_bank_charges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_bank_charges ALTER COLUMN id SET DEFAULT nextval('public.ticketing_bank_charges_id_seq'::regclass);


--
-- Name: ticketing_bank_submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_bank_submissions ALTER COLUMN id SET DEFAULT nextval('public.ticketing_bank_submissions_id_seq'::regclass);


--
-- Name: ticketing_billing_accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_billing_accounts ALTER COLUMN id SET DEFAULT nextval('public.ticketing_billing_accounts_id_seq'::regclass);


--
-- Name: ticketing_billing_transfers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_billing_transfers ALTER COLUMN id SET DEFAULT nextval('public.ticketing_billing_transfers_id_seq'::regclass);


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
-- Name: ticketing_log_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_log_events ALTER COLUMN id SET DEFAULT nextval('public.ticketing_log_events_id_seq'::regclass);


--
-- Name: ticketing_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_orders ALTER COLUMN id SET DEFAULT nextval('public.ticketing_orders_id_seq'::regclass);


--
-- Name: ticketing_push_notifications_devices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_push_notifications_devices ALTER COLUMN id SET DEFAULT nextval('public.ticketing_push_notifications_devices_id_seq'::regclass);


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
-- Name: ticketing_ticket_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_ticket_types ALTER COLUMN id SET DEFAULT nextval('public.ticketing_ticket_types_id_seq'::regclass);


--
-- Name: ticketing_tickets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_tickets ALTER COLUMN id SET DEFAULT nextval('public.ticketing_tickets_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: galleries galleries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.galleries
    ADD CONSTRAINT galleries_pkey PRIMARY KEY (id);


--
-- Name: members_dates members_dates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_dates
    ADD CONSTRAINT members_dates_pkey PRIMARY KEY (id);


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
-- Name: ticketing_bank_charges ticketing_bank_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_bank_charges
    ADD CONSTRAINT ticketing_bank_charges_pkey PRIMARY KEY (id);


--
-- Name: ticketing_bank_submissions ticketing_bank_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_bank_submissions
    ADD CONSTRAINT ticketing_bank_submissions_pkey PRIMARY KEY (id);


--
-- Name: ticketing_billing_accounts ticketing_billing_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_billing_accounts
    ADD CONSTRAINT ticketing_billing_accounts_pkey PRIMARY KEY (id);


--
-- Name: ticketing_billing_transfers ticketing_billing_transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_billing_transfers
    ADD CONSTRAINT ticketing_billing_transfers_pkey PRIMARY KEY (id);


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
-- Name: ticketing_push_notifications_devices ticketing_push_notifications_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_push_notifications_devices
    ADD CONSTRAINT ticketing_push_notifications_devices_pkey PRIMARY KEY (id);


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
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_billing_acounts_on_id_and_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billing_acounts_on_id_and_type ON public.ticketing_billing_accounts USING btree (billable_id, billable_type);


--
-- Name: index_documents_on_members_group; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_members_group ON public.documents USING btree (members_group);


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
-- Name: index_newsletter_subscribers_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_newsletter_subscribers_on_email ON public.newsletter_subscribers USING btree (email);


--
-- Name: index_newsletter_subscribers_on_subscriber_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_newsletter_subscribers_on_subscriber_list_id ON public.newsletter_subscribers USING btree (subscriber_list_id);


--
-- Name: index_newsletter_subscribers_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_newsletter_subscribers_on_token ON public.newsletter_subscribers USING btree (token);


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
-- Name: index_ticketing_bank_charges_on_approved; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_bank_charges_on_approved ON public.ticketing_bank_charges USING btree (approved);


--
-- Name: index_ticketing_bank_charges_on_chargeable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_bank_charges_on_chargeable ON public.ticketing_bank_charges USING btree (chargeable_id, chargeable_type);


--
-- Name: index_ticketing_bank_charges_on_submission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_bank_charges_on_submission_id ON public.ticketing_bank_charges USING btree (submission_id);


--
-- Name: index_ticketing_billing_transfers_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_billing_transfers_on_account_id ON public.ticketing_billing_transfers USING btree (account_id);


--
-- Name: index_ticketing_billing_transfers_on_participant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_billing_transfers_on_participant_id ON public.ticketing_billing_transfers USING btree (participant_id);


--
-- Name: index_ticketing_blocks_on_seating_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_blocks_on_seating_id ON public.ticketing_blocks USING btree (seating_id);


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
-- Name: index_ticketing_coupons_reservation_groups_on_coupon_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_coupons_reservation_groups_on_coupon_id ON public.ticketing_coupons_reservation_groups USING btree (coupon_id);


--
-- Name: index_ticketing_coupons_reservation_groups_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_coupons_reservation_groups_on_group_id ON public.ticketing_coupons_reservation_groups USING btree (reservation_group_id);


--
-- Name: index_ticketing_event_dates_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_event_dates_on_event_id ON public.ticketing_event_dates USING btree (event_id);


--
-- Name: index_ticketing_events_on_archived; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_events_on_archived ON public.ticketing_events USING btree (archived);


--
-- Name: index_ticketing_events_on_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticketing_events_on_identifier ON public.ticketing_events USING btree (identifier);


--
-- Name: index_ticketing_events_on_seating_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_events_on_seating_id ON public.ticketing_events USING btree (seating_id);


--
-- Name: index_ticketing_events_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticketing_events_on_slug ON public.ticketing_events USING btree (slug);


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
-- Name: index_ticketing_push_notifications_devices_on_app_and_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticketing_push_notifications_devices_on_app_and_token ON public.ticketing_push_notifications_devices USING btree (app, token);


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
-- Name: index_ticketing_seats_on_block_id_and_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticketing_seats_on_block_id_and_number ON public.ticketing_seats USING btree (block_id, number);


--
-- Name: index_ticketing_signing_keys_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketing_signing_keys_on_active ON public.ticketing_signing_keys USING btree (active);


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
-- Name: index_users_on_activation_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_activation_code ON public.users USING btree (activation_code);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_family_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_family_id ON public.users USING btree (family_id);


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
-- Name: newsletter_images fk_rails_038053fe4b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_images
    ADD CONSTRAINT fk_rails_038053fe4b FOREIGN KEY (newsletter_id) REFERENCES public.newsletter_newsletters(id);


--
-- Name: ticketing_billing_transfers fk_rails_071c9c9aef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_billing_transfers
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
-- Name: ticketing_billing_transfers fk_rails_17a5504e18; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_billing_transfers
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
-- Name: ticketing_billing_transfers fk_rails_50c9e4ab50; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_billing_transfers
    ADD CONSTRAINT fk_rails_50c9e4ab50 FOREIGN KEY (reverse_transfer_id) REFERENCES public.ticketing_billing_transfers(id);


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
-- Name: ticketing_bank_charges fk_rails_684a6280d2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_bank_charges
    ADD CONSTRAINT fk_rails_684a6280d2 FOREIGN KEY (submission_id) REFERENCES public.ticketing_bank_submissions(id);


--
-- Name: passbook_registrations fk_rails_7231cc423e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passbook_registrations
    ADD CONSTRAINT fk_rails_7231cc423e FOREIGN KEY (device_id) REFERENCES public.passbook_devices(id);


--
-- Name: ticketing_coupons_reservation_groups fk_rails_727a2e4bc0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_coupons_reservation_groups
    ADD CONSTRAINT fk_rails_727a2e4bc0 FOREIGN KEY (coupon_id) REFERENCES public.ticketing_coupons(id);


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
-- Name: ticketing_coupons_reservation_groups fk_rails_a9e9990530; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_coupons_reservation_groups
    ADD CONSTRAINT fk_rails_a9e9990530 FOREIGN KEY (reservation_group_id) REFERENCES public.ticketing_reservation_groups(id);


--
-- Name: ticketing_box_office_purchases fk_rails_aaed8504ca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_box_office_purchases
    ADD CONSTRAINT fk_rails_aaed8504ca FOREIGN KEY (box_office_id) REFERENCES public.ticketing_box_office_box_offices(id);


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
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: members_exclusive_ticket_type_credit_spendings fk_rails_c6eb01b535; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members_exclusive_ticket_type_credit_spendings
    ADD CONSTRAINT fk_rails_c6eb01b535 FOREIGN KEY (member_id) REFERENCES public.users(id);


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
-- Name: ticketing_orders fk_rails_dfaebcd775; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_orders
    ADD CONSTRAINT fk_rails_dfaebcd775 FOREIGN KEY (box_office_id) REFERENCES public.ticketing_box_office_box_offices(id);


--
-- Name: ticketing_check_ins fk_rails_e666ea82e7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketing_check_ins
    ADD CONSTRAINT fk_rails_e666ea82e7 FOREIGN KEY (ticket_id) REFERENCES public.ticketing_tickets(id);


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
('20130116124919'),
('20130126224240'),
('20130126225210'),
('20130127110550'),
('20130128193500'),
('20130208194309'),
('20130211234021'),
('20130211234157'),
('20130211234708'),
('20130211234734'),
('20130211234854'),
('20130212141331'),
('20130212141649'),
('20130212141758'),
('20130212145740'),
('20130214205556'),
('20130215184140'),
('20130217162638'),
('20130225202949'),
('20130225204749'),
('20130225205413'),
('20130310175856'),
('20130317210339'),
('20130320181238'),
('20130322111948'),
('20130323143146'),
('20130324134443'),
('20130325133347'),
('20130404163731'),
('20130406183834'),
('20130409194228'),
('20130413142754'),
('20130423182152'),
('20130502180534'),
('20130512173100'),
('20130530172608'),
('20130616122643'),
('20130622173109'),
('20130623172717'),
('20130722082802'),
('20130722201703'),
('20130730134519'),
('20130730163544'),
('20130801171926'),
('20130807131502'),
('20130811212035'),
('20130813132756'),
('20130816094618'),
('20131128230237'),
('20140204130359'),
('20140425131530'),
('20140430231032'),
('20140502002733'),
('20140503224535'),
('20140505135554'),
('20140530084810'),
('20140601121240'),
('20140604112905'),
('20140610080742'),
('20140610172922'),
('20140621112735'),
('20140621215652'),
('20140718123334'),
('20150517175321'),
('20150524120013'),
('20150528135311'),
('20150530125204'),
('20150712120955'),
('20150723170442'),
('20151003130228'),
('20151006141228'),
('20160522172027'),
('20160522211522'),
('20160604102137'),
('20160604163914'),
('20160607170525'),
('20160721123404'),
('20170624162514'),
('20180119163716'),
('20180521105047'),
('20180612105436'),
('20180705202900'),
('20180714113618'),
('20181015153927'),
('20181016195210'),
('20181017201602'),
('20181017205841'),
('20181020134814'),
('20181024161610'),
('20181029200609'),
('20181104184515'),
('20181109155509'),
('20181218184943'),
('20181223214432'),
('20190110215510'),
('20190115165147'),
('20190118164859'),
('20190220181856'),
('20190321134259'),
('20190428010037'),
('20190503125200'),
('20190814122151'),
('20190814170321'),
('20190821201506'),
('20190821221505'),
('20190821231434'),
('20190823175242'),
('20190826203751'),
('20190828194326'),
('20190901143224'),
('20190901170312'),
('20190930212209'),
('20191002095906'),
('20191009195115'),
('20191214215830'),
('20191217195300'),
('20200106104452'),
('20200126224058'),
('20200127111237'),
('20200129150306'),
('20200131193946'),
('20200206143022'),
('20200210184433'),
('20200210221526'),
('20200213133157');


