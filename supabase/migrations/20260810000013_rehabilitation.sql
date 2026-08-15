-- ============================================================
-- Migration 013: rehabilitation_programs + exercises
--               + program_exercises + exercise_sessions
-- Project: RespiraCare
-- Date: 2026-08-10
-- exercise_sessions is INSERT-ONLY (audit/progress log).
-- program_exercises is a 1:N junction (program ↔ exercise).
-- ============================================================

-- ---------- rehabilitation_programs ----------
create table if not exists public.rehabilitation_programs (
    id                          uuid primary key default gen_random_uuid(),
    patient_profile_id          uuid not null,
    title                       text not null,
    description                 text not null default '',
    target_weekly_sessions      integer not null default 5,
    start_date                  date not null default current_date,
    end_date                    date,                          -- NULL = ongoing
    is_active                   boolean not null default true,
    created_at                  timestamptz not null default now(),
    updated_at                  timestamptz not null default now()
);

alter table public.rehabilitation_programs
    drop constraint if exists rehab_programs_patient_profile_id_fkey;
alter table public.rehabilitation_programs
    add constraint rehab_programs_patient_profile_id_fkey
    foreign key (patient_profile_id) references public.patient_profiles(id)
    on delete restrict;

-- partial UNIQUE: one active ongoing program per patient.
drop index if exists public.idx_rehab_programs_patient_active_unique;
create unique index idx_rehab_programs_patient_active_unique
    on public.rehabilitation_programs (patient_profile_id)
    where end_date is null and is_active = true;

-- ---------- exercises (catalogue) ----------
create table if not exists public.exercises (
    id                  uuid primary key default gen_random_uuid(),
    name                text not null,
    description         text not null default '',
    duration_seconds    integer not null,
    video_url           text,                         -- Storage path
    instructions        text not null,                -- validated by clinical team
    "order"             integer not null default 0,    -- default display order
    is_active           boolean not null default true,
    created_at          timestamptz not null default now(),
    updated_at          timestamptz not null default now(),
    constraint exercises_duration_positive
        check (duration_seconds > 0)
);

-- ---------- program_exercises (junction, per-program order) ----------
create table if not exists public.program_exercises (
    id                  uuid primary key default gen_random_uuid(),
    program_id          uuid not null,
    exercise_id         uuid not null,
    order_in_program    integer not null,
    created_at          timestamptz not null default now()
);

alter table public.program_exercises
    drop constraint if exists program_exercises_program_id_fkey;
alter table public.program_exercises
    add constraint program_exercises_program_id_fkey
    foreign key (program_id) references public.rehabilitation_programs(id)
    on delete cascade;

alter table public.program_exercises
    drop constraint if exists program_exercises_exercise_id_fkey;
alter table public.program_exercises
    add constraint program_exercises_exercise_id_fkey
    foreign key (exercise_id) references public.exercises(id)
    on delete restrict;

alter table public.program_exercises
    drop constraint if exists program_exercises_program_exercise_unique;
alter table public.program_exercises
    add constraint program_exercises_program_exercise_unique
    unique (program_id, exercise_id);

-- ---------- exercise_sessions (insert-only progress log) ----------
create table if not exists public.exercise_sessions (
    id                          uuid primary key default gen_random_uuid(),
    patient_profile_id          uuid not null,
    exercise_id                 uuid not null,
    exercise_name               text not null,             -- denormalised for rendering
    program_id                  uuid,                      -- nullable if standalone
    completed_at                timestamptz not null default now(),
    actual_duration_seconds     integer not null,
    perceived_effort            integer
                                check (perceived_effort is null or (perceived_effort between 1 and 10)),
    notes                       text,
    created_at                  timestamptz not null default now(),
    constraint exercise_sessions_duration_positive
        check (actual_duration_seconds > 0)
);

alter table public.exercise_sessions
    drop constraint if exists exercise_sessions_patient_profile_id_fkey;
alter table public.exercise_sessions
    add constraint exercise_sessions_patient_profile_id_fkey
    foreign key (patient_profile_id) references public.patient_profiles(id)
    on delete restrict;

alter table public.exercise_sessions
    drop constraint if exists exercise_sessions_exercise_id_fkey;
alter table public.exercise_sessions
    add constraint exercise_sessions_exercise_id_fkey
    foreign key (exercise_id) references public.exercises(id)
    on delete restrict;

alter table public.exercise_sessions
    drop constraint if exists exercise_sessions_program_id_fkey;
alter table public.exercise_sessions
    add constraint exercise_sessions_program_id_fkey
    foreign key (program_id) references public.rehabilitation_programs(id)
    on delete set null;

-- Done.
