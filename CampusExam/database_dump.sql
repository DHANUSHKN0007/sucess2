--
-- PostgreSQL database dump
--

\restrict tsQQoQ1uht7LSf5hPY5cRAzux3wng9eovoHrrNxUWNdm94czsbEjx1zt1I6DpDf

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

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

ALTER TABLE IF EXISTS ONLY public.subject DROP CONSTRAINT IF EXISTS subject_department_id_fkey;
ALTER TABLE IF EXISTS ONLY public.student_session_result DROP CONSTRAINT IF EXISTS student_session_result_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.student_session_result DROP CONSTRAINT IF EXISTS student_session_result_import_id_fkey;
ALTER TABLE IF EXISTS ONLY public.student_roster DROP CONSTRAINT IF EXISTS student_roster_group_id_fkey;
ALTER TABLE IF EXISTS ONLY public.student_roster DROP CONSTRAINT IF EXISTS student_roster_department_id_fkey;
ALTER TABLE IF EXISTS ONLY public.session_unlock_credential DROP CONSTRAINT IF EXISTS session_unlock_credential_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.session_unlock_credential DROP CONSTRAINT IF EXISTS session_unlock_credential_generated_by_fkey;
ALTER TABLE IF EXISTS ONLY public.session_transfer_history DROP CONSTRAINT IF EXISTS session_transfer_history_transferred_by_fkey;
ALTER TABLE IF EXISTS ONLY public.session_transfer_history DROP CONSTRAINT IF EXISTS session_transfer_history_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.session_transfer_history DROP CONSTRAINT IF EXISTS session_transfer_history_authorization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.session_token DROP CONSTRAINT IF EXISTS session_token_account_id_fkey;
ALTER TABLE IF EXISTS ONLY public.session_roster_snapshot DROP CONSTRAINT IF EXISTS session_roster_snapshot_student_id_fkey;
ALTER TABLE IF EXISTS ONLY public.session_roster_snapshot DROP CONSTRAINT IF EXISTS session_roster_snapshot_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.security_violation_log DROP CONSTRAINT IF EXISTS security_violation_log_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.secure_package DROP CONSTRAINT IF EXISTS secure_package_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.secure_package DROP CONSTRAINT IF EXISTS secure_package_exported_by_fkey;
ALTER TABLE IF EXISTS ONLY public.relogin_authorization DROP CONSTRAINT IF EXISTS relogin_authorization_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.relogin_authorization DROP CONSTRAINT IF EXISTS relogin_authorization_authorized_by_fkey;
ALTER TABLE IF EXISTS ONLY public.question_bank DROP CONSTRAINT IF EXISTS question_bank_subject_id_fkey;
ALTER TABLE IF EXISTS ONLY public.question_bank_item DROP CONSTRAINT IF EXISTS question_bank_item_bank_id_fkey;
ALTER TABLE IF EXISTS ONLY public.question DROP CONSTRAINT IF EXISTS question_bank_id_fkey;
ALTER TABLE IF EXISTS ONLY public.question_bank DROP CONSTRAINT IF EXISTS question_bank_finalized_by_fkey;
ALTER TABLE IF EXISTS ONLY public.question_bank DROP CONSTRAINT IF EXISTS question_bank_department_id_fkey;
ALTER TABLE IF EXISTS ONLY public.question_bank DROP CONSTRAINT IF EXISTS question_bank_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.paper_version DROP CONSTRAINT IF EXISTS paper_version_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.paper_version_question DROP CONSTRAINT IF EXISTS paper_version_question_version_id_fkey;
ALTER TABLE IF EXISTS ONLY public.paper_version_question DROP CONSTRAINT IF EXISTS paper_version_question_question_id_fkey;
ALTER TABLE IF EXISTS ONLY public.paper_version DROP CONSTRAINT IF EXISTS paper_version_paper_id_fkey;
ALTER TABLE IF EXISTS ONLY public.lab_result_import DROP CONSTRAINT IF EXISTS lab_result_import_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.lab_result_import DROP CONSTRAINT IF EXISTS lab_result_import_released_by_fkey;
ALTER TABLE IF EXISTS ONLY public.lab_result_import DROP CONSTRAINT IF EXISTS lab_result_import_imported_by_fkey;
ALTER TABLE IF EXISTS ONLY public.lab_result_import DROP CONSTRAINT IF EXISTS lab_result_import_approved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.generated_paper_question DROP CONSTRAINT IF EXISTS generated_paper_question_question_id_fkey;
ALTER TABLE IF EXISTS ONLY public.generated_paper_question DROP CONSTRAINT IF EXISTS generated_paper_question_paper_id_fkey;
ALTER TABLE IF EXISTS ONLY public.generated_paper DROP CONSTRAINT IF EXISTS generated_paper_bank_id_fkey;
ALTER TABLE IF EXISTS ONLY public.faculty_scope DROP CONSTRAINT IF EXISTS faculty_scope_subject_id_fkey;
ALTER TABLE IF EXISTS ONLY public.faculty_scope DROP CONSTRAINT IF EXISTS faculty_scope_group_id_fkey;
ALTER TABLE IF EXISTS ONLY public.faculty_scope DROP CONSTRAINT IF EXISTS faculty_scope_faculty_id_fkey;
ALTER TABLE IF EXISTS ONLY public.examination_session DROP CONSTRAINT IF EXISTS examination_session_subject_id_fkey;
ALTER TABLE IF EXISTS ONLY public.examination_session DROP CONSTRAINT IF EXISTS examination_session_selected_paper_id_fkey;
ALTER TABLE IF EXISTS ONLY public.examination_session DROP CONSTRAINT IF EXISTS examination_session_group_id_fkey;
ALTER TABLE IF EXISTS ONLY public.examination_session DROP CONSTRAINT IF EXISTS examination_session_department_id_fkey;
ALTER TABLE IF EXISTS ONLY public.examination_session DROP CONSTRAINT IF EXISTS examination_session_cycle_id_fkey;
ALTER TABLE IF EXISTS ONLY public.examination_session DROP CONSTRAINT IF EXISTS examination_session_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.examination_cycle DROP CONSTRAINT IF EXISTS examination_cycle_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.exam_question DROP CONSTRAINT IF EXISTS exam_question_exam_id_fkey;
ALTER TABLE IF EXISTS ONLY public.exam DROP CONSTRAINT IF EXISTS exam_bank_id_fkey;
ALTER TABLE IF EXISTS ONLY public.course_outcome_submission DROP CONSTRAINT IF EXISTS course_outcome_submission_subject_id_fkey;
ALTER TABLE IF EXISTS ONLY public.course_outcome_submission DROP CONSTRAINT IF EXISTS course_outcome_submission_department_id_fkey;
ALTER TABLE IF EXISTS ONLY public.course_outcome_submission DROP CONSTRAINT IF EXISTS course_outcome_submission_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.course_outcome_statement DROP CONSTRAINT IF EXISTS course_outcome_statement_revision_id_fkey;
ALTER TABLE IF EXISTS ONLY public.course_outcome_revision DROP CONSTRAINT IF EXISTS course_outcome_revision_uploaded_by_fkey;
ALTER TABLE IF EXISTS ONLY public.course_outcome_revision DROP CONSTRAINT IF EXISTS course_outcome_revision_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.course_outcome_review DROP CONSTRAINT IF EXISTS course_outcome_review_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.course_outcome_review DROP CONSTRAINT IF EXISTS course_outcome_review_reviewed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.computer_assignment DROP CONSTRAINT IF EXISTS computer_assignment_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bank DROP CONSTRAINT IF EXISTS bank_subject_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bank_scope DROP CONSTRAINT IF EXISTS bank_scope_group_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bank_scope DROP CONSTRAINT IF EXISTS bank_scope_bank_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bank DROP CONSTRAINT IF EXISTS bank_owner_id_fkey;
ALTER TABLE IF EXISTS ONLY public.audit DROP CONSTRAINT IF EXISTS audit_actor_fkey;
ALTER TABLE IF EXISTS ONLY public.attempt DROP CONSTRAINT IF EXISTS attempt_exam_id_student_id_fkey;
ALTER TABLE IF EXISTS ONLY public.assignment DROP CONSTRAINT IF EXISTS assignment_student_id_fkey;
ALTER TABLE IF EXISTS ONLY public.assignment DROP CONSTRAINT IF EXISTS assignment_exam_id_fkey;
ALTER TABLE IF EXISTS ONLY public.answer_key_correction DROP CONSTRAINT IF EXISTS answer_key_correction_submitted_by_fkey;
ALTER TABLE IF EXISTS ONLY public.answer_key_correction DROP CONSTRAINT IF EXISTS answer_key_correction_subject_id_fkey;
ALTER TABLE IF EXISTS ONLY public.answer_key_correction DROP CONSTRAINT IF EXISTS answer_key_correction_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.answer_key_correction DROP CONSTRAINT IF EXISTS answer_key_correction_decided_by_fkey;
ALTER TABLE IF EXISTS ONLY public.answer DROP CONSTRAINT IF EXISTS answer_exam_id_position_fkey;
ALTER TABLE IF EXISTS ONLY public.answer DROP CONSTRAINT IF EXISTS answer_attempt_id_exam_id_fkey;
ALTER TABLE IF EXISTS ONLY public.account DROP CONSTRAINT IF EXISTS account_group_id_fkey;
ALTER TABLE IF EXISTS ONLY public.account DROP CONSTRAINT IF EXISTS account_department_id_fkey;
ALTER TABLE IF EXISTS ONLY public.academic_group DROP CONSTRAINT IF EXISTS academic_group_department_id_fkey;
DROP INDEX IF EXISTS public.uq_active_unlock_credential;
DROP INDEX IF EXISTS public.question_prompt_key;
DROP INDEX IF EXISTS public.one_active_attempt;
DROP INDEX IF EXISTS public.idx_unlock_cred_session;
DROP INDEX IF EXISTS public.idx_student_roster_dept_sem;
DROP INDEX IF EXISTS public.idx_session_transfer_session_usn;
DROP INDEX IF EXISTS public.idx_sec_violation_session_usn;
DROP INDEX IF EXISTS public.idx_relogin_auth_session_usn;
DROP INDEX IF EXISTS public.idx_qb_item_bank_mod;
DROP INDEX IF EXISTS public.idx_key_corr_session;
DROP INDEX IF EXISTS public.idx_exam_session_sched;
DROP INDEX IF EXISTS public.idx_co_submission_dept_sem;
DROP INDEX IF EXISTS public.idx_account_dept_role;
DROP INDEX IF EXISTS public.attempt_due;
ALTER TABLE IF EXISTS ONLY public.subject DROP CONSTRAINT IF EXISTS subject_pkey;
ALTER TABLE IF EXISTS ONLY public.student_session_result DROP CONSTRAINT IF EXISTS student_session_result_session_id_usn_key;
ALTER TABLE IF EXISTS ONLY public.student_session_result DROP CONSTRAINT IF EXISTS student_session_result_pkey;
ALTER TABLE IF EXISTS ONLY public.student_roster DROP CONSTRAINT IF EXISTS student_roster_usn_key;
ALTER TABLE IF EXISTS ONLY public.student_roster DROP CONSTRAINT IF EXISTS student_roster_pkey;
ALTER TABLE IF EXISTS ONLY public.session_unlock_credential DROP CONSTRAINT IF EXISTS session_unlock_credential_session_id_sitting_name_revision_key;
ALTER TABLE IF EXISTS ONLY public.session_unlock_credential DROP CONSTRAINT IF EXISTS session_unlock_credential_pkey;
ALTER TABLE IF EXISTS ONLY public.session_transfer_history DROP CONSTRAINT IF EXISTS session_transfer_history_pkey;
ALTER TABLE IF EXISTS ONLY public.session_token DROP CONSTRAINT IF EXISTS session_token_pkey;
ALTER TABLE IF EXISTS ONLY public.session_roster_snapshot DROP CONSTRAINT IF EXISTS session_roster_snapshot_pkey;
ALTER TABLE IF EXISTS ONLY public.security_violation_log DROP CONSTRAINT IF EXISTS security_violation_log_pkey;
ALTER TABLE IF EXISTS ONLY public.secure_package DROP CONSTRAINT IF EXISTS secure_package_session_id_key;
ALTER TABLE IF EXISTS ONLY public.secure_package DROP CONSTRAINT IF EXISTS secure_package_pkey;
ALTER TABLE IF EXISTS ONLY public.secure_package DROP CONSTRAINT IF EXISTS secure_package_package_uid_key;
ALTER TABLE IF EXISTS ONLY public.relogin_authorization DROP CONSTRAINT IF EXISTS relogin_authorization_token_id_key;
ALTER TABLE IF EXISTS ONLY public.relogin_authorization DROP CONSTRAINT IF EXISTS relogin_authorization_token_hash_key;
ALTER TABLE IF EXISTS ONLY public.relogin_authorization DROP CONSTRAINT IF EXISTS relogin_authorization_pkey;
ALTER TABLE IF EXISTS ONLY public.question DROP CONSTRAINT IF EXISTS question_pkey;
ALTER TABLE IF EXISTS ONLY public.question_bank DROP CONSTRAINT IF EXISTS question_bank_pkey;
ALTER TABLE IF EXISTS ONLY public.question_bank_item DROP CONSTRAINT IF EXISTS question_bank_item_pkey;
ALTER TABLE IF EXISTS ONLY public.question_bank_item DROP CONSTRAINT IF EXISTS question_bank_item_bank_id_question_uid_key;
ALTER TABLE IF EXISTS ONLY public.paper_version DROP CONSTRAINT IF EXISTS paper_version_session_id_version_letter_key;
ALTER TABLE IF EXISTS ONLY public.paper_version_question DROP CONSTRAINT IF EXISTS paper_version_question_pkey;
ALTER TABLE IF EXISTS ONLY public.paper_version DROP CONSTRAINT IF EXISTS paper_version_pkey;
ALTER TABLE IF EXISTS ONLY public.lab_result_import DROP CONSTRAINT IF EXISTS lab_result_import_session_id_key;
ALTER TABLE IF EXISTS ONLY public.lab_result_import DROP CONSTRAINT IF EXISTS lab_result_import_pkey;
ALTER TABLE IF EXISTS ONLY public.generated_paper_question DROP CONSTRAINT IF EXISTS generated_paper_question_pkey;
ALTER TABLE IF EXISTS ONLY public.generated_paper DROP CONSTRAINT IF EXISTS generated_paper_pkey;
ALTER TABLE IF EXISTS ONLY public.generated_paper DROP CONSTRAINT IF EXISTS generated_paper_bank_id_paper_number_key;
ALTER TABLE IF EXISTS ONLY public.faculty_scope DROP CONSTRAINT IF EXISTS faculty_scope_pkey;
ALTER TABLE IF EXISTS ONLY public.examination_session DROP CONSTRAINT IF EXISTS examination_session_pkey;
ALTER TABLE IF EXISTS ONLY public.examination_cycle DROP CONSTRAINT IF EXISTS examination_cycle_pkey;
ALTER TABLE IF EXISTS ONLY public.exam_question DROP CONSTRAINT IF EXISTS exam_question_pkey;
ALTER TABLE IF EXISTS ONLY public.exam DROP CONSTRAINT IF EXISTS exam_pkey;
ALTER TABLE IF EXISTS ONLY public.department DROP CONSTRAINT IF EXISTS department_pkey;
ALTER TABLE IF EXISTS ONLY public.department DROP CONSTRAINT IF EXISTS department_code_key;
ALTER TABLE IF EXISTS ONLY public.course_outcome_submission DROP CONSTRAINT IF EXISTS course_outcome_submission_subject_id_academic_session_key;
ALTER TABLE IF EXISTS ONLY public.course_outcome_submission DROP CONSTRAINT IF EXISTS course_outcome_submission_pkey;
ALTER TABLE IF EXISTS ONLY public.course_outcome_statement DROP CONSTRAINT IF EXISTS course_outcome_statement_revision_id_co_code_key;
ALTER TABLE IF EXISTS ONLY public.course_outcome_statement DROP CONSTRAINT IF EXISTS course_outcome_statement_pkey;
ALTER TABLE IF EXISTS ONLY public.course_outcome_revision DROP CONSTRAINT IF EXISTS course_outcome_revision_submission_id_revision_number_key;
ALTER TABLE IF EXISTS ONLY public.course_outcome_revision DROP CONSTRAINT IF EXISTS course_outcome_revision_pkey;
ALTER TABLE IF EXISTS ONLY public.course_outcome_review DROP CONSTRAINT IF EXISTS course_outcome_review_pkey;
ALTER TABLE IF EXISTS ONLY public.computer_assignment DROP CONSTRAINT IF EXISTS computer_assignment_session_id_computer_number_key;
ALTER TABLE IF EXISTS ONLY public.computer_assignment DROP CONSTRAINT IF EXISTS computer_assignment_pkey;
ALTER TABLE IF EXISTS ONLY public.bank_scope DROP CONSTRAINT IF EXISTS bank_scope_pkey;
ALTER TABLE IF EXISTS ONLY public.bank DROP CONSTRAINT IF EXISTS bank_pkey;
ALTER TABLE IF EXISTS ONLY public.audit DROP CONSTRAINT IF EXISTS audit_pkey;
ALTER TABLE IF EXISTS ONLY public.attempt DROP CONSTRAINT IF EXISTS attempt_pkey;
ALTER TABLE IF EXISTS ONLY public.attempt DROP CONSTRAINT IF EXISTS attempt_id_exam_id_key;
ALTER TABLE IF EXISTS ONLY public.assignment DROP CONSTRAINT IF EXISTS assignment_pkey;
ALTER TABLE IF EXISTS ONLY public.answer DROP CONSTRAINT IF EXISTS answer_pkey;
ALTER TABLE IF EXISTS ONLY public.answer_key_correction DROP CONSTRAINT IF EXISTS answer_key_correction_pkey;
ALTER TABLE IF EXISTS ONLY public.account DROP CONSTRAINT IF EXISTS account_username_key;
ALTER TABLE IF EXISTS ONLY public.account DROP CONSTRAINT IF EXISTS account_pkey;
ALTER TABLE IF EXISTS ONLY public.academic_group DROP CONSTRAINT IF EXISTS academic_group_pkey;
ALTER TABLE IF EXISTS ONLY public.academic_group DROP CONSTRAINT IF EXISTS academic_group_department_academic_session_study_year_semes_key;
DROP TABLE IF EXISTS public.subject;
DROP TABLE IF EXISTS public.student_session_result;
DROP TABLE IF EXISTS public.student_roster;
DROP TABLE IF EXISTS public.session_unlock_credential;
DROP TABLE IF EXISTS public.session_transfer_history;
DROP TABLE IF EXISTS public.session_token;
DROP TABLE IF EXISTS public.session_roster_snapshot;
DROP TABLE IF EXISTS public.security_violation_log;
DROP TABLE IF EXISTS public.secure_package;
DROP TABLE IF EXISTS public.relogin_authorization;
DROP TABLE IF EXISTS public.question_bank_item;
DROP TABLE IF EXISTS public.question_bank;
DROP TABLE IF EXISTS public.question;
DROP TABLE IF EXISTS public.paper_version_question;
DROP TABLE IF EXISTS public.paper_version;
DROP TABLE IF EXISTS public.lab_result_import;
DROP TABLE IF EXISTS public.generated_paper_question;
DROP TABLE IF EXISTS public.generated_paper;
DROP TABLE IF EXISTS public.faculty_scope;
DROP TABLE IF EXISTS public.examination_session;
DROP TABLE IF EXISTS public.examination_cycle;
DROP TABLE IF EXISTS public.exam_question;
DROP TABLE IF EXISTS public.exam;
DROP TABLE IF EXISTS public.department;
DROP TABLE IF EXISTS public.course_outcome_submission;
DROP TABLE IF EXISTS public.course_outcome_statement;
DROP TABLE IF EXISTS public.course_outcome_revision;
DROP TABLE IF EXISTS public.course_outcome_review;
DROP TABLE IF EXISTS public.computer_assignment;
DROP TABLE IF EXISTS public.bank_scope;
DROP TABLE IF EXISTS public.bank;
DROP TABLE IF EXISTS public.audit;
DROP TABLE IF EXISTS public.attempt;
DROP TABLE IF EXISTS public.assignment;
DROP TABLE IF EXISTS public.answer_key_correction;
DROP TABLE IF EXISTS public.answer;
DROP TABLE IF EXISTS public.account;
DROP TABLE IF EXISTS public.academic_group;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: academic_group; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.academic_group (
    id bigint NOT NULL,
    department text NOT NULL,
    academic_session text NOT NULL,
    study_year integer DEFAULT 1,
    semester integer NOT NULL,
    section text NOT NULL,
    department_id bigint,
    year integer,
    CONSTRAINT academic_group_semester_check CHECK ((semester > 0)),
    CONSTRAINT academic_group_study_year_check CHECK ((study_year > 0))
);


ALTER TABLE public.academic_group OWNER TO campusexam;

--
-- Name: academic_group_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.academic_group ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.academic_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: account; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.account (
    id bigint NOT NULL,
    username text NOT NULL,
    password_hash text NOT NULL,
    role text NOT NULL,
    group_id bigint,
    department_id bigint,
    full_name text,
    email text,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    contact_number text,
    employee_id text,
    designation text,
    status text DEFAULT 'ACTIVE'::text NOT NULL,
    last_login_at timestamp with time zone,
    theme_preference text DEFAULT 'system'::text,
    CONSTRAINT chk_account_status CHECK ((status = ANY (ARRAY['ACTIVE'::text, 'INACTIVE'::text, 'SUSPENDED'::text])))
);


ALTER TABLE public.account OWNER TO campusexam;

--
-- Name: account_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.account ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: answer; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.answer (
    attempt_id bigint NOT NULL,
    exam_id bigint NOT NULL,
    "position" integer NOT NULL,
    choice integer,
    review boolean NOT NULL,
    version bigint NOT NULL,
    CONSTRAINT answer_choice_check CHECK (((choice >= 1) AND (choice <= 4))),
    CONSTRAINT answer_version_check CHECK ((version > 0))
);


ALTER TABLE public.answer OWNER TO campusexam;

--
-- Name: answer_key_correction; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.answer_key_correction (
    id bigint NOT NULL,
    session_id bigint NOT NULL,
    subject_id bigint NOT NULL,
    question_uid text NOT NULL,
    question_text text NOT NULL,
    original_correct text NOT NULL,
    proposed_correct text NOT NULL,
    reason text NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    submitted_by bigint NOT NULL,
    submitted_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    decided_by bigint,
    decided_at timestamp with time zone,
    decision_reason text,
    CONSTRAINT answer_key_correction_original_correct_check CHECK ((original_correct = ANY (ARRAY['A'::text, 'B'::text, 'C'::text, 'D'::text]))),
    CONSTRAINT answer_key_correction_proposed_correct_check CHECK ((proposed_correct = ANY (ARRAY['A'::text, 'B'::text, 'C'::text, 'D'::text, 'ALL_CORRECT'::text, 'SCRAP_QUESTION'::text]))),
    CONSTRAINT answer_key_correction_status_check CHECK ((status = ANY (ARRAY['PENDING'::text, 'APPROVED'::text, 'REJECTED'::text])))
);


ALTER TABLE public.answer_key_correction OWNER TO campusexam;

--
-- Name: answer_key_correction_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.answer_key_correction ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.answer_key_correction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: assignment; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.assignment (
    exam_id bigint NOT NULL,
    student_id bigint NOT NULL
);


ALTER TABLE public.assignment OWNER TO campusexam;

