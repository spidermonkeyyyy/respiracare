-- ============================================================
-- Migration 003: patient_profiles + nurse_profiles
-- Project: RespiraCare
-- Date: 2026-08-10
-- Principle: separate domain UUIDs. patient_profiles.id and
-- nurse_profiles.id are NOT aliases of profiles.id; they are
-- independent UUIDs so role transitions don't collide.
-- (Step 2 v2.1 approval decision 3 = A.)
-- ============================================================

-- ---------- patient_profiles ----------
create table if not exists public.patient_profiles (
    id              uuid primary key default gen_random_uuid(),
    profile_id      uuid not null,
    "condition"     text not null,             -- "condition" is a reserved-ish word but quoted is fine
    classification  text not null,
    summary         text not null default '',
    current_nurse_id uuid,                      -- denormalised; maintained by trigger in Migration 004
    created_at      timestamptz not null default now(),
    updated_at      timestamptz not null default now()
);

alter table public.patient_profiles
    drop constraint if exists patient_profiles_profile_id_fkey;
alter table public.patient_profiles
    add constraint patient_profiles_profile_id_fkey
    foreign key (profile_id) references public.profiles(id)
    on delete cascade;

alter table public.patient_profiles
    drop constraint if exists patient_profiles_profile_id_unique;
alter table public.patient_profiles
    add constraint patient_profiles_profile_id_unique unique (profile_id);

-- current_nurse_id FK: defined in Migration 004 (forward reference to
-- nurse_profiles, which is created immediately below but exists in the
-- same migration). We define it here for clarity.
alter table public.patient_profiles
    drop constraint if exists patient_profiles_current_nurse_id_fkey;
alter table public.patient_profiles
    add constraint patient_profiles_current_nurse_id_fkey
    foreign key (current_nurse_id) references public.nurse_profiles(id)
    on delete set null;

-- ---------- nurse_profiles ----------
create table if not exists public.nurse_profiles (
    id              uuid primary key default gen_random_uuid(),
    profile_id      uuid not null,
    created_at      timestamptz not null default now(),
    updated_at      timestamptz not null default now()
);

alter table public.nurse_profiles
    drop constraint if exists nurse_profiles_profile_id_fkey;
alter table public.nurse_profiles
    add constraint nurse_profiles_profile_id_fkey
    foreign key (profile_id) references public.profiles(id)
    on delete cascade;

alter table public.nurse_profiles
    drop constraint if exists nurse_profiles_profile_id_unique;
alter table public.nurse_profiles
    add constraint nurse_profiles_profile_id_unique unique (profile_id);

-- Done.
