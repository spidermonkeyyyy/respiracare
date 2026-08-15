-- ============================================================
-- Migration 015: nurse_assessments + escalations
--               + inhaler_video_reviews + video_submissions
-- Project: RespiraCare
-- Date: 2026-08-10
-- Notes:
--   - nurse_assessments is INSERT-ONLY (immutable audit-trail).
--   - escalations is a MUTABLE lifecycle table (status can change);
--     NOT in the audit-trail group (v2.1 correction #9).
--   - inhaler_video_reviews is mutable (nurse updates review status).
--   - video_submissions is mutable (review status changes).
-- ============================================================

-- ---------- nurse_assessments (immutable audit) ----------
create table if not exists public.nurse_assessments (
    id                      uuid primary key default gen_random_uuid(),
    patient_profile_id      uuid not null,
    nurse_id                uuid not null,
    status                  text not null
                            check (status in ('no_concern','enhanced_monitoring','patient_contact','pneumologist_review')),
    observation             text not null,
    action                  text not null,
    note                    text,
    created_at              timestamptz not null default now()
);

alter table public.nurse_assessments
    drop constraint if exists nurse_assessments_patient_profile_id_fkey;
alter table public.nurse_assessments
    add constraint nurse_assessments_patient_profile_id_fkey
    foreign key (patient_profile_id) references public.patient_profiles(id)
    on delete restrict;

alter table public.nurse_assessments
    drop constraint if exists nurse_assessments_nurse_id_fkey;
alter table public.nurse_assessments
    add constraint nurse_assessments_nurse_id_fkey
    foreign key (nurse_id) references public.nurse_profiles(id)
    on delete restrict;

-- ---------- escalations (mutable lifecycle; not audit) ----------
create table if not exists public.escalations (
    id                          uuid primary key default gen_random_uuid(),
    patient_profile_id          uuid not null,
    nurse_id                    uuid not null,
    reason                      text not null
                                check (reason in ('symptom_change','treatment_concern','inhaler_technique','other')),
    priority                    text not null default 'normal'
                                check (priority in ('normal','high')),
    nurse_summary               text not null,
    supporting_information      text,
    pneumologist_id             uuid,                       -- profiles.id (role = pneumologist); NULL until assigned
    status                      text not null default 'submitted'
                                check (status in ('submitted','in_review','resolved')),
    created_at                  timestamptz not null default now(),
    updated_at                  timestamptz not null default now()
);

alter table public.escalations
    drop constraint if exists escalations_patient_profile_id_fkey;
alter table public.escalations
    add constraint escalations_patient_profile_id_fkey
    foreign key (patient_profile_id) references public.patient_profiles(id)
    on delete restrict;

alter table public.escalations
    drop constraint if exists escalations_nurse_id_fkey;
alter table public.escalations
    add constraint escalations_nurse_id_fkey
    foreign key (nurse_id) references public.nurse_profiles(id)
    on delete restrict;

alter table public.escalations
    drop constraint if exists escalations_pneumologist_id_fkey;
alter table public.escalations
    add constraint escalations_pneumologist_id_fkey
    foreign key (pneumologist_id) references public.profiles(id)
    on delete set null;

-- ---------- video_submissions (metadata only; actual file in Storage) ----------
create table if not exists public.video_submissions (
    id                      uuid primary key default gen_random_uuid(),
    patient_profile_id      uuid not null,
    file_uri                 text not null,                -- Storage object path
    uploaded_at              timestamptz not null default now(),
    review_status           text not null default 'pending_review'
                            check (review_status in ('pending_review','reviewed','retry_requested')),
    reviewed_at             timestamptz,
    reviewer_note           text,
    duration_seconds        integer,
    created_at              timestamptz not null default now(),
    updated_at              timestamptz not null default now()
);

alter table public.video_submissions
    drop constraint if exists video_submissions_patient_profile_id_fkey;
alter table public.video_submissions
    add constraint video_submissions_patient_profile_id_fkey
    foreign key (patient_profile_id) references public.patient_profiles(id)
    on delete restrict;

-- ---------- inhaler_video_reviews (nurse review record) ----------
create table if not exists public.inhaler_video_reviews (
    id                      uuid primary key default gen_random_uuid(),
    patient_profile_id      uuid not null,
    patient_name            text not null,                -- denormalised for rendering
    nurse_id                uuid not null,
    video_submission_id     uuid not null,
    video_url               text not null,                -- signed URL or Storage path
    status                  text not null
                            check (status in ('correct','needs_improvement','new_video_requested')),
    submitted_at            timestamptz,
    comment                 text,
    created_at              timestamptz not null default now(),
    updated_at              timestamptz not null default now()
);

alter table public.inhaler_video_reviews
    drop constraint if exists inhaler_reviews_patient_profile_id_fkey;
alter table public.inhaler_video_reviews
    add constraint inhaler_reviews_patient_profile_id_fkey
    foreign key (patient_profile_id) references public.patient_profiles(id)
    on delete restrict;

alter table public.inhaler_video_reviews
    drop constraint if exists inhaler_reviews_nurse_id_fkey;
alter table public.inhaler_video_reviews
    add constraint inhaler_reviews_nurse_id_fkey
    foreign key (nurse_id) references public.nurse_profiles(id)
    on delete restrict;

alter table public.inhaler_video_reviews
    drop constraint if exists inhaler_reviews_video_submission_id_fkey;
alter table public.inhaler_video_reviews
    add constraint inhaler_reviews_video_submission_id_fkey
    foreign key (video_submission_id) references public.video_submissions(id)
    on delete restrict;

-- Done.
