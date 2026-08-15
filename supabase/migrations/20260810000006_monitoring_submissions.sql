-- ============================================================
-- Migration 006: monitoring_submissions + monitoring_answers
-- Project: RespiraCare
-- Date: 2026-08-10
-- Corrections applied (v2.1):
--   - monitoring_submissions.spo2_value is an explicit denormalised
--     column maintained by a trigger on monitoring_answers.
--   - monitoring_answers XOR CHECK exactly one of (value_text,
--     value_numeric) is non-null per row.
--   - monitoring_answers.question_id references the UUID PK of
--     monitoring_questions, NOT question_key.
-- ============================================================

-- ---------- monitoring_submissions ----------
create table if not exists public.monitoring_submissions (
    id                  uuid primary key default gen_random_uuid(),
    patient_profile_id  uuid not null,
    submitted_at        timestamptz not null default now(),
    measurement_source  text not null default 'manual'
                        check (measurement_source in ('manual','bluetooth')),
    spo2_value          integer,                                 -- denormalised; maintained by trigger
    evaluation_status   text not null default 'pending'
                        check (evaluation_status in ('pending','normal','review_required')),
    patient_message     text,                                     -- Flutter EvaluationResult.patientMessage
    evaluated_at        timestamptz,
    created_at          timestamptz not null default now()
);

alter table public.monitoring_submissions
    drop constraint if exists monitoring_submissions_patient_profile_id_fkey;
alter table public.monitoring_submissions
    add constraint monitoring_submissions_patient_profile_id_fkey
    foreign key (patient_profile_id) references public.patient_profiles(id)
    on delete restrict;

-- ---------- monitoring_answers ----------
create table if not exists public.monitoring_answers (
    id              uuid primary key default gen_random_uuid(),
    submission_id   uuid not null,
    question_id     uuid not null,               -- FK to monitoring_questions.id (UUID PK)
    value_text      text,                        -- single_choice: option id
    value_numeric   numeric,                     -- numeric_input: numeric value
    display_label   text not null,               -- pre-formatted for rendering
    created_at      timestamptz not null default now(),
    -- XOR: exactly one of value_text / value_numeric must be non-null.
    constraint monitoring_answers_xor_check
        check ((value_text is not null) <> (value_numeric is not null))
);

alter table public.monitoring_answers
    drop constraint if exists monitoring_answers_submission_id_fkey;
alter table public.monitoring_answers
    add constraint monitoring_answers_submission_id_fkey
    foreign key (submission_id) references public.monitoring_submissions(id)
    on delete cascade;

alter table public.monitoring_answers
    drop constraint if exists monitoring_answers_question_id_fkey;
alter table public.monitoring_answers
    add constraint monitoring_answers_question_id_fkey
    foreign key (question_id) references public.monitoring_questions(id)
    on delete restrict;

-- One answer per question per submission.
drop index if exists public.idx_ma_submission_question_unique;
create unique index idx_ma_submission_question_unique
    on public.monitoring_answers (submission_id, question_id);

-- ============================================================
-- Trigger: sync_submission_spo2_value
-- After INSERT/UPDATE on monitoring_answers, if the linked question's
-- question_key = 'spo2', copy value_numeric (rounded) into the parent
-- monitoring_submissions.spo2_value.
-- ============================================================
create or replace function public.sync_submission_spo2_value()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_question_key text;
    v_sub uuid;
    v_value numeric;
begin
    if (tg_op = 'INSERT') then
        v_sub := new.submission_id;
        select question_key into v_question_key
          from public.monitoring_questions
         where id = new.question_id;
        v_value := new.value_numeric;
    elsif (tg_op = 'UPDATE') then
        v_sub := new.submission_id;
        select question_key into v_question_key
          from public.monitoring_questions
         where id = new.question_id;
        v_value := new.value_numeric;
    end if;

    if v_question_key = 'spo2' and v_value is not null then
        update public.monitoring_submissions
        set spo2_value = v_value::int
        where id = v_sub;
    elsif v_question_key = 'spo2' and v_value is null then
        update public.monitoring_submissions
        set spo2_value = null
        where id = v_sub;
    end if;

    return coalesce(new, old);
end;
$$;

drop trigger if exists trg_sync_submission_spo2_ins on public.monitoring_answers;
create trigger trg_sync_submission_spo2_ins
    after insert on public.monitoring_answers
    for each row execute procedure public.sync_submission_spo2_value();

drop trigger if exists trg_sync_submission_spo2_upd on public.monitoring_answers;
create trigger trg_sync_submission_spo2_upd
    after update of value_numeric on public.monitoring_answers
    for each row execute procedure public.sync_submission_spo2_value();

-- Done.