--
-- Name: attempt; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.attempt (
    id bigint NOT NULL,
    exam_id bigint NOT NULL,
    student_id bigint NOT NULL,
    started timestamp with time zone NOT NULL,
    deadline timestamp with time zone NOT NULL,
    last_seen timestamp with time zone NOT NULL,
    submitted timestamp with time zone,
    reason text,
    score numeric(12,2),
    pending integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.attempt OWNER TO campusexam;

--
-- Name: attempt_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.attempt ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.attempt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: audit; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.audit (
    id bigint NOT NULL,
    happened timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    actor bigint,
    action text NOT NULL,
    entity text NOT NULL,
    detail text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.audit OWNER TO campusexam;

--
-- Name: audit_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.audit ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: bank; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.bank (
    id bigint NOT NULL,
    owner_id bigint NOT NULL,
    subject_id bigint NOT NULL,
    title text NOT NULL,
    state text DEFAULT 'DRAFT'::text NOT NULL,
    CONSTRAINT bank_state_check CHECK ((state = ANY (ARRAY['DRAFT'::text, 'SUBMITTED'::text, 'APPROVED'::text, 'REJECTED'::text, 'ARCHIVED'::text])))
);


ALTER TABLE public.bank OWNER TO campusexam;

--
-- Name: bank_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.bank ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.bank_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: bank_scope; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.bank_scope (
    bank_id bigint NOT NULL,
    group_id bigint NOT NULL
);


ALTER TABLE public.bank_scope OWNER TO campusexam;

--
-- Name: computer_assignment; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.computer_assignment (
    id bigint NOT NULL,
    session_id bigint NOT NULL,
    computer_number text NOT NULL,
    assigned_version_letter text NOT NULL,
    CONSTRAINT computer_assignment_assigned_version_letter_check CHECK ((assigned_version_letter = ANY (ARRAY['A'::text, 'B'::text, 'C'::text, 'D'::text])))
);


ALTER TABLE public.computer_assignment OWNER TO campusexam;

--
-- Name: computer_assignment_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.computer_assignment ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.computer_assignment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: course_outcome_review; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.course_outcome_review (
    id bigint NOT NULL,
    submission_id bigint NOT NULL,
    reviewed_by bigint NOT NULL,
    decision text NOT NULL,
    comments text NOT NULL,
    reviewed_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    CONSTRAINT course_outcome_review_decision_check CHECK ((decision = ANY (ARRAY['REVIEWED_OK'::text, 'CLARIFICATION_REQUESTED'::text])))
);


ALTER TABLE public.course_outcome_review OWNER TO campusexam;

--
-- Name: course_outcome_review_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.course_outcome_review ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.course_outcome_review_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: course_outcome_revision; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.course_outcome_revision (
    id bigint NOT NULL,
    submission_id bigint NOT NULL,
    revision_number integer NOT NULL,
    file_name text NOT NULL,
    file_size_bytes bigint NOT NULL,
    file_hash_sha256 text NOT NULL,
    pdf_blob bytea,
    uploaded_by bigint NOT NULL,
    uploaded_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.course_outcome_revision OWNER TO campusexam;

--
-- Name: course_outcome_revision_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.course_outcome_revision ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.course_outcome_revision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: course_outcome_statement; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.course_outcome_statement (
    id bigint NOT NULL,
    revision_id bigint NOT NULL,
    co_code text NOT NULL,
    description text NOT NULL,
    bloom_level text NOT NULL,
    target_percentage numeric(5,2)
);


ALTER TABLE public.course_outcome_statement OWNER TO campusexam;

--
-- Name: course_outcome_statement_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.course_outcome_statement ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.course_outcome_statement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: course_outcome_submission; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.course_outcome_submission (
    id bigint NOT NULL,
    subject_id bigint NOT NULL,
    department_id bigint NOT NULL,
    academic_session text NOT NULL,
    semester integer NOT NULL,
    current_revision integer DEFAULT 1 NOT NULL,
    status text DEFAULT 'Under Review'::text NOT NULL,
    created_by bigint NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    updated_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    CONSTRAINT course_outcome_submission_semester_check CHECK (((semester >= 1) AND (semester <= 8))),
    CONSTRAINT course_outcome_submission_status_check CHECK ((status = ANY (ARRAY['Under Review'::text, 'Reviewed'::text, 'Clarification Requested'::text])))
);


ALTER TABLE public.course_outcome_submission OWNER TO campusexam;

--
-- Name: course_outcome_submission_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.course_outcome_submission ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.course_outcome_submission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: department; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.department (
    id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.department OWNER TO campusexam;

--
-- Name: department_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.department ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.department_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: exam; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.exam (
    id bigint NOT NULL,
    title text NOT NULL,
    instructions text NOT NULL,
    bank_id bigint NOT NULL,
    mode text NOT NULL,
    duration integer NOT NULL,
    attempt_limit integer NOT NULL,
    opens timestamp with time zone NOT NULL,
    closes timestamp with time zone NOT NULL,
    pass_marks numeric(12,2) NOT NULL,
    released boolean DEFAULT false NOT NULL,
    CONSTRAINT exam_attempt_limit_check CHECK (((attempt_limit >= 1) AND (attempt_limit <= 100))),
    CONSTRAINT exam_check CHECK ((closes > opens)),
    CONSTRAINT exam_duration_check CHECK (((duration >= 1) AND (duration <= 28800))),
    CONSTRAINT exam_mode_check CHECK ((mode = ANY (ARRAY['OFFICIAL'::text, 'PRACTICE'::text]))),
    CONSTRAINT exam_pass_marks_check CHECK ((pass_marks >= (0)::numeric))
);


ALTER TABLE public.exam OWNER TO campusexam;

--
-- Name: exam_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.exam ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.exam_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: exam_question; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.exam_question (
    exam_id bigint NOT NULL,
    "position" integer NOT NULL,
    prompt text NOT NULL,
    options text[] NOT NULL,
    correct integer NOT NULL,
    explanation text NOT NULL,
    topic text NOT NULL,
    difficulty text NOT NULL,
    marks numeric(8,2) NOT NULL,
    penalty numeric(8,2) NOT NULL,
    CONSTRAINT exam_question_position_check CHECK (("position" > 0))
);


ALTER TABLE public.exam_question OWNER TO campusexam;

--
-- Name: examination_cycle; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.examination_cycle (
    id bigint NOT NULL,
    title text NOT NULL,
    academic_session text NOT NULL,
    cycle_type text NOT NULL,
    created_by bigint NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.examination_cycle OWNER TO campusexam;

--
-- Name: examination_cycle_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.examination_cycle ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.examination_cycle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: examination_session; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.examination_session (
    id bigint NOT NULL,
    cycle_id bigint NOT NULL,
    subject_id bigint NOT NULL,
    department_id bigint NOT NULL,
    group_id bigint NOT NULL,
    session_date date NOT NULL,
    sitting text NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    duration_minutes integer NOT NULL,
    assigned_lab text NOT NULL,
    selected_paper_id bigint,
    status text DEFAULT 'SCHEDULED'::text NOT NULL,
    created_by bigint NOT NULL,
    frozen_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    total_marks numeric(8,2) DEFAULT 30.00 NOT NULL,
    passing_marks numeric(8,2) NOT NULL,
    cancellation_reason text,
    is_cancelled boolean DEFAULT false NOT NULL,
    package_revision integer DEFAULT 1 NOT NULL,
    CONSTRAINT chk_passing_marks_range CHECK (((passing_marks > (0)::numeric) AND (passing_marks <= total_marks))),
    CONSTRAINT examination_session_duration_minutes_check CHECK ((duration_minutes > 0)),
    CONSTRAINT examination_session_sitting_check CHECK ((sitting = ANY (ARRAY['MORNING'::text, 'AFTERNOON'::text]))),
    CONSTRAINT examination_session_status_check CHECK ((status = ANY (ARRAY['SCHEDULED'::text, 'FROZEN'::text, 'PACKAGE_EXPORTED'::text, 'RESULTS_IMPORTED'::text, 'APPROVED'::text, 'RELEASED'::text, 'CANCELLED'::text, 'RETIRED'::text])))
);


ALTER TABLE public.examination_session OWNER TO campusexam;

--
-- Name: examination_session_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.examination_session ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.examination_session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: faculty_scope; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.faculty_scope (
    faculty_id bigint NOT NULL,
    group_id bigint NOT NULL,
    subject_id bigint NOT NULL
);


ALTER TABLE public.faculty_scope OWNER TO campusexam;

--
-- Name: generated_paper; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.generated_paper (
    id bigint NOT NULL,
    bank_id bigint NOT NULL,
    paper_number integer NOT NULL,
    title text NOT NULL,
    status text DEFAULT 'READY'::text NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    CONSTRAINT generated_paper_paper_number_check CHECK (((paper_number >= 1) AND (paper_number <= 4))),
    CONSTRAINT generated_paper_status_check CHECK ((status = ANY (ARRAY['READY'::text, 'SELECTED'::text, 'CONSUMED'::text, 'RETIRED'::text])))
);


ALTER TABLE public.generated_paper OWNER TO campusexam;

--
-- Name: generated_paper_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.generated_paper ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.generated_paper_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: generated_paper_question; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.generated_paper_question (
    paper_id bigint NOT NULL,
    question_id bigint NOT NULL,
    module_number integer NOT NULL,
    paper_position integer NOT NULL,
    CONSTRAINT generated_paper_question_paper_position_check CHECK (((paper_position >= 1) AND (paper_position <= 30)))
);


ALTER TABLE public.generated_paper_question OWNER TO campusexam;

--
-- Name: lab_result_import; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.lab_result_import (
    id bigint NOT NULL,
    session_id bigint NOT NULL,
    raw_payload_json text NOT NULL,
    signature_hex text NOT NULL,
    total_candidates integer NOT NULL,
    attended integer NOT NULL,
    absent integer NOT NULL,
    highest_marks numeric(8,2) DEFAULT 0 NOT NULL,
    average_marks numeric(8,2) DEFAULT 0 NOT NULL,
    pass_percentage numeric(5,2) DEFAULT 0 NOT NULL,
    status text DEFAULT 'IMPORTED'::text NOT NULL,
    imported_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    imported_by bigint NOT NULL,
    approved_at timestamp with time zone,
    approved_by bigint,
    released_at timestamp with time zone,
    released_by bigint,
    CONSTRAINT lab_result_import_status_check CHECK ((status = ANY (ARRAY['IMPORTED'::text, 'APPROVED'::text, 'RELEASED'::text])))
);


ALTER TABLE public.lab_result_import OWNER TO campusexam;

--
-- Name: lab_result_import_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.lab_result_import ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.lab_result_import_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: paper_version; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.paper_version (
    id bigint NOT NULL,
    session_id bigint NOT NULL,
    paper_id bigint NOT NULL,
    version_letter text NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    CONSTRAINT paper_version_version_letter_check CHECK ((version_letter = ANY (ARRAY['A'::text, 'B'::text, 'C'::text, 'D'::text])))
);


ALTER TABLE public.paper_version OWNER TO campusexam;

--
-- Name: paper_version_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.paper_version ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.paper_version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: paper_version_question; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.paper_version_question (
    version_id bigint NOT NULL,
    question_id bigint NOT NULL,
    question_uid text NOT NULL,
    display_position integer NOT NULL,
    shuffled_options text[] NOT NULL,
    shuffled_correct integer NOT NULL,
    marks numeric(8,2) DEFAULT 1.00 NOT NULL,
    CONSTRAINT paper_version_question_display_position_check CHECK (((display_position >= 1) AND (display_position <= 30))),
    CONSTRAINT paper_version_question_shuffled_correct_check CHECK (((shuffled_correct >= 1) AND (shuffled_correct <= 4)))
);


ALTER TABLE public.paper_version_question OWNER TO campusexam;

--
-- Name: question; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.question (
    id bigint NOT NULL,
    bank_id bigint NOT NULL,
    prompt text NOT NULL,
    options text[] NOT NULL,
    correct integer NOT NULL,
    explanation text NOT NULL,
    topic text NOT NULL,
    difficulty text NOT NULL,
    marks numeric(8,2) NOT NULL,
    penalty numeric(8,2) NOT NULL,
    CONSTRAINT question_check CHECK (((penalty >= (0)::numeric) AND (penalty <= marks))),
    CONSTRAINT question_correct_check CHECK (((correct >= 1) AND (correct <= 4))),
    CONSTRAINT question_difficulty_check CHECK ((difficulty = ANY (ARRAY['EASY'::text, 'MEDIUM'::text, 'HARD'::text]))),
    CONSTRAINT question_marks_check CHECK ((marks > (0)::numeric)),
    CONSTRAINT question_options_check CHECK ((cardinality(options) = 4))
);


ALTER TABLE public.question OWNER TO campusexam;

--
-- Name: question_bank; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.question_bank (
    id bigint CONSTRAINT question_bank_id_not_null1 NOT NULL,
    department_id bigint NOT NULL,
    subject_id bigint NOT NULL,
    academic_session text NOT NULL,
    semester integer NOT NULL,
    title text NOT NULL,
    created_by bigint NOT NULL,
    revision_number integer DEFAULT 1 NOT NULL,
    state text DEFAULT 'DRAFT'::text NOT NULL,
    total_questions integer DEFAULT 0 NOT NULL,
    finalized_at timestamp with time zone,
    finalized_by bigint,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    CONSTRAINT question_bank_state_check CHECK ((state = ANY (ARRAY['DRAFT'::text, 'SUBMITTED'::text, 'FINALIZED'::text, 'REOPENED'::text, 'ARCHIVED'::text])))
);


ALTER TABLE public.question_bank OWNER TO campusexam;

--
-- Name: question_bank_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.question_bank ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.question_bank_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: question_bank_item; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.question_bank_item (
    id bigint NOT NULL,
    bank_id bigint NOT NULL,
    question_uid text NOT NULL,
    module_number integer NOT NULL,
    prompt text NOT NULL,
    options text[] NOT NULL,
    correct integer NOT NULL,
    explanation text,
    marks numeric(8,2) DEFAULT 1.00 NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    has_images boolean DEFAULT false NOT NULL,
    stem_images jsonb DEFAULT '[]'::jsonb,
    option_images jsonb DEFAULT '[]'::jsonb,
    CONSTRAINT question_bank_item_correct_check CHECK (((correct >= 1) AND (correct <= 4))),
    CONSTRAINT question_bank_item_module_number_check CHECK (((module_number >= 1) AND (module_number <= 5))),
    CONSTRAINT question_bank_item_options_check CHECK ((cardinality(options) = 4))
);


ALTER TABLE public.question_bank_item OWNER TO campusexam;

--
-- Name: question_bank_item_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.question_bank_item ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.question_bank_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: question_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.question ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: relogin_authorization; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.relogin_authorization (
    id bigint NOT NULL,
    session_id bigint NOT NULL,
    student_usn text NOT NULL,
    assigned_workstation_id text NOT NULL,
    target_workstation_id text DEFAULT 'Any Available PC'::text,
    token_id text NOT NULL,
    token_hash text NOT NULL,
    reason text NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    authorized_by bigint,
    authorized_at timestamp with time zone,
    expires_at timestamp with time zone NOT NULL,
    is_one_time_used boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    CONSTRAINT relogin_authorization_status_check CHECK ((status = ANY (ARRAY['PENDING'::text, 'APPROVED'::text, 'USED'::text, 'EXPIRED'::text])))
);


ALTER TABLE public.relogin_authorization OWNER TO campusexam;

--
-- Name: relogin_authorization_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.relogin_authorization ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.relogin_authorization_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: secure_package; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.secure_package (
    id bigint NOT NULL,
    session_id bigint NOT NULL,
    package_uid text NOT NULL,
    encrypted_payload text NOT NULL,
    encrypted_key_hex text NOT NULL,
    iv_hex text NOT NULL,
    signature_hex text NOT NULL,
    digest_hex text NOT NULL,
    status text DEFAULT 'PREPARED'::text NOT NULL,
    exported_at timestamp with time zone,
    exported_by bigint,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    CONSTRAINT secure_package_status_check CHECK ((status = ANY (ARRAY['PREPARED'::text, 'EXPORTED'::text, 'RECEIVED'::text, 'VERIFIED'::text, 'ACCEPTED'::text])))
);


ALTER TABLE public.secure_package OWNER TO campusexam;

--
-- Name: secure_package_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.secure_package ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.secure_package_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: security_violation_log; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.security_violation_log (
    id bigint NOT NULL,
    session_id bigint NOT NULL,
    student_usn text NOT NULL,
    workstation_id text,
    violation_type text NOT NULL,
    label text NOT NULL,
    description text NOT NULL,
    current_question_index integer,
    remaining_seconds integer,
    answered_count integer,
    logged_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    CONSTRAINT security_violation_log_violation_type_check CHECK ((violation_type = ANY (ARRAY['TAB_SWITCH'::text, 'WINDOW_BLUR'::text, 'SHORTCUT_KEY'::text, 'FULLSCREEN_EXIT'::text, 'DEVTOOLS_ATTEMPT'::text])))
);


ALTER TABLE public.security_violation_log OWNER TO campusexam;

--
-- Name: security_violation_log_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.security_violation_log ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.security_violation_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: session_roster_snapshot; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.session_roster_snapshot (
    session_id bigint NOT NULL,
    student_id bigint NOT NULL,
    usn text NOT NULL,
    full_name text NOT NULL,
    date_of_birth date NOT NULL
);


ALTER TABLE public.session_roster_snapshot OWNER TO campusexam;

--
-- Name: session_token; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.session_token (
    token_hash text NOT NULL,
    account_id bigint NOT NULL,
    expires timestamp with time zone NOT NULL
);


ALTER TABLE public.session_token OWNER TO campusexam;

--
-- Name: session_transfer_history; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.session_transfer_history (
    id bigint NOT NULL,
    session_id bigint NOT NULL,
    student_usn text NOT NULL,
    from_workstation text NOT NULL,
    to_workstation text NOT NULL,
    authorization_id bigint,
    reason text NOT NULL,
    transferred_by bigint NOT NULL,
    transferred_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.session_transfer_history OWNER TO campusexam;

--
-- Name: session_transfer_history_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.session_transfer_history ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.session_transfer_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: session_unlock_credential; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.session_unlock_credential (
    id bigint NOT NULL,
    session_id bigint NOT NULL,
    sitting_name text NOT NULL,
    masked_preview text NOT NULL,
    verifier_hash text NOT NULL,
    salt text NOT NULL,
    iterations integer DEFAULT 600000 NOT NULL,
    revision integer DEFAULT 1 NOT NULL,
    status text DEFAULT 'Active'::text NOT NULL,
    generated_by bigint NOT NULL,
    generated_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    last_synced_at timestamp with time zone,
    CONSTRAINT session_unlock_credential_sitting_name_check CHECK ((sitting_name = ANY (ARRAY['MORNING'::text, 'AFTERNOON'::text]))),
    CONSTRAINT session_unlock_credential_status_check CHECK ((status = ANY (ARRAY['Active'::text, 'Revoked'::text, 'Expired'::text, 'Superseded'::text])))
);


ALTER TABLE public.session_unlock_credential OWNER TO campusexam;

--
-- Name: session_unlock_credential_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.session_unlock_credential ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.session_unlock_credential_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: student_roster; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.student_roster (
    id bigint NOT NULL,
    usn text NOT NULL,
    full_name text NOT NULL,
    date_of_birth date NOT NULL,
    group_id bigint NOT NULL,
    department_id bigint NOT NULL,
    semester integer NOT NULL,
    section text NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.student_roster OWNER TO campusexam;

--
-- Name: student_roster_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.student_roster ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.student_roster_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: student_session_result; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.student_session_result (
    id bigint NOT NULL,
    import_id bigint NOT NULL,
    session_id bigint NOT NULL,
    usn text NOT NULL,
    full_name text NOT NULL,
    assigned_version text NOT NULL,
    total_questions integer NOT NULL,
    correct_count integer NOT NULL,
    incorrect_count integer NOT NULL,
    unanswered_count integer NOT NULL,
    score numeric(8,2) NOT NULL,
    passed boolean NOT NULL,
    submission_status text NOT NULL
);


ALTER TABLE public.student_session_result OWNER TO campusexam;

--
-- Name: student_session_result_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.student_session_result ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.student_session_result_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: subject; Type: TABLE; Schema: public; Owner: campusexam
--

CREATE TABLE public.subject (
    id bigint NOT NULL,
    name text NOT NULL,
    code text,
    department_id bigint,
    semester integer DEFAULT 1,
    applicable_sections text[] DEFAULT ARRAY['Section A'::text, 'Section B'::text]
);


ALTER TABLE public.subject OWNER TO campusexam;

--
-- Name: subject_id_seq; Type: SEQUENCE; Schema: public; Owner: campusexam
--

ALTER TABLE public.subject ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.subject_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: academic_group; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.academic_group (id, department, academic_session, study_year, semester, section, department_id, year) FROM stdin;
1	CSE	2025-2026	1	2	A	1	1
2	CSE	2026-27	3	5	C	1	3
3	CSE	2026-27	1	5	D	1	3
5	CSE	2026-27	3	5	A	1	3
7	CSE	2025-26	3	5	Section B	1	3
8	CIVIL	2025-26	3	5	Section A	2	3
9	CIVIL	2025-26	3	5	Section B	2	3
10	CSE-AI	2025-26	3	5	Section A	5	3
11	CSE-AI	2025-26	3	5	Section B	5	3
12	CSE-DS	2025-26	3	5	Section A	6	3
13	CSE-DS	2025-26	3	5	Section B	6	3
14	CSE-BS	2025-26	3	5	Section A	7	3
15	CSE-BS	2025-26	3	5	Section B	7	3
16	CSE-AIML	2025-26	3	5	Section A	8	3
17	CSE-AIML	2025-26	3	5	Section B	8	3
18	CSE-IOTCS	2025-26	3	5	Section A	9	3
19	CSE-IOTCS	2025-26	3	5	Section B	9	3
20	COMP	2025-26	3	5	Section A	10	3
21	COMP	2025-26	3	5	Section B	10	3
22	ECE	2025-26	3	5	Section A	11	3
23	ECE	2025-26	3	5	Section B	11	3
24	ISE	2025-26	3	5	Section A	12	3
25	ISE	2025-26	3	5	Section B	12	3
26	MECH	2025-26	3	5	Section A	13	3
27	MECH	2025-26	3	5	Section B	13	3
95	CSE	2026-27	2	3	A	1	2
96	CSE	2026-27	2	3	B	1	2
97	CSE	2025-26	3	5	Section A	1	3
141	E158CI	2025-26	3	5	Section A	60	3
142	E158CI	2025-26	3	5	Section B	60	3
\.


--
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.account (id, username, password_hash, role, group_id, department_id, full_name, email, created_at, contact_number, employee_id, designation, status, last_login_at, theme_preference) FROM stdin;
2	4mh25cs001	d757c5598ae41cc105b41655b31e85b3:c03ebb297aa716cdfdef73901e63cd757fc296c29ba281a729b01fa01713ff95	STUDENT	1	\N	\N	\N	2026-11-17 22:53:38.958699+05:30	\N	\N	\N	ACTIVE	\N	system
15	hod.cse.aiml	614bd3cd4a54305d032d7b1356ebadd1:f5ed4f8bc8a739fbfb0d21846405b3d58a009803878de6c157b9763989ebf024	HOD	\N	8	HOD CSE - AI & ML	hod.cse.aiml@mitmysore.in	2026-11-19 09:35:13.377422+05:30	\N	EMP-HOD.CSE.AIML	Head of Department	ACTIVE	\N	system
8	4mh25cs097	8bef67341cf6bc1ecb0ed32f01f7afc3:a2501fbebdae3b5e856a71e4634b976a1135ccfd5ed839bebb6a22cb5de69d73	STUDENT	\N	\N	Candidate 4MH25CS097	\N	2026-11-18 14:46:44.681329+05:30	\N	\N	\N	ACTIVE	\N	system
9	4mh25cs096	9aa2f127e919b1f6b2db7e55e2df3ab3:796f1642ebbecb54928834c3eb4816c687eaad5845908c72ce37b77b2bc6acca	STUDENT	\N	\N	Candidate 4MH25CS096	\N	2026-11-18 15:12:30.196251+05:30	\N	\N	\N	ACTIVE	\N	system
6	4mh25cs129	626d51759eb8f6610638dfce20a97c8a:5e7a57c37dd136e37b5fd99c4355664108234c77f66f7138efb3e0bcc1328ff0	STUDENT	\N	\N	Candidate 4MH25CS129	\N	2026-11-18 00:04:31.806755+05:30	\N	\N	\N	ACTIVE	\N	system
16	hod.cse.iotcs	35e037a3bcb6f5219708ecb4bb0e7006:b18bfecc6022a9dd88054d718b84a009aa8efe4cc19f72ee070aa8cafeef20b1	HOD	\N	9	HOD CSE - IoT & Cyber Security	hod.cse.iotcs@mitmysore.in	2026-11-19 09:35:13.522592+05:30	\N	EMP-HOD.CSE.IOTCS	Head of Department	ACTIVE	2026-11-19 10:21:13.964119+05:30	system
10	4mh25cs121	77228dade22b960365fe4870b45ac158:0389cb9398ebce2c03fe7e9ca5ed6183e886be6a8fbfab516581fc8485094ae0	STUDENT	\N	\N	Candidate 4MH25CS121	\N	2026-11-18 15:52:46.659241+05:30	\N	\N	\N	ACTIVE	\N	system
3	principal	e7903b0b92e884af70f5b53c4051386f:d01f1e45b5b5488ee92016d595bf512ee5f441f2fcb32fe1fada7fee78517ba0	PRINCIPAL	\N	\N	Principal	principal@mitmysore.in	2026-11-17 23:49:31.183097+05:30	\N	\N	Principal & Chief Academic Officer	ACTIVE	2026-11-19 11:56:02.353187+05:30	system
5	coe	f41be4da2d5d76bce51476fed7fa8a95:2779de7ba760acfb8c931b7b43362e460ed693b71c7c84565ce84170dc652df9	COE	\N	\N	Controller of Examinations	coe@mitmysore.in	2026-11-17 23:49:31.184903+05:30	\N	\N	Controller of Examinations	ACTIVE	2026-11-19 12:00:02.904621+05:30	system
11	hod.civil	8619761b69d7b757b678a3b137f8ba0f:701bf024f55c7efe8d7801f4736fc4bb0e8ed36cad3537d713a85874f620a5b4	HOD	\N	2	HOD Civil Engineering	hod.civil@mitmysore.in	2026-11-19 09:35:12.519062+05:30	\N	EMP-HOD.CIVIL	Head of Department	ACTIVE	\N	system
12	hod.cse.ai	8589d81e42e5ddb2c312f53ad50ebea4:bc761e8325dd2e11c80805737d2ce918dd0c467b5f26c66456ffa031c03a6047	HOD	\N	5	HOD CSE - Artificial Intelligence	hod.cse.ai@mitmysore.in	2026-11-19 09:35:12.896451+05:30	\N	EMP-HOD.CSE.AI	Head of Department	ACTIVE	\N	system
1	admin	00f495dfe5ab5c41f6ac73e61080affb:f43e57ab877a269ce12935f9f4e3735d8e389ef76cb3414bfc5649470ac5e685	ADMIN	\N	\N	System Administrator	\N	2026-11-17 22:53:38.958424+05:30	\N	\N	Central Administrator	ACTIVE	2026-11-19 12:35:01.584193+05:30	system
13	hod.cse.ds	a8024f93847f85e2fe00e30f4229ca69:da7f4e65e08ab21978337fd7e81d4800bf87ac33be3c10533a58440b67ee2e44	HOD	\N	6	HOD CSE - Data Science	hod.cse.ds@mitmysore.in	2026-11-19 09:35:13.056804+05:30	\N	EMP-HOD.CSE.DS	Head of Department	ACTIVE	\N	system
14	hod.cse.bs	252d55cec2b9513ccc7f7f19c55a7f37:5074a1f1dc8d5a2f7efd4171b11c94ceafe226290786a084e67b974627e6b718	HOD	\N	7	HOD CSE - Business Systems	hod.cse.bs@mitmysore.in	2026-11-19 09:35:13.228654+05:30	\N	EMP-HOD.CSE.BS	Head of Department	ACTIVE	\N	system
23	hod_e158ci	cdbc43ce01cff07fa0a58376c61f64e9:2b2af11cdf4e8ad4a531fb1ed1cdfdc3289beea796fd7eb24c54b807a31e905c	HOD	\N	60	Aryaman M	aryamanm77@gmail.com	2026-11-19 12:13:04.36983+05:30	07892713585	GHJKL3;3	Head of Department	ACTIVE	\N	system
17	hod.comp	b5f3fc4fc4d894b5fd3a258a7e552c3f:4ccfc4c38ed7c40db1cba234861adc02fa5223ecf5c1ccad56fb686fa1fc0a7a	HOD	\N	10	HOD Computer Engineering	hod.comp@mitmysore.in	2026-11-19 09:35:13.655001+05:30	\N	EMP-HOD.COMP	Head of Department	ACTIVE	\N	system
18	hod.ece	3404646334ca817859530c4be692c279:b257a97d1e4838c979dc978df61078fb38313d7264cb22596fe1bb42e01fc856	HOD	\N	11	HOD Electronics & Communication Engineering	hod.ece@mitmysore.in	2026-11-19 09:35:13.785688+05:30	\N	EMP-HOD.ECE	Head of Department	ACTIVE	2026-11-19 10:21:38.352455+05:30	system
19	hod.ise	ff940eedce4d7ce00f471eba5a683544:af5266f6fc67ecd613b7c274ff9bbe3e346b5222c742876b9933a8524c4f28d9	HOD	\N	12	HOD Information Science & Engineering	hod.ise@mitmysore.in	2026-11-19 09:35:13.911218+05:30	\N	EMP-HOD.ISE	Head of Department	ACTIVE	\N	system
20	hod.mech	355978704f26fd89eca120c5eb67e776:1f49dd8885e0e3a82156ca2584bb8cb921b8c84ed2512b92e5466f72d2eca66c	HOD	\N	13	HOD Mechanical Engineering	hod.mech@mitmysore.in	2026-11-19 09:35:14.035848+05:30	\N	EMP-HOD.MECH	Head of Department	ACTIVE	\N	system
\.


--
-- Data for Name: answer; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.answer (attempt_id, exam_id, "position", choice, review, version) FROM stdin;
1	1	1	1	f	1
2	1	2	3	f	1
2	1	1	2	f	1
\.


--
-- Data for Name: answer_key_correction; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.answer_key_correction (id, session_id, subject_id, question_uid, question_text, original_correct, proposed_correct, reason, status, submitted_by, submitted_at, decided_by, decided_at, decision_reason) FROM stdin;
\.


--
-- Data for Name: assignment; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.assignment (exam_id, student_id) FROM stdin;
1	2
\.


--
-- Data for Name: attempt; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.attempt (id, exam_id, student_id, started, deadline, last_seen, submitted, reason, score, pending) FROM stdin;
1	1	2	2026-11-09 23:55:18.842875+05:30	2026-11-10 00:25:18.842875+05:30	2026-11-09 23:55:21.320686+05:30	2026-11-09 23:55:24.346268+05:30	MANUAL	0.00	0
2	1	2	2026-11-09 23:55:27.278656+05:30	2026-11-10 00:25:27.278656+05:30	2026-11-09 23:55:42.375561+05:30	2026-11-10 00:25:27.699548+05:30	DEADLINE	5.00	0
\.


--
-- Data for Name: audit; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.audit (id, happened, actor, action, entity, detail) FROM stdin;
1	2026-11-09 23:48:12.702971+05:30	1	groups	1	
2	2026-11-09 23:48:29.688479+05:30	1	accounts	2	
3	2026-11-09 23:50:32.500219+05:30	1	subjects	1	
4	2026-11-09 23:50:32.583658+05:30	1	BANK_CREATED	1	
5	2026-11-09 23:50:32.677212+05:30	1	QUESTION_CREATED	1	
6	2026-11-09 23:50:32.750334+05:30	1	QUESTION_CREATED	2	
7	2026-11-09 23:53:54.491421+05:30	1	subjects	2	
8	2026-11-09 23:54:00.937798+05:30	1	BANK_CREATED	2	
9	2026-11-09 23:54:08.66255+05:30	1	QUESTION_CREATED	3	
10	2026-11-09 23:54:08.763548+05:30	1	QUESTION_CREATED	4	
11	2026-11-09 23:54:50.046598+05:30	1	BANK_SUBMITTED	2	
12	2026-11-09 23:54:55.507664+05:30	1	BANK_APPROVED	2	
13	2026-11-09 23:55:04.694271+05:30	1	EXAM_PUBLISHED	1	
14	2026-11-09 23:55:18.843998+05:30	2	ATTEMPT_STARTED	1	
15	2026-11-09 23:55:24.347308+05:30	2	ATTEMPT_SUBMITTED	1	MANUAL
16	2026-11-09 23:55:27.279405+05:30	2	ATTEMPT_STARTED	2	
17	2026-11-10 00:25:27.700557+05:30	\N	ATTEMPT_SUBMITTED	2	DEADLINE
18	2026-11-17 23:12:32.163027+05:30	1	USER_LOGIN_V1	account:1	Logged in via V1 Auth API
19	2026-11-17 23:12:38.391277+05:30	1	USER_LOGIN_V1	account:1	Logged in via V1 Auth API
20	2026-11-17 23:14:16.652784+05:30	1	USER_LOGIN_V1	account:1	Logged in via V1 Auth API
21	2026-11-17 23:14:31.806561+05:30	1	COE_LOGIN_V1	account:1	COE logged in via V1 Auth API
22	2026-11-17 23:40:56.757399+05:30	1	USER_LOGIN_V1	account:1	Logged in via V1 Auth API
23	2026-11-17 23:50:33.345729+05:30	1	USER_LOGIN_V1	account:1	Logged in via V1 Auth API
24	2026-11-17 23:51:15.348922+05:30	3	USER_LOGIN_V1	account:3	Logged in via V1 Auth API
26	2026-11-17 23:52:06.171977+05:30	5	COE_LOGIN_V1	account:5	COE logged in via V1 Auth API
27	2026-11-18 00:11:11.734945+05:30	5	COE_LOGIN_V1	account:5	COE logged in via V1 Auth API
28	2026-11-18 00:14:21.917735+05:30	5	CHANGE_PASSWORD_V1	account:5	Password changed successfully
29	2026-11-18 00:15:08.783741+05:30	5	COE_LOGIN_V1	account:5	COE logged in via V1 Auth API
30	2026-11-18 00:15:42.681004+05:30	1	USER_LOGIN_V1	account:1	Logged in via V1 Auth API
31	2026-11-18 00:17:03.236255+05:30	1	CREATE_HOD_DEPARTMENT	department:2	Created HOD pfpf (CIVIL)
32	2026-11-18 00:18:51.954306+05:30	3	USER_LOGIN_V1	account:3	Logged in via V1 Auth API
36	2026-11-18 01:16:25.225898+05:30	5	COE_LOGIN_V1	account:5	COE logged in via V1 Auth API
44	2026-11-18 11:28:28.205392+05:30	5	COE_LOGIN_V1	account:5	COE logged in via V1 Auth API
45	2026-11-18 11:29:09.304501+05:30	1	USER_LOGIN_V1	account:1	Logged in via V1 Auth API
47	2026-11-18 14:09:09.31008+05:30	5	COE_LOGIN_V1	account:5	COE logged in via V1 Auth API
51	2026-11-18 14:38:33.260933+05:30	1	USER_LOGIN_V1	account:1	Logged in via V1 Auth API
52	2026-11-18 14:39:43.066497+05:30	3	USER_LOGIN_V1	account:3	Logged in via V1 Auth API
54	2026-11-18 14:44:22.372272+05:30	5	COE_LOGIN_V1	account:5	COE logged in via V1 Auth API
61	2026-11-18 15:20:28.282827+05:30	5	COE_LOGIN_V1	account:5	COE logged in via V1 Auth API
25	2026-11-17 23:51:34.626935+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
65	2026-11-18 15:27:13.991895+05:30	6	SECURITY_UNLOCK_APPROVED	session:11:student:4MH25CS129	Invigilator override approved (total violations: 0)
66	2026-11-18 15:27:28.986866+05:30	6	STUDENT_EXAM_SUBMITTED	exam_submission:11:4MH25CS129	{"success":true,"status":"SUBMITTED","completionState":"COMPLETED","confirmationReference":"CONF-MITM-1A1CD3A6","confirmationCode":"CONF-MITM-1A1CD3A6","examinationId":"11","sessionId":"11","studentUsn":"4MH25CS129","studentName":"Candidate 4MH25CS129","department":"Computer Science and Engineering","semester":"4","section":"A","subjectCode":"CS401","subjectName":"Database Management Systems","examinationType":"Main Lab Examination","assignedWorkstationId":"PC-01","submittedAt":"2026-11-18T09:57:28.985082800Z","submissionTrigger":"MANUAL","totalQuestions":30,"answeredCount":2,"totalAnswered":2,"unansweredCount":28}
71	2026-11-18 15:47:59.581147+05:30	5	COE_LOGIN_V1	account:5	COE logged in via V1 Auth API
72	2026-11-18 15:51:06.236928+05:30	6	POST_SUBMISSION_RELOGIN_BLOCKED	exam_submission:11:4MH25CS129	Blocked post-submission re-login attempt by 4MH25CS129 on workstation PC-01; terminal lockdown triggered.
73	2026-11-18 15:51:48.988235+05:30	6	POST_SUBMISSION_LOCKDOWN_RESET	session:11:student:4MH25CS129	Invigilator unlocked post-submission re-login lockdown back to clean Login screen (exam remains permanently SUBMITTED).
74	2026-11-18 15:52:08.027478+05:30	6	POST_SUBMISSION_RELOGIN_BLOCKED	exam_submission:11:4MH25CS129	Blocked post-submission re-login attempt by 4MH25CS129 on workstation PC-01; terminal lockdown triggered.
75	2026-11-18 15:52:24.570404+05:30	6	POST_SUBMISSION_LOCKDOWN_RESET	session:11:student:4MH25CS129	Invigilator unlocked post-submission re-login lockdown back to clean Login screen (exam remains permanently SUBMITTED).
76	2026-11-18 15:52:58.231959+05:30	10	STUDENT_EXAM_SUBMITTED	exam_submission:11:4MH25CS121	{"success":true,"status":"SUBMITTED","completionState":"COMPLETED","confirmationReference":"CONF-MITM-E9AADDB7","confirmationCode":"CONF-MITM-E9AADDB7","examinationId":"11","sessionId":"11","studentUsn":"4MH25CS121","studentName":"Candidate 4MH25CS121","department":"Computer Science and Engineering","semester":"4","section":"A","subjectCode":"CS401","subjectName":"Database Management Systems","examinationType":"Main Lab Examination","assignedWorkstationId":"PC-01","submittedAt":"2026-11-18T10:22:58.230020700Z","submissionTrigger":"MANUAL","totalQuestions":30,"answeredCount":1,"totalAnswered":1,"unansweredCount":29}
77	2026-11-18 15:53:18.722923+05:30	10	POST_SUBMISSION_RELOGIN_BLOCKED	exam_submission:11:4MH25CS121	Blocked post-submission re-login attempt by 4MH25CS121 on workstation PC-01; terminal lockdown triggered.
79	2026-11-18 19:40:20.493324+05:30	5	COE_LOGIN_V1	account:5	COE logged in via V1 Auth API
82	2026-11-19 09:48:46.401005+05:30	5	COE_LOGIN_V1	account:5	COE logged in via V1 Auth API
83	2026-11-19 09:49:32.023296+05:30	5	COE_LOGIN_V1	account:5	COE logged in via V1 Auth API
84	2026-11-19 09:53:14.180361+05:30	1	USER_LOGIN_V1	account:1	Logged in via V1 Auth API
85	2026-11-19 09:54:03.520046+05:30	1	USER_LOGIN_V1	account:1	Logged in via V1 Auth API
88	2026-11-19 09:56:46.564803+05:30	5	COE_LOGIN_V1	account:5	COE logged in via V1 Auth API
89	2026-11-19 09:59:25.317166+05:30	1	USER_LOGIN_V1	account:1	Logged in via V1 Auth API
99	2026-11-19 10:08:48.049091+05:30	1	USER_LOGIN_V1	account:1	Logged in via V1 Auth API
100	2026-11-19 10:13:09.470188+05:30	1	TOGGLE_HOD_STATUS	account:7	Changed status to INACTIVE
101	2026-11-19 10:13:44.816186+05:30	1	TOGGLE_HOD_STATUS	account:7	Changed status to ACTIVE
102	2026-11-19 10:18:15.378751+05:30	1	USER_LOGIN_V1	account:1	Logged in via V1 Auth API
104	2026-11-19 10:20:08.908482+05:30	18	USER_LOGIN_V1	account:18	Logged in via V1 Auth API
105	2026-11-19 10:21:13.966916+05:30	16	USER_LOGIN_V1	account:16	Logged in via V1 Auth API
106	2026-11-19 10:21:38.356348+05:30	18	USER_LOGIN_V1	account:18	Logged in via V1 Auth API
113	2026-11-19 11:56:02.355807+05:30	3	USER_LOGIN_V1	account:3	Logged in via V1 Auth API
114	2026-11-19 11:56:29.880057+05:30	3	CREATE_HOD_DEPARTMENT	department:58	Created HOD Dr. Arya Auto (E158RRTTGGCI)
115	2026-11-19 11:56:49.6321+05:30	3	DELETE_HOD	account:21	Deleted HOD Dr. Arya Auto (hod_e158rrttggci)
118	2026-11-19 12:00:02.90717+05:30	5	COE_LOGIN_V1	account:5	COE logged in via V1 Auth API
120	2026-11-19 12:12:05.72806+05:30	1	CREATE_HOD_DEPARTMENT	department:59	Created HOD Aryaman M (MHCS093KSLOMPS)
121	2026-11-19 12:12:13.361954+05:30	1	DELETE_HOD	account:22	Deleted HOD Aryaman M (hod_mhcs093kslomps)
122	2026-11-19 12:12:25.795688+05:30	1	DELETE_HOD	account:7	Deleted HOD pfpf (hod_civil)
123	2026-11-19 12:13:04.370658+05:30	1	CREATE_HOD_DEPARTMENT	department:60	Created HOD Aryaman M (E158CI)
131	2026-11-19 12:35:01.586408+05:30	1	USER_LOGIN_V1	account:1	Logged in via V1 Auth API
33	2026-11-18 00:19:34.253545+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
34	2026-11-18 00:40:49.891243+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
35	2026-11-18 01:09:36.848764+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
37	2026-11-18 01:17:01.875357+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
38	2026-11-18 01:17:12.739635+05:30	1	ADD_SECTION	academic_group:2	Added Section C to Sem 5
39	2026-11-18 01:20:13.509867+05:30	1	CREATE_SUBJECT	subject:3	Created 69 - ai
40	2026-11-18 01:35:09.381005+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
41	2026-11-18 01:35:22.407325+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
42	2026-11-18 01:35:22.452673+05:30	1	ADD_SECTION	academic_group:3	Added Section D to Sem 5
43	2026-11-18 01:35:22.532017+05:30	1	CREATE_SUBJECT	subject:4	Created CS502 - Web Technology
46	2026-11-18 11:29:39.648593+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
48	2026-11-18 14:11:03.124389+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
49	2026-11-18 14:15:57.876404+05:30	1	ADD_SECTION	academic_group:4	Added Section SEXY to Sem 5
50	2026-11-18 14:16:14.987852+05:30	1	CREATE_SUBJECT	subject:5	Created 6969 - sexy asubject
53	2026-11-18 14:40:32.674172+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
55	2026-11-18 14:55:26.910311+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
56	2026-11-18 15:19:14.74107+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
57	2026-11-18 15:19:40.227197+05:30	1	BULK_UPLOAD_QUESTIONS	question_bank:1	Imported 600 questions into question bank (0 skipped duplicates)
58	2026-11-18 15:20:08.785675+05:30	1	HOD_QUESTION_SET_GENERATED	subject_generation:3	{"generationId":"GEN-3-1794995408751","departmentId":"1","semesterNumber":5,"subjectId":"3","questionBankRevisionId":"QBR-1-600","blueprintRevisionId":"BPR-30","generatedSetCount":20,"questionsPerSet":30,"moduleDistribution":{"1":6,"2":6,"3":6,"4":6,"5":6},"totalUniqueQuestionsAllocated":600,"poolQuestionCount":600,"overlapAcrossSets":0,"integrityVerified":true,"publicationStatus":"Not Published","setStatuses":[{"setNumber":1,"setLabel":"Set 1","questionCount":30,"status":"Available"},{"setNumber":2,"setLabel":"Set 2","questionCount":30,"status":"Available"},{"setNumber":3,"setLabel":"Set 3","questionCount":30,"status":"Available"},{"setNumber":4,"setLabel":"Set 4","questionCount":30,"status":"Available"},{"setNumber":5,"setLabel":"Set 5","questionCount":30,"status":"Available"},{"setNumber":6,"setLabel":"Set 6","questionCount":30,"status":"Available"},{"setNumber":7,"setLabel":"Set 7","questionCount":30,"status":"Available"},{"setNumber":8,"setLabel":"Set 8","questionCount":30,"status":"Available"},{"setNumber":9,"setLabel":"Set 9","questionCount":30,"status":"Available"},{"setNumber":10,"setLabel":"Set 10","questionCount":30,"status":"Available"},{"setNumber":11,"setLabel":"Set 11","questionCount":30,"status":"Available"},{"setNumber":12,"setLabel":"Set 12","questionCount":30,"status":"Available"},{"setNumber":13,"setLabel":"Set 13","questionCount":30,"status":"Available"},{"setNumber":14,"setLabel":"Set 14","questionCount":30,"status":"Available"},{"setNumber":15,"setLabel":"Set 15","questionCount":30,"status":"Available"},{"setNumber":16,"setLabel":"Set 16","questionCount":30,"status":"Available"},{"setNumber":17,"setLabel":"Set 17","questionCount":30,"status":"Available"},{"setNumber":18,"setLabel":"Set 18","questionCount":30,"status":"Available"},{"setNumber":19,"setLabel":"Set 19","questionCount":30,"status":"Available"},{"setNumber":20,"setLabel":"Set 20","questionCount":30,"status":"Available"}]}
59	2026-11-18 15:20:08.98264+05:30	1	HOD_QUESTION_SET_PUBLISHED	subject_publication:3	{"id":"PUB-3-1","generationId":"GEN-3-1794995408751","subjectId":"3","subjectCode":"69","subjectName":"ai","departmentId":"1","semesterNumber":5,"revisionNumber":"R1","questionBankRevisionId":"QBR-1-600","blueprintRevisionId":"BPR-30","blueprint":{"totalQuestions":30,"totalQuestionsPerSet":30,"moduleDistribution":{"1":6,"2":6,"3":6,"4":6,"5":6}},"poolQuestionCount":600,"setsGeneratedCount":20,"totalUniqueQuestionsAllocated":600,"setStatuses":[{"setNumber":1,"setLabel":"Set 1","questionCount":30,"status":"Available"},{"setNumber":2,"setLabel":"Set 2","questionCount":30,"status":"Available"},{"setNumber":3,"setLabel":"Set 3","questionCount":30,"status":"Available"},{"setNumber":4,"setLabel":"Set 4","questionCount":30,"status":"Available"},{"setNumber":5,"setLabel":"Set 5","questionCount":30,"status":"Available"},{"setNumber":6,"setLabel":"Set 6","questionCount":30,"status":"Available"},{"setNumber":7,"setLabel":"Set 7","questionCount":30,"status":"Available"},{"setNumber":8,"setLabel":"Set 8","questionCount":30,"status":"Available"},{"setNumber":9,"setLabel":"Set 9","questionCount":30,"status":"Available"},{"setNumber":10,"setLabel":"Set 10","questionCount":30,"status":"Available"},{"setNumber":11,"setLabel":"Set 11","questionCount":30,"status":"Available"},{"setNumber":12,"setLabel":"Set 12","questionCount":30,"status":"Available"},{"setNumber":13,"setLabel":"Set 13","questionCount":30,"status":"Available"},{"setNumber":14,"setLabel":"Set 14","questionCount":30,"status":"Available"},{"setNumber":15,"setLabel":"Set 15","questionCount":30,"status":"Available"},{"setNumber":16,"setLabel":"Set 16","questionCount":30,"status":"Available"},{"setNumber":17,"setLabel":"Set 17","questionCount":30,"status":"Available"},{"setNumber":18,"setLabel":"Set 18","questionCount":30,"status":"Available"},{"setNumber":19,"setLabel":"Set 19","questionCount":30,"status":"Available"},{"setNumber":20,"setLabel":"Set 20","questionCount":30,"status":"Available"}],"status":"Published","publishedBy":"hod.cse","publishedAt":"2026-11-18T09:50:08.982366700Z","notes":"Generated 4 disjoint sets (4 versions each) across 5 modules"}
60	2026-11-18 15:20:08.98313+05:30	1	PUBLISH_QUESTION_SETS	question_bank:1	Published 20 Disjoint Question Sets (R1) to COE
62	2026-11-18 15:20:47.266916+05:30	1	HOD_QUESTION_SET_GENERATED	subject_generation:3	{"generationId":"GEN-3-1794995447249","departmentId":"1","semesterNumber":5,"subjectId":"3","questionBankRevisionId":"QBR-1-600","blueprintRevisionId":"BPR-30","generatedSetCount":20,"questionsPerSet":30,"moduleDistribution":{"1":6,"2":6,"3":6,"4":6,"5":6},"totalUniqueQuestionsAllocated":600,"poolQuestionCount":600,"overlapAcrossSets":0,"integrityVerified":true,"publicationStatus":"Not Published","setStatuses":[{"setNumber":1,"setLabel":"Set 1","questionCount":30,"status":"Available"},{"setNumber":2,"setLabel":"Set 2","questionCount":30,"status":"Available"},{"setNumber":3,"setLabel":"Set 3","questionCount":30,"status":"Available"},{"setNumber":4,"setLabel":"Set 4","questionCount":30,"status":"Available"},{"setNumber":5,"setLabel":"Set 5","questionCount":30,"status":"Available"},{"setNumber":6,"setLabel":"Set 6","questionCount":30,"status":"Available"},{"setNumber":7,"setLabel":"Set 7","questionCount":30,"status":"Available"},{"setNumber":8,"setLabel":"Set 8","questionCount":30,"status":"Available"},{"setNumber":9,"setLabel":"Set 9","questionCount":30,"status":"Available"},{"setNumber":10,"setLabel":"Set 10","questionCount":30,"status":"Available"},{"setNumber":11,"setLabel":"Set 11","questionCount":30,"status":"Available"},{"setNumber":12,"setLabel":"Set 12","questionCount":30,"status":"Available"},{"setNumber":13,"setLabel":"Set 13","questionCount":30,"status":"Available"},{"setNumber":14,"setLabel":"Set 14","questionCount":30,"status":"Available"},{"setNumber":15,"setLabel":"Set 15","questionCount":30,"status":"Available"},{"setNumber":16,"setLabel":"Set 16","questionCount":30,"status":"Available"},{"setNumber":17,"setLabel":"Set 17","questionCount":30,"status":"Available"},{"setNumber":18,"setLabel":"Set 18","questionCount":30,"status":"Available"},{"setNumber":19,"setLabel":"Set 19","questionCount":30,"status":"Available"},{"setNumber":20,"setLabel":"Set 20","questionCount":30,"status":"Available"}]}
103	2026-11-19 10:18:21.868579+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
107	2026-11-19 10:21:46.488867+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
108	2026-11-19 10:23:21.043352+05:30	1	CREATE_SUBJECT	subject:6	Created MH25CS0303 - DSA
63	2026-11-18 15:20:47.441185+05:30	1	HOD_QUESTION_SET_PUBLISHED	subject_publication:3	{"id":"PUB-3-2","generationId":"GEN-3-1794995447249","subjectId":"3","subjectCode":"69","subjectName":"ai","departmentId":"1","semesterNumber":5,"revisionNumber":"R2","questionBankRevisionId":"QBR-1-600","blueprintRevisionId":"BPR-30","blueprint":{"totalQuestions":30,"totalQuestionsPerSet":30,"moduleDistribution":{"1":6,"2":6,"3":6,"4":6,"5":6}},"poolQuestionCount":600,"setsGeneratedCount":20,"totalUniqueQuestionsAllocated":600,"setStatuses":[{"setNumber":1,"setLabel":"Set 1","questionCount":30,"status":"Available"},{"setNumber":2,"setLabel":"Set 2","questionCount":30,"status":"Available"},{"setNumber":3,"setLabel":"Set 3","questionCount":30,"status":"Available"},{"setNumber":4,"setLabel":"Set 4","questionCount":30,"status":"Available"},{"setNumber":5,"setLabel":"Set 5","questionCount":30,"status":"Available"},{"setNumber":6,"setLabel":"Set 6","questionCount":30,"status":"Available"},{"setNumber":7,"setLabel":"Set 7","questionCount":30,"status":"Available"},{"setNumber":8,"setLabel":"Set 8","questionCount":30,"status":"Available"},{"setNumber":9,"setLabel":"Set 9","questionCount":30,"status":"Available"},{"setNumber":10,"setLabel":"Set 10","questionCount":30,"status":"Available"},{"setNumber":11,"setLabel":"Set 11","questionCount":30,"status":"Available"},{"setNumber":12,"setLabel":"Set 12","questionCount":30,"status":"Available"},{"setNumber":13,"setLabel":"Set 13","questionCount":30,"status":"Available"},{"setNumber":14,"setLabel":"Set 14","questionCount":30,"status":"Available"},{"setNumber":15,"setLabel":"Set 15","questionCount":30,"status":"Available"},{"setNumber":16,"setLabel":"Set 16","questionCount":30,"status":"Available"},{"setNumber":17,"setLabel":"Set 17","questionCount":30,"status":"Available"},{"setNumber":18,"setLabel":"Set 18","questionCount":30,"status":"Available"},{"setNumber":19,"setLabel":"Set 19","questionCount":30,"status":"Available"},{"setNumber":20,"setLabel":"Set 20","questionCount":30,"status":"Available"}],"status":"Published","publishedBy":"hod.cse","publishedAt":"2026-11-18T09:50:47.440363800Z","notes":"Generated 4 disjoint sets (4 versions each) across 5 modules"}
64	2026-11-18 15:20:47.441884+05:30	1	PUBLISH_QUESTION_SETS	question_bank:1	Published 20 Disjoint Question Sets (R2) to COE
67	2026-11-18 15:46:44.491178+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
68	2026-11-18 15:47:48.721687+05:30	1	HOD_QUESTION_SET_GENERATED	subject_generation:3	{"generationId":"GEN-3-1794997068672","departmentId":"1","semesterNumber":5,"subjectId":"3","questionBankRevisionId":"QBR-1-600","blueprintRevisionId":"BPR-30","generatedSetCount":20,"questionsPerSet":30,"moduleDistribution":{"1":6,"2":6,"3":6,"4":6,"5":6},"totalUniqueQuestionsAllocated":600,"poolQuestionCount":600,"overlapAcrossSets":0,"integrityVerified":true,"publicationStatus":"Not Published","setStatuses":[{"setNumber":1,"setLabel":"Set 1","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":2,"setLabel":"Set 2","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":3,"setLabel":"Set 3","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":4,"setLabel":"Set 4","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":5,"setLabel":"Set 5","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":6,"setLabel":"Set 6","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":7,"setLabel":"Set 7","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":8,"setLabel":"Set 8","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":9,"setLabel":"Set 9","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":10,"setLabel":"Set 10","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":11,"setLabel":"Set 11","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":12,"setLabel":"Set 12","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":13,"setLabel":"Set 13","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":14,"setLabel":"Set 14","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":15,"setLabel":"Set 15","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":16,"setLabel":"Set 16","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":17,"setLabel":"Set 17","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":18,"setLabel":"Set 18","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":19,"setLabel":"Set 19","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"},{"setNumber":20,"setLabel":"Set 20","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Not Published"}]}
69	2026-11-18 15:47:48.899879+05:30	1	HOD_QUESTION_SET_PUBLISHED	subject_publication:3	{"id":"PUB-3-3","generationId":"GEN-3-1794997068672","subjectId":"3","subjectCode":"69","subjectName":"ai","departmentId":"1","semesterNumber":5,"revisionNumber":"R3","questionBankRevisionId":"QBR-1-600","blueprintRevisionId":"BPR-30","blueprint":{"totalQuestions":30,"totalQuestionsPerSet":30,"moduleDistribution":{"1":6,"2":6,"3":6,"4":6,"5":6}},"poolQuestionCount":600,"setsGeneratedCount":20,"totalUniqueQuestionsAllocated":600,"setStatuses":[{"setNumber":1,"setLabel":"Set 1","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":2,"setLabel":"Set 2","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":3,"setLabel":"Set 3","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":4,"setLabel":"Set 4","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":5,"setLabel":"Set 5","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":6,"setLabel":"Set 6","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":7,"setLabel":"Set 7","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":8,"setLabel":"Set 8","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":9,"setLabel":"Set 9","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":10,"setLabel":"Set 10","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":11,"setLabel":"Set 11","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":12,"setLabel":"Set 12","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":13,"setLabel":"Set 13","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":14,"setLabel":"Set 14","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":15,"setLabel":"Set 15","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":16,"setLabel":"Set 16","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":17,"setLabel":"Set 17","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":18,"setLabel":"Set 18","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":19,"setLabel":"Set 19","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"},{"setNumber":20,"setLabel":"Set 20","questionCount":30,"totalQuestions":30,"status":"Available","publicationStatus":"Published"}],"status":"Published","publishedBy":"hod.cse","publishedAt":"2026-11-18T10:17:48.899159600Z","notes":"Generated 4 disjoint sets (4 versions each) across 5 modules"}
70	2026-11-18 15:47:48.90045+05:30	1	PUBLISH_QUESTION_SETS	question_bank:1	Published 20 Disjoint Question Sets (R3) to COE
78	2026-11-18 15:55:27.288222+05:30	1	ADD_SECTION	academic_group:5	Added Section A to Sem 5
80	2026-11-18 19:41:16.767976+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
81	2026-11-19 09:46:37.935103+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
86	2026-11-19 09:54:09.691731+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
87	2026-11-19 09:55:13.622422+05:30	1	UPLOAD_STUDENT_LIST	academic_group:5	Uploaded 30 students
90	2026-11-19 09:59:39.899038+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
91	2026-11-19 10:05:33.696503+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
92	2026-11-19 10:05:45.338956+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
93	2026-11-19 10:05:45.474262+05:30	1	DELETE_SECTION	department:1	Deleted Section SEXY from Sem 5
94	2026-11-19 10:05:51.806817+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
95	2026-11-19 10:06:15.028431+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
96	2026-11-19 10:06:44.129096+05:30	1	ADD_SECTION	academic_group:94	Added Section TEST to Sem 5
97	2026-11-19 10:07:06.879313+05:30	1	DELETE_SECTION	department:1	Deleted Section TEST from Sem 5
98	2026-11-19 10:07:43.297069+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
109	2026-11-19 10:26:23.622024+05:30	1	ADD_SECTION	academic_group:95	Added Section A to Sem 3
110	2026-11-19 10:26:31.796145+05:30	1	ADD_SECTION	academic_group:96	Added Section B to Sem 3
111	2026-11-19 10:27:35.629973+05:30	1	CREATE_SUBJECT	subject:11	Created MH23456 - WEB
112	2026-11-19 10:33:45.845844+05:30	1	UPDATE_INDIVIDUAL_STUDENT	student_roster:8	Updated student 4MH24CS101
116	2026-11-19 11:57:24.228455+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
117	2026-11-19 11:58:20.019071+05:30	1	CREATE_SUBJECT	subject:13	Created MH23456 - WEB
119	2026-11-19 12:01:33.220302+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
124	2026-11-19 12:14:14.964327+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
125	2026-11-19 12:15:03.819275+05:30	1	CREATE_SUBJECT	subject:14	Created MH25DSA - DSA
126	2026-11-19 12:15:42.506197+05:30	1	CREATE_SUBJECT	subject:15	Created MH25DSA - DSA
127	2026-11-19 12:26:09.662355+05:30	1	BULK_UPLOAD_QUESTIONS	question_bank:2	Imported 30 questions into question bank (0 skipped duplicates)
128	2026-11-19 12:31:28.214741+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
129	2026-11-19 12:31:58.62922+05:30	1	DELETE_SUBJECT	subject:11	Deleted subject MH23456
130	2026-11-19 12:34:41.295971+05:30	1	USER_LOGIN_V1	account:4	Logged in via V1 Auth API
132	2026-11-19 12:35:43.404471+05:30	1	DELETE_HOD	account:4	Deleted HOD HOD Computer Science & Engineering (hod.cse)
\.


--
-- Data for Name: bank; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.bank (id, owner_id, subject_id, title, state) FROM stdin;
1	1	1	Midterm Test 1	DRAFT
2	1	2	DSA Question Bank	APPROVED
\.


--
-- Data for Name: bank_scope; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.bank_scope (bank_id, group_id) FROM stdin;
1	1
2	1
\.


--
-- Data for Name: computer_assignment; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.computer_assignment (id, session_id, computer_number, assigned_version_letter) FROM stdin;
\.


--
-- Data for Name: course_outcome_review; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.course_outcome_review (id, submission_id, reviewed_by, decision, comments, reviewed_at) FROM stdin;
\.


--
-- Data for Name: course_outcome_revision; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.course_outcome_revision (id, submission_id, revision_number, file_name, file_size_bytes, file_hash_sha256, pdf_blob, uploaded_by, uploaded_at) FROM stdin;
\.


--
-- Data for Name: course_outcome_statement; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.course_outcome_statement (id, revision_id, co_code, description, bloom_level, target_percentage) FROM stdin;
\.


--
-- Data for Name: course_outcome_submission; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.course_outcome_submission (id, subject_id, department_id, academic_session, semester, current_revision, status, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: department; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.department (id, code, name, created_at) FROM stdin;
1	CSE	Computer Science and Engineering	2026-11-17 23:28:07.467477+05:30
2	CIVIL	civil	2026-11-18 00:17:03.087811+05:30
5	CSE-AI	CSE - Artificial Intelligence	2026-11-19 09:35:11.717951+05:30
6	CSE-DS	CSE - Data Science	2026-11-19 09:35:11.720035+05:30
7	CSE-BS	CSE - Business Systems	2026-11-19 09:35:11.720455+05:30
8	CSE-AIML	CSE - AI & ML	2026-11-19 09:35:11.720822+05:30
9	CSE-IOTCS	CSE - IoT & Cyber Security incl. Blockchain	2026-11-19 09:35:11.721169+05:30
10	COMP	Computer Engineering	2026-11-19 09:35:11.721412+05:30
11	ECE	Electronics & Communication Engineering	2026-11-19 09:35:11.721644+05:30
12	ISE	Information Science & Engineering	2026-11-19 09:35:11.721925+05:30
13	MECH	Mechanical Engineering	2026-11-19 09:35:11.722162+05:30
60	E158CI	AIML	2026-11-19 12:13:04.226769+05:30
\.


--
-- Data for Name: exam; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.exam (id, title, instructions, bank_id, mode, duration, attempt_limit, opens, closes, pass_marks, released) FROM stdin;
1	DSA Midterm Assessment	Answer all questions.	2	PRACTICE	1800	5	2026-11-09 23:55:04+05:30	2026-11-11 23:55:04+05:30	2.00	f
\.


--
-- Data for Name: exam_question; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.exam_question (exam_id, "position", prompt, options, correct, explanation, topic, difficulty, marks, penalty) FROM stdin;
1	1	What is the worst-case time complexity of linear search?	{O(1),O(n),"O(log n)",O(n^2)}	2		Algorithms	EASY	2.00	0.00
1	2	Which data structure works on a LIFO principle?	{Queue,Tree,Stack,Array}	3		Data Structures	MEDIUM	3.00	1.00
\.


--
-- Data for Name: examination_cycle; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.examination_cycle (id, title, academic_session, cycle_type, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: examination_session; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.examination_session (id, cycle_id, subject_id, department_id, group_id, session_date, sitting, start_time, end_time, duration_minutes, assigned_lab, selected_paper_id, status, created_by, frozen_at, created_at, total_marks, passing_marks, cancellation_reason, is_cancelled, package_revision) FROM stdin;
\.


--
-- Data for Name: faculty_scope; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.faculty_scope (faculty_id, group_id, subject_id) FROM stdin;
\.


--
-- Data for Name: generated_paper; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.generated_paper (id, bank_id, paper_number, title, status, created_at) FROM stdin;
13	1	1	Set 1	READY	2026-11-18 15:20:47.430018+05:30
14	1	2	Set 2	READY	2026-11-18 15:20:47.432987+05:30
15	1	3	Set 3	READY	2026-11-18 15:20:47.435233+05:30
16	1	4	Set 4	READY	2026-11-18 15:20:47.437038+05:30
\.


--
-- Data for Name: generated_paper_question; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.generated_paper_question (paper_id, question_id, module_number, paper_position) FROM stdin;
13	1	1	1
13	2	1	2
13	3	1	3
13	4	1	4
13	5	1	5
13	6	1	6
13	121	2	7
13	122	2	8
13	123	2	9
13	124	2	10
13	125	2	11
13	126	2	12
13	241	3	13
13	242	3	14
13	243	3	15
13	244	3	16
13	245	3	17
13	246	3	18
13	361	4	19
13	362	4	20
13	363	4	21
13	364	4	22
13	365	4	23
13	366	4	24
13	481	5	25
13	482	5	26
13	483	5	27
13	484	5	28
13	485	5	29
13	486	5	30
14	7	1	1
14	8	1	2
14	9	1	3
14	10	1	4
14	11	1	5
14	12	1	6
14	127	2	7
14	128	2	8
14	129	2	9
14	130	2	10
14	131	2	11
14	132	2	12
14	247	3	13
14	248	3	14
14	249	3	15
14	250	3	16
14	251	3	17
14	252	3	18
14	367	4	19
14	368	4	20
14	369	4	21
14	370	4	22
14	371	4	23
14	372	4	24
14	487	5	25
14	488	5	26
14	489	5	27
14	490	5	28
14	491	5	29
14	492	5	30
15	13	1	1
15	14	1	2
15	15	1	3
15	16	1	4
15	17	1	5
15	18	1	6
15	133	2	7
15	134	2	8
15	135	2	9
15	136	2	10
15	137	2	11
15	138	2	12
15	253	3	13
15	254	3	14
15	255	3	15
15	256	3	16
15	257	3	17
15	258	3	18
15	373	4	19
15	374	4	20
15	375	4	21
15	376	4	22
15	377	4	23
15	378	4	24
15	493	5	25
15	494	5	26
15	495	5	27
15	496	5	28
15	497	5	29
15	498	5	30
16	19	1	1
16	20	1	2
16	21	1	3
16	22	1	4
16	23	1	5
16	24	1	6
16	139	2	7
16	140	2	8
16	141	2	9
16	142	2	10
16	143	2	11
16	144	2	12
16	259	3	13
16	260	3	14
16	261	3	15
16	262	3	16
16	263	3	17
16	264	3	18
16	379	4	19
16	380	4	20
16	381	4	21
16	382	4	22
16	383	4	23
16	384	4	24
16	499	5	25
16	500	5	26
16	501	5	27
16	502	5	28
16	503	5	29
16	504	5	30
\.


--
-- Data for Name: lab_result_import; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.lab_result_import (id, session_id, raw_payload_json, signature_hex, total_candidates, attended, absent, highest_marks, average_marks, pass_percentage, status, imported_at, imported_by, approved_at, approved_by, released_at, released_by) FROM stdin;
\.


--
-- Data for Name: paper_version; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.paper_version (id, session_id, paper_id, version_letter, created_at) FROM stdin;
\.


--
-- Data for Name: paper_version_question; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.paper_version_question (version_id, question_id, question_uid, display_position, shuffled_options, shuffled_correct, marks) FROM stdin;
\.


--
-- Data for Name: question; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.question (id, bank_id, prompt, options, correct, explanation, topic, difficulty, marks, penalty) FROM stdin;
1	1	What is the worst-case time complexity of linear search?	{O(1),O(n),"O(log n)",O(n^2)}	2		Algorithms	EASY	2.00	0.00
2	1	Which data structure works on a LIFO (Last In First Out) principle?	{Queue,Tree,Stack,Array}	3		Data Structures	MEDIUM	3.00	1.00
3	2	What is the worst-case time complexity of linear search?	{O(1),O(n),"O(log n)",O(n^2)}	2		Algorithms	EASY	2.00	0.00
4	2	Which data structure works on a LIFO principle?	{Queue,Tree,Stack,Array}	3		Data Structures	MEDIUM	3.00	1.00
\.


--
-- Data for Name: question_bank; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.question_bank (id, department_id, subject_id, academic_session, semester, title, created_by, revision_number, state, total_questions, finalized_at, finalized_by, created_at) FROM stdin;
1	1	3	2026-27	5	69 Question Bank	1	3	FINALIZED	600	2026-11-18 15:47:48.899+05:30	1	2026-11-18 15:19:39.759472+05:30
\.


--
-- Data for Name: question_bank_item; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.question_bank_item (id, bank_id, question_uid, module_number, prompt, options, correct, explanation, marks, created_at, has_images, stem_images, option_images) FROM stdin;
1	1	Q-M1-DD29A5BDF3	1	Which data structure follows the Last-In-First-Out (LIFO) principle?	{"Linked list",Stack,Queue,Array}	2	\N	1.00	2026-11-18 15:19:39.773081+05:30	f	[]	[]
2	1	Q-M1-CCAF29F908	1	Which data structure follows the First-In-First-Out (FIFO) principle?	{Stack,"Hash table","Binary tree",Queue}	4	\N	1.00	2026-11-18 15:19:39.775775+05:30	f	[]	[]
3	1	Q-M1-707BC794B7	1	What is the time complexity of binary search on a sorted array of n elements?	{O(n),O(1),"O(log n)","O(n log n)"}	3	\N	1.00	2026-11-18 15:19:39.77733+05:30	f	[]	[]
4	1	Q-M1-28D4798F7F	1	What is the worst-case time complexity of linear search?	{O(n^2),O(1),"O(log n)",O(n)}	4	\N	1.00	2026-11-18 15:19:39.77896+05:30	f	[]	[]
5	1	Q-M1-B90A78E463	1	What is the average-case time complexity of quicksort?	{O(n^2),"O(log n)","O(n log n)",O(n)}	3	\N	1.00	2026-11-18 15:19:39.780503+05:30	f	[]	[]
6	1	Q-M1-65BE937360	1	When does quicksort exhibit its worst-case O(n^2) behaviour?	{"When the array has exactly two elements","When the array is completely random","When the pivot is always the smallest or largest element","When all pivots are chosen as the median"}	3	\N	1.00	2026-11-18 15:19:39.782103+05:30	f	[]	[]
7	1	Q-M1-1331E0B804	1	What is the worst-case time complexity of merge sort?	{O(n^2),"O(n log n)","O(log n)",O(n)}	2	\N	1.00	2026-11-18 15:19:39.783668+05:30	f	[]	[]
8	1	Q-M1-7B4A7CAA0B	1	Which of the following sorting algorithms is stable by default?	{"Selection sort","Quick sort","Heap sort","Merge sort"}	4	\N	1.00	2026-11-18 15:19:39.785318+05:30	f	[]	[]
9	1	Q-M1-E3E23FD6D3	1	What is the auxiliary space complexity of heap sort?	{O(n),"O(n log n)","O(log n)",O(1)}	4	\N	1.00	2026-11-18 15:19:39.786988+05:30	f	[]	[]
10	1	Q-M1-97B11DFF0F	1	What auxiliary space does a standard array-based merge sort need?	{O(n),O(n^2),"O(log n)",O(1)}	1	\N	1.00	2026-11-18 15:19:39.788519+05:30	f	[]	[]
11	1	Q-M1-1A074B7553	1	What is the best-case time complexity of bubble sort with the early-exit optimisation?	{O(n),O(n^2),"O(n log n)","O(log n)"}	1	\N	1.00	2026-11-18 15:19:39.790018+05:30	f	[]	[]
12	1	Q-M1-3C7AD7CF1B	1	What is the worst-case time complexity of insertion sort?	{O(n^2),"O(n log n)","O(log n)",O(n)}	1	\N	1.00	2026-11-18 15:19:39.790784+05:30	f	[]	[]
13	1	Q-M1-16BB75C546	1	Binary search can only be applied to a collection that is:	{Unsorted,Sorted,"Linked with pointers only","Of fixed-size strings only"}	2	\N	1.00	2026-11-18 15:19:39.791448+05:30	f	[]	[]
14	1	Q-M1-E6B28CEB51	1	An inorder traversal of a binary search tree visits the keys in which order?	{"Random order","Level order","Ascending order","Descending order"}	3	\N	1.00	2026-11-18 15:19:39.792136+05:30	f	[]	[]
15	1	Q-M1-7BA8BF3E48	1	In which order does a preorder traversal visit nodes?	{"Left, Right, Root","Root, Left, Right","Right, Root, Left","Left, Root, Right"}	2	\N	1.00	2026-11-18 15:19:39.792776+05:30	f	[]	[]
16	1	Q-M1-F0DEE70B27	1	In which order does a postorder traversal visit nodes?	{"Left, Right, Root","Root, Right, Left","Left, Root, Right","Root, Left, Right"}	1	\N	1.00	2026-11-18 15:19:39.793518+05:30	f	[]	[]
17	1	Q-M1-AE322F2082	1	What is the maximum number of nodes in a binary tree of height h, if a single root node has height 0?	{"2h + 1","2^(h+1) - 1",2^h,h^2}	2	\N	1.00	2026-11-18 15:19:39.794293+05:30	f	[]	[]
18	1	Q-M1-2F8F73F500	1	How many edges does a tree with n nodes have?	{"n + 1",n,"n - 1","n / 2"}	3	\N	1.00	2026-11-18 15:19:39.795776+05:30	f	[]	[]
19	1	Q-M1-DB3E0C0BB6	1	How many edges does a complete undirected graph with n vertices have?	{n(n-1)/2,n(n+1)/2,2n,n^2}	1	\N	1.00	2026-11-18 15:19:39.796526+05:30	f	[]	[]
20	1	Q-M1-28D8F16741	1	Which data structure is typically used to implement breadth-first search?	{Heap,Queue,Stack,"Hash map"}	2	\N	1.00	2026-11-18 15:19:39.798053+05:30	f	[]	[]
21	1	Q-M1-54B2EBB3F5	1	Which data structure is typically used to implement iterative depth-first search?	{Queue,Stack,"Priority queue","Deque with sorting"}	2	\N	1.00	2026-11-18 15:19:39.799572+05:30	f	[]	[]
22	1	Q-M1-1C0117CF7C	1	Dijkstra's shortest path algorithm may fail when the graph contains:	{"Cycles with positive weights","Parallel edges with equal weights","Negative edge weights","Disconnected vertices"}	3	\N	1.00	2026-11-18 15:19:39.801058+05:30	f	[]	[]
23	1	Q-M1-88AF59F4F5	1	Which shortest-path algorithm can handle negative edge weights?	{Prim,Bellman-Ford,Kruskal,Dijkstra}	2	\N	1.00	2026-11-18 15:19:39.802543+05:30	f	[]	[]
24	1	Q-M1-85653B964F	1	Kruskal's algorithm builds a minimum spanning tree by:	{"Growing a tree from a single start vertex","Removing the heaviest edge of every vertex","Running breadth-first search repeatedly","Sorting edges by weight and adding those that do not form a cycle"}	4	\N	1.00	2026-11-18 15:19:39.80411+05:30	f	[]	[]
25	1	Q-M1-50E9C47D5D	1	Prim's algorithm builds a minimum spanning tree by:	{"Dividing the graph into two halves","Sorting all edges globally first","Growing the tree one vertex at a time by adding the cheapest connecting edge","Using a topological ordering"}	3	\N	1.00	2026-11-18 15:19:39.805669+05:30	f	[]	[]
26	1	Q-M1-A58217F389	1	Topological sorting is possible only for which type of graph?	{"Directed acyclic graph","Complete graph","Undirected cyclic graph","Any weighted graph"}	1	\N	1.00	2026-11-18 15:19:39.807115+05:30	f	[]	[]
27	1	Q-M1-B97F562A2B	1	What is the average-case time complexity of lookup in a hash table with a good hash function?	{"O(n log n)",O(n),O(1),"O(log n)"}	3	\N	1.00	2026-11-18 15:19:39.808679+05:30	f	[]	[]
28	1	Q-M1-CDD6343B14	1	Resolving hash collisions by storing colliding keys in a linked list at the same slot is called:	{"Linear probing",Chaining,"Double hashing",Rehashing}	2	\N	1.00	2026-11-18 15:19:39.8102+05:30	f	[]	[]
29	1	Q-M1-9809EAA951	1	Which of the following is an open-addressing collision resolution technique?	{"Tree bins","Linear probing","Bucket linked lists","Separate chaining"}	2	\N	1.00	2026-11-18 15:19:39.811658+05:30	f	[]	[]
30	1	Q-M1-CAEDE2CCFF	1	The load factor of a hash table with n keys and m slots is:	{"n / m","n * m","m / n","n - m"}	1	\N	1.00	2026-11-18 15:19:39.812434+05:30	f	[]	[]
31	1	Q-M1-717A429FC4	1	In an AVL tree, the balance factor of every node must be:	{"Any positive integer","Between -2 and +2","0 only","-1, 0 or +1"}	4	\N	1.00	2026-11-18 15:19:39.814668+05:30	f	[]	[]
32	1	Q-M1-CB8C473A3B	1	In a red-black tree, what is the colour of the root?	{Red,Black,"Either, chosen at random","Depends on tree height"}	2	\N	1.00	2026-11-18 15:19:39.816212+05:30	f	[]	[]
33	1	Q-M1-4240DED540	1	Which tree structure is widely used in database indexes and file systems?	{"Decision tree",Trie,"Binary expression tree",B-tree}	4	\N	1.00	2026-11-18 15:19:39.817794+05:30	f	[]	[]
34	1	Q-M1-BF8BF4D146	1	In a min-heap, the root element is:	{"The median element","The largest element","The most recently inserted element","The smallest element"}	4	\N	1.00	2026-11-18 15:19:39.819826+05:30	f	[]	[]
35	1	Q-M1-9C437BBBF0	1	What is the time complexity of inserting an element into a binary heap?	{"O(n log n)",O(1),"O(log n)",O(n)}	3	\N	1.00	2026-11-18 15:19:39.820762+05:30	f	[]	[]
36	1	Q-M1-5BD7F99051	1	What is the time complexity of building a binary heap from n unsorted elements using bottom-up heapify?	{O(n^2),O(n),"O(log n)","O(n log n)"}	2	\N	1.00	2026-11-18 15:19:39.822509+05:30	f	[]	[]
37	1	Q-M1-529F5BFE22	1	A priority queue is most commonly implemented using:	{"A singly linked list sorted lazily","A stack","A circular array","A binary heap"}	4	\N	1.00	2026-11-18 15:19:39.82409+05:30	f	[]	[]
38	1	Q-M1-65C1E293F8	1	How many pointers does each node of a doubly linked list contain?	{Two,One,Zero,Three}	1	\N	1.00	2026-11-18 15:19:39.825679+05:30	f	[]	[]
39	1	Q-M1-75A966B5D1	1	In a circular linked list, the last node points to:	{"The first node","Itself only","The middle node","NULL"}	1	\N	1.00	2026-11-18 15:19:39.82717+05:30	f	[]	[]
40	1	Q-M1-A9B39E001C	1	What is the time complexity of reversing a singly linked list of n nodes?	{O(1),O(n),"O(log n)",O(n^2)}	2	\N	1.00	2026-11-18 15:19:39.828663+05:30	f	[]	[]
41	1	Q-M1-91B558FAEE	1	Which algorithm detects a cycle in a linked list using two pointers moving at different speeds?	{"Floyd's tortoise and hare","Kadane's algorithm","Dutch national flag","Boyer-Moore voting"}	1	\N	1.00	2026-11-18 15:19:39.830276+05:30	f	[]	[]
42	1	Q-M1-189559CBC9	1	What is the time complexity of accessing an array element by its index?	{O(n),"O(n log n)",O(1),"O(log n)"}	3	\N	1.00	2026-11-18 15:19:39.832031+05:30	f	[]	[]
43	1	Q-M1-2F93E34C32	1	What is the time complexity of inserting an element at the beginning of an array of n elements?	{O(n),O(n^2),"O(log n)",O(1)}	1	\N	1.00	2026-11-18 15:19:39.833398+05:30	f	[]	[]
44	1	Q-M1-5C43C1695F	1	Every correct recursive function must have:	{"A return type of void","A global variable","A loop","A base case"}	4	\N	1.00	2026-11-18 15:19:39.83481+05:30	f	[]	[]
45	1	Q-M1-061DC9023E	1	A stack overflow error in recursion most commonly occurs because of:	{"Using an iterative loop","Declaring the function static","Missing or unreachable base case","Too many local variables of type char"}	3	\N	1.00	2026-11-18 15:19:39.836223+05:30	f	[]	[]
46	1	Q-M1-CACDB9C057	1	What is the time complexity of the naive recursive Fibonacci algorithm?	{O(2^n),O(n),O(n^2),"O(log n)"}	1	\N	1.00	2026-11-18 15:19:39.837194+05:30	f	[]	[]
47	1	Q-M1-A37687848A	1	Dynamic programming is applicable when a problem has:	{"Overlapping subproblems and optimal substructure","Random inputs","Only independent subproblems","No recursive structure"}	1	\N	1.00	2026-11-18 15:19:39.838072+05:30	f	[]	[]
48	1	Q-M1-55BF9F553F	1	Memoization is a technique that:	{"Sorts arrays in place","Caches the results of expensive function calls","Compresses source code","Removes recursion from the compiler"}	2	\N	1.00	2026-11-18 15:19:39.838733+05:30	f	[]	[]
49	1	Q-M1-10D45FAFB3	1	A greedy algorithm works by:	{"Trying every possible solution","Making the locally optimal choice at each step","Dividing the problem into equal halves","Storing all subproblem results"}	2	\N	1.00	2026-11-18 15:19:39.839379+05:30	f	[]	[]
50	1	Q-M1-49FEB80D9D	1	Which of the following is a classic divide-and-conquer algorithm?	{"Merge sort","Linear search","Counting the nodes iteratively","Bubble sort"}	1	\N	1.00	2026-11-18 15:19:39.840102+05:30	f	[]	[]
51	1	Q-M1-F110280326	1	The 0/1 knapsack problem is best solved using:	{"Breadth-first search","A simple greedy approach","Dynamic programming","Binary search"}	3	\N	1.00	2026-11-18 15:19:39.840898+05:30	f	[]	[]
52	1	Q-M1-9B7F651489	1	The fractional knapsack problem is optimally solved using:	{"Dynamic programming only","Brute force only","A greedy algorithm",Backtracking}	3	\N	1.00	2026-11-18 15:19:39.841598+05:30	f	[]	[]
53	1	Q-M1-B87E9FAB6C	1	The longest common subsequence problem is typically solved using:	{"Topological sort","Greedy selection","Binary search","Dynamic programming"}	4	\N	1.00	2026-11-18 15:19:39.843012+05:30	f	[]	[]
54	1	Q-M1-CD8B1B826B	1	What is the minimum number of moves needed to solve the Tower of Hanoi puzzle with n disks?	{n!,2n,n^2,"2^n - 1"}	4	\N	1.00	2026-11-18 15:19:39.843712+05:30	f	[]	[]
55	1	Q-M1-36BAAC2AE4	1	Big-O notation describes:	{"An exact tight bound only","The memory address of a function","An asymptotic lower bound","An asymptotic upper bound"}	4	\N	1.00	2026-11-18 15:19:39.844325+05:30	f	[]	[]
56	1	Q-M1-090E0A1A1F	1	Big-Omega notation describes:	{"Average running time","An asymptotic upper bound","Compile time","An asymptotic lower bound"}	4	\N	1.00	2026-11-18 15:19:39.845462+05:30	f	[]	[]
57	1	Q-M1-3C7A5C6B4E	1	Big-Theta notation describes:	{"Only the best case","The space used by the stack","Only the worst case","An asymptotically tight bound"}	4	\N	1.00	2026-11-18 15:19:39.846137+05:30	f	[]	[]
58	1	Q-M1-0B08D9272C	1	An algorithm with O(1) time complexity runs in:	{"Linear time","Exponential time","Logarithmic time","Constant time"}	4	\N	1.00	2026-11-18 15:19:39.846723+05:30	f	[]	[]
59	1	Q-M1-2A99E4D23F	1	Which of the following functions grows the fastest as n becomes large?	{n^2,"n log n",2^n,n!}	4	\N	1.00	2026-11-18 15:19:39.847361+05:30	f	[]	[]
60	1	Q-M1-EF00364DF6	1	The Master theorem is used to solve:	{"Divide-and-conquer recurrences","String matching problems","Graph colouring problems","Linear equations"}	1	\N	1.00	2026-11-18 15:19:39.848037+05:30	f	[]	[]
61	1	Q-M1-4C38848C60	1	The recurrence T(n) = 2T(n/2) + n solves to:	{"Theta(log n)","Theta(n log n)",Theta(n),Theta(n^2)}	2	\N	1.00	2026-11-18 15:19:39.848755+05:30	f	[]	[]
62	1	Q-M1-9D91BB4B4B	1	Which of the following is NOT a pillar of object-oriented programming?	{Polymorphism,Compilation,Encapsulation,Inheritance}	2	\N	1.00	2026-11-18 15:19:39.850359+05:30	f	[]	[]
63	1	Q-M1-81FB1066F2	1	Polymorphism literally means:	{"Many classes","Many forms","Hidden data","Single inheritance"}	2	\N	1.00	2026-11-18 15:19:39.851025+05:30	f	[]	[]
64	1	Q-M1-3B2A8C08BC	1	Inheritance in OOP allows a class to:	{"Hide its private members","Run faster","Acquire properties and behaviour of another class","Be instantiated without a constructor"}	3	\N	1.00	2026-11-18 15:19:39.851763+05:30	f	[]	[]
65	1	Q-M1-288E94D59D	1	Abstraction in OOP refers to:	{"Binding data and methods in one unit only","Converting types automatically","Creating multiple objects from one class","Hiding implementation details and showing only essential features"}	4	\N	1.00	2026-11-18 15:19:39.852524+05:30	f	[]	[]
66	1	Q-M1-660FE595A1	1	Method overloading means:	{"Hiding a method with a private modifier","Calling a method recursively","Same method name with different parameter lists","Redefining a parent method in a subclass"}	3	\N	1.00	2026-11-18 15:19:39.853257+05:30	f	[]	[]
67	1	Q-M1-9EEE537D16	1	Method overriding means:	{"Two methods share a name but differ in parameters in one class","A method calls itself","A method is declared static","A subclass provides its own implementation of a parent method"}	4	\N	1.00	2026-11-18 15:19:39.854009+05:30	f	[]	[]
68	1	Q-M1-C99FC24597	1	The main purpose of a constructor is to:	{"Import a library","Destroy an object","Declare a class","Initialise a newly created object"}	4	\N	1.00	2026-11-18 15:19:39.854798+05:30	f	[]	[]
69	1	Q-M1-812483A7F2	1	In Python, which of these data types is mutable?	{tuple,str,frozenset,list}	4	\N	1.00	2026-11-18 15:19:39.85552+05:30	f	[]	[]
70	1	Q-M1-C7E18E58AA	1	In Python, which of these data types is immutable?	{dict,set,tuple,list}	3	\N	1.00	2026-11-18 15:19:39.856445+05:30	f	[]	[]
71	1	Q-M1-1E8C2F4DD4	1	Dictionary keys in Python must be:	{"Integers only",Sorted,Hashable,Mutable}	3	\N	1.00	2026-11-18 15:19:39.857189+05:30	f	[]	[]
72	1	Q-M1-CE3C4E114A	1	What does the Python expression len([1, 2, 3]) return?	{1,4,2,3}	4	\N	1.00	2026-11-18 15:19:39.857943+05:30	f	[]	[]
73	1	Q-M1-747C818F38	1	What does 7 // 2 evaluate to in Python 3?	{3.5,3,4,2}	2	\N	1.00	2026-11-18 15:19:39.858826+05:30	f	[]	[]
74	1	Q-M1-ECB2A25121	1	What does 2 ** 3 evaluate to in Python?	{8,9,6,5}	1	\N	1.00	2026-11-18 15:19:39.859592+05:30	f	[]	[]
75	1	Q-M1-B6663AA83F	1	What is the type of the result of 5 / 2 in Python 3?	{complex,float,str,int}	2	\N	1.00	2026-11-18 15:19:39.860676+05:30	f	[]	[]
76	1	Q-M1-3D4504A6A0	1	What does the Python expression "abc"[::-1] return?	{"\\"ab\\"","\\"bca\\"","\\"abc\\"","\\"cba\\""}	4	\N	1.00	2026-11-18 15:19:39.861325+05:30	f	[]	[]
77	1	Q-M1-AC83A9C329	1	Which Python keyword is used to define a function?	{function,func,"lambda only",def}	4	\N	1.00	2026-11-18 15:19:39.861946+05:30	f	[]	[]
78	1	Q-M1-CE6F476A43	1	What does bool([]) evaluate to in Python?	{"An error",False,None,True}	2	\N	1.00	2026-11-18 15:19:39.862589+05:30	f	[]	[]
79	1	Q-M1-CAF0C2A26E	1	A Python set is best described as a collection that is:	{"Unordered with unique elements","Immutable and indexed","Ordered with duplicates","Key-value paired"}	1	\N	1.00	2026-11-18 15:19:39.863212+05:30	f	[]	[]
80	1	Q-M1-8E8FC3C244	1	What sequence does range(3) generate in Python?	{"0, 1, 2","1, 2, 3","0, 1, 2, 3","3, 2, 1"}	1	\N	1.00	2026-11-18 15:19:39.863892+05:30	f	[]	[]
81	1	Q-M1-FC18ADDAB5	1	A lambda in Python is:	{"A loop construct","An anonymous single-expression function","A class decorator only","A type of exception"}	2	\N	1.00	2026-11-18 15:19:39.864572+05:30	f	[]	[]
82	1	Q-M1-9DDA60E9B8	1	In Python, the "is" operator checks whether two variables:	{"Refer to the same object","Have the same type","Have equal values","Are both non-empty"}	1	\N	1.00	2026-11-18 15:19:39.865225+05:30	f	[]	[]
83	1	Q-M1-F44FA80AF4	1	In C, the size of an int on most modern 32/64-bit systems is typically:	{"4 bytes","16 bytes","2 bytes","1 byte"}	1	\N	1.00	2026-11-18 15:19:39.865906+05:30	f	[]	[]
84	1	Q-M1-7AD8F6B795	1	A pointer in C stores:	{"A character only","A function body","A memory address","A floating-point value"}	3	\N	1.00	2026-11-18 15:19:39.866515+05:30	f	[]	[]
85	1	Q-M1-8E559F733B	1	In C, memory allocated using malloc comes from the:	{"Register file","Code segment",Heap,Stack}	3	\N	1.00	2026-11-18 15:19:39.867316+05:30	f	[]	[]
86	1	Q-M1-D238464FB0	1	In C, which function releases memory previously allocated by malloc?	{release,delete,free,dealloc}	3	\N	1.00	2026-11-18 15:19:39.868197+05:30	f	[]	[]
87	1	Q-M1-5019240A0C	1	In C, the unary & operator returns:	{"The size of the operand","The address of its operand","The value at an address","The bitwise complement"}	2	\N	1.00	2026-11-18 15:19:39.868913+05:30	f	[]	[]
88	1	Q-M1-F1CD73DFBF	1	In most C expressions, an array name decays to:	{"The array length","A copy of the array","A null pointer","A pointer to its first element"}	4	\N	1.00	2026-11-18 15:19:39.86962+05:30	f	[]	[]
89	1	Q-M1-93FB63C568	1	Which character terminates a C string?	{"'\\\\n'","'\\\\0'","' '",EOF}	2	\N	1.00	2026-11-18 15:19:39.870327+05:30	f	[]	[]
90	1	Q-M1-45DCF64107	1	What does printf("%d", 5/2) print in C?	{0,2,2.5,3}	2	\N	1.00	2026-11-18 15:19:39.870977+05:30	f	[]	[]
91	1	Q-M1-6ACAB1F7E0	1	In C++, which operator dynamically allocates memory?	{new,"malloc only",create,alloc}	1	\N	1.00	2026-11-18 15:19:39.871588+05:30	f	[]	[]
92	1	Q-M1-70F5CBE9B9	1	The Java Virtual Machine executes:	{Bytecode,"Machine code only for the host CPU",Assembly,"Source code directly"}	1	\N	1.00	2026-11-18 15:19:39.872206+05:30	f	[]	[]
93	1	Q-M1-939A5776F3	1	Which Java keyword prevents a class from being extended?	{volatile,static,final,abstract}	3	\N	1.00	2026-11-18 15:19:39.873196+05:30	f	[]	[]
94	1	Q-M1-837D48A096	1	In Java, the String class is:	{"Always null by default","A primitive type",Immutable,Mutable}	3	\N	1.00	2026-11-18 15:19:39.873855+05:30	f	[]	[]
95	1	Q-M1-B2FF692F06	1	Java supports multiple inheritance of type through:	{"Multiple extends clauses on classes",Templates,Interfaces,"Friend classes"}	3	\N	1.00	2026-11-18 15:19:39.874511+05:30	f	[]	[]
96	1	Q-M1-B9C5979DCC	1	Garbage collection in Java refers to:	{"Automatic reclamation of unused objects' memory","Compiling unused code","Clearing the console","Manual deletion of variables"}	1	\N	1.00	2026-11-18 15:19:39.87558+05:30	f	[]	[]
97	1	Q-M1-23166A3A6B	1	A static variable in a class is:	{"Always constant","Visible only inside constructors","Shared among all instances of the class","Created separately for each object"}	3	\N	1.00	2026-11-18 15:19:39.876267+05:30	f	[]	[]
98	1	Q-M1-41217D5A63	1	Compared with an interpreter, a compiler:	{"Translates the whole program before execution","Requires no source code","Never produces errors","Executes one line at a time"}	1	\N	1.00	2026-11-18 15:19:39.876961+05:30	f	[]	[]
99	1	Q-M1-CB7301CE55	1	Dividing an integer by zero during program execution is an example of a:	{"Linker warning","Preprocessor directive","Syntax error","Runtime error"}	4	\N	1.00	2026-11-18 15:19:39.877604+05:30	f	[]	[]
100	1	Q-M1-515DF0C3C0	1	What is the result of x XOR x for any integer x?	{x,1,0,-x}	3	\N	1.00	2026-11-18 15:19:39.878681+05:30	f	[]	[]
101	1	Q-M1-8E062A3084	1	Left-shifting an unsigned integer by one bit is equivalent to:	{"Multiplying by 2","Dividing by 2",Squaring,"Adding 1"}	1	\N	1.00	2026-11-18 15:19:39.8798+05:30	f	[]	[]
102	1	Q-M1-8D5D13504E	1	What is the binary representation of the decimal number 10?	{1100,1001,1010,0101}	3	\N	1.00	2026-11-18 15:19:39.880487+05:30	f	[]	[]
103	1	Q-M1-898ECBEC8E	1	What is the hexadecimal representation of decimal 255?	{EE,F0,FF,100}	3	\N	1.00	2026-11-18 15:19:39.88121+05:30	f	[]	[]
104	1	Q-M1-F6F9B51158	1	Two's complement notation is used to represent:	{"ASCII characters","Floating-point exponents","Boolean flags","Signed integers"}	4	\N	1.00	2026-11-18 15:19:39.881993+05:30	f	[]	[]
105	1	Q-M1-F3B9A099DC	1	When an argument is passed by reference, the called function can:	{"Only read a copy","Modify the caller's original variable","Not access the variable","Change the function's name"}	2	\N	1.00	2026-11-18 15:19:39.8826+05:30	f	[]	[]
106	1	Q-M1-346D454636	1	A local variable declared inside a function is accessible:	{"Only in main","Throughout the entire program","Only within that function","In every file"}	3	\N	1.00	2026-11-18 15:19:39.883409+05:30	f	[]	[]
107	1	Q-M1-0CD16BD502	1	A deque (double-ended queue) allows insertion and deletion at:	{"Only the front","Both ends","Only the rear","Only the middle"}	2	\N	1.00	2026-11-18 15:19:39.884267+05:30	f	[]	[]
108	1	Q-M1-200650F751	1	A trie is most commonly used for:	{"Prefix-based string searching","Sorting integers","Graph colouring","Matrix multiplication"}	1	\N	1.00	2026-11-18 15:19:39.884942+05:30	f	[]	[]
109	1	Q-M1-176E6D363A	1	Which two operations are fundamental to the disjoint-set (union-find) data structure?	{"Push and Pop","Find and Union","Insert and Heapify","Enqueue and Dequeue"}	2	\N	1.00	2026-11-18 15:19:39.886013+05:30	f	[]	[]
110	1	Q-M1-4958A07F2C	1	The main advantage of a circular queue over a simple linear array queue is that it:	{"Has unlimited capacity","Sorts items automatically","Needs no front pointer","Reuses vacated space"}	4	\N	1.00	2026-11-18 15:19:39.886709+05:30	f	[]	[]
111	1	Q-M1-1895C033D3	1	Which data structure is used to evaluate a postfix expression?	{Queue,Heap,Graph,Stack}	4	\N	1.00	2026-11-18 15:19:39.887426+05:30	f	[]	[]
112	1	Q-M1-4571F2F7FC	1	Which data structure is used to convert an infix expression to postfix?	{Stack,"Hash table","Binary heap",Queue}	1	\N	1.00	2026-11-18 15:19:39.888036+05:30	f	[]	[]
113	1	Q-M1-BD6FA14271	1	What is the postfix form of the infix expression A + B * C?	{ABC*+,AB+C*,+A*BC,ABC+*}	1	\N	1.00	2026-11-18 15:19:39.888585+05:30	f	[]	[]
114	1	Q-M1-4B34F29592	1	A sparse matrix is one in which:	{"Every element is non-zero","Most elements are zero","All elements are equal","Rows and columns are unequal"}	2	\N	1.00	2026-11-18 15:19:39.88925+05:30	f	[]	[]
115	1	Q-M1-715D1B2576	1	A binary tree in which every node has either 0 or 2 children is called:	{"A complete binary tree","A degenerate tree","A full binary tree","A skewed tree"}	3	\N	1.00	2026-11-18 15:19:39.89002+05:30	f	[]	[]
116	1	Q-M1-B43B52D4A9	1	What is the height of a balanced binary search tree with n nodes?	{O(1),O(n),"O(log n)","O(n log n)"}	3	\N	1.00	2026-11-18 15:19:39.890639+05:30	f	[]	[]
117	1	Q-M1-60DF03DA41	1	What is the worst-case search time in a completely skewed binary search tree?	{"O(log n)",O(n),O(1),"O(n log n)"}	2	\N	1.00	2026-11-18 15:19:39.891253+05:30	f	[]	[]
118	1	Q-M1-58103184ED	1	Interpolation search performs best on:	{"Uniformly distributed sorted data","Hash tables","Skewed unsorted arrays","Unsorted linked lists"}	1	\N	1.00	2026-11-18 15:19:39.892001+05:30	f	[]	[]
119	1	Q-M1-D461866D55	1	What is the amortised cost of appending an element to a dynamic array (e.g. Python list)?	{O(1),"O(log n)",O(n),O(n^2)}	1	\N	1.00	2026-11-18 15:19:39.892613+05:30	f	[]	[]
120	1	Q-M1-A77EA8A65D	1	Which sorting algorithm repeatedly selects the minimum element from the unsorted part and moves it to the front?	{"Shell sort","Counting sort","Insertion sort","Selection sort"}	4	\N	1.00	2026-11-18 15:19:39.893287+05:30	f	[]	[]
121	1	Q-M2-C76B9B4023	2	What does DBMS stand for?	{"Digital Base Mapping Software","Database Management System","Distributed Binary Memory System","Data Backup Management System"}	2	\N	1.00	2026-11-18 15:19:39.893948+05:30	f	[]	[]
122	1	Q-M2-FEE1BAAA1D	2	Which SQL statement is used to retrieve data from a table?	{SELECT,INSERT,UPDATE,EXTRACT}	1	\N	1.00	2026-11-18 15:19:39.895864+05:30	f	[]	[]
123	1	Q-M2-8373515CC3	2	Which SQL command adds new rows to a table?	{"ADD ROW",INSERT,PUT,APPEND}	2	\N	1.00	2026-11-18 15:19:39.896696+05:30	f	[]	[]
124	1	Q-M2-AE7BCC896B	2	Which SQL command modifies existing rows?	{UPDATE,"ALTER ROW",MODIFY,CHANGE}	1	\N	1.00	2026-11-18 15:19:39.897463+05:30	f	[]	[]
125	1	Q-M2-BC97ABAD97	2	Which SQL command removes rows from a table while keeping its structure?	{"REMOVE TABLE",DROP,DELETE,ERASE}	3	\N	1.00	2026-11-18 15:19:39.898149+05:30	f	[]	[]
126	1	Q-M2-4C7491574A	2	Which SQL command removes a table and its structure entirely?	{CLEAR,"TRUNCATE ROWS",DROP,DELETE}	3	\N	1.00	2026-11-18 15:19:39.898763+05:30	f	[]	[]
127	1	Q-M2-14FE7CB171	2	Which SQL command quickly removes all rows from a table and cannot normally be rolled back in many systems?	{DELETE,REVOKE,UPDATE,TRUNCATE}	4	\N	1.00	2026-11-18 15:19:39.899322+05:30	f	[]	[]
128	1	Q-M2-EFF86C7837	2	Which SQL command changes the structure of an existing table?	{ALTER,"CHANGE ROW",UPDATE,"MODIFY DATA"}	1	\N	1.00	2026-11-18 15:19:39.900736+05:30	f	[]	[]
129	1	Q-M2-508DF9B698	2	Which SQL clause is used to filter rows before grouping?	{"GROUP BY",HAVING,"ORDER BY",WHERE}	4	\N	1.00	2026-11-18 15:19:39.901412+05:30	f	[]	[]
130	1	Q-M2-E1184B1B0C	2	Which SQL clause filters groups after aggregation?	{HAVING,LIMIT,WHERE,DISTINCT}	1	\N	1.00	2026-11-18 15:19:39.902405+05:30	f	[]	[]
131	1	Q-M2-BC69A74560	2	Which SQL clause sorts the result set?	{"GROUP BY","SORT WITH",ARRANGE,"ORDER BY"}	4	\N	1.00	2026-11-18 15:19:39.903052+05:30	f	[]	[]
132	1	Q-M2-EF4751DAED	2	Which keyword removes duplicate rows from a SELECT result?	{"UNIQUE ROWS",SINGLE,DISTINCT,ONLY}	3	\N	1.00	2026-11-18 15:19:39.903759+05:30	f	[]	[]
133	1	Q-M2-DB841D2A26	2	Which aggregate function returns the number of rows?	{TOTAL,SUM,NUMBER,COUNT}	4	\N	1.00	2026-11-18 15:19:39.90445+05:30	f	[]	[]
134	1	Q-M2-32EBEED3CF	2	Which aggregate function returns the average of numeric values?	{MEDIAN,MEAN,AVERAGE_OF,AVG}	4	\N	1.00	2026-11-18 15:19:39.905578+05:30	f	[]	[]
135	1	Q-M2-915304BA6C	2	Which SQL operator tests whether a value lies within an inclusive range?	{SPAN,WITHIN,BETWEEN,RANGE}	3	\N	1.00	2026-11-18 15:19:39.906469+05:30	f	[]	[]
136	1	Q-M2-D2238F2CD5	2	Which SQL operator matches string patterns using wildcards?	{SIMILAR,LIKE,MATCHES,PATTERN}	2	\N	1.00	2026-11-18 15:19:39.907262+05:30	f	[]	[]
137	1	Q-M2-19AC6BEF6A	2	In a LIKE pattern, the percent sign (%) represents:	{"Zero or more characters","A literal percent sign","A digit","Exactly one character"}	1	\N	1.00	2026-11-18 15:19:39.907968+05:30	f	[]	[]
138	1	Q-M2-7830EFABCF	2	In a LIKE pattern, the underscore (_) represents:	{"A space only","A literal underscore","Zero or more characters","Exactly one character"}	4	\N	1.00	2026-11-18 15:19:39.908714+05:30	f	[]	[]
139	1	Q-M2-BA39B0D5BE	2	Which SQL value represents a missing or unknown value?	{VOID,"NULL",ZERO,EMPTY}	2	\N	1.00	2026-11-18 15:19:39.909427+05:30	f	[]	[]
140	1	Q-M2-C4B206625E	2	Which expression correctly tests for NULL in SQL?	{"column = NULL","column IS NULL","column EQUALS NULL","column == NULL"}	2	\N	1.00	2026-11-18 15:19:39.910118+05:30	f	[]	[]
141	1	Q-M2-AA8C48145C	2	Which JOIN returns only rows with matching values in both tables?	{"INNER JOIN","FULL OUTER JOIN","CROSS JOIN","LEFT JOIN"}	1	\N	1.00	2026-11-18 15:19:39.91068+05:30	f	[]	[]
142	1	Q-M2-51915CFD2D	2	Which JOIN returns all rows from the left table and matched rows from the right table?	{"RIGHT OUTER JOIN","LEFT OUTER JOIN","INNER JOIN","CROSS JOIN"}	2	\N	1.00	2026-11-18 15:19:39.911326+05:30	f	[]	[]
143	1	Q-M2-5B1CC85EC8	2	Which JOIN produces the Cartesian product of two tables?	{"CROSS JOIN","NATURAL JOIN","SELF JOIN","INNER JOIN"}	1	\N	1.00	2026-11-18 15:19:39.91198+05:30	f	[]	[]
144	1	Q-M2-DDABB7EEDA	2	A SELF JOIN is a join in which:	{"A table is joined with itself","Two identical databases are merged","A view joins a trigger","A table joins only its primary key"}	1	\N	1.00	2026-11-18 15:19:39.912575+05:30	f	[]	[]
145	1	Q-M2-9F399C27B4	2	Which SQL set operator returns rows common to both queries?	{"MINUS ALL",INTERSECT,MERGE,UNION}	2	\N	1.00	2026-11-18 15:19:39.913101+05:30	f	[]	[]
146	1	Q-M2-AF7B2A2CF2	2	Which SQL operator combines results of two queries and removes duplicates?	{UNION,"UNION ALL",APPEND,JOIN}	1	\N	1.00	2026-11-18 15:19:39.913715+05:30	f	[]	[]
147	1	Q-M2-0D7A274CC7	2	Which SQL operator combines results of two queries and keeps duplicates?	{UNION,"UNION ALL",INTERSECT,"DISTINCT UNION"}	2	\N	1.00	2026-11-18 15:19:39.914356+05:30	f	[]	[]
148	1	Q-M2-8CEFC99B47	2	A subquery is:	{"A stored index","A query that runs only at midnight","A query nested inside another query","A backup copy of a table"}	3	\N	1.00	2026-11-18 15:19:39.915002+05:30	f	[]	[]
149	1	Q-M2-BDF2FD623F	2	What is a primary key?	{"A column that can contain duplicate values","A column that always contains NULL","A column or set of columns uniquely identifying each row","A key used to encrypt data"}	3	\N	1.00	2026-11-18 15:19:39.915617+05:30	f	[]	[]
150	1	Q-M2-EE29E39316	2	Can a primary key column contain NULL values?	{No,"Only if it is numeric","Yes, any number of times","Yes, but only once"}	1	\N	1.00	2026-11-18 15:19:39.916334+05:30	f	[]	[]
151	1	Q-M2-EB4DFA4C72	2	What is a foreign key?	{"A duplicate primary key in the same table","A key used only for sorting","An encrypted password column","A column that references the primary key of another table"}	4	\N	1.00	2026-11-18 15:19:39.917041+05:30	f	[]	[]
152	1	Q-M2-332C1CCA69	2	A candidate key is:	{"A minimal set of attributes that can uniquely identify a row","Any column containing numbers","A key that is always a foreign key","A key stored in the index only"}	1	\N	1.00	2026-11-18 15:19:39.917702+05:30	f	[]	[]
153	1	Q-M2-520BC5ED3D	2	A super key is:	{"The smallest possible key","A key that references another table","A key that is hidden from users","A set of attributes that uniquely identifies a row, possibly with extra attributes"}	4	\N	1.00	2026-11-18 15:19:39.91832+05:30	f	[]	[]
154	1	Q-M2-51E67689C0	2	A composite key is:	{"A key made up of two or more attributes","A key that is automatically generated","A key that holds only text","A key stored in a separate database"}	1	\N	1.00	2026-11-18 15:19:39.918911+05:30	f	[]	[]
155	1	Q-M2-E809198EEE	2	Which constraint ensures that all values in a column are different?	{"NOT NULL",DEFAULT,UNIQUE,CHECK}	3	\N	1.00	2026-11-18 15:19:39.919555+05:30	f	[]	[]
156	1	Q-M2-44B196CCF3	2	Which constraint prevents a column from holding NULL values?	{UNIQUE,INDEX,"NOT NULL",DEFAULT}	3	\N	1.00	2026-11-18 15:19:39.920204+05:30	f	[]	[]
157	1	Q-M2-4A446A5854	2	Which constraint validates that values satisfy a specified condition?	{"FOREIGN KEY",DEFAULT,CHECK,"PRIMARY KEY"}	3	\N	1.00	2026-11-18 15:19:39.920844+05:30	f	[]	[]
158	1	Q-M2-753ABA7010	2	Which constraint supplies a value when none is provided during insertion?	{REFERENCES,UNIQUE,CHECK,DEFAULT}	4	\N	1.00	2026-11-18 15:19:39.921448+05:30	f	[]	[]
159	1	Q-M2-7CD55E39CF	2	What is referential integrity?	{"Every table must have an index","Foreign key values must match existing primary key values or be NULL","Queries must always use joins","All columns must be numeric"}	2	\N	1.00	2026-11-18 15:19:39.922061+05:30	f	[]	[]
160	1	Q-M2-CB406D454B	2	What does ER in ER diagram stand for?	{Entity-Record,Event-Response,Entity-Relationship,External-Relation}	3	\N	1.00	2026-11-18 15:19:39.922691+05:30	f	[]	[]
161	1	Q-M2-1E36686FE7	2	In an ER diagram, an entity is typically drawn as a:	{Rectangle,Diamond,Triangle,Oval}	1	\N	1.00	2026-11-18 15:19:39.923257+05:30	f	[]	[]
162	1	Q-M2-452BBA81FE	2	In an ER diagram, a relationship is typically drawn as a:	{Oval,"Circle with a cross",Rectangle,Diamond}	4	\N	1.00	2026-11-18 15:19:39.923957+05:30	f	[]	[]
163	1	Q-M2-5EDF9A286A	2	In an ER diagram, an attribute is typically drawn as an:	{Arrow,Rectangle,Diamond,Oval}	4	\N	1.00	2026-11-18 15:19:39.925092+05:30	f	[]	[]
164	1	Q-M2-87ADFE1C0D	2	A weak entity is one that:	{"Has no attributes","Cannot be uniquely identified by its own attributes alone","Has no relationship","Is stored only in memory"}	2	\N	1.00	2026-11-18 15:19:39.925857+05:30	f	[]	[]
165	1	Q-M2-F5FB175282	2	A derived attribute is one that:	{"Has multiple values","Can be calculated from other attributes","Is always NULL","Is the primary key"}	2	\N	1.00	2026-11-18 15:19:39.926468+05:30	f	[]	[]
166	1	Q-M2-945B48B447	2	A multivalued attribute is one that:	{"Can hold more than one value for a single entity","Is calculated from others","Cannot be stored","Is always a key"}	1	\N	1.00	2026-11-18 15:19:39.927342+05:30	f	[]	[]
167	1	Q-M2-1E76C2ECD7	2	Which cardinality describes that many students can enrol in many courses?	{Many-to-many,One-to-many,Zero-to-one,One-to-one}	1	\N	1.00	2026-11-18 15:19:39.928036+05:30	f	[]	[]
168	1	Q-M2-DF0E7FE779	2	A many-to-many relationship in a relational schema is typically implemented using:	{"A trigger","A junction (associative) table","A single column","A view"}	2	\N	1.00	2026-11-18 15:19:39.928765+05:30	f	[]	[]
169	1	Q-M2-69A8E74C95	2	What is normalization?	{"Encrypting data for security","Converting data to JSON","Organising data to reduce redundancy and improve integrity","Backing up data regularly"}	3	\N	1.00	2026-11-18 15:19:39.929508+05:30	f	[]	[]
170	1	Q-M2-C8E25C1653	2	A table is in First Normal Form (1NF) if:	{"All columns are numeric","All attributes hold atomic values","It has no foreign keys","It has exactly one column"}	2	\N	1.00	2026-11-18 15:19:39.93011+05:30	f	[]	[]
171	1	Q-M2-6E6C81E897	2	A table is in Second Normal Form (2NF) if it is in 1NF and:	{"Has no partial dependency on a composite key","Has no transitive dependency","Has no primary key","Has only one row"}	1	\N	1.00	2026-11-18 15:19:39.930739+05:30	f	[]	[]
172	1	Q-M2-770A4B23CB	2	A table is in Third Normal Form (3NF) if it is in 2NF and:	{"Has no transitive dependency of non-key attributes on the key","Has no composite keys","Has at most three columns","Has no foreign keys"}	1	\N	1.00	2026-11-18 15:19:39.932294+05:30	f	[]	[]
173	1	Q-M2-54B2871EAC	2	Boyce-Codd Normal Form (BCNF) requires that for every functional dependency X -> Y:	{"X is a super key","Y is NULL","X is a foreign key","Y is a prime attribute only"}	1	\N	1.00	2026-11-18 15:19:39.932911+05:30	f	[]	[]
174	1	Q-M2-77B43B81C6	2	A functional dependency X -> Y means:	{"X is a foreign key of Y","Y determines many X values only","Each value of X determines exactly one value of Y","X and Y are identical columns"}	3	\N	1.00	2026-11-18 15:19:39.933542+05:30	f	[]	[]
175	1	Q-M2-0D7E5CB6CF	2	What is denormalization?	{"Converting tables to text","Deliberately adding redundancy to improve read performance","Splitting tables into smaller atoms","Removing all keys"}	2	\N	1.00	2026-11-18 15:19:39.934202+05:30	f	[]	[]
176	1	Q-M2-25A4375267	2	What does ACID stand for in database transactions?	{"Accuracy, Consistency, Integrity, Durability","Availability, Consistency, Isolation, Durability","Atomicity, Concurrency, Isolation, Distribution","Atomicity, Consistency, Isolation, Durability"}	4	\N	1.00	2026-11-18 15:19:39.934845+05:30	f	[]	[]
177	1	Q-M2-89246E552D	2	Atomicity in ACID means a transaction is:	{"Always read-only",All-or-nothing,"Always fast","Executed on a single CPU"}	2	\N	1.00	2026-11-18 15:19:39.935508+05:30	f	[]	[]
178	1	Q-M2-13E6669C18	2	Consistency in ACID means a transaction:	{"Always uses indexes","Never changes data","Runs only once","Moves the database from one valid state to another"}	4	\N	1.00	2026-11-18 15:19:39.936146+05:30	f	[]	[]
179	1	Q-M2-B463D1A6FB	2	Isolation in ACID ensures that:	{"Tables are separated into schemas","Data is stored on separate disks","Concurrent transactions do not interfere with one another","Users are isolated from the network"}	3	\N	1.00	2026-11-18 15:19:39.937399+05:30	f	[]	[]
180	1	Q-M2-2CA072416B	2	Durability in ACID ensures that:	{"Committed changes survive system failures","Transactions never fail","Data is encrypted","Queries are cached"}	1	\N	1.00	2026-11-18 15:19:39.938068+05:30	f	[]	[]
181	1	Q-M2-2998809A6B	2	Which SQL command makes a transaction's changes permanent?	{SAVEPOINT,ROLLBACK,COMMIT,GRANT}	3	\N	1.00	2026-11-18 15:19:39.938673+05:30	f	[]	[]
182	1	Q-M2-17A35642C0	2	Which SQL command undoes the changes of the current transaction?	{CHECKPOINT,COMMIT,ROLLBACK,REVOKE}	3	\N	1.00	2026-11-18 15:19:39.939431+05:30	f	[]	[]
183	1	Q-M2-AAE86764F2	2	Which SQL command sets a point within a transaction to which one can roll back partially?	{BOOKMARK,LABEL,SAVEPOINT,MARKER}	3	\N	1.00	2026-11-18 15:19:39.940027+05:30	f	[]	[]
184	1	Q-M2-6B92F3682B	2	Which SQL command gives privileges to a user?	{PERMIT,ALLOW,ENABLE,GRANT}	4	\N	1.00	2026-11-18 15:19:39.940553+05:30	f	[]	[]
185	1	Q-M2-A60736C90F	2	Which SQL command withdraws privileges from a user?	{REMOVE,REVOKE,DETACH,"DENY ALL"}	2	\N	1.00	2026-11-18 15:19:39.941169+05:30	f	[]	[]
186	1	Q-M2-C1DDBA808E	2	Which category does CREATE TABLE belong to?	{"DML (Data Manipulation Language)","DCL (Data Control Language)","TCL (Transaction Control Language)","DDL (Data Definition Language)"}	4	\N	1.00	2026-11-18 15:19:39.941851+05:30	f	[]	[]
187	1	Q-M2-1BFD8F5EB2	2	Which category does INSERT belong to?	{"TCL (Transaction Control Language)","DML (Data Manipulation Language)","DCL (Data Control Language)","DDL (Data Definition Language)"}	2	\N	1.00	2026-11-18 15:19:39.942457+05:30	f	[]	[]
188	1	Q-M2-2E9B663DC6	2	Which category does GRANT belong to?	{"DCL (Data Control Language)","DML (Data Manipulation Language)","DDL (Data Definition Language)","TCL (Transaction Control Language)"}	1	\N	1.00	2026-11-18 15:19:39.943166+05:30	f	[]	[]
189	1	Q-M2-C7EBA5CDF3	2	Which category does COMMIT belong to?	{"DCL (Data Control Language)","DML (Data Manipulation Language)","DDL (Data Definition Language)","TCL (Transaction Control Language)"}	4	\N	1.00	2026-11-18 15:19:39.94376+05:30	f	[]	[]
190	1	Q-M2-41C15E7D88	2	A database view is:	{"A physical copy of a table","A backup file","A virtual table based on the result of a query","A type of index"}	3	\N	1.00	2026-11-18 15:19:39.944358+05:30	f	[]	[]
191	1	Q-M2-E5A36BE931	2	What is the main purpose of an index in a database?	{"To enforce foreign keys","To speed up data retrieval","To reduce the number of columns","To encrypt data"}	2	\N	1.00	2026-11-18 15:19:39.945021+05:30	f	[]	[]
192	1	Q-M2-CDC4A63A4A	2	A disadvantage of creating many indexes on a table is:	{"Slower SELECT queries on all columns","Loss of primary keys","Slower insert, update and delete operations","Inability to join tables"}	3	\N	1.00	2026-11-18 15:19:39.945637+05:30	f	[]	[]
193	1	Q-M2-6A20917444	2	A clustered index determines:	{"The order of columns in the SELECT list","The size of the backup","The physical order of data rows in the table","The users allowed to read a table"}	3	\N	1.00	2026-11-18 15:19:39.946311+05:30	f	[]	[]
194	1	Q-M2-A5BDC840A3	2	Which data structure is most commonly used to implement database indexes?	{"Binary heap",Stack,"B+ tree","Circular queue"}	3	\N	1.00	2026-11-18 15:19:39.947026+05:30	f	[]	[]
195	1	Q-M2-B57892EBCC	2	A stored procedure is:	{"A type of constraint","A network protocol","A temporary table","A precompiled set of SQL statements stored in the database"}	4	\N	1.00	2026-11-18 15:19:39.947575+05:30	f	[]	[]
196	1	Q-M2-79BF3DB665	2	A trigger is:	{"An index type","A manual backup command","A join variant","Code that executes automatically in response to a table event"}	4	\N	1.00	2026-11-18 15:19:39.948281+05:30	f	[]	[]
197	1	Q-M2-295E54449C	2	A cursor in SQL is used to:	{"Move the mouse in a GUI","Process query results row by row","Create indexes","Encrypt columns"}	2	\N	1.00	2026-11-18 15:19:39.948888+05:30	f	[]	[]
198	1	Q-M2-2483E9EE97	2	What does relational algebra operation sigma (σ) represent?	{Selection,Join,Projection,Union}	1	\N	1.00	2026-11-18 15:19:39.949688+05:30	f	[]	[]
199	1	Q-M2-2F78D90D79	2	What does relational algebra operation pi (π) represent?	{Difference,Projection,Rename,Selection}	2	\N	1.00	2026-11-18 15:19:39.950489+05:30	f	[]	[]
200	1	Q-M2-6EDA34A292	2	Which relational algebra operator is used for renaming?	{"Rho (ρ)","Sigma (σ)","Pi (π)","Tau (τ)"}	1	\N	1.00	2026-11-18 15:19:39.951273+05:30	f	[]	[]
201	1	Q-M2-268A7CF39A	2	Union-compatible relations must have:	{"The same table name","The same number of attributes with matching domains","The same primary key","Identical row counts"}	2	\N	1.00	2026-11-18 15:19:39.951862+05:30	f	[]	[]
202	1	Q-M2-7C985AC4CB	2	What does the term 'degree' of a relation mean?	{"The number of attributes (columns)","The number of indexes","The number of foreign keys","The number of tuples (rows)"}	1	\N	1.00	2026-11-18 15:19:39.952528+05:30	f	[]	[]
203	1	Q-M2-99E7BED1E6	2	What does the term 'cardinality' of a relation mean in the relational model?	{"The number of tables","The number of attributes","The number of views","The number of tuples (rows)"}	4	\N	1.00	2026-11-18 15:19:39.95327+05:30	f	[]	[]
204	1	Q-M2-907179D9FA	2	A tuple in relational terminology corresponds to a:	{Table,Row,Database,Column}	2	\N	1.00	2026-11-18 15:19:39.954011+05:30	f	[]	[]
205	1	Q-M2-51411453BF	2	An attribute in relational terminology corresponds to a:	{Schema,Row,Column,Table}	3	\N	1.00	2026-11-18 15:19:39.954931+05:30	f	[]	[]
206	1	Q-M2-AEC00ADB4B	2	Which phenomenon occurs when a transaction reads data written by another uncommitted transaction?	{Deadlock,"Dirty read","Phantom read","Lost commit"}	2	\N	1.00	2026-11-18 15:19:39.955505+05:30	f	[]	[]
379	1	Q-M4-86B668E3C5	4	How many bits are in an IPv6 address?	{64,32,256,128}	4	\N	1.00	2026-11-18 15:19:40.072173+05:30	f	[]	[]
207	1	Q-M2-94EB484650	2	A non-repeatable read occurs when:	{"A table is dropped","A row is deleted","A row read twice in a transaction returns different values","A query returns no rows"}	3	\N	1.00	2026-11-18 15:19:39.956105+05:30	f	[]	[]
208	1	Q-M2-9A7955BC95	2	A phantom read occurs when:	{"A repeated query returns additional rows inserted by another transaction","A transaction reads uncommitted data","A row disappears from the log","An index becomes invalid"}	1	\N	1.00	2026-11-18 15:19:39.956764+05:30	f	[]	[]
209	1	Q-M2-5FA4876A62	2	Which isolation level is the strictest in standard SQL?	{"Repeatable read","Read committed",Serializable,"Read uncommitted"}	3	\N	1.00	2026-11-18 15:19:39.957409+05:30	f	[]	[]
210	1	Q-M2-D622B57F01	2	Which isolation level permits dirty reads?	{"Repeatable read","Read committed",Serializable,"Read uncommitted"}	4	\N	1.00	2026-11-18 15:19:39.958046+05:30	f	[]	[]
211	1	Q-M2-D1A3BEF025	2	Two-phase locking (2PL) ensures:	{"Automatic normalization","Data encryption","Faster index creation","Serializability of transactions"}	4	\N	1.00	2026-11-18 15:19:39.958673+05:30	f	[]	[]
212	1	Q-M2-2B62A81F4E	2	In database locking, a shared lock allows:	{"Only one transaction to write","Renaming the item","Deleting the item","Multiple transactions to read the same item"}	4	\N	1.00	2026-11-18 15:19:39.959333+05:30	f	[]	[]
213	1	Q-M2-C31DB34283	2	In database locking, an exclusive lock allows:	{"Only index scans","Only backup operations","Many transactions to read simultaneously","Only one transaction to read and write the item"}	4	\N	1.00	2026-11-18 15:19:39.960028+05:30	f	[]	[]
214	1	Q-M2-B33B17F147	2	A deadlock in a database occurs when:	{"A query runs slowly","Two or more transactions wait for each other's locks indefinitely","A table has no rows","An index is missing"}	2	\N	1.00	2026-11-18 15:19:39.960718+05:30	f	[]	[]
215	1	Q-M2-06B6614D33	2	The write-ahead log (WAL) protocol requires that:	{"Data pages are written before the log","Only reads are logged","Log records are written to stable storage before the changed data pages","Logs are deleted at commit"}	3	\N	1.00	2026-11-18 15:19:39.961356+05:30	f	[]	[]
216	1	Q-M2-7248206DEC	2	What is a checkpoint in a DBMS?	{"A user permission level","A point at which buffered changes are flushed to disk to speed recovery","A schema backup name","A type of lock"}	2	\N	1.00	2026-11-18 15:19:39.962034+05:30	f	[]	[]
217	1	Q-M2-C3BFD12412	2	Which structure is used to test whether a schedule is conflict serializable?	{"ER diagram",B-tree,"Parse tree","Precedence (serialization) graph"}	4	\N	1.00	2026-11-18 15:19:39.962735+05:30	f	[]	[]
218	1	Q-M2-E93295E83D	2	Which type of database is MongoDB?	{"Relational SQL","Column-oriented relational","Graph database","Document-oriented NoSQL"}	4	\N	1.00	2026-11-18 15:19:39.963419+05:30	f	[]	[]
219	1	Q-M2-2A0909B1AA	2	Which type of database is Redis primarily known as?	{"In-memory key-value store","Relational database","Time-series only","Document store on disk only"}	1	\N	1.00	2026-11-18 15:19:39.964124+05:30	f	[]	[]
220	1	Q-M2-CAC90B7A79	2	Which type of database is Neo4j?	{"Graph database","Object-relational database","Wide-column store","Key-value store"}	1	\N	1.00	2026-11-18 15:19:39.964799+05:30	f	[]	[]
221	1	Q-M2-AA05AB8F10	2	The CAP theorem states that a distributed system cannot simultaneously guarantee all of:	{"Concurrency, Atomicity and Persistence","Consistency, Availability and Partition tolerance","Capacity, Access and Privacy","Cost, Accuracy and Performance"}	2	\N	1.00	2026-11-18 15:19:39.965461+05:30	f	[]	[]
222	1	Q-M2-FA1527CC11	2	BASE properties are commonly associated with:	{"Traditional relational systems",Compilers,"Hardware design","NoSQL systems"}	4	\N	1.00	2026-11-18 15:19:39.966042+05:30	f	[]	[]
223	1	Q-M2-A3D21BDA56	2	What is sharding?	{"Compressing a table","Encrypting a database","Horizontally partitioning data across multiple servers","Joining tables on disk"}	3	\N	1.00	2026-11-18 15:19:39.966671+05:30	f	[]	[]
224	1	Q-M2-147EEF93FF	2	What is database replication?	{"Copying data across multiple servers to improve availability","Converting data to XML","Splitting a table by columns","Deleting old data"}	1	\N	1.00	2026-11-18 15:19:39.967402+05:30	f	[]	[]
225	1	Q-M2-1B5468AA90	2	What is a data warehouse mainly used for?	{"Handling real-time bank transactions only","Analytical processing of large historical data","Hosting websites","Running operating systems"}	2	\N	1.00	2026-11-18 15:19:39.968057+05:30	f	[]	[]
226	1	Q-M2-E426A05948	2	OLTP systems are characterised by:	{"No concurrency","Many short, frequent transactions","Few long analytical queries","Read-only data"}	2	\N	1.00	2026-11-18 15:19:39.968669+05:30	f	[]	[]
227	1	Q-M2-8A4905ECBD	2	OLAP systems are characterised by:	{"No aggregation","Many tiny updates","Single-row lookups only","Complex analytical queries over large volumes of data"}	4	\N	1.00	2026-11-18 15:19:39.969324+05:30	f	[]	[]
228	1	Q-M2-AC19F347A2	2	What is the purpose of the GROUP BY clause?	{"To join tables","To group rows sharing values so aggregates can be computed","To sort rows","To limit output rows"}	2	\N	1.00	2026-11-18 15:19:39.970389+05:30	f	[]	[]
229	1	Q-M2-E263695A45	2	Which SQL function returns the largest value in a column?	{TOP,HIGHEST,MAX,BIG}	3	\N	1.00	2026-11-18 15:19:39.971058+05:30	f	[]	[]
230	1	Q-M2-3734D3B5D9	2	Which SQL clause limits the number of rows returned (in MySQL and PostgreSQL)?	{"STOP AT","ROWNUM BY",LIMIT,CAP}	3	\N	1.00	2026-11-18 15:19:39.971801+05:30	f	[]	[]
231	1	Q-M2-CD21292651	2	What does SELECT * FROM students do?	{"Deletes all students","Returns only the first column","Creates a table named students","Returns all columns of all rows in students"}	4	\N	1.00	2026-11-18 15:19:39.972511+05:30	f	[]	[]
232	1	Q-M2-464A632B38	2	What does the SQL keyword AS do?	{"Assigns a primary key","Starts a transaction","Creates an alias for a column or table","Aggregates rows"}	3	\N	1.00	2026-11-18 15:19:39.973233+05:30	f	[]	[]
233	1	Q-M2-BDFAF5C9BA	2	Which SQL operator checks whether a value matches any value in a list?	{"ANY LIST",HAS,CONTAINS,IN}	4	\N	1.00	2026-11-18 15:19:39.97386+05:30	f	[]	[]
234	1	Q-M2-AECBA020AE	2	Which SQL keyword tests whether a subquery returns at least one row?	{AVAILABLE,"HAS ROWS",EXISTS,PRESENT}	3	\N	1.00	2026-11-18 15:19:39.974482+05:30	f	[]	[]
235	1	Q-M2-64969CC778	2	In SQL, what does ON DELETE CASCADE do for a foreign key?	{"Deletes dependent child rows when the parent row is deleted","Sets all columns to zero","Deletes the entire database","Blocks deletion permanently"}	1	\N	1.00	2026-11-18 15:19:39.975174+05:30	f	[]	[]
236	1	Q-M2-6518BFF3DE	2	Which SQL data type is best for storing an exact monetary amount?	{FLOAT,DECIMAL,BLOB,CHAR}	2	\N	1.00	2026-11-18 15:19:39.975836+05:30	f	[]	[]
237	1	Q-M2-D7D233E972	2	Which SQL data type stores variable-length character strings?	{INT,CHAR,VARCHAR,DATE}	3	\N	1.00	2026-11-18 15:19:39.976427+05:30	f	[]	[]
238	1	Q-M2-3886BE5E92	2	Which SQL data type stores large binary objects such as images?	{BLOB,BOOLEAN,VARCHAR,TINYINT}	1	\N	1.00	2026-11-18 15:19:39.976993+05:30	f	[]	[]
239	1	Q-M2-40126685E1	2	Which SQL function converts a string to uppercase in most databases?	{UPPER,BIGCASE,TOUPPER,CAPS}	1	\N	1.00	2026-11-18 15:19:39.977526+05:30	f	[]	[]
240	1	Q-M2-6CA881D284	2	What does the SQL function COALESCE do?	{"Counts distinct rows","Converts text to uppercase","Merges two tables","Returns the first non-NULL argument"}	4	\N	1.00	2026-11-18 15:19:39.978132+05:30	f	[]	[]
241	1	Q-M3-D39D72C62A	3	What is the primary role of an operating system?	{"Designing user interfaces only","Managing hardware resources and providing services to programs","Browsing the internet","Compiling source code"}	2	\N	1.00	2026-11-18 15:19:39.978765+05:30	f	[]	[]
242	1	Q-M3-4DE4036424	3	Which component of the OS is always resident in memory and manages core functions?	{Shell,Compiler,"Loader script",Kernel}	4	\N	1.00	2026-11-18 15:19:39.979307+05:30	f	[]	[]
243	1	Q-M3-7B25777E6A	3	What is the difference between a shell and a kernel?	{"The shell manages memory while the kernel is a text editor","The shell is a user interface to the kernel","The kernel runs only user commands","They are the same component"}	2	\N	1.00	2026-11-18 15:19:39.9798+05:30	f	[]	[]
244	1	Q-M3-5EA1481D9A	3	Which mode has unrestricted access to hardware instructions?	{"Safe mode only","User mode","Guest mode","Kernel mode"}	4	\N	1.00	2026-11-18 15:19:39.980353+05:30	f	[]	[]
245	1	Q-M3-4E61668BCC	3	What is a system call?	{"A request from a program to the OS kernel for a service","A phone call to support","A compiler directive","A hardware interrupt only"}	1	\N	1.00	2026-11-18 15:19:39.980976+05:30	f	[]	[]
246	1	Q-M3-8011798CDB	3	Which of these is an example of a monolithic kernel OS?	{"MINIX 3","Traditional Linux","Mach microkernel alone",QNX}	2	\N	1.00	2026-11-18 15:19:39.981682+05:30	f	[]	[]
247	1	Q-M3-F67DF8758A	3	Which design places only essential services in the kernel and runs others in user space?	{Microkernel,"Single-user kernel","Monolithic kernel","Batch system"}	1	\N	1.00	2026-11-18 15:19:39.982408+05:30	f	[]	[]
248	1	Q-M3-48B1C1678E	3	A process is best defined as:	{"A header file","A program in execution","A CPU register","A program stored on disk"}	2	\N	1.00	2026-11-18 15:19:39.983016+05:30	f	[]	[]
249	1	Q-M3-E878F316A8	3	What is a Process Control Block (PCB)?	{"A type of memory page","A hardware chip","A scheduling algorithm","A data structure holding information about a process"}	4	\N	1.00	2026-11-18 15:19:39.983648+05:30	f	[]	[]
250	1	Q-M3-A22C1FA5DF	3	Which of these is NOT a standard process state?	{Ready,Compiled,Waiting,Running}	2	\N	1.00	2026-11-18 15:19:39.984259+05:30	f	[]	[]
251	1	Q-M3-FBB632683E	3	In which state is a process waiting to be assigned to the CPU?	{Blocked,Running,Terminated,Ready}	4	\N	1.00	2026-11-18 15:19:39.984817+05:30	f	[]	[]
252	1	Q-M3-2815562795	3	Which event moves a process from running to waiting (blocked) state?	{"Requesting an I/O operation","Being created","Time quantum expiry","Normal completion"}	1	\N	1.00	2026-11-18 15:19:39.985531+05:30	f	[]	[]
253	1	Q-M3-BFA5D69CD4	3	What is a context switch?	{"Saving the state of one process and loading that of another","Rebooting the OS","Changing the monitor","Switching from C to Java"}	1	\N	1.00	2026-11-18 15:19:39.986133+05:30	f	[]	[]
254	1	Q-M3-20CC78E678	3	Context switching is considered:	{"The most productive CPU activity","Pure overhead because no useful work is done during it","Only needed in single-process systems","Free of cost"}	2	\N	1.00	2026-11-18 15:19:39.986799+05:30	f	[]	[]
255	1	Q-M3-F6255BBD3E	3	What is a thread?	{"A hardware register","A lightweight unit of execution within a process","A kind of file","A network packet"}	2	\N	1.00	2026-11-18 15:19:39.987448+05:30	f	[]	[]
256	1	Q-M3-4489BDD59B	3	Threads of the same process share:	{"Stack and registers",Nothing,"Code, data and open files","Program counter"}	3	\N	1.00	2026-11-18 15:19:39.988389+05:30	f	[]	[]
257	1	Q-M3-24907F14CF	3	Which of these is private to each thread?	{"Global variables","Stack and registers","Code segment",Heap}	2	\N	1.00	2026-11-18 15:19:39.989026+05:30	f	[]	[]
258	1	Q-M3-00B9FD0ABF	3	A key advantage of multithreading is:	{"Using more disk space","Eliminating all synchronisation issues","Preventing deadlocks automatically","Better responsiveness and resource sharing"}	4	\N	1.00	2026-11-18 15:19:39.989766+05:30	f	[]	[]
259	1	Q-M3-1B369333B1	3	Which system call creates a new process in UNIX/Linux?	{start,create_proc,spawnl,fork}	4	\N	1.00	2026-11-18 15:19:39.990525+05:30	f	[]	[]
260	1	Q-M3-07EBB7ABB5	3	What value does fork() return in the child process?	{-1,"The child's PID",0,"The parent's PID"}	3	\N	1.00	2026-11-18 15:19:39.991126+05:30	f	[]	[]
261	1	Q-M3-876EF679D8	3	What value does fork() return to the parent process on success?	{"The child's PID",0,"The parent's PID",-1}	1	\N	1.00	2026-11-18 15:19:39.991681+05:30	f	[]	[]
262	1	Q-M3-D9FABDE348	3	A zombie process is one that:	{"Runs forever","Has no parent and is running","Uses all memory","Has terminated but still has an entry in the process table"}	4	\N	1.00	2026-11-18 15:19:39.992268+05:30	f	[]	[]
263	1	Q-M3-6955E149E9	3	An orphan process is one whose:	{"Memory is full","Child has terminated","State is ready","Parent has terminated while it is still running"}	4	\N	1.00	2026-11-18 15:19:39.99288+05:30	f	[]	[]
264	1	Q-M3-BB54F61441	3	Which Linux system call replaces the current process image with a new program?	{"clone only",exec,wait,fork}	2	\N	1.00	2026-11-18 15:19:39.993578+05:30	f	[]	[]
265	1	Q-M3-5E89A83A5E	3	Which system call makes a parent wait for its child to finish?	{exit,wait,pause,sleep}	2	\N	1.00	2026-11-18 15:19:39.994197+05:30	f	[]	[]
266	1	Q-M3-6774117909	3	Which CPU scheduling algorithm is non-preemptive and runs processes in arrival order?	{"First-Come, First-Served (FCFS)","Multilevel feedback queue","Shortest Remaining Time First","Round Robin"}	1	\N	1.00	2026-11-18 15:19:39.994997+05:30	f	[]	[]
267	1	Q-M3-78CA4A2D68	3	Which problem is commonly associated with FCFS scheduling?	{"Convoy effect","Belady's anomaly","Priority inversion",Thrashing}	1	\N	1.00	2026-11-18 15:19:39.996069+05:30	f	[]	[]
268	1	Q-M3-D6D664C52D	3	Which scheduling algorithm gives minimum average waiting time for a given set of processes (when burst times are known)?	{FCFS,"Round Robin","Priority scheduling","Shortest Job First"}	4	\N	1.00	2026-11-18 15:19:39.996606+05:30	f	[]	[]
269	1	Q-M3-6079693814	3	The preemptive version of Shortest Job First is called:	{"Shortest Remaining Time First","Round Robin","First Come First Served","Longest Job First"}	1	\N	1.00	2026-11-18 15:19:39.997109+05:30	f	[]	[]
270	1	Q-M3-E697CF1783	3	Which scheduling algorithm uses a fixed time quantum?	{SJF,FCFS,"Highest response ratio next","Round Robin"}	4	\N	1.00	2026-11-18 15:19:39.997618+05:30	f	[]	[]
271	1	Q-M3-2D27582EC0	3	In Round Robin scheduling, if the time quantum is very large, it behaves like:	{"Priority scheduling",SJF,FCFS,"Multilevel queue"}	3	\N	1.00	2026-11-18 15:19:39.998205+05:30	f	[]	[]
272	1	Q-M3-BED4E1B4A5	3	In Round Robin scheduling, if the time quantum is extremely small, the main problem is:	{"Starvation of short jobs",Deadlock,"Excessive context-switch overhead","Convoy effect"}	3	\N	1.00	2026-11-18 15:19:39.998835+05:30	f	[]	[]
273	1	Q-M3-17BD1872AE	3	Starvation in priority scheduling can be solved by:	{"Disabling interrupts","Increasing quantum size",Paging,Aging}	4	\N	1.00	2026-11-18 15:19:39.999393+05:30	f	[]	[]
274	1	Q-M3-FF871DCBCB	3	Turnaround time is defined as:	{"Completion time minus arrival time","Waiting time minus burst time","Response time plus I/O time","Arrival time minus burst time"}	1	\N	1.00	2026-11-18 15:19:39.999933+05:30	f	[]	[]
275	1	Q-M3-F4C27A2CE5	3	Waiting time of a process equals:	{"Burst time minus arrival time","Completion time minus burst time plus arrival","Turnaround time minus burst time","Turnaround time plus burst time"}	3	\N	1.00	2026-11-18 15:19:40.000477+05:30	f	[]	[]
276	1	Q-M3-BF1856696A	3	Response time is the time between:	{"Submission of a request and the first response","Completion and arrival","Start and end of the I/O","Two context switches"}	1	\N	1.00	2026-11-18 15:19:40.001067+05:30	f	[]	[]
277	1	Q-M3-10E6CAD9C7	3	Throughput of a system is:	{"Memory used per process","Number of processes completed per unit time","Total CPU idle time","Average disk seek time"}	2	\N	1.00	2026-11-18 15:19:40.001698+05:30	f	[]	[]
278	1	Q-M3-4D0C60B106	3	A race condition occurs when:	{"A CPU overheats","The outcome depends on the timing of concurrent accesses to shared data","Two processes run on different CPUs without sharing","A process finishes too quickly"}	2	\N	1.00	2026-11-18 15:19:40.002318+05:30	f	[]	[]
279	1	Q-M3-551379EDC6	3	A critical section is:	{"Code that accesses shared resources and must not be executed by more than one process at a time","The most important function of the kernel","A damaged memory area","A boot sector"}	1	\N	1.00	2026-11-18 15:19:40.0029+05:30	f	[]	[]
280	1	Q-M3-C34954276F	3	Which of the following is NOT a requirement for a critical section solution?	{"Bounded waiting","Maximum CPU speed","Mutual exclusion",Progress}	2	\N	1.00	2026-11-18 15:19:40.003444+05:30	f	[]	[]
281	1	Q-M3-A21610EE79	3	What is a semaphore?	{"A network device","A type of cache","An integer variable used for process synchronisation","A disk scheduler"}	3	\N	1.00	2026-11-18 15:19:40.004032+05:30	f	[]	[]
282	1	Q-M3-14B2B03FE4	3	Which two atomic operations are defined on a semaphore?	{"read and write","wait (P) and signal (V)","push and pop","open and close"}	2	\N	1.00	2026-11-18 15:19:40.004563+05:30	f	[]	[]
283	1	Q-M3-1623720691	3	A binary semaphore can take values:	{"Only negative integers","0 to 255","0 and 1","Any integer"}	3	\N	1.00	2026-11-18 15:19:40.005056+05:30	f	[]	[]
284	1	Q-M3-5B34249C68	3	What is a mutex mainly used for?	{"Mutual exclusion over a shared resource","Network routing","File compression","Memory paging"}	1	\N	1.00	2026-11-18 15:19:40.005571+05:30	f	[]	[]
285	1	Q-M3-59348C2538	3	Which classic problem models a bounded buffer shared between producers and consumers?	{"Producer-Consumer problem","Dining philosophers",Readers-writers,"Banker's problem"}	1	\N	1.00	2026-11-18 15:19:40.006132+05:30	f	[]	[]
286	1	Q-M3-CB423835E4	3	Which classic problem illustrates deadlock and starvation with five philosophers sharing five forks?	{"Cigarette smokers","Producer-consumer problem","Sleeping barber","Dining philosophers problem"}	4	\N	1.00	2026-11-18 15:19:40.006679+05:30	f	[]	[]
287	1	Q-M3-EDAAA84B67	3	A monitor in OS synchronisation is:	{"A page replacement policy","A high-level construct that ensures only one process is active inside it at a time","A display device","A CPU performance counter"}	2	\N	1.00	2026-11-18 15:19:40.007263+05:30	f	[]	[]
288	1	Q-M3-81105873F6	3	A spinlock is a lock in which a thread:	{"Kills other threads","Repeatedly checks (busy waits) until the lock becomes available","Sleeps until woken","Never acquires the lock"}	2	\N	1.00	2026-11-18 15:19:40.007854+05:30	f	[]	[]
289	1	Q-M3-1BDD3A06A9	3	What is deadlock?	{"A state where processes wait indefinitely for resources held by each other","A fast CPU state","A memory leak","A scheduling algorithm"}	1	\N	1.00	2026-11-18 15:19:40.008443+05:30	f	[]	[]
290	1	Q-M3-CDCC3E7B3E	3	Which of the following is NOT one of the four necessary conditions for deadlock?	{Preemption,"Circular wait","Hold and wait","Mutual exclusion"}	1	\N	1.00	2026-11-18 15:19:40.00904+05:30	f	[]	[]
291	1	Q-M3-0B18396F5D	3	The 'no preemption' condition for deadlock means:	{"Resources cannot be forcibly taken from a process holding them","Memory cannot be paged","The CPU cannot be preempted by interrupts","Processes cannot be created"}	1	\N	1.00	2026-11-18 15:19:40.009681+05:30	f	[]	[]
292	1	Q-M3-BD06BD3ECE	3	Which algorithm is used for deadlock avoidance?	{"Round Robin","Elevator algorithm","Banker's algorithm",LRU}	3	\N	1.00	2026-11-18 15:19:40.01029+05:30	f	[]	[]
293	1	Q-M3-135E278FC2	3	A system state is 'safe' if:	{"All memory is free","No process is running","There exists a sequence in which all processes can finish","No resources are allocated"}	3	\N	1.00	2026-11-18 15:19:40.010907+05:30	f	[]	[]
294	1	Q-M3-716F4F992A	3	Breaking the circular wait condition can be done by:	{"Imposing a total ordering on resource requests","Using more threads","Allowing preemption of the CPU","Increasing RAM"}	1	\N	1.00	2026-11-18 15:19:40.01151+05:30	f	[]	[]
295	1	Q-M3-ACE2A217C5	3	A resource-allocation graph with a cycle implies deadlock for sure when:	{"The graph is acyclic","Each resource type has only a single instance","Resources are plentiful","Processes are idle"}	2	\N	1.00	2026-11-18 15:19:40.012191+05:30	f	[]	[]
296	1	Q-M3-9D30B5E984	3	What is the 'ostrich algorithm' for deadlock handling?	{"Killing all processes","Preempting all resources","Using spinlocks","Ignoring the problem"}	4	\N	1.00	2026-11-18 15:19:40.013178+05:30	f	[]	[]
297	1	Q-M3-2CBBA98CE2	3	Logical address is generated by:	{"The CPU","The disk controller","The MMU hardware output","The memory unit"}	1	\N	1.00	2026-11-18 15:19:40.013749+05:30	f	[]	[]
298	1	Q-M3-D4B3EEBA12	3	Physical address refers to:	{"An address on the network","The actual location in main memory","The address seen by a program","A cache tag"}	2	\N	1.00	2026-11-18 15:19:40.014943+05:30	f	[]	[]
299	1	Q-M3-D8EAA4E30F	3	The hardware that maps logical addresses to physical addresses is:	{ALU,"Memory Management Unit (MMU)","Cache controller","DMA controller"}	2	\N	1.00	2026-11-18 15:19:40.016157+05:30	f	[]	[]
300	1	Q-M3-6AD9CD7B2E	3	Contiguous memory allocation can suffer from:	{"Disk failure","Cache misses only","External fragmentation","Page faults only"}	3	\N	1.00	2026-11-18 15:19:40.016894+05:30	f	[]	[]
301	1	Q-M3-1CBF9D988B	3	Internal fragmentation occurs when:	{"Free memory is scattered in small holes","Files are too large","Pages are missing","Allocated memory is larger than the requested amount, leaving unused space inside"}	4	\N	1.00	2026-11-18 15:19:40.017494+05:30	f	[]	[]
302	1	Q-M3-F577DE2074	3	External fragmentation can be reduced by:	{"Using smaller caches","Disabling paging","Increasing block size",Compaction}	4	\N	1.00	2026-11-18 15:19:40.018979+05:30	f	[]	[]
303	1	Q-M3-11E8924E17	3	Which memory allocation strategy picks the first hole that is large enough?	{"Worst fit","First fit","Next quantum","Best fit"}	2	\N	1.00	2026-11-18 15:19:40.020235+05:30	f	[]	[]
304	1	Q-M3-0CFC4B0B5A	3	Which allocation strategy picks the smallest hole that is large enough?	{"Random fit","First fit","Worst fit","Best fit"}	4	\N	1.00	2026-11-18 15:19:40.021625+05:30	f	[]	[]
305	1	Q-M3-D61DA68ECE	3	Paging divides physical memory into fixed-size blocks called:	{Segments,Sectors,Frames,Clusters}	3	\N	1.00	2026-11-18 15:19:40.022308+05:30	f	[]	[]
306	1	Q-M3-5DFA629206	3	Paging divides logical memory into fixed-size blocks called:	{Pages,Banks,Frames,Tracks}	1	\N	1.00	2026-11-18 15:19:40.022904+05:30	f	[]	[]
307	1	Q-M3-18EE607D18	3	Paging eliminates:	{"Page tables","Internal fragmentation","External fragmentation","All fragmentation"}	3	\N	1.00	2026-11-18 15:19:40.023508+05:30	f	[]	[]
308	1	Q-M3-F747C6776A	3	Which structure maps pages to frames?	{"File allocation table","Interrupt vector","Process table","Page table"}	4	\N	1.00	2026-11-18 15:19:40.024065+05:30	f	[]	[]
309	1	Q-M3-0118756FCC	3	What is the Translation Lookaside Buffer (TLB)?	{"A disk cache","A buffer for keyboard input","A network buffer","A fast cache of recent page-table entries"}	4	\N	1.00	2026-11-18 15:19:40.024737+05:30	f	[]	[]
310	1	Q-M3-6777F29C75	3	A TLB hit means:	{"The page translation was found in the TLB","The cache is full","The page is on disk","The process crashed"}	1	\N	1.00	2026-11-18 15:19:40.025365+05:30	f	[]	[]
311	1	Q-M3-D8136EC250	3	Segmentation divides a program into:	{"Logical units of variable size","Equal-sized pages",Sectors,"Fixed frames"}	1	\N	1.00	2026-11-18 15:19:40.02598+05:30	f	[]	[]
312	1	Q-M3-AAE608E3E5	3	What is virtual memory?	{"A technique that lets programs use more memory than physically available","A cloud backup","A memory chip type","Memory used only by the kernel"}	1	\N	1.00	2026-11-18 15:19:40.026617+05:30	f	[]	[]
313	1	Q-M3-42708CDFEF	3	What is a page fault?	{"A full disk","A corrupted page table","An access to a page that is not currently in main memory","A hardware failure of RAM"}	3	\N	1.00	2026-11-18 15:19:40.027227+05:30	f	[]	[]
314	1	Q-M3-C919BF6C76	3	Demand paging loads a page:	{"Only during idle time",Never,"At program start for all pages","Only when it is referenced"}	4	\N	1.00	2026-11-18 15:19:40.027763+05:30	f	[]	[]
315	1	Q-M3-7023A42605	3	Which page replacement algorithm replaces the page that will not be used for the longest time in the future?	{LRU,Optimal,Clock,FIFO}	2	\N	1.00	2026-11-18 15:19:40.028329+05:30	f	[]	[]
316	1	Q-M3-E738498CB3	3	Which page replacement algorithm replaces the page that was loaded earliest?	{Optimal,LRU,FIFO,LFU}	3	\N	1.00	2026-11-18 15:19:40.028918+05:30	f	[]	[]
317	1	Q-M3-6FCAF43833	3	Which page replacement algorithm replaces the page unused for the longest past time?	{LRU,MRU,FIFO,Optimal}	1	\N	1.00	2026-11-18 15:19:40.030041+05:30	f	[]	[]
318	1	Q-M3-B24E8FD5EF	3	Belady's anomaly is associated with:	{"Stack algorithms","FIFO page replacement","Optimal page replacement","LRU page replacement"}	2	\N	1.00	2026-11-18 15:19:40.030603+05:30	f	[]	[]
319	1	Q-M3-C44C6810B1	3	Thrashing occurs when:	{"A system spends more time paging than executing processes","Too many files are open","The CPU is overheated","The disk is full"}	1	\N	1.00	2026-11-18 15:19:40.031414+05:30	f	[]	[]
320	1	Q-M3-7903DDC3B0	3	The working set model is used to:	{"Schedule disk requests","Encrypt memory","Allocate files","Reduce thrashing by keeping needed pages in memory"}	4	\N	1.00	2026-11-18 15:19:40.032097+05:30	f	[]	[]
321	1	Q-M3-8D6390BF5D	3	The Clock page replacement algorithm is an approximation of:	{Optimal,Random,LRU,"FIFO exactly"}	3	\N	1.00	2026-11-18 15:19:40.032655+05:30	f	[]	[]
322	1	Q-M3-F89D1B3155	3	In a system with 4 KB pages, how many bits are needed for the page offset?	{14,10,12,16}	3	\N	1.00	2026-11-18 15:19:40.034012+05:30	f	[]	[]
323	1	Q-M3-498A3728F6	3	Which file system structure tracks free disk blocks using a bit per block?	{"Directory tree",Inode,Bitmap,FAT}	3	\N	1.00	2026-11-18 15:19:40.034636+05:30	f	[]	[]
324	1	Q-M3-BB43F4BF35	3	In UNIX file systems, an inode stores:	{"Only the file name","The file's contents only","Network settings","File metadata and block pointers"}	4	\N	1.00	2026-11-18 15:19:40.0352+05:30	f	[]	[]
325	1	Q-M3-075877486C	3	Which file allocation method suffers from external fragmentation and supports fast sequential access?	{"Contiguous allocation","Hashed allocation","Indexed allocation","Linked allocation"}	1	\N	1.00	2026-11-18 15:19:40.035843+05:30	f	[]	[]
326	1	Q-M3-59130E522E	3	Which file allocation method stores a pointer to the next block in each block?	{"Inode allocation","Contiguous allocation","Indexed allocation","Linked allocation"}	4	\N	1.00	2026-11-18 15:19:40.036506+05:30	f	[]	[]
327	1	Q-M3-93BBC472CF	3	Which file allocation method uses an index block containing pointers to all file blocks?	{"Contiguous allocation","Indexed allocation","Hashed allocation","Linked allocation"}	2	\N	1.00	2026-11-18 15:19:40.037102+05:30	f	[]	[]
328	1	Q-M3-527672CF2B	3	A hard link in UNIX is:	{"Another directory entry pointing to the same inode","A network link","A copy of the file","A shortcut to a file path"}	1	\N	1.00	2026-11-18 15:19:40.037624+05:30	f	[]	[]
329	1	Q-M3-4399EDEE32	3	A symbolic (soft) link in UNIX is:	{"A file lock","A second inode for the same data","A hardware link","A file containing the path of another file"}	4	\N	1.00	2026-11-18 15:19:40.038189+05:30	f	[]	[]
330	1	Q-M3-7C24337D22	3	Which Linux command lists files in a directory?	{cd,cat,ls,ps}	3	\N	1.00	2026-11-18 15:19:40.038789+05:30	f	[]	[]
331	1	Q-M3-3425695C41	3	Which Linux command prints the current working directory?	{cwd,dir,pwd,whoami}	3	\N	1.00	2026-11-18 15:19:40.03949+05:30	f	[]	[]
332	1	Q-M3-3528606DF1	3	Which Linux command changes file permissions?	{"chgrp only",chperm,chmod,chown}	3	\N	1.00	2026-11-18 15:19:40.040236+05:30	f	[]	[]
333	1	Q-M3-5B0ED55EF4	3	Which Linux command changes the owner of a file?	{chmod,chpasswd,chown,umask}	3	\N	1.00	2026-11-18 15:19:40.040879+05:30	f	[]	[]
334	1	Q-M3-08BF9053AF	3	In Linux, the permission mode 755 means:	{"Owner rw-, group r--, others r--","Owner rwx, group r-x, others r-x","Owner r-x, group r-x, others rwx","Owner rwx, group rwx, others rwx"}	2	\N	1.00	2026-11-18 15:19:40.042937+05:30	f	[]	[]
335	1	Q-M3-F1EC54B6CB	3	In Linux, the permission mode 644 means:	{"Owner r--, group rw-, others rw-","Owner rwx, group r-x, others r-x","Owner rwx, group rw-, others r--","Owner rw-, group r--, others r--"}	4	\N	1.00	2026-11-18 15:19:40.043523+05:30	f	[]	[]
336	1	Q-M3-0BB6881410	3	Which Linux command displays running processes?	{ps,mkdir,ls,df}	1	\N	1.00	2026-11-18 15:19:40.044052+05:30	f	[]	[]
337	1	Q-M3-D6704EE05F	3	Which Linux command sends a signal to terminate a process?	{abort,kill,end,stop}	2	\N	1.00	2026-11-18 15:19:40.044657+05:30	f	[]	[]
338	1	Q-M3-EF0EF18358	3	Which Linux command shows disk space usage of file systems?	{df,free,top,"du only for files"}	1	\N	1.00	2026-11-18 15:19:40.045227+05:30	f	[]	[]
339	1	Q-M3-57900A07C0	3	Which Linux command searches for text patterns in files?	{"sed only for deletion",find,grep,cat}	3	\N	1.00	2026-11-18 15:19:40.04583+05:30	f	[]	[]
340	1	Q-M3-74FCAB0411	3	Which operator redirects standard output to a file, overwriting it?	{>,|,>>,<}	1	\N	1.00	2026-11-18 15:19:40.046753+05:30	f	[]	[]
341	1	Q-M3-A053A6A49F	3	Which operator appends standard output to a file?	{>,"<< only",>>,|}	3	\N	1.00	2026-11-18 15:19:40.047315+05:30	f	[]	[]
342	1	Q-M3-1E848D5153	3	What is the PID of the init/systemd process on Linux?	{1000,100,0,1}	4	\N	1.00	2026-11-18 15:19:40.047983+05:30	f	[]	[]
343	1	Q-M3-A25BB28B6D	3	Which file descriptor number represents standard input in UNIX?	{2,1,0,3}	3	\N	1.00	2026-11-18 15:19:40.048647+05:30	f	[]	[]
344	1	Q-M3-007FDA9904	3	Which file descriptor number represents standard error in UNIX?	{1,2,3,0}	2	\N	1.00	2026-11-18 15:19:40.049323+05:30	f	[]	[]
345	1	Q-M3-B93F91B25A	3	What is an interrupt?	{"A memory leak","A type of loop","A signal that makes the CPU suspend its current task to handle an event","A file error"}	3	\N	1.00	2026-11-18 15:19:40.049953+05:30	f	[]	[]
346	1	Q-M3-698856417E	3	What does DMA (Direct Memory Access) allow?	{"The CPU to bypass the OS","Memory to be formatted","Programs to skip compilation","Devices to transfer data to memory without CPU involvement for each byte"}	4	\N	1.00	2026-11-18 15:19:40.051212+05:30	f	[]	[]
347	1	Q-M3-3C6E432738	3	Spooling is mainly used to:	{"Compress files","Queue jobs for slow devices like printers","Encrypt output","Reduce RAM size"}	2	\N	1.00	2026-11-18 15:19:40.051916+05:30	f	[]	[]
348	1	Q-M3-E66B8A9E46	3	Which disk scheduling algorithm services requests in the order they arrive?	{SSTF,SCAN,FCFS,C-LOOK}	3	\N	1.00	2026-11-18 15:19:40.052474+05:30	f	[]	[]
380	1	Q-M4-79FB2A66D2	4	How many bits are in a MAC address?	{32,128,48,64}	3	\N	1.00	2026-11-18 15:19:40.072833+05:30	f	[]	[]
349	1	Q-M3-C54DEE83B4	3	Which disk scheduling algorithm chooses the request closest to the current head position?	{FCFS,SCAN,C-SCAN,SSTF}	4	\N	1.00	2026-11-18 15:19:40.053451+05:30	f	[]	[]
350	1	Q-M3-F320481300	3	Which disk scheduling algorithm is also known as the elevator algorithm?	{SSTF,Random,FCFS,SCAN}	4	\N	1.00	2026-11-18 15:19:40.05426+05:30	f	[]	[]
351	1	Q-M3-265ABC4033	3	Seek time is the time taken to:	{"Rotate the platter to the sector","Transfer data","Move the disk arm to the required cylinder","Format the disk"}	3	\N	1.00	2026-11-18 15:19:40.054823+05:30	f	[]	[]
352	1	Q-M3-CEAFF6F10B	3	Rotational latency is the time for:	{"The disk to spin up","The CPU to switch tasks","The desired sector to rotate under the head","The arm to move to a track"}	3	\N	1.00	2026-11-18 15:19:40.055327+05:30	f	[]	[]
353	1	Q-M3-81E0EC7FC4	3	Which RAID level uses striping without redundancy?	{"RAID 6","RAID 0","RAID 1","RAID 5"}	2	\N	1.00	2026-11-18 15:19:40.055938+05:30	f	[]	[]
354	1	Q-M3-77E189F410	3	Which RAID level uses mirroring?	{"RAID 10 only with parity","RAID 0","RAID 5","RAID 1"}	4	\N	1.00	2026-11-18 15:19:40.056628+05:30	f	[]	[]
355	1	Q-M3-1FB7746778	3	Which RAID level uses distributed parity and tolerates a single disk failure?	{"RAID 2","RAID 0","RAID 5","RAID 1"}	3	\N	1.00	2026-11-18 15:19:40.057319+05:30	f	[]	[]
356	1	Q-M3-F2CED5656F	3	A batch operating system:	{"Executes groups of similar jobs without user interaction","Needs a GUI","Is designed only for phones","Supports real-time response"}	1	\N	1.00	2026-11-18 15:19:40.058184+05:30	f	[]	[]
357	1	Q-M3-2F443C40A9	3	A real-time operating system (RTOS) is characterised by:	{"Large graphical interfaces","High throughput regardless of timing","No scheduling","Guaranteed response within strict time constraints"}	4	\N	1.00	2026-11-18 15:19:40.058869+05:30	f	[]	[]
358	1	Q-M3-CF5F77C371	3	What is multiprogramming?	{"Writing programs in multiple languages","Keeping several programs in memory to maximise CPU utilisation","Running programs on several computers","Compiling programs in parallel"}	2	\N	1.00	2026-11-18 15:19:40.059506+05:30	f	[]	[]
359	1	Q-M3-6DA1C9733E	3	What does symmetric multiprocessing (SMP) mean?	{"Each CPU has its own OS","All processors share memory and run the same OS","One CPU controls all others","Processors are on different networks"}	2	\N	1.00	2026-11-18 15:19:40.060139+05:30	f	[]	[]
360	1	Q-M3-0BD3BD4A71	3	The bootstrap loader is stored in:	{"The hard disk's data area only","RAM at runtime only",ROM/firmware,Cache}	3	\N	1.00	2026-11-18 15:19:40.060773+05:30	f	[]	[]
361	1	Q-M4-402B47219F	4	How many layers are there in the OSI reference model?	{6,5,7,4}	3	\N	1.00	2026-11-18 15:19:40.061341+05:30	f	[]	[]
362	1	Q-M4-C93F3E8121	4	Which OSI layer is responsible for routing packets between networks?	{"Session layer","Network layer","Data link layer","Transport layer"}	2	\N	1.00	2026-11-18 15:19:40.061922+05:30	f	[]	[]
363	1	Q-M4-60FD9BF87D	4	Which OSI layer provides end-to-end reliable delivery between processes?	{"Physical layer","Presentation layer","Network layer","Transport layer"}	4	\N	1.00	2026-11-18 15:19:40.062503+05:30	f	[]	[]
364	1	Q-M4-C364110772	4	Which OSI layer handles encryption, compression and data format translation?	{"Application layer","Data link layer","Presentation layer","Session layer"}	3	\N	1.00	2026-11-18 15:19:40.063045+05:30	f	[]	[]
365	1	Q-M4-4C4B3B8750	4	Which OSI layer establishes, manages and terminates sessions between applications?	{"Session layer","Transport layer","Network layer","Presentation layer"}	1	\N	1.00	2026-11-18 15:19:40.063583+05:30	f	[]	[]
366	1	Q-M4-14B04F5C33	4	Which OSI layer deals with the physical transmission of raw bits?	{"Transport layer","Data link layer","Physical layer","Network layer"}	3	\N	1.00	2026-11-18 15:19:40.064145+05:30	f	[]	[]
367	1	Q-M4-F3B4DD8FC3	4	Which OSI layer is responsible for framing and MAC addressing?	{"Session layer","Network layer","Physical layer","Data link layer"}	4	\N	1.00	2026-11-18 15:19:40.064727+05:30	f	[]	[]
368	1	Q-M4-174DBB4D7D	4	The data unit at the network layer is called a:	{Bit,Frame,Segment,Packet}	4	\N	1.00	2026-11-18 15:19:40.065253+05:30	f	[]	[]
369	1	Q-M4-AE88EC2BEC	4	The data unit at the data link layer is called a:	{Segment,Packet,Frame,Datagram}	3	\N	1.00	2026-11-18 15:19:40.065793+05:30	f	[]	[]
370	1	Q-M4-1D0888D33B	4	The data unit at the TCP transport layer is called a:	{Packet,Bit,Frame,Segment}	4	\N	1.00	2026-11-18 15:19:40.066341+05:30	f	[]	[]
371	1	Q-M4-2320BFEC2A	4	How many layers does the TCP/IP model have in its commonly taught four-layer form?	{3,4,7,5}	2	\N	1.00	2026-11-18 15:19:40.066887+05:30	f	[]	[]
372	1	Q-M4-319E316869	4	Which TCP/IP layer corresponds to the OSI network layer?	{"Application layer","Transport layer","Internet layer","Link layer"}	3	\N	1.00	2026-11-18 15:19:40.067445+05:30	f	[]	[]
373	1	Q-M4-B086BA6279	4	Which device operates primarily at the physical layer and simply regenerates signals?	{Router,Bridge,Gateway,Repeater}	4	\N	1.00	2026-11-18 15:19:40.068463+05:30	f	[]	[]
374	1	Q-M4-6A9AD4A770	4	Which device forwards frames based on MAC addresses?	{Repeater,Switch,Hub,Modem}	2	\N	1.00	2026-11-18 15:19:40.069282+05:30	f	[]	[]
375	1	Q-M4-7F1FCF1996	4	Which device forwards packets between different networks based on IP addresses?	{Repeater,Hub,Switch,Router}	4	\N	1.00	2026-11-18 15:19:40.069869+05:30	f	[]	[]
376	1	Q-M4-81000E02DC	4	Which device broadcasts every incoming signal to all its ports?	{Switch,Firewall,Hub,Router}	3	\N	1.00	2026-11-18 15:19:40.070453+05:30	f	[]	[]
377	1	Q-M4-9521E14656	4	Which device converts digital signals to analogue signals for transmission over telephone lines?	{Modem,Hub,Bridge,Switch}	1	\N	1.00	2026-11-18 15:19:40.071015+05:30	f	[]	[]
378	1	Q-M4-955890B0E9	4	How many bits are in an IPv4 address?	{48,128,32,64}	3	\N	1.00	2026-11-18 15:19:40.07163+05:30	f	[]	[]
381	1	Q-M4-E78AEB425F	4	How is an IPv4 address typically written?	{"Binary only","Dotted decimal notation","Octal with slashes","Colon hexadecimal notation"}	2	\N	1.00	2026-11-18 15:19:40.073737+05:30	f	[]	[]
382	1	Q-M4-3B8F861AE1	4	Which IPv4 class has a default subnet mask of 255.0.0.0?	{"Class D","Class A","Class C","Class B"}	2	\N	1.00	2026-11-18 15:19:40.074353+05:30	f	[]	[]
383	1	Q-M4-B331E4E44B	4	Which IPv4 class has a default subnet mask of 255.255.0.0?	{"Class B","Class E","Class A","Class C"}	1	\N	1.00	2026-11-18 15:19:40.074932+05:30	f	[]	[]
384	1	Q-M4-43867F12BE	4	Which IPv4 class has a default subnet mask of 255.255.255.0?	{"Class B","Class D","Class C","Class A"}	3	\N	1.00	2026-11-18 15:19:40.075481+05:30	f	[]	[]
385	1	Q-M4-4DAD034D12	4	Which IPv4 class is reserved for multicast?	{"Class E","Class D","Class A","Class C"}	2	\N	1.00	2026-11-18 15:19:40.076036+05:30	f	[]	[]
386	1	Q-M4-2F3B1FA115	4	What is the first-octet range of Class A addresses?	{"224 to 239","192 to 223","1 to 126","128 to 191"}	3	\N	1.00	2026-11-18 15:19:40.077085+05:30	f	[]	[]
387	1	Q-M4-2D3C60C4FB	4	What is the first-octet range of Class B addresses?	{"240 to 255","1 to 126","192 to 223","128 to 191"}	4	\N	1.00	2026-11-18 15:19:40.077919+05:30	f	[]	[]
388	1	Q-M4-F2C91973A2	4	What is the first-octet range of Class C addresses?	{"128 to 191","192 to 223","224 to 239","1 to 126"}	2	\N	1.00	2026-11-18 15:19:40.078539+05:30	f	[]	[]
389	1	Q-M4-8563210BB9	4	Which of the following is a private IPv4 address?	{192.168.1.10,8.8.8.8,11.0.0.1,172.32.0.5}	1	\N	1.00	2026-11-18 15:19:40.079106+05:30	f	[]	[]
390	1	Q-M4-262C7AF895	4	Which address range is reserved for private use under RFC 1918 for Class A?	{"127.0.0.0 to 127.255.255.255","10.0.0.0 to 10.255.255.255","100.0.0.0 to 100.255.255.255","11.0.0.0 to 11.255.255.255"}	2	\N	1.00	2026-11-18 15:19:40.079973+05:30	f	[]	[]
391	1	Q-M4-884B7980D9	4	What is the loopback address in IPv4?	{192.0.0.1,0.0.0.0,127.0.0.1,255.255.255.255}	3	\N	1.00	2026-11-18 15:19:40.080575+05:30	f	[]	[]
392	1	Q-M4-AF51E30CE0	4	What does the IPv4 address 255.255.255.255 represent?	{Loopback,"Multicast group","Default route","Limited broadcast"}	4	\N	1.00	2026-11-18 15:19:40.081168+05:30	f	[]	[]
393	1	Q-M4-8077C5336B	4	What does CIDR notation /24 signify?	{"The last 24 bits are the network portion","24 subnets","The first 24 bits are the network portion","24 hosts per network"}	3	\N	1.00	2026-11-18 15:19:40.081756+05:30	f	[]	[]
394	1	Q-M4-C7C465FEA7	4	What is the subnet mask for /26?	{255.255.255.128,255.255.255.240,255.255.255.224,255.255.255.192}	4	\N	1.00	2026-11-18 15:19:40.082378+05:30	f	[]	[]
395	1	Q-M4-BF1AB6CD52	4	How many usable host addresses are in a /24 network?	{255,254,256,252}	2	\N	1.00	2026-11-18 15:19:40.083214+05:30	f	[]	[]
396	1	Q-M4-27838B4505	4	How many usable host addresses are in a /30 network?	{1,2,6,4}	2	\N	1.00	2026-11-18 15:19:40.08378+05:30	f	[]	[]
397	1	Q-M4-9AF319D29E	4	How many usable host addresses are in a /27 network?	{62,28,30,32}	3	\N	1.00	2026-11-18 15:19:40.084403+05:30	f	[]	[]
398	1	Q-M4-12C2454DCF	4	What is the purpose of subnetting?	{"Encrypting traffic","Dividing a network into smaller logical networks","Increasing signal strength","Converting IPv4 to IPv6"}	2	\N	1.00	2026-11-18 15:19:40.084959+05:30	f	[]	[]
399	1	Q-M4-9102010588	4	What is the network address of host 192.168.10.77/26?	{192.168.10.76,192.168.10.0,192.168.10.128,192.168.10.64}	4	\N	1.00	2026-11-18 15:19:40.085505+05:30	f	[]	[]
400	1	Q-M4-0792069960	4	What is the broadcast address of network 192.168.1.0/24?	{192.168.1.1,192.168.1.254,192.168.0.255,192.168.1.255}	4	\N	1.00	2026-11-18 15:19:40.086048+05:30	f	[]	[]
401	1	Q-M4-2E509F3132	4	Which technology lets devices with private addresses access the internet using a public address?	{NAT,DHCP,DNS,ARP}	1	\N	1.00	2026-11-18 15:19:40.086858+05:30	f	[]	[]
402	1	Q-M4-30BFB395A3	4	Which protocol dynamically assigns IP addresses to hosts?	{SMTP,DHCP,ICMP,DNS}	2	\N	1.00	2026-11-18 15:19:40.0874+05:30	f	[]	[]
403	1	Q-M4-2BB0F0398B	4	Which protocol translates domain names to IP addresses?	{DHCP,ARP,FTP,DNS}	4	\N	1.00	2026-11-18 15:19:40.087944+05:30	f	[]	[]
404	1	Q-M4-641E51B8D3	4	Which protocol resolves an IP address to a MAC address on a local network?	{ARP,"RARP only for names",ICMP,DNS}	1	\N	1.00	2026-11-18 15:19:40.088553+05:30	f	[]	[]
405	1	Q-M4-A767071368	4	Which protocol is used by the ping command?	{UDP,SMTP,ICMP,TCP}	3	\N	1.00	2026-11-18 15:19:40.089225+05:30	f	[]	[]
406	1	Q-M4-ABE8251573	4	Which protocol provides connection-oriented, reliable data transfer?	{ICMP,UDP,TCP,IP}	3	\N	1.00	2026-11-18 15:19:40.089782+05:30	f	[]	[]
407	1	Q-M4-9622DFEA04	4	Which protocol provides connectionless, best-effort data transfer with low overhead?	{FTP,TCP,"SCTP only for streams",UDP}	4	\N	1.00	2026-11-18 15:19:40.090312+05:30	f	[]	[]
408	1	Q-M4-9F417E532B	4	How many steps are there in the TCP connection establishment handshake?	{3,2,4,5}	1	\N	1.00	2026-11-18 15:19:40.090926+05:30	f	[]	[]
409	1	Q-M4-01B6914B57	4	What is the sequence of messages in the TCP three-way handshake?	{"ACK, SYN, FIN","FIN, ACK, SYN","SYN, SYN-ACK, ACK","SYN, ACK, FIN"}	3	\N	1.00	2026-11-18 15:19:40.09166+05:30	f	[]	[]
410	1	Q-M4-67037D7769	4	Which TCP flag is used to terminate a connection gracefully?	{SYN,PSH,FIN,URG}	3	\N	1.00	2026-11-18 15:19:40.092259+05:30	f	[]	[]
411	1	Q-M4-30D1B29A7E	4	Which mechanism does TCP use to avoid overwhelming the receiver?	{NAT,"Checksum only",Subnetting,"Flow control using a sliding window"}	4	\N	1.00	2026-11-18 15:19:40.092848+05:30	f	[]	[]
412	1	Q-M4-EFF05AD265	4	Which mechanism does TCP use to reduce congestion in the network?	{"Frame check","ARP caching","DNS caching","Congestion control"}	4	\N	1.00	2026-11-18 15:19:40.093383+05:30	f	[]	[]
413	1	Q-M4-896E316602	4	Which TCP congestion-control phase increases the congestion window exponentially at first?	{"Time wait","Slow start","Congestion avoidance","Fast recovery"}	2	\N	1.00	2026-11-18 15:19:40.093951+05:30	f	[]	[]
414	1	Q-M4-EC1681D1DE	4	What is the well-known port number for HTTP?	{443,21,25,80}	4	\N	1.00	2026-11-18 15:19:40.094505+05:30	f	[]	[]
415	1	Q-M4-87E4787C2B	4	What is the well-known port number for HTTPS?	{80,443,8080,22}	2	\N	1.00	2026-11-18 15:19:40.095209+05:30	f	[]	[]
416	1	Q-M4-C2C08F7277	4	What is the well-known port number for SSH?	{23,22,53,25}	2	\N	1.00	2026-11-18 15:19:40.095749+05:30	f	[]	[]
417	1	Q-M4-A0B1ED5AB8	4	What is the well-known port number for Telnet?	{22,21,23,110}	3	\N	1.00	2026-11-18 15:19:40.097096+05:30	f	[]	[]
418	1	Q-M4-2AEA5A75DF	4	What is the well-known port number for FTP control connections?	{69,21,22,"20 only for control"}	2	\N	1.00	2026-11-18 15:19:40.097666+05:30	f	[]	[]
419	1	Q-M4-79CE950C0F	4	What is the well-known port number for SMTP?	{25,"587 only",143,110}	1	\N	1.00	2026-11-18 15:19:40.098248+05:30	f	[]	[]
420	1	Q-M4-2B5EF39C8C	4	What is the well-known port number for DNS?	{67,80,53,161}	3	\N	1.00	2026-11-18 15:19:40.098785+05:30	f	[]	[]
421	1	Q-M4-3D0F6F5CFC	4	Which protocol is used to send email from a client to a mail server?	{POP3,SNMP,IMAP,SMTP}	4	\N	1.00	2026-11-18 15:19:40.099417+05:30	f	[]	[]
422	1	Q-M4-A6B36DC1E8	4	Which protocol downloads email from a server and usually removes it from the server by default?	{POP3,SMTP,HTTP,IMAP}	1	\N	1.00	2026-11-18 15:19:40.100002+05:30	f	[]	[]
423	1	Q-M4-4CE3E3E3B5	4	Which email retrieval protocol keeps messages on the server and synchronises across devices?	{SMTP,IMAP,TFTP,POP3}	2	\N	1.00	2026-11-18 15:19:40.100649+05:30	f	[]	[]
424	1	Q-M4-B724465A27	4	Which protocol is used for transferring web pages?	{FTP,SNMP,TFTP,HTTP}	4	\N	1.00	2026-11-18 15:19:40.101151+05:30	f	[]	[]
425	1	Q-M4-34B30EDF35	4	Which HTTP method is typically used to retrieve a resource?	{POST,PUT,GET,DELETE}	3	\N	1.00	2026-11-18 15:19:40.101682+05:30	f	[]	[]
426	1	Q-M4-9D26EC544D	4	Which HTTP method is typically used to submit data to be processed by the server?	{HEAD,POST,GET,TRACE}	2	\N	1.00	2026-11-18 15:19:40.102775+05:30	f	[]	[]
427	1	Q-M4-59A47DD6D6	4	Which HTTP status code indicates a successful request?	{200,404,500,301}	1	\N	1.00	2026-11-18 15:19:40.103396+05:30	f	[]	[]
428	1	Q-M4-32D026F88E	4	Which HTTP status code means 'Not Found'?	{403,200,500,404}	4	\N	1.00	2026-11-18 15:19:40.10398+05:30	f	[]	[]
429	1	Q-M4-D1320ED7AE	4	Which HTTP status code means 'Internal Server Error'?	{500,404,301,401}	1	\N	1.00	2026-11-18 15:19:40.104857+05:30	f	[]	[]
430	1	Q-M4-E92AC39575	4	Which HTTP status code indicates a permanent redirect?	{302,304,200,301}	4	\N	1.00	2026-11-18 15:19:40.105481+05:30	f	[]	[]
431	1	Q-M4-7D0C8F98DF	4	Which HTTP status code means 'Forbidden'?	{404,401,403,502}	3	\N	1.00	2026-11-18 15:19:40.10606+05:30	f	[]	[]
432	1	Q-M4-AEF148B26C	4	What does HTTPS add to HTTP?	{"Faster speed only","Free hosting","Larger packet size","Encryption using TLS"}	4	\N	1.00	2026-11-18 15:19:40.106613+05:30	f	[]	[]
433	1	Q-M4-0080713DAC	4	Which protocol is used to securely log in to a remote machine?	{Telnet,FTP,SSH,TFTP}	3	\N	1.00	2026-11-18 15:19:40.107143+05:30	f	[]	[]
434	1	Q-M4-515CDE8DB1	4	Which protocol is used to transfer files and uses separate control and data connections?	{SMTP,FTP,HTTP,NTP}	2	\N	1.00	2026-11-18 15:19:40.107781+05:30	f	[]	[]
435	1	Q-M4-11DDD6FEE6	4	Which routing protocol is an interior gateway protocol using hop count as its metric?	{BGP,RIP,EGP,OSPF}	2	\N	1.00	2026-11-18 15:19:40.10827+05:30	f	[]	[]
436	1	Q-M4-7DAF57C5C8	4	What is the maximum hop count allowed in RIP?	{15,30,16,255}	1	\N	1.00	2026-11-18 15:19:40.108757+05:30	f	[]	[]
437	1	Q-M4-CD246D8BE5	4	Which routing protocol uses the link-state approach and Dijkstra's algorithm?	{OSPF,RIP,IGRP,BGP}	1	\N	1.00	2026-11-18 15:19:40.109344+05:30	f	[]	[]
438	1	Q-M4-B879B612A4	4	Which routing protocol is the standard exterior gateway protocol of the internet?	{BGP,OSPF,RIP,IS-IS}	1	\N	1.00	2026-11-18 15:19:40.109939+05:30	f	[]	[]
439	1	Q-M4-44468D9069	4	Distance vector routing protocols share routing information with:	{"All routers in the network via flooding","Directly connected neighbours","DNS servers","Only the default gateway of the sender"}	2	\N	1.00	2026-11-18 15:19:40.110431+05:30	f	[]	[]
440	1	Q-M4-19FB1CD9B6	4	The 'count-to-infinity' problem is associated with:	{"Source routing","Static routing","Link-state routing","Distance vector routing"}	4	\N	1.00	2026-11-18 15:19:40.110926+05:30	f	[]	[]
441	1	Q-M4-C7C8231700	4	Static routing differs from dynamic routing in that:	{"Routes adapt automatically","Routes are manually configured","It needs no routing table","It uses BGP"}	2	\N	1.00	2026-11-18 15:19:40.111529+05:30	f	[]	[]
442	1	Q-M4-45911E8E96	4	What is a default gateway?	{"The router a host uses to reach other networks","The DHCP lease time","The broadcast address","The DNS server address"}	1	\N	1.00	2026-11-18 15:19:40.112405+05:30	f	[]	[]
443	1	Q-M4-00EC976B75	4	What is the purpose of the TTL field in an IP header?	{"To encrypt the packet","To set priority","To limit the lifetime of a packet and prevent infinite loops","To store the checksum"}	3	\N	1.00	2026-11-18 15:19:40.112979+05:30	f	[]	[]
444	1	Q-M4-45176B5612	4	Which command traces the route packets take to a destination in Windows?	{netstat,ping,ipconfig,tracert}	4	\N	1.00	2026-11-18 15:19:40.113485+05:30	f	[]	[]
445	1	Q-M4-65A9229AEB	4	Which command shows active network connections and listening ports?	{netstat,arp,tracert,nslookup}	1	\N	1.00	2026-11-18 15:19:40.113953+05:30	f	[]	[]
446	1	Q-M4-86A5845874	4	Which command displays IP configuration of network interfaces in Windows?	{ifconfig,ipscan,netcfg,ipconfig}	4	\N	1.00	2026-11-18 15:19:40.114412+05:30	f	[]	[]
447	1	Q-M4-876C81EF16	4	Which Ethernet standard operates at 100 Mbps over twisted pair?	{10BASE-T,100BASE-TX,10GBASE-T,1000BASE-SX}	2	\N	1.00	2026-11-18 15:19:40.115056+05:30	f	[]	[]
448	1	Q-M4-C82C650756	4	Which access method was used by classic shared-medium Ethernet?	{CSMA/CD,CSMA/CA,"Token passing",TDMA}	1	\N	1.00	2026-11-18 15:19:40.115595+05:30	f	[]	[]
449	1	Q-M4-D8908E214A	4	Which access method does Wi-Fi (IEEE 802.11) use to avoid collisions?	{"Token ring",FDMA,CSMA/CA,CSMA/CD}	3	\N	1.00	2026-11-18 15:19:40.116147+05:30	f	[]	[]
450	1	Q-M4-F8DBC26014	4	Which IEEE standard defines Wi-Fi?	{802.15,802.11,802.16,802.3}	2	\N	1.00	2026-11-18 15:19:40.11672+05:30	f	[]	[]
451	1	Q-M4-3D67B5B6DD	4	Which IEEE standard defines Ethernet?	{802.1X,802.3,802.15,802.11}	2	\N	1.00	2026-11-18 15:19:40.117345+05:30	f	[]	[]
452	1	Q-M4-C758667E36	4	What is VLAN used for?	{"Logically segmenting a LAN into separate broadcast domains","Increasing Wi-Fi range","Translating addresses","Encrypting WAN traffic"}	1	\N	1.00	2026-11-18 15:19:40.117879+05:30	f	[]	[]
453	1	Q-M4-5BDD47BC04	4	What does the Spanning Tree Protocol (STP) prevent?	{"DNS poisoning","Port scanning","IP spoofing","Switching loops"}	4	\N	1.00	2026-11-18 15:19:40.118384+05:30	f	[]	[]
454	1	Q-M4-A495F71854	4	What is a MAC address?	{"An IP address alias","A DNS record","A domain suffix","A unique hardware address of a network interface"}	4	\N	1.00	2026-11-18 15:19:40.119259+05:30	f	[]	[]
455	1	Q-M4-A82A8A4AED	4	Which topology connects all devices to a central hub or switch?	{Ring,Mesh,Star,Bus}	3	\N	1.00	2026-11-18 15:19:40.121044+05:30	f	[]	[]
456	1	Q-M4-6AD34F0537	4	In which topology does failure of the single backbone cable bring down the whole network?	{Tree,Star,Bus,"Full mesh"}	3	\N	1.00	2026-11-18 15:19:40.121593+05:30	f	[]	[]
457	1	Q-M4-5337F44BFF	4	In a full-mesh topology of n nodes, how many links are required?	{n(n-1)/2,2n,n,n-1}	1	\N	1.00	2026-11-18 15:19:40.122037+05:30	f	[]	[]
458	1	Q-M4-8BC937AA9F	4	What is the maximum segment length for standard Cat5e/Cat6 Ethernet over copper?	{"500 metres","100 metres","1 kilometre","10 metres"}	2	\N	1.00	2026-11-18 15:19:40.122871+05:30	f	[]	[]
459	1	Q-M4-A12A589955	4	Which type of network spans a small geographic area like a building?	{LAN,MAN,WAN,PAN}	1	\N	1.00	2026-11-18 15:19:40.123858+05:30	f	[]	[]
460	1	Q-M4-C9F04EB850	4	Which type of network covers a large geographical area like countries?	{PAN,HAN,LAN,WAN}	4	\N	1.00	2026-11-18 15:19:40.124878+05:30	f	[]	[]
461	1	Q-M4-0F75FA15D7	4	What is a VPN primarily used for?	{"Speeding up Wi-Fi","Creating a secure encrypted tunnel over a public network","Assigning IP addresses","Blocking all traffic"}	2	\N	1.00	2026-11-18 15:19:40.125411+05:30	f	[]	[]
462	1	Q-M4-C55B228F35	4	What is a firewall?	{"A DNS server","A security system that filters network traffic by rules","A backup tool","A cooling device"}	2	\N	1.00	2026-11-18 15:19:40.126004+05:30	f	[]	[]
463	1	Q-M4-2BFDA0AF47	4	What is multiplexing?	{"Combining multiple signals over one shared medium","Amplifying a signal","Splitting a signal into noise","Encrypting signals"}	1	\N	1.00	2026-11-18 15:19:40.126496+05:30	f	[]	[]
464	1	Q-M4-9F4E666EA0	4	Which multiplexing technique divides the available frequency spectrum into separate bands?	{TDM,SDM,FDM,CDM}	3	\N	1.00	2026-11-18 15:19:40.127016+05:30	f	[]	[]
465	1	Q-M4-6E65A2B235	4	Which multiplexing technique allocates time slots to each user on a shared channel?	{TDM,FDM,OFDM,WDM}	1	\N	1.00	2026-11-18 15:19:40.12764+05:30	f	[]	[]
466	1	Q-M4-760E907A6D	4	Which error detection method uses polynomial division and is widely used in data link layers?	{CRC,"Hamming distance","Huffman coding","Parity only"}	1	\N	1.00	2026-11-18 15:19:40.128139+05:30	f	[]	[]
467	1	Q-M4-7262F40BA6	4	Which error-correcting code can correct single-bit errors?	{"Simple parity",CRC,"Hamming code",Checksum}	3	\N	1.00	2026-11-18 15:19:40.128689+05:30	f	[]	[]
468	1	Q-M4-C4917343F7	4	Which flow control technique allows multiple frames to be sent before waiting for acknowledgement?	{Handshake,Parity,Stop-and-wait,"Sliding window"}	4	\N	1.00	2026-11-18 15:19:40.129585+05:30	f	[]	[]
469	1	Q-M4-D13DCE1E7E	4	In Stop-and-Wait protocol, the sender:	{"Never waits","Sends frames continuously","Uses two windows","Sends one frame and waits for acknowledgement"}	4	\N	1.00	2026-11-18 15:19:40.130124+05:30	f	[]	[]
470	1	Q-M4-60ADC4229A	4	Which ARQ protocol retransmits only the erroneous or lost frames?	{Go-Back-N,"Stop-and-Wait only","Selective Repeat",Alohanet}	3	\N	1.00	2026-11-18 15:19:40.131298+05:30	f	[]	[]
471	1	Q-M4-EBB22EFDDF	4	What does the Go-Back-N protocol do upon detecting a lost frame?	{"Retransmits that frame and all subsequent frames","Ignores it","Retransmits only that frame","Restarts the connection"}	1	\N	1.00	2026-11-18 15:19:40.132431+05:30	f	[]	[]
472	1	Q-M4-60F877D09B	4	What is the maximum size of an IPv4 packet?	{"65,535 bytes","32,768 bytes","1,024 bytes","1,500 bytes"}	1	\N	1.00	2026-11-18 15:19:40.133011+05:30	f	[]	[]
473	1	Q-M4-74148250EA	4	What is the standard Ethernet MTU?	{"1500 bytes","576 bytes","9000 bytes","65535 bytes"}	1	\N	1.00	2026-11-18 15:19:40.133521+05:30	f	[]	[]
474	1	Q-M4-3F0916A53D	4	What is the purpose of IPv6 over IPv4?	{"Shorter addresses","Lower bandwidth use only","A much larger address space","Elimination of routers"}	3	\N	1.00	2026-11-18 15:19:40.133972+05:30	f	[]	[]
475	1	Q-M4-DDE384AB33	4	Which IPv6 address represents the loopback address?	{FE80::1,::1,::0,FF00::1}	2	\N	1.00	2026-11-18 15:19:40.134813+05:30	f	[]	[]
476	1	Q-M4-7C7EFF0706	4	What does DNS record type MX specify?	{"The mail exchange server for a domain","The name server","The canonical name","The IPv6 address of a host"}	1	\N	1.00	2026-11-18 15:19:40.13562+05:30	f	[]	[]
477	1	Q-M4-1B7B7ABCD3	4	Which DNS record type maps a hostname to an IPv4 address?	{A,CNAME,PTR,AAAA}	1	\N	1.00	2026-11-18 15:19:40.136288+05:30	f	[]	[]
478	1	Q-M4-7D39612ADF	4	Which DNS record type maps a hostname to an IPv6 address?	{TXT,AAAA,A,MX}	2	\N	1.00	2026-11-18 15:19:40.137005+05:30	f	[]	[]
479	1	Q-M4-F7997D62A0	4	What is a socket in network programming?	{"An endpoint defined by an IP address and port number","A power outlet","A kind of firewall rule","A cable type"}	1	\N	1.00	2026-11-18 15:19:40.137592+05:30	f	[]	[]
480	1	Q-M4-9C48D5B639	4	What characterises a peer-to-peer network?	{"Each node can act as both client and server","Nodes cannot share files","One central server controls everything","It requires a hub"}	1	\N	1.00	2026-11-18 15:19:40.138247+05:30	f	[]	[]
481	1	Q-M5-B2C5129191	5	What does SDLC stand for?	{"System Design Language Code","Software Deployment Logic Chain","Structured Data Link Control","Software Development Life Cycle"}	4	\N	1.00	2026-11-18 15:19:40.138976+05:30	f	[]	[]
482	1	Q-M5-AA572455CA	5	Which SDLC model follows a linear sequential flow of phases?	{"Prototype model","Agile model","Spiral model","Waterfall model"}	4	\N	1.00	2026-11-18 15:19:40.139625+05:30	f	[]	[]
483	1	Q-M5-9485B07253	5	Which SDLC model emphasises risk analysis in repeated cycles?	{"Spiral model","Big Bang model","Waterfall model",V-model}	1	\N	1.00	2026-11-18 15:19:40.140281+05:30	f	[]	[]
484	1	Q-M5-ED8C50A8DE	5	Which SDLC model pairs each development phase with a corresponding testing phase?	{"Waterfall model",V-model,"Incremental model","RAD model"}	2	\N	1.00	2026-11-18 15:19:40.140899+05:30	f	[]	[]
485	1	Q-M5-8D2F7D4FB2	5	Which model builds a working sample early so users can give feedback on requirements?	{"Waterfall model",V-model,"Big Bang model","Prototyping model"}	4	\N	1.00	2026-11-18 15:19:40.141455+05:30	f	[]	[]
486	1	Q-M5-07687455BD	5	A major disadvantage of the Waterfall model is:	{"Difficulty accommodating changing requirements","Lack of documentation","Excessive customer involvement","Too many iterations"}	1	\N	1.00	2026-11-18 15:19:40.142069+05:30	f	[]	[]
487	1	Q-M5-EB1CBD3C94	5	Which document describes what a software system should do, as agreed with stakeholders?	{"Source code listing","Test log","Release notes","Software Requirements Specification (SRS)"}	4	\N	1.00	2026-11-18 15:19:40.142702+05:30	f	[]	[]
488	1	Q-M5-9D9A7FAA4F	5	Requirements that describe system qualities such as performance, security and usability are called:	{"Functional requirements","Design patterns","Non-functional requirements","Domain rules only"}	3	\N	1.00	2026-11-18 15:19:40.143273+05:30	f	[]	[]
489	1	Q-M5-3CE316A5B9	5	Requirements that describe specific behaviours or functions of a system are called:	{"Quality attributes","Functional requirements","Non-functional requirements",Constraints}	2	\N	1.00	2026-11-18 15:19:40.143916+05:30	f	[]	[]
490	1	Q-M5-0896CE7A31	5	What is the Agile Manifesto's preference regarding working software and comprehensive documentation?	{"Working software is valued over comprehensive documentation","Both are discouraged","Documentation is valued over working software","Neither matters"}	1	\N	1.00	2026-11-18 15:19:40.144578+05:30	f	[]	[]
491	1	Q-M5-8D2AC7573E	5	In Scrum, who is responsible for maximising the value of the product and managing the product backlog?	{"Project sponsor","Product Owner","Scrum Master",Developer}	2	\N	1.00	2026-11-18 15:19:40.145191+05:30	f	[]	[]
492	1	Q-M5-521A5798F4	5	In Scrum, who helps the team follow Scrum practices and removes impediments?	{"Product Owner","Tester only",Client,"Scrum Master"}	4	\N	1.00	2026-11-18 15:19:40.145737+05:30	f	[]	[]
493	1	Q-M5-453C5E37C9	5	What is a sprint in Scrum?	{"A requirements document","A single bug fix","A fixed time-boxed iteration to deliver a potentially shippable increment","A deployment script"}	3	\N	1.00	2026-11-18 15:19:40.146299+05:30	f	[]	[]
494	1	Q-M5-717A338376	5	What is the usual maximum length of a Scrum sprint?	{"One day","One year","Six months","One month"}	4	\N	1.00	2026-11-18 15:19:40.147507+05:30	f	[]	[]
495	1	Q-M5-85CE575124	5	Which Scrum event is held daily to synchronise the team's work?	{"Backlog refinement","Sprint retrospective","Daily Scrum (stand-up)","Sprint review"}	3	\N	1.00	2026-11-18 15:19:40.148051+05:30	f	[]	[]
496	1	Q-M5-819A620235	5	Which Scrum event inspects how the last sprint went and plans improvements to the process?	{"Daily Scrum","Sprint retrospective","Sprint review","Sprint planning"}	2	\N	1.00	2026-11-18 15:19:40.148632+05:30	f	[]	[]
497	1	Q-M5-2FAC1516E1	5	What is a user story in Agile?	{"A test log","A short description of a feature from the user's perspective","A UML diagram","A database script"}	2	\N	1.00	2026-11-18 15:19:40.149202+05:30	f	[]	[]
498	1	Q-M5-1F0A880A2F	5	What does Kanban primarily use to visualise work?	{"An ER diagram","A board with columns showing workflow states","A UML class diagram","A Gantt chart only"}	2	\N	1.00	2026-11-18 15:19:40.149745+05:30	f	[]	[]
499	1	Q-M5-C197C4D2A2	5	Which Extreme Programming (XP) practice involves two developers working together at one workstation?	{"Pair programming","Hot patching","Code freeze","Waterfall review"}	1	\N	1.00	2026-11-18 15:19:40.150346+05:30	f	[]	[]
500	1	Q-M5-FE75784890	5	What does TDD stand for?	{"Test-Driven Development","Total Delivery Deadline","Test Data Design","Technical Debt Display"}	1	\N	1.00	2026-11-18 15:19:40.15099+05:30	f	[]	[]
501	1	Q-M5-8DE26F960C	5	In TDD, what is written first?	{"The user manual","The deployment script","A failing test","The production code"}	3	\N	1.00	2026-11-18 15:19:40.152911+05:30	f	[]	[]
502	1	Q-M5-EA478C171D	5	What does the term 'technical debt' describe?	{"Money owed to vendors","The future cost of choosing quick but suboptimal solutions","Server rental cost","Salaries of developers"}	2	\N	1.00	2026-11-18 15:19:40.153629+05:30	f	[]	[]
503	1	Q-M5-D12FC36278	5	What is refactoring?	{"Restructuring code without changing its external behaviour","Changing the programming language","Adding new features","Deleting tests"}	1	\N	1.00	2026-11-18 15:19:40.154389+05:30	f	[]	[]
504	1	Q-M5-734848F327	5	Which testing level focuses on individual functions or classes in isolation?	{"Acceptance testing","Integration testing","System testing","Unit testing"}	4	\N	1.00	2026-11-18 15:19:40.155226+05:30	f	[]	[]
505	1	Q-M5-918FFB23B8	5	Which testing level verifies interactions between combined modules?	{"Usability testing only","Smoke testing only","Unit testing","Integration testing"}	4	\N	1.00	2026-11-18 15:19:40.155957+05:30	f	[]	[]
506	1	Q-M5-D8972E8C44	5	Which testing level validates the complete integrated system against requirements?	{"Mutation testing","Component testing","Unit testing","System testing"}	4	\N	1.00	2026-11-18 15:19:40.156632+05:30	f	[]	[]
507	1	Q-M5-78FD962FB9	5	Which testing is performed by end users or clients to decide whether to accept the software?	{"Unit testing","Static analysis","User acceptance testing","Load testing"}	3	\N	1.00	2026-11-18 15:19:40.157216+05:30	f	[]	[]
508	1	Q-M5-CE71903CD4	5	What is regression testing?	{"Testing only new features","Re-testing to ensure recent changes did not break existing features","Testing the user manual","Testing hardware"}	2	\N	1.00	2026-11-18 15:19:40.157812+05:30	f	[]	[]
509	1	Q-M5-920ED140D1	5	In black-box testing, the tester:	{"Examines internal code paths","Writes the production code","Tests functionality without knowledge of internal code","Only reviews documentation"}	3	\N	1.00	2026-11-18 15:19:40.158417+05:30	f	[]	[]
510	1	Q-M5-4E0AA59B82	5	In white-box testing, the tester:	{"Only tests the UI","Only tests performance","Has no access to code","Has knowledge of the internal code structure"}	4	\N	1.00	2026-11-18 15:19:40.159001+05:30	f	[]	[]
511	1	Q-M5-4382E791E5	5	What does boundary value analysis focus on?	{"Test cases at the edges of input ranges","Random mid-range values","Database indexing","Only invalid data types"}	1	\N	1.00	2026-11-18 15:19:40.159568+05:30	f	[]	[]
512	1	Q-M5-18B5A0D904	5	What does equivalence partitioning do?	{"Partitions disks","Splits the code into modules","Divides the team into groups","Divides inputs into classes expected to behave similarly"}	4	\N	1.00	2026-11-18 15:19:40.16014+05:30	f	[]	[]
513	1	Q-M5-E58EC4DD45	5	What does code coverage measure?	{"The proportion of code executed by tests","The number of developers","Execution speed","Memory footprint"}	1	\N	1.00	2026-11-18 15:19:40.160734+05:30	f	[]	[]
514	1	Q-M5-43FC3B6455	5	What is the aim of load testing?	{"Checking only syntax","Checking system behaviour under expected user load","Testing a single function","Finding spelling errors"}	2	\N	1.00	2026-11-18 15:19:40.161315+05:30	f	[]	[]
515	1	Q-M5-2D77873965	5	What is stress testing?	{"Testing UI colours","Testing only under low load","Testing beyond normal operational capacity to find breaking points","Reviewing code style"}	3	\N	1.00	2026-11-18 15:19:40.161873+05:30	f	[]	[]
516	1	Q-M5-FEBE86ECD6	5	What is a smoke test?	{"A complete exhaustive test","A security penetration test","A quick check that the most critical functions work","A hardware heat test"}	3	\N	1.00	2026-11-18 15:19:40.162459+05:30	f	[]	[]
517	1	Q-M5-585A4FB128	5	In software testing, a 'bug' that causes the program to produce wrong output is a:	{Milestone,Defect,Requirement,Feature}	2	\N	1.00	2026-11-18 15:19:40.163018+05:30	f	[]	[]
518	1	Q-M5-ADA2CEADB4	5	Cyclomatic complexity measures:	{"The number of independent paths through code","The length of variable names","The number of files","The count of comments"}	1	\N	1.00	2026-11-18 15:19:40.163681+05:30	f	[]	[]
519	1	Q-M5-37510DA832	5	Low coupling and high cohesion between modules are considered:	{"Good design characteristics",Irrelevant,"Only suitable for small programs","Poor design characteristics"}	1	\N	1.00	2026-11-18 15:19:40.164307+05:30	f	[]	[]
520	1	Q-M5-86B0CF277E	5	Which UML diagram shows the static structure of classes and their relationships?	{"State diagram","Sequence diagram","Activity diagram","Class diagram"}	4	\N	1.00	2026-11-18 15:19:40.165209+05:30	f	[]	[]
521	1	Q-M5-7B69980808	5	Which UML diagram shows interactions between objects ordered by time?	{"Sequence diagram","Component diagram","Deployment diagram","Class diagram"}	1	\N	1.00	2026-11-18 15:19:40.166201+05:30	f	[]	[]
522	1	Q-M5-1CC6808519	5	Which UML diagram captures how actors interact with the system's functionality?	{"Class diagram","Package diagram","Object diagram","Use case diagram"}	4	\N	1.00	2026-11-18 15:19:40.168112+05:30	f	[]	[]
523	1	Q-M5-1F8C4CD821	5	Which UML diagram models the flow of activities or workflows?	{"Class diagram","ER diagram","Activity diagram","Component diagram"}	3	\N	1.00	2026-11-18 15:19:40.168716+05:30	f	[]	[]
524	1	Q-M5-2C4280F575	5	Which design pattern ensures that a class has only one instance?	{Decorator,Observer,Factory,Singleton}	4	\N	1.00	2026-11-18 15:19:40.169291+05:30	f	[]	[]
525	1	Q-M5-0E1AEDB284	5	Which design pattern defines a one-to-many dependency so that dependents are notified of state changes?	{Singleton,Adapter,Observer,Builder}	3	\N	1.00	2026-11-18 15:19:40.169943+05:30	f	[]	[]
526	1	Q-M5-A1EF78CF74	5	Which design pattern provides an interface for creating objects while letting subclasses choose the class to instantiate?	{Facade,"Factory Method",Singleton,Proxy}	2	\N	1.00	2026-11-18 15:19:40.170473+05:30	f	[]	[]
527	1	Q-M5-E279782F0A	5	Which design pattern lets incompatible interfaces work together?	{Prototype,Adapter,Observer,Strategy}	2	\N	1.00	2026-11-18 15:19:40.171114+05:30	f	[]	[]
528	1	Q-M5-5171BD0F26	5	Which design pattern adds responsibilities to an object dynamically without changing its class?	{Singleton,Decorator,Flyweight,Iterator}	2	\N	1.00	2026-11-18 15:19:40.171629+05:30	f	[]	[]
529	1	Q-M5-3AF458DD47	5	In the SOLID principles, what does the 'S' stand for?	{"Static Scope Principle","Simple Syntax Principle","Single Responsibility Principle","Secure Storage Principle"}	3	\N	1.00	2026-11-18 15:19:40.172205+05:30	f	[]	[]
530	1	Q-M5-808615B5A7	5	In the SOLID principles, what does the 'O' stand for?	{"Object Oriented Principle","Overloading Only Principle","Optimal Output Principle","Open/Closed Principle"}	4	\N	1.00	2026-11-18 15:19:40.173104+05:30	f	[]	[]
531	1	Q-M5-F63CCBE0FA	5	What does the MVC architecture pattern stand for?	{Module-Variable-Class,Main-View-Console,Model-View-Controller,Memory-Virtual-Cache}	3	\N	1.00	2026-11-18 15:19:40.174001+05:30	f	[]	[]
532	1	Q-M5-4C776952B5	5	In MVC, which component handles user input and updates the model?	{Controller,"Router table",View,Model}	1	\N	1.00	2026-11-18 15:19:40.174829+05:30	f	[]	[]
533	1	Q-M5-CE6E82B86D	5	Which version control system is distributed and created by Linus Torvalds?	{Perforce,CVS,Git,SVN}	3	\N	1.00	2026-11-18 15:19:40.175558+05:30	f	[]	[]
534	1	Q-M5-2E7BA613E8	5	Which Git command creates a local copy of a remote repository?	{"git clone","git fetch","git commit","git init"}	1	\N	1.00	2026-11-18 15:19:40.17643+05:30	f	[]	[]
535	1	Q-M5-18A08FB2CB	5	Which Git command records staged changes to the repository history?	{"git push","git add","git pull","git commit"}	4	\N	1.00	2026-11-18 15:19:40.177209+05:30	f	[]	[]
536	1	Q-M5-473AAF371E	5	Which Git command stages changes for the next commit?	{"git stash","git merge","git add","git commit"}	3	\N	1.00	2026-11-18 15:19:40.177768+05:30	f	[]	[]
537	1	Q-M5-9784D0EF62	5	Which Git command uploads local commits to a remote repository?	{"git pull","git clone","git push","git status"}	3	\N	1.00	2026-11-18 15:19:40.178305+05:30	f	[]	[]
538	1	Q-M5-48326C7794	5	Which Git command shows the state of the working directory and staging area?	{"git remote","git diff only","git status","git log"}	3	\N	1.00	2026-11-18 15:19:40.178785+05:30	f	[]	[]
539	1	Q-M5-5BC01C9032	5	Which Git command combines changes from one branch into the current branch?	{"git branch","git tag","git merge","git reset"}	3	\N	1.00	2026-11-18 15:19:40.179608+05:30	f	[]	[]
540	1	Q-M5-A255B8F6BA	5	What does CI/CD stand for in DevOps?	{"Continuous Integration / Continuous Delivery","Compile Instantly / Compile Daily","Central Integration / Central Distribution","Code Inspection / Code Deployment"}	1	\N	1.00	2026-11-18 15:19:40.180337+05:30	f	[]	[]
541	1	Q-M5-AC4F49E2BB	5	What is the primary goal of continuous integration?	{"Eliminating version control","Avoiding all testing","Frequently merging code and automatically building and testing it","Releasing once a year"}	3	\N	1.00	2026-11-18 15:19:40.18108+05:30	f	[]	[]
542	1	Q-M5-550E425BE7	5	Which tool is a widely used platform for containerising applications?	{Excel,Wireshark,Docker,Photoshop}	3	\N	1.00	2026-11-18 15:19:40.181786+05:30	f	[]	[]
543	1	Q-M5-F25C785D76	5	Which tool is commonly used for orchestrating containers at scale?	{Figma,Notepad,Postman,Kubernetes}	4	\N	1.00	2026-11-18 15:19:40.183327+05:30	f	[]	[]
544	1	Q-M5-D82DAA8A8F	5	Which cloud service model provides virtualised computing infrastructure such as virtual machines?	{IaaS,PaaS,SaaS,DaaS}	1	\N	1.00	2026-11-18 15:19:40.183974+05:30	f	[]	[]
545	1	Q-M5-20176DFCF7	5	Which cloud service model provides a platform for developing and deploying applications without managing infrastructure?	{IaaS,PaaS,"BaaS only for storage",SaaS}	2	\N	1.00	2026-11-18 15:19:40.184506+05:30	f	[]	[]
546	1	Q-M5-D8BAC4F44E	5	Which cloud service model delivers complete software applications over the internet?	{SaaS,HaaS,PaaS,IaaS}	1	\N	1.00	2026-11-18 15:19:40.185089+05:30	f	[]	[]
547	1	Q-M5-5E3091464D	5	Which software cost estimation model predicts effort based on project size, commonly measured in KLOC?	{"COCOMO model","CRC card","ER model","PERT diagram"}	1	\N	1.00	2026-11-18 15:19:40.186305+05:30	f	[]	[]
548	1	Q-M5-25077719F3	5	In cybersecurity, what does the CIA triad stand for?	{"Confidentiality, Identity, Authentication","Cryptography, Identity, Access","Control, Inspection, Authorization","Confidentiality, Integrity, Availability"}	4	\N	1.00	2026-11-18 15:19:40.18697+05:30	f	[]	[]
549	1	Q-M5-872B78EA20	5	In the CIA triad, confidentiality ensures that:	{"Information is deleted after use","Information is always available","Information is accessible only to authorised parties","Information is never changed"}	3	\N	1.00	2026-11-18 15:19:40.187563+05:30	f	[]	[]
550	1	Q-M5-7FD080EB26	5	In the CIA triad, integrity ensures that:	{"Data is always online","Data is accurate and not tampered with","Data is always encrypted","Data is backed up daily"}	2	\N	1.00	2026-11-18 15:19:40.188115+05:30	f	[]	[]
551	1	Q-M5-CF11297D70	5	In the CIA triad, availability ensures that:	{"Data is hashed","Data is compressed","Systems and data are accessible when needed","Data is hidden"}	3	\N	1.00	2026-11-18 15:19:40.18868+05:30	f	[]	[]
552	1	Q-M5-B6223059AF	5	What is the difference between authentication and authorization?	{"They are identical","Authentication is encryption; authorization is hashing","Authentication grants permissions; authorization verifies identity","Authentication verifies identity; authorization grants permissions"}	4	\N	1.00	2026-11-18 15:19:40.189248+05:30	f	[]	[]
553	1	Q-M5-851887A52D	5	What is multi-factor authentication (MFA)?	{"Using two or more different verification factors","Using two passwords of the same type","Logging in twice","Using a longer password"}	1	\N	1.00	2026-11-18 15:19:40.189776+05:30	f	[]	[]
554	1	Q-M5-76154E4340	5	Which of the following is an example of 'something you are' in authentication?	{Fingerprint,"Smart card",Password,PIN}	1	\N	1.00	2026-11-18 15:19:40.190385+05:30	f	[]	[]
555	1	Q-M5-7B3E3BB99D	5	Which of the following is an example of 'something you have' in authentication?	{"Hardware token",Password,"Mother's maiden name",Fingerprint}	1	\N	1.00	2026-11-18 15:19:40.190977+05:30	f	[]	[]
556	1	Q-M5-77FDB5C40C	5	What is symmetric encryption?	{"Hashing of data","Encryption using a public and a private key","Encryption without a key","Encryption using the same key to encrypt and decrypt"}	4	\N	1.00	2026-11-18 15:19:40.19162+05:30	f	[]	[]
557	1	Q-M5-C007369AF9	5	Which of the following is a symmetric encryption algorithm?	{ECC,AES,Diffie-Hellman,RSA}	2	\N	1.00	2026-11-18 15:19:40.192224+05:30	f	[]	[]
558	1	Q-M5-C046A6F4A3	5	Which of the following is an asymmetric encryption algorithm?	{RSA,Blowfish,AES,DES}	1	\N	1.00	2026-11-18 15:19:40.192818+05:30	f	[]	[]
559	1	Q-M5-EABAC848D9	5	What is the key size of the DES algorithm?	{"256 bits","512 bits","128 bits","56 bits (effective)"}	4	\N	1.00	2026-11-18 15:19:40.193631+05:30	f	[]	[]
560	1	Q-M5-43B6042D47	5	What block size does AES use?	{"56 bits","64 bits","256 bits","128 bits"}	4	\N	1.00	2026-11-18 15:19:40.194212+05:30	f	[]	[]
561	1	Q-M5-D983F17CC2	5	Which key is used to verify a digital signature?	{"The verifier's private key","The signer's public key","A session key","The signer's private key"}	2	\N	1.00	2026-11-18 15:19:40.195362+05:30	f	[]	[]
562	1	Q-M5-3AA5B7B33E	5	Which key is used by a sender to digitally sign a message?	{"Sender's public key","Sender's private key","Receiver's private key","Receiver's public key"}	2	\N	1.00	2026-11-18 15:19:40.196043+05:30	f	[]	[]
563	1	Q-M5-CD1028977B	5	What is a cryptographic hash function?	{"A one-way function that maps data to a fixed-size digest","A key exchange protocol","A compression algorithm","A reversible encryption method"}	1	\N	1.00	2026-11-18 15:19:40.196598+05:30	f	[]	[]
564	1	Q-M5-2D27A26468	5	Which of these hash algorithms is considered broken for security purposes?	{BLAKE2,MD5,SHA-3,SHA-256}	2	\N	1.00	2026-11-18 15:19:40.197331+05:30	f	[]	[]
565	1	Q-M5-D82ADE3E4E	5	What is the output size of SHA-256?	{"128 bits","256 bits","160 bits","512 bits"}	2	\N	1.00	2026-11-18 15:19:40.199034+05:30	f	[]	[]
566	1	Q-M5-89574F14C6	5	What is salting in password storage?	{"Adding random data to a password before hashing","Sending the password by email","Encrypting the password with AES","Storing passwords in plain text"}	1	\N	1.00	2026-11-18 15:19:40.199641+05:30	f	[]	[]
567	1	Q-M5-A6164D1773	5	What is a digital certificate?	{"An electronic document binding a public key to an identity, issued by a CA","A paper diploma","A firewall rule","An encrypted password list"}	1	\N	1.00	2026-11-18 15:19:40.200244+05:30	f	[]	[]
568	1	Q-M5-AE844F35E9	5	What does PKI stand for?	{"Protected Kernel Instruction","Public Key Infrastructure","Packet Key Inspection","Private Key Interface"}	2	\N	1.00	2026-11-18 15:19:40.200945+05:30	f	[]	[]
569	1	Q-M5-F638DFE716	5	What is the main purpose of Diffie-Hellman?	{"Compressing files","Detecting malware","Securely establishing a shared secret over an insecure channel","Hashing passwords"}	3	\N	1.00	2026-11-18 15:19:40.201567+05:30	f	[]	[]
570	1	Q-M5-A0379D7FA6	5	Which protocol provides encryption for HTTPS connections?	{SNMP,ARP,ICMP,TLS}	4	\N	1.00	2026-11-18 15:19:40.20219+05:30	f	[]	[]
571	1	Q-M5-6517A29A1E	5	What is phishing?	{"Deceiving users into revealing sensitive information via fake messages","Encrypting files for ransom","Scanning ports","Overloading a server"}	1	\N	1.00	2026-11-18 15:19:40.204283+05:30	f	[]	[]
572	1	Q-M5-715BF1C6E1	5	What is ransomware?	{"A firewall type","A backup program","Malware that encrypts files and demands payment","Software that speeds up the PC"}	3	\N	1.00	2026-11-18 15:19:40.204936+05:30	f	[]	[]
573	1	Q-M5-311AC3839B	5	What is a computer virus?	{"A network cable defect","A type of antivirus","A hardware fault","Malicious code that attaches to programs and spreads when they run"}	4	\N	1.00	2026-11-18 15:19:40.205551+05:30	f	[]	[]
574	1	Q-M5-E82CB0DBA6	5	What distinguishes a worm from a virus?	{"A worm spreads by itself over networks without needing a host file","A worm only deletes files","A worm needs user action always","A worm is a hardware device"}	1	\N	1.00	2026-11-18 15:19:40.206352+05:30	f	[]	[]
575	1	Q-M5-E4F458CDA3	5	What is a Trojan horse in malware terms?	{"A firewall rule","An encryption key","A self-replicating network worm","Malware disguised as legitimate software"}	4	\N	1.00	2026-11-18 15:19:40.206954+05:30	f	[]	[]
576	1	Q-M5-96DCA8DE48	5	What is spyware?	{"A network sniffer for admins only","An antivirus tool","Software that secretly gathers user information","A compiler"}	3	\N	1.00	2026-11-18 15:19:40.207517+05:30	f	[]	[]
577	1	Q-M5-5FF31D709B	5	What is a keylogger?	{"A program that records keystrokes","A key-exchange protocol","A password manager","A hardware lock"}	1	\N	1.00	2026-11-18 15:19:40.2081+05:30	f	[]	[]
578	1	Q-M5-78178D2E73	5	What is a DDoS attack?	{"Injecting SQL","Intercepting emails","Overwhelming a target with traffic from many sources","Stealing a password through guessing"}	3	\N	1.00	2026-11-18 15:19:40.208775+05:30	f	[]	[]
579	1	Q-M5-C415761A93	5	What is a man-in-the-middle (MITM) attack?	{"Physically stealing a laptop","Guessing passwords by trial","Flooding a server","An attacker secretly intercepts and possibly alters communication between two parties"}	4	\N	1.00	2026-11-18 15:19:40.209325+05:30	f	[]	[]
580	1	Q-M5-4577BE8D81	5	What is SQL injection?	{"Backing up databases","Installing a SQL server","Encrypting SQL queries","Inserting malicious SQL through input fields to manipulate a database"}	4	\N	1.00	2026-11-18 15:19:40.209868+05:30	f	[]	[]
581	1	Q-M5-D61EC0CD8F	5	Which technique best prevents SQL injection?	{"Disabling indexes","Parameterised queries (prepared statements)","Longer passwords","Using HTTP instead of HTTPS"}	2	\N	1.00	2026-11-18 15:19:40.210426+05:30	f	[]	[]
582	1	Q-M5-5A58AA4092	5	What is cross-site scripting (XSS)?	{"Stealing physical devices","Injecting malicious scripts into web pages viewed by other users","Flooding DNS servers","Cracking Wi-Fi passwords"}	2	\N	1.00	2026-11-18 15:19:40.210962+05:30	f	[]	[]
583	1	Q-M5-BEA1AD6F71	5	What is cross-site request forgery (CSRF)?	{"Brute-forcing a password","Spoofing an IP","Tricking an authenticated user's browser into performing unwanted actions","Injecting SQL"}	3	\N	1.00	2026-11-18 15:19:40.21149+05:30	f	[]	[]
584	1	Q-M5-FE5F3F7B0B	5	What is a buffer overflow vulnerability?	{"Too many open tabs","Writing more data to a buffer than it can hold, corrupting adjacent memory","Running out of disk space","A network congestion event"}	2	\N	1.00	2026-11-18 15:19:40.212089+05:30	f	[]	[]
585	1	Q-M5-60E6002220	5	What is a brute-force attack?	{"Exploiting a zero-day","Social engineering by phone","Sniffing packets","Trying all possible passwords or keys until one works"}	4	\N	1.00	2026-11-18 15:19:40.212682+05:30	f	[]	[]
586	1	Q-M5-C61DE37A39	5	What is a zero-day vulnerability?	{"A vulnerability in an old OS only","A type of firewall","A flaw unknown to the vendor with no patch available","A bug fixed on release day"}	3	\N	1.00	2026-11-18 15:19:40.213223+05:30	f	[]	[]
587	1	Q-M5-04DC91F0AE	5	What is social engineering?	{"Designing public websites","Writing code collaboratively","Manipulating people into divulging confidential information","Building social networks"}	3	\N	1.00	2026-11-18 15:19:40.213965+05:30	f	[]	[]
588	1	Q-M5-67BCED9074	5	What is the principle of least privilege?	{"Passwords must be short","Users get only the minimum access needed for their tasks","Users get all access by default","Only administrators log in"}	2	\N	1.00	2026-11-18 15:19:40.214685+05:30	f	[]	[]
589	1	Q-M5-671FF1A5B1	5	What is an intrusion detection system (IDS)?	{"A backup device","A system that monitors traffic for suspicious activity and alerts","A device that encrypts traffic","A load balancer"}	2	\N	1.00	2026-11-18 15:19:40.215245+05:30	f	[]	[]
590	1	Q-M5-7DAD50D709	5	What distinguishes an IPS from an IDS?	{"An IPS is used only for Wi-Fi","An IPS is a type of printer","An IPS only logs","An IPS can actively block detected threats"}	4	\N	1.00	2026-11-18 15:19:40.215759+05:30	f	[]	[]
591	1	Q-M5-49572B4E73	5	What is penetration testing?	{"Authorised simulated attacks to find vulnerabilities","Auditing hardware inventory","Testing only code syntax","Measuring Wi-Fi speed"}	1	\N	1.00	2026-11-18 15:19:40.21628+05:30	f	[]	[]
592	1	Q-M5-9661344203	5	Which Wi-Fi security standard is considered the most secure among the following?	{WEP,WPA3,"Open network",WPA}	2	\N	1.00	2026-11-18 15:19:40.216877+05:30	f	[]	[]
593	1	Q-M5-3B940EFFF4	5	Which Wi-Fi security protocol is known to be fundamentally weak and easily cracked?	{WPA3,WPA2,802.1X,WEP}	4	\N	1.00	2026-11-18 15:19:40.217385+05:30	f	[]	[]
594	1	Q-M5-241D29F120	5	What is steganography?	{"Compressing images","Hiding data inside another file or medium","Encrypting data with AES","Hashing passwords"}	2	\N	1.00	2026-11-18 15:19:40.217872+05:30	f	[]	[]
595	1	Q-M5-EFFA8D9324	5	What is non-repudiation in security?	{"Preventing a party from denying an action they performed","Encrypting backups","Blocking packets","Hiding identities"}	1	\N	1.00	2026-11-18 15:19:40.218485+05:30	f	[]	[]
596	1	Q-M5-27B5472466	5	What does GDPR primarily regulate?	{"Software licensing","Network speed standards","Protection of personal data and privacy in the EU","Hardware recycling"}	3	\N	1.00	2026-11-18 15:19:40.218977+05:30	f	[]	[]
597	1	Q-M5-545430E3C8	5	What is the purpose of a backup strategy such as the 3-2-1 rule?	{"Writing 3 tests for 2 modules and 1 class","Keeping 3 copies on 2 media types with 1 offsite","Running 3 firewalls and 2 IDS with 1 router","Using 3 passwords for 2 systems with 1 token"}	2	\N	1.00	2026-11-18 15:19:40.221223+05:30	f	[]	[]
598	1	Q-M5-BC8D2B7F36	5	What is a honeypot?	{"A decoy system designed to attract and study attackers","A virus scanner","A load balancer","A password vault"}	1	\N	1.00	2026-11-18 15:19:40.221797+05:30	f	[]	[]
599	1	Q-M5-E4F4837FF6	5	What does OWASP Top 10 list?	{"Ten network protocols","The most critical web application security risks","The ten fastest programming languages","The ten best antivirus tools"}	2	\N	1.00	2026-11-18 15:19:40.223033+05:30	f	[]	[]
600	1	Q-M5-C05364B439	5	Which Agile artefact is an ordered list of everything that might be needed in the product?	{"Burn-down chart","Sprint review report","Product backlog","Release tag"}	3	\N	1.00	2026-11-18 15:19:40.224154+05:30	f	[]	[]
\.


--
-- Data for Name: relogin_authorization; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.relogin_authorization (id, session_id, student_usn, assigned_workstation_id, target_workstation_id, token_id, token_hash, reason, status, authorized_by, authorized_at, expires_at, is_one_time_used, created_at) FROM stdin;
\.


--
-- Data for Name: secure_package; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.secure_package (id, session_id, package_uid, encrypted_payload, encrypted_key_hex, iv_hex, signature_hex, digest_hex, status, exported_at, exported_by, created_at) FROM stdin;
\.


--
-- Data for Name: security_violation_log; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.security_violation_log (id, session_id, student_usn, workstation_id, violation_type, label, description, current_question_index, remaining_seconds, answered_count, logged_at) FROM stdin;
\.


--
-- Data for Name: session_roster_snapshot; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.session_roster_snapshot (session_id, student_id, usn, full_name, date_of_birth) FROM stdin;
\.


--
-- Data for Name: session_token; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.session_token (token_hash, account_id, expires) FROM stdin;
313475d352cf148e2ebb70b4cbbdf3a34bd57b54c22fac00776325f9d3cb4985	18	2026-11-19 22:20:08.902975+05:30
fa1b6c906144bc8291790d03e370a29ed95860b99c49ce561f5c3fa77420fde1	16	2026-11-19 22:21:13.962999+05:30
d8363ba54af141aeb525d0fd000c97ebd5765ec22ea354d7cf553a243df7b343	5	2026-11-20 00:00:02.904066+05:30
259350c61952cbcaf246ca4ab6dd349123b99fe84169d3ed4828a61dbeac50a3	2	2026-11-10 11:49:10.472921+05:30
a65695f057581691f96817c1cfa7321311c1a85b3342ba75b4c4e2771f79bf24	2	2026-11-10 11:50:57.781291+05:30
4f695e8910baee37e488a87d396bb57d2885a0271678c20053b355dfed76035c	2	2026-11-10 11:51:02.275229+05:30
4dbe502c0800e724f3b82684fb197606e347e58d79fae6fb72e8e94e742d3119	2	2026-11-10 11:51:07.541046+05:30
a4cda87eb213186d81a5deca8160269b3e9df322a12a4ae832526db078a20e55	1	2026-11-20 00:35:01.583592+05:30
25130c4e852547c31663f181bff36e9c6c8d8f7f85977fcc4485333b02dfcbc0	2	2026-11-10 11:52:10.806496+05:30
d101509f6ce387540cdee90f7ef5f898dbf3fc5ea6b798191719ecc3da50f087	2	2026-11-10 11:52:56.768322+05:30
be650ca5f80ee2b548e4e4b7c9ee5f3f8d54e46724f3cb596487e160be737e02	2	2026-11-10 11:55:17.270369+05:30
7c854d388362878cb47fc16d4758e24c6007e661f47adbba8d458431e4fb87d4	2	2026-11-18 03:28:15.593575+05:30
820566b077088e6a262087172cb41e9a4425dbb4992f0e75f5cddebb0158f60f	2	2026-11-18 03:31:25.040228+05:30
01015318ce4d4967e3cc94394f95227efcdc5fd8cf9ea5bd7b34e1e19122da1d	2	2026-11-18 03:44:35.996334+05:30
83dab30978a7645271f88dc1d18b16faf3d447de33c7bea72a0592fe9fecc9ee	2	2026-11-18 03:53:12.414604+05:30
c9f962ae75198432000ccb8c952cff228d8080bc66ed3e9a641698a8b2667884	6	2026-11-18 04:04:31.808162+05:30
53ac895d9c2aa3187a660187cd0de0390d55919e6fa952a937f22033434e36e2	6	2026-11-18 04:06:32.983584+05:30
d694a2482b9c4f618919c86dcdeb0b3288d4fc210c736990b6ab56d29e9902c5	6	2026-11-18 04:07:05.371341+05:30
3e749bd56e671d918823e0048200cb8214530595f3b097783bff3723d9b9914a	6	2026-11-18 04:10:15.4255+05:30
4561404b8508303e56ebc7e3185db499851df80dcf3fc44718d22533d7a34c89	2	2026-11-18 05:35:48.852645+05:30
6fd9a681528089ae1a89c64658e8b893e5797808c853ba87ccf47ad334373d4c	6	2026-11-18 05:44:03.718032+05:30
48e6fc25140fe2c6bc944ea46db29852946b4ddd5907302b360a101e77945865	6	2026-11-18 05:44:47.933448+05:30
a78b125fc085d0c737157df20e6c21c77f7544e5279c9e46719a362d88873258	6	2026-11-18 05:47:03.824462+05:30
dfbfab72fa4a8f2f2c8bca90ba2ce7765015c7169e17b460e7137e4d587b34c3	6	2026-11-18 18:08:46.217701+05:30
126309259fa5b998883ebad697171c8cbab95f678eeb79c8a5a145bf65793bca	6	2026-11-18 18:29:31.090104+05:30
552212767047e9639d5ec928c07d1464583a7312fd6a0581a6f99f67334270ac	8	2026-11-18 18:46:44.682009+05:30
5e4b89ba7c31f7bdc9670f4f720029ffed1d474007dcb696e8955d037ce6b568	8	2026-11-18 18:53:38.772619+05:30
3289ed7084b833105491665969c42e86dbc82c64ab4b47e9672b7ef5e35336d9	8	2026-11-18 18:54:05.015998+05:30
ff0e334cac72834848f35145caa957c5d065f1126a8e0f058e5e86fbfca3a484	6	2026-11-18 18:54:05.39296+05:30
01deaf39d469a07b3fd9fb50102c80b54f156313775ebfe90a7d3a6d47a7980e	9	2026-11-18 19:12:30.199383+05:30
f8a4db162ea9b6a59a1b33f0a8c6fc84504bcabd65ed8243328db06a3a8e2f6a	10	2026-11-18 19:52:46.659988+05:30
5f712bab091369d3b0058f3a9c8862cf7b3919a6f6a86cfa21d84424cf949608	5	2026-11-19 21:49:32.019197+05:30
871688a33a2c6a4d62724caec2f1c53b53f9f093c3c4b72613846b0edcbd8f87	5	2026-11-19 21:56:46.559487+05:30
a4804118a935f4682265836bd6e30685244f3ef8a0de8eb8b0a5360a6a6914ee	1	2026-11-19 21:59:25.313188+05:30
\.


--
-- Data for Name: session_transfer_history; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.session_transfer_history (id, session_id, student_usn, from_workstation, to_workstation, authorization_id, reason, transferred_by, transferred_at) FROM stdin;
\.


--
-- Data for Name: session_unlock_credential; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.session_unlock_credential (id, session_id, sitting_name, masked_preview, verifier_hash, salt, iterations, revision, status, generated_by, generated_at, expires_at, last_synced_at) FROM stdin;
\.


--
-- Data for Name: student_roster; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.student_roster (id, usn, full_name, date_of_birth, group_id, department_id, semester, section, created_at) FROM stdin;
3	4MH25CS001	Candidate 4MH25CS001	2005-06-15	1	1	4	A	2026-11-17 23:28:15.560417+05:30
4	4MH25CS129	Candidate 4MH25CS129	2006-07-24	1	1	4	A	2026-11-18 00:04:31.589872+05:30
5	4MH25CS097	Candidate 4MH25CS097	2005-06-15	1	1	4	A	2026-11-18 14:46:44.357285+05:30
6	4MH25CS096	Candidate 4MH25CS096	2005-06-15	1	1	4	A	2026-11-18 15:12:29.958541+05:30
7	4MH25CS121	Candidate 4MH25CS121	2005-06-22	1	1	4	A	2026-11-18 15:52:46.41344+05:30
9	4MH24CS002	Aditi Rao	2005-06-27	5	1	5	A	2026-11-19 09:55:13.613261+05:30
10	4MH24CS003	Akash Gowda	2005-05-13	5	1	5	A	2026-11-19 09:55:13.613779+05:30
11	4MH24CS004	Amrutha Hegde	2006-05-15	5	1	5	A	2026-11-19 09:55:13.614231+05:30
12	4MH24CS005	Ananya Shetty	2005-09-18	5	1	5	A	2026-11-19 09:55:13.614772+05:30
13	4MH24CS006	Anirudh Bhat	2005-09-03	5	1	5	A	2026-11-19 09:55:13.615573+05:30
14	4MH24CS007	Apoorva Nayak	2005-08-23	5	1	5	A	2026-11-19 09:55:13.616071+05:30
15	4MH24CS008	Arjun Deshpande	2005-07-11	5	1	5	A	2026-11-19 09:55:13.616553+05:30
16	4MH24CS009	Bhavana Kamath	2006-05-13	5	1	5	A	2026-11-19 09:55:13.616832+05:30
17	4MH24CS010	Chetan Kumar M	2005-06-22	5	1	5	A	2026-11-19 09:55:13.617078+05:30
18	4MH24CS011	Darshan Patil	2006-04-12	5	1	5	A	2026-11-19 09:55:13.617299+05:30
19	4MH24CS012	Deepika Joshi	2006-05-15	5	1	5	A	2026-11-19 09:55:13.61749+05:30
20	4MH24CS013	Dhanush Urs	2006-07-31	5	1	5	A	2026-11-19 09:55:13.617685+05:30
21	4MH24CS014	Divya Murthy	2006-02-04	5	1	5	A	2026-11-19 09:55:13.617984+05:30
22	4MH24CS015	Gagan Prasad	2005-06-14	5	1	5	A	2026-11-19 09:55:13.618504+05:30
23	4MH24CS016	Harshitha N	2006-02-27	5	1	5	A	2026-11-19 09:55:13.618856+05:30
24	4MH24CS017	Karthik Acharya	2005-12-03	5	1	5	A	2026-11-19 09:55:13.619075+05:30
25	4MH24CS018	Kavya Hegde	2005-05-17	5	1	5	A	2026-11-19 09:55:13.619258+05:30
26	4MH24CS019	Keerthana S	2005-05-16	5	1	5	A	2026-11-19 09:55:13.619422+05:30
27	4MH24CS020	Manoj Gowda	2005-06-17	5	1	5	A	2026-11-19 09:55:13.619585+05:30
28	4MH24CS021	Meghana Pai	2005-08-20	5	1	5	A	2026-11-19 09:55:13.619752+05:30
29	4MH24CS022	Nikhil Sharma	2005-08-28	5	1	5	A	2026-11-19 09:55:13.619898+05:30
30	4MH24CS023	Nithya Shree R	2006-01-14	5	1	5	A	2026-11-19 09:55:13.620043+05:30
31	4MH24CS024	Pranav Shenoy	2006-03-05	5	1	5	A	2026-11-19 09:55:13.620242+05:30
32	4MH24CS025	Priyanka Kulkarni	2005-05-14	5	1	5	A	2026-11-19 09:55:13.620421+05:30
33	4MH24CS026	Rakshith V	2006-02-12	5	1	5	A	2026-11-19 09:55:13.620596+05:30
34	4MH24CS027	Rohan Menon	2005-08-10	5	1	5	A	2026-11-19 09:55:13.620823+05:30
35	4MH24CS028	Sahana Bharadwaj	2006-05-02	5	1	5	A	2026-11-19 09:55:13.62137+05:30
36	4MH24CS029	Shreyas Alva	2006-03-29	5	1	5	A	2026-11-19 09:55:13.621689+05:30
37	4MH24CS030	Sneha Raj	2006-04-25	5	1	5	A	2026-11-19 09:55:13.621908+05:30
8	4MH24CS101	Aarav Kulkarni	2006-03-24	5	1	5	A	2026-11-19 09:55:13.610385+05:30
\.


--
-- Data for Name: student_session_result; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.student_session_result (id, import_id, session_id, usn, full_name, assigned_version, total_questions, correct_count, incorrect_count, unanswered_count, score, passed, submission_status) FROM stdin;
\.


--
-- Data for Name: subject; Type: TABLE DATA; Schema: public; Owner: campusexam
--

COPY public.subject (id, name, code, department_id, semester, applicable_sections) FROM stdin;
3	ai	69	1	5	{"Section A","Section B"}
1	Database Management Systems	CS401	1	4	{"Section A","Section B"}
2	Object Oriented Programming with Java	CS501	1	5	{"Section A","Section B"}
4	Web Technology	CS502	1	5	{"Section A","Section B"}
5	sexy asubject	6969	1	5	{"Section SEXY"}
6	DSA	MH25CS0303	1	5	{"Section A","Section B"}
13	WEB	MH23456	1	3	{"Section A","Section B"}
14	DSA	MH25DSA	1	3	{"Section A","Section B"}
15	DSA	MH25DSA	1	5	{"Section A","Section B"}
\.


--
-- Name: academic_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.academic_group_id_seq', 142, true);


--
-- Name: account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.account_id_seq', 23, true);


--
-- Name: answer_key_correction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.answer_key_correction_id_seq', 1, false);


--
-- Name: attempt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.attempt_id_seq', 2, true);


--
-- Name: audit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.audit_id_seq', 132, true);


--
-- Name: bank_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.bank_id_seq', 2, true);


--
-- Name: computer_assignment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.computer_assignment_id_seq', 1, false);


--
-- Name: course_outcome_review_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.course_outcome_review_id_seq', 1, false);


--
-- Name: course_outcome_revision_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.course_outcome_revision_id_seq', 1, false);


--
-- Name: course_outcome_statement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.course_outcome_statement_id_seq', 1, false);


--
-- Name: course_outcome_submission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.course_outcome_submission_id_seq', 1, false);


--
-- Name: department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.department_id_seq', 71, true);


--
-- Name: exam_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.exam_id_seq', 1, true);


--
-- Name: examination_cycle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.examination_cycle_id_seq', 1, false);


--
-- Name: examination_session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.examination_session_id_seq', 1, false);


--
-- Name: generated_paper_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.generated_paper_id_seq', 24, true);


--
-- Name: lab_result_import_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.lab_result_import_id_seq', 1, false);


--
-- Name: paper_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.paper_version_id_seq', 1, false);


--
-- Name: question_bank_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.question_bank_id_seq', 2, true);


--
-- Name: question_bank_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.question_bank_item_id_seq', 630, true);


--
-- Name: question_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.question_id_seq', 4, true);


--
-- Name: relogin_authorization_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.relogin_authorization_id_seq', 1, false);


--
-- Name: secure_package_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.secure_package_id_seq', 1, false);


--
-- Name: security_violation_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.security_violation_log_id_seq', 12, true);


--
-- Name: session_transfer_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.session_transfer_history_id_seq', 1, false);


--
-- Name: session_unlock_credential_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.session_unlock_credential_id_seq', 1, false);


--
-- Name: student_roster_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.student_roster_id_seq', 37, true);


--
-- Name: student_session_result_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.student_session_result_id_seq', 1, false);


--
-- Name: subject_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusexam
--

SELECT pg_catalog.setval('public.subject_id_seq', 15, true);


--
-- Name: academic_group academic_group_department_academic_session_study_year_semes_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.academic_group
    ADD CONSTRAINT academic_group_department_academic_session_study_year_semes_key UNIQUE (department, academic_session, study_year, semester, section);


--
-- Name: academic_group academic_group_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.academic_group
    ADD CONSTRAINT academic_group_pkey PRIMARY KEY (id);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: account account_username_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_username_key UNIQUE (username);


--
-- Name: answer_key_correction answer_key_correction_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.answer_key_correction
    ADD CONSTRAINT answer_key_correction_pkey PRIMARY KEY (id);


--
-- Name: answer answer_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.answer
    ADD CONSTRAINT answer_pkey PRIMARY KEY (attempt_id, "position");


--
-- Name: assignment assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.assignment
    ADD CONSTRAINT assignment_pkey PRIMARY KEY (exam_id, student_id);


--
-- Name: attempt attempt_id_exam_id_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.attempt
    ADD CONSTRAINT attempt_id_exam_id_key UNIQUE (id, exam_id);


--
-- Name: attempt attempt_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.attempt
    ADD CONSTRAINT attempt_pkey PRIMARY KEY (id);


--
-- Name: audit audit_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.audit
    ADD CONSTRAINT audit_pkey PRIMARY KEY (id);


--
-- Name: bank bank_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.bank
    ADD CONSTRAINT bank_pkey PRIMARY KEY (id);


--
-- Name: bank_scope bank_scope_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.bank_scope
    ADD CONSTRAINT bank_scope_pkey PRIMARY KEY (bank_id, group_id);


--
-- Name: computer_assignment computer_assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.computer_assignment
    ADD CONSTRAINT computer_assignment_pkey PRIMARY KEY (id);


--
-- Name: computer_assignment computer_assignment_session_id_computer_number_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.computer_assignment
    ADD CONSTRAINT computer_assignment_session_id_computer_number_key UNIQUE (session_id, computer_number);


--
-- Name: course_outcome_review course_outcome_review_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.course_outcome_review
    ADD CONSTRAINT course_outcome_review_pkey PRIMARY KEY (id);


--
-- Name: course_outcome_revision course_outcome_revision_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.course_outcome_revision
    ADD CONSTRAINT course_outcome_revision_pkey PRIMARY KEY (id);


--
-- Name: course_outcome_revision course_outcome_revision_submission_id_revision_number_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.course_outcome_revision
    ADD CONSTRAINT course_outcome_revision_submission_id_revision_number_key UNIQUE (submission_id, revision_number);


--
-- Name: course_outcome_statement course_outcome_statement_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.course_outcome_statement
    ADD CONSTRAINT course_outcome_statement_pkey PRIMARY KEY (id);


--
-- Name: course_outcome_statement course_outcome_statement_revision_id_co_code_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.course_outcome_statement
    ADD CONSTRAINT course_outcome_statement_revision_id_co_code_key UNIQUE (revision_id, co_code);


--
-- Name: course_outcome_submission course_outcome_submission_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.course_outcome_submission
    ADD CONSTRAINT course_outcome_submission_pkey PRIMARY KEY (id);


--
-- Name: course_outcome_submission course_outcome_submission_subject_id_academic_session_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.course_outcome_submission
    ADD CONSTRAINT course_outcome_submission_subject_id_academic_session_key UNIQUE (subject_id, academic_session);


--
-- Name: department department_code_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_code_key UNIQUE (code);


--
-- Name: department department_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_pkey PRIMARY KEY (id);


--
-- Name: exam exam_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.exam
    ADD CONSTRAINT exam_pkey PRIMARY KEY (id);


--
-- Name: exam_question exam_question_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.exam_question
    ADD CONSTRAINT exam_question_pkey PRIMARY KEY (exam_id, "position");


--
-- Name: examination_cycle examination_cycle_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.examination_cycle
    ADD CONSTRAINT examination_cycle_pkey PRIMARY KEY (id);


--
-- Name: examination_session examination_session_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.examination_session
    ADD CONSTRAINT examination_session_pkey PRIMARY KEY (id);


--
-- Name: faculty_scope faculty_scope_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.faculty_scope
    ADD CONSTRAINT faculty_scope_pkey PRIMARY KEY (faculty_id, group_id, subject_id);


--
-- Name: generated_paper generated_paper_bank_id_paper_number_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.generated_paper
    ADD CONSTRAINT generated_paper_bank_id_paper_number_key UNIQUE (bank_id, paper_number);


--
-- Name: generated_paper generated_paper_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.generated_paper
    ADD CONSTRAINT generated_paper_pkey PRIMARY KEY (id);


--
-- Name: generated_paper_question generated_paper_question_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.generated_paper_question
    ADD CONSTRAINT generated_paper_question_pkey PRIMARY KEY (paper_id, paper_position);


--
-- Name: lab_result_import lab_result_import_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.lab_result_import
    ADD CONSTRAINT lab_result_import_pkey PRIMARY KEY (id);


--
-- Name: lab_result_import lab_result_import_session_id_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.lab_result_import
    ADD CONSTRAINT lab_result_import_session_id_key UNIQUE (session_id);


--
-- Name: paper_version paper_version_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.paper_version
    ADD CONSTRAINT paper_version_pkey PRIMARY KEY (id);


--
-- Name: paper_version_question paper_version_question_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.paper_version_question
    ADD CONSTRAINT paper_version_question_pkey PRIMARY KEY (version_id, display_position);


--
-- Name: paper_version paper_version_session_id_version_letter_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.paper_version
    ADD CONSTRAINT paper_version_session_id_version_letter_key UNIQUE (session_id, version_letter);


--
-- Name: question_bank_item question_bank_item_bank_id_question_uid_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.question_bank_item
    ADD CONSTRAINT question_bank_item_bank_id_question_uid_key UNIQUE (bank_id, question_uid);


--
-- Name: question_bank_item question_bank_item_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.question_bank_item
    ADD CONSTRAINT question_bank_item_pkey PRIMARY KEY (id);


--
-- Name: question_bank question_bank_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.question_bank
    ADD CONSTRAINT question_bank_pkey PRIMARY KEY (id);


--
-- Name: question question_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.question
    ADD CONSTRAINT question_pkey PRIMARY KEY (id);


--
-- Name: relogin_authorization relogin_authorization_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.relogin_authorization
    ADD CONSTRAINT relogin_authorization_pkey PRIMARY KEY (id);


--
-- Name: relogin_authorization relogin_authorization_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.relogin_authorization
    ADD CONSTRAINT relogin_authorization_token_hash_key UNIQUE (token_hash);


--
-- Name: relogin_authorization relogin_authorization_token_id_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.relogin_authorization
    ADD CONSTRAINT relogin_authorization_token_id_key UNIQUE (token_id);


--
-- Name: secure_package secure_package_package_uid_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.secure_package
    ADD CONSTRAINT secure_package_package_uid_key UNIQUE (package_uid);


--
-- Name: secure_package secure_package_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.secure_package
    ADD CONSTRAINT secure_package_pkey PRIMARY KEY (id);


--
-- Name: secure_package secure_package_session_id_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.secure_package
    ADD CONSTRAINT secure_package_session_id_key UNIQUE (session_id);


--
-- Name: security_violation_log security_violation_log_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.security_violation_log
    ADD CONSTRAINT security_violation_log_pkey PRIMARY KEY (id);


--
-- Name: session_roster_snapshot session_roster_snapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.session_roster_snapshot
    ADD CONSTRAINT session_roster_snapshot_pkey PRIMARY KEY (session_id, student_id);


--
-- Name: session_token session_token_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.session_token
    ADD CONSTRAINT session_token_pkey PRIMARY KEY (token_hash);


--
-- Name: session_transfer_history session_transfer_history_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.session_transfer_history
    ADD CONSTRAINT session_transfer_history_pkey PRIMARY KEY (id);


--
-- Name: session_unlock_credential session_unlock_credential_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.session_unlock_credential
    ADD CONSTRAINT session_unlock_credential_pkey PRIMARY KEY (id);


--
-- Name: session_unlock_credential session_unlock_credential_session_id_sitting_name_revision_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.session_unlock_credential
    ADD CONSTRAINT session_unlock_credential_session_id_sitting_name_revision_key UNIQUE (session_id, sitting_name, revision);


--
-- Name: student_roster student_roster_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.student_roster
    ADD CONSTRAINT student_roster_pkey PRIMARY KEY (id);


--
-- Name: student_roster student_roster_usn_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.student_roster
    ADD CONSTRAINT student_roster_usn_key UNIQUE (usn);


--
-- Name: student_session_result student_session_result_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.student_session_result
    ADD CONSTRAINT student_session_result_pkey PRIMARY KEY (id);


--
-- Name: student_session_result student_session_result_session_id_usn_key; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.student_session_result
    ADD CONSTRAINT student_session_result_session_id_usn_key UNIQUE (session_id, usn);


--
-- Name: subject subject_pkey; Type: CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.subject
    ADD CONSTRAINT subject_pkey PRIMARY KEY (id);


--
-- Name: attempt_due; Type: INDEX; Schema: public; Owner: campusexam
--

CREATE INDEX attempt_due ON public.attempt USING btree (deadline) WHERE (submitted IS NULL);


--
-- Name: idx_account_dept_role; Type: INDEX; Schema: public; Owner: campusexam
--

CREATE INDEX idx_account_dept_role ON public.account USING btree (department_id, role);


--
-- Name: idx_co_submission_dept_sem; Type: INDEX; Schema: public; Owner: campusexam
--

CREATE INDEX idx_co_submission_dept_sem ON public.course_outcome_submission USING btree (department_id, semester);


--
-- Name: idx_exam_session_sched; Type: INDEX; Schema: public; Owner: campusexam
--

CREATE INDEX idx_exam_session_sched ON public.examination_session USING btree (session_date, sitting, assigned_lab);


--
-- Name: idx_key_corr_session; Type: INDEX; Schema: public; Owner: campusexam
--

CREATE INDEX idx_key_corr_session ON public.answer_key_correction USING btree (session_id, status);


--
-- Name: idx_qb_item_bank_mod; Type: INDEX; Schema: public; Owner: campusexam
--

CREATE INDEX idx_qb_item_bank_mod ON public.question_bank_item USING btree (bank_id, module_number);


--
-- Name: idx_relogin_auth_session_usn; Type: INDEX; Schema: public; Owner: campusexam
--

CREATE INDEX idx_relogin_auth_session_usn ON public.relogin_authorization USING btree (session_id, student_usn, status);


--
-- Name: idx_sec_violation_session_usn; Type: INDEX; Schema: public; Owner: campusexam
--

CREATE INDEX idx_sec_violation_session_usn ON public.security_violation_log USING btree (session_id, student_usn);


--
-- Name: idx_session_transfer_session_usn; Type: INDEX; Schema: public; Owner: campusexam
--

CREATE INDEX idx_session_transfer_session_usn ON public.session_transfer_history USING btree (session_id, student_usn);


--
-- Name: idx_student_roster_dept_sem; Type: INDEX; Schema: public; Owner: campusexam
--

CREATE INDEX idx_student_roster_dept_sem ON public.student_roster USING btree (department_id, semester, section);


--
-- Name: idx_unlock_cred_session; Type: INDEX; Schema: public; Owner: campusexam
--

CREATE INDEX idx_unlock_cred_session ON public.session_unlock_credential USING btree (session_id, status);


--
-- Name: one_active_attempt; Type: INDEX; Schema: public; Owner: campusexam
--

CREATE UNIQUE INDEX one_active_attempt ON public.attempt USING btree (exam_id, student_id) WHERE (submitted IS NULL);


--
-- Name: question_prompt_key; Type: INDEX; Schema: public; Owner: campusexam
--

CREATE UNIQUE INDEX question_prompt_key ON public.question USING btree (bank_id, lower(btrim(prompt)));


--
-- Name: uq_active_unlock_credential; Type: INDEX; Schema: public; Owner: campusexam
--

CREATE UNIQUE INDEX uq_active_unlock_credential ON public.session_unlock_credential USING btree (session_id, sitting_name) WHERE (status = 'Active'::text);


--
-- Name: academic_group academic_group_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.academic_group
    ADD CONSTRAINT academic_group_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(id);


--
-- Name: account account_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(id);


--
-- Name: account account_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.academic_group(id);


--
-- Name: answer answer_attempt_id_exam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.answer
    ADD CONSTRAINT answer_attempt_id_exam_id_fkey FOREIGN KEY (attempt_id, exam_id) REFERENCES public.attempt(id, exam_id);


--
-- Name: answer answer_exam_id_position_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.answer
    ADD CONSTRAINT answer_exam_id_position_fkey FOREIGN KEY (exam_id, "position") REFERENCES public.exam_question(exam_id, "position");


--
-- Name: answer_key_correction answer_key_correction_decided_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.answer_key_correction
    ADD CONSTRAINT answer_key_correction_decided_by_fkey FOREIGN KEY (decided_by) REFERENCES public.account(id);


--
-- Name: answer_key_correction answer_key_correction_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.answer_key_correction
    ADD CONSTRAINT answer_key_correction_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.examination_session(id) ON DELETE CASCADE;


--
-- Name: answer_key_correction answer_key_correction_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.answer_key_correction
    ADD CONSTRAINT answer_key_correction_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subject(id);


--
-- Name: answer_key_correction answer_key_correction_submitted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.answer_key_correction
    ADD CONSTRAINT answer_key_correction_submitted_by_fkey FOREIGN KEY (submitted_by) REFERENCES public.account(id);


--
-- Name: assignment assignment_exam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.assignment
    ADD CONSTRAINT assignment_exam_id_fkey FOREIGN KEY (exam_id) REFERENCES public.exam(id);


--
-- Name: assignment assignment_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.assignment
    ADD CONSTRAINT assignment_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.account(id);


--
-- Name: attempt attempt_exam_id_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.attempt
    ADD CONSTRAINT attempt_exam_id_student_id_fkey FOREIGN KEY (exam_id, student_id) REFERENCES public.assignment(exam_id, student_id);


--
-- Name: audit audit_actor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.audit
    ADD CONSTRAINT audit_actor_fkey FOREIGN KEY (actor) REFERENCES public.account(id);


--
-- Name: bank bank_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.bank
    ADD CONSTRAINT bank_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.account(id);


--
-- Name: bank_scope bank_scope_bank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.bank_scope
    ADD CONSTRAINT bank_scope_bank_id_fkey FOREIGN KEY (bank_id) REFERENCES public.bank(id);


--
-- Name: bank_scope bank_scope_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.bank_scope
    ADD CONSTRAINT bank_scope_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.academic_group(id);


--
-- Name: bank bank_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.bank
    ADD CONSTRAINT bank_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subject(id);


--
-- Name: computer_assignment computer_assignment_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.computer_assignment
    ADD CONSTRAINT computer_assignment_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.examination_session(id) ON DELETE CASCADE;


--
-- Name: course_outcome_review course_outcome_review_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.course_outcome_review
    ADD CONSTRAINT course_outcome_review_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.account(id);


--
-- Name: course_outcome_review course_outcome_review_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.course_outcome_review
    ADD CONSTRAINT course_outcome_review_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.course_outcome_submission(id) ON DELETE CASCADE;


--
-- Name: course_outcome_revision course_outcome_revision_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.course_outcome_revision
    ADD CONSTRAINT course_outcome_revision_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.course_outcome_submission(id) ON DELETE CASCADE;


--
-- Name: course_outcome_revision course_outcome_revision_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.course_outcome_revision
    ADD CONSTRAINT course_outcome_revision_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.account(id);


--
-- Name: course_outcome_statement course_outcome_statement_revision_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.course_outcome_statement
    ADD CONSTRAINT course_outcome_statement_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES public.course_outcome_revision(id) ON DELETE CASCADE;


--
-- Name: course_outcome_submission course_outcome_submission_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.course_outcome_submission
    ADD CONSTRAINT course_outcome_submission_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.account(id);


--
-- Name: course_outcome_submission course_outcome_submission_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.course_outcome_submission
    ADD CONSTRAINT course_outcome_submission_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(id);


--
-- Name: course_outcome_submission course_outcome_submission_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.course_outcome_submission
    ADD CONSTRAINT course_outcome_submission_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subject(id) ON DELETE CASCADE;


--
-- Name: exam exam_bank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.exam
    ADD CONSTRAINT exam_bank_id_fkey FOREIGN KEY (bank_id) REFERENCES public.bank(id);


--
-- Name: exam_question exam_question_exam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.exam_question
    ADD CONSTRAINT exam_question_exam_id_fkey FOREIGN KEY (exam_id) REFERENCES public.exam(id);


--
-- Name: examination_cycle examination_cycle_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.examination_cycle
    ADD CONSTRAINT examination_cycle_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.account(id);


--
-- Name: examination_session examination_session_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.examination_session
    ADD CONSTRAINT examination_session_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.account(id);


--
-- Name: examination_session examination_session_cycle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.examination_session
    ADD CONSTRAINT examination_session_cycle_id_fkey FOREIGN KEY (cycle_id) REFERENCES public.examination_cycle(id);


--
-- Name: examination_session examination_session_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.examination_session
    ADD CONSTRAINT examination_session_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(id);


--
-- Name: examination_session examination_session_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.examination_session
    ADD CONSTRAINT examination_session_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.academic_group(id);


--
-- Name: examination_session examination_session_selected_paper_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.examination_session
    ADD CONSTRAINT examination_session_selected_paper_id_fkey FOREIGN KEY (selected_paper_id) REFERENCES public.generated_paper(id);


--
-- Name: examination_session examination_session_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.examination_session
    ADD CONSTRAINT examination_session_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subject(id);


--
-- Name: faculty_scope faculty_scope_faculty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.faculty_scope
    ADD CONSTRAINT faculty_scope_faculty_id_fkey FOREIGN KEY (faculty_id) REFERENCES public.account(id);


--
-- Name: faculty_scope faculty_scope_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.faculty_scope
    ADD CONSTRAINT faculty_scope_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.academic_group(id);


--
-- Name: faculty_scope faculty_scope_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.faculty_scope
    ADD CONSTRAINT faculty_scope_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subject(id);


--
-- Name: generated_paper generated_paper_bank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.generated_paper
    ADD CONSTRAINT generated_paper_bank_id_fkey FOREIGN KEY (bank_id) REFERENCES public.question_bank(id);


--
-- Name: generated_paper_question generated_paper_question_paper_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.generated_paper_question
    ADD CONSTRAINT generated_paper_question_paper_id_fkey FOREIGN KEY (paper_id) REFERENCES public.generated_paper(id) ON DELETE CASCADE;


--
-- Name: generated_paper_question generated_paper_question_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.generated_paper_question
    ADD CONSTRAINT generated_paper_question_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.question_bank_item(id);


--
-- Name: lab_result_import lab_result_import_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.lab_result_import
    ADD CONSTRAINT lab_result_import_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.account(id);


--
-- Name: lab_result_import lab_result_import_imported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.lab_result_import
    ADD CONSTRAINT lab_result_import_imported_by_fkey FOREIGN KEY (imported_by) REFERENCES public.account(id);


--
-- Name: lab_result_import lab_result_import_released_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.lab_result_import
    ADD CONSTRAINT lab_result_import_released_by_fkey FOREIGN KEY (released_by) REFERENCES public.account(id);


--
-- Name: lab_result_import lab_result_import_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.lab_result_import
    ADD CONSTRAINT lab_result_import_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.examination_session(id);


--
-- Name: paper_version paper_version_paper_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.paper_version
    ADD CONSTRAINT paper_version_paper_id_fkey FOREIGN KEY (paper_id) REFERENCES public.generated_paper(id);


--
-- Name: paper_version_question paper_version_question_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.paper_version_question
    ADD CONSTRAINT paper_version_question_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.question_bank_item(id);


--
-- Name: paper_version_question paper_version_question_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.paper_version_question
    ADD CONSTRAINT paper_version_question_version_id_fkey FOREIGN KEY (version_id) REFERENCES public.paper_version(id) ON DELETE CASCADE;


--
-- Name: paper_version paper_version_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.paper_version
    ADD CONSTRAINT paper_version_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.examination_session(id) ON DELETE CASCADE;


--
-- Name: question_bank question_bank_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.question_bank
    ADD CONSTRAINT question_bank_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.account(id);


--
-- Name: question_bank question_bank_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.question_bank
    ADD CONSTRAINT question_bank_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(id);


--
-- Name: question_bank question_bank_finalized_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.question_bank
    ADD CONSTRAINT question_bank_finalized_by_fkey FOREIGN KEY (finalized_by) REFERENCES public.account(id);


--
-- Name: question question_bank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.question
    ADD CONSTRAINT question_bank_id_fkey FOREIGN KEY (bank_id) REFERENCES public.bank(id);


--
-- Name: question_bank_item question_bank_item_bank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.question_bank_item
    ADD CONSTRAINT question_bank_item_bank_id_fkey FOREIGN KEY (bank_id) REFERENCES public.question_bank(id) ON DELETE CASCADE;


--
-- Name: question_bank question_bank_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.question_bank
    ADD CONSTRAINT question_bank_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subject(id);


--
-- Name: relogin_authorization relogin_authorization_authorized_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.relogin_authorization
    ADD CONSTRAINT relogin_authorization_authorized_by_fkey FOREIGN KEY (authorized_by) REFERENCES public.account(id);


--
-- Name: relogin_authorization relogin_authorization_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.relogin_authorization
    ADD CONSTRAINT relogin_authorization_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.examination_session(id) ON DELETE CASCADE;


--
-- Name: secure_package secure_package_exported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.secure_package
    ADD CONSTRAINT secure_package_exported_by_fkey FOREIGN KEY (exported_by) REFERENCES public.account(id);


--
-- Name: secure_package secure_package_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.secure_package
    ADD CONSTRAINT secure_package_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.examination_session(id);


--
-- Name: security_violation_log security_violation_log_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.security_violation_log
    ADD CONSTRAINT security_violation_log_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.examination_session(id) ON DELETE CASCADE;


--
-- Name: session_roster_snapshot session_roster_snapshot_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.session_roster_snapshot
    ADD CONSTRAINT session_roster_snapshot_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.examination_session(id) ON DELETE CASCADE;


--
-- Name: session_roster_snapshot session_roster_snapshot_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.session_roster_snapshot
    ADD CONSTRAINT session_roster_snapshot_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.student_roster(id);


--
-- Name: session_token session_token_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.session_token
    ADD CONSTRAINT session_token_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(id);


--
-- Name: session_transfer_history session_transfer_history_authorization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.session_transfer_history
    ADD CONSTRAINT session_transfer_history_authorization_id_fkey FOREIGN KEY (authorization_id) REFERENCES public.relogin_authorization(id);


--
-- Name: session_transfer_history session_transfer_history_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.session_transfer_history
    ADD CONSTRAINT session_transfer_history_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.examination_session(id) ON DELETE CASCADE;


--
-- Name: session_transfer_history session_transfer_history_transferred_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.session_transfer_history
    ADD CONSTRAINT session_transfer_history_transferred_by_fkey FOREIGN KEY (transferred_by) REFERENCES public.account(id);


--
-- Name: session_unlock_credential session_unlock_credential_generated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.session_unlock_credential
    ADD CONSTRAINT session_unlock_credential_generated_by_fkey FOREIGN KEY (generated_by) REFERENCES public.account(id);


--
-- Name: session_unlock_credential session_unlock_credential_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.session_unlock_credential
    ADD CONSTRAINT session_unlock_credential_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.examination_session(id) ON DELETE CASCADE;


--
-- Name: student_roster student_roster_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.student_roster
    ADD CONSTRAINT student_roster_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(id);


--
-- Name: student_roster student_roster_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.student_roster
    ADD CONSTRAINT student_roster_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.academic_group(id);


--
-- Name: student_session_result student_session_result_import_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.student_session_result
    ADD CONSTRAINT student_session_result_import_id_fkey FOREIGN KEY (import_id) REFERENCES public.lab_result_import(id) ON DELETE CASCADE;


--
-- Name: student_session_result student_session_result_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.student_session_result
    ADD CONSTRAINT student_session_result_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.examination_session(id);


--
-- Name: subject subject_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusexam
--

ALTER TABLE ONLY public.subject
    ADD CONSTRAINT subject_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(id);


--
-- PostgreSQL database dump complete
--

\unrestrict tsQQoQ1uht7LSf5hPY5cRAzux3wng9eovoHrrNxUWNdm94czsbEjx1zt1I6DpDf

