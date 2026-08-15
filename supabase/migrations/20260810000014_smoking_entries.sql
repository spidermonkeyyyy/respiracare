-- ============================================================
-- Migration 014: smoking_entries
-- Project: RespiraCare
-- Date: 2026-08-10
-- Append-only per-entry craving/log — mirrors Dart SmokingEntry
-- exactly. NO "single progress" row (v1.0 regression fixed).
-- Note: patients may DELETE their own entries (Dart
-- EducationRepository.deleteSmokingEntry exists), so this table is
-- NOT in the immutable audit-trail group.
-- ============================================================

create table if not exists public.smoking_entries (
    id                      uuid primary key default gen_random_uuid(),
    patient_profile_id      uuid not null,
    entry_date              date not null default current_date,
    cigarettes_consumed     integer not null default 0
                            check (cigarettes_consumed >= 0),
    craving_intensity       text not null default 'low'
                            check (craving_intensity in ('low','moderate','high')),
    trigger                 text not null default 'other'
                            check (trigger in ('stress','habit','social','emotion','other')),
    personal_note           text,
    created_at              timestamptz not null default now()
);

alter table public.smoking_entries
    drop constraint if exists smoking_entries_patient_profile_id_fkey;
alter table public.smoking_entries
    add constraint smoking_entries_patient_profile_id_fkey
    foreign key (patient_profile_id) references public.patient_profiles(id)
    on delete restrict;

-- Done.
