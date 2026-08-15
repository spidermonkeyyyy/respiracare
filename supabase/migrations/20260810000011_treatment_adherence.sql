-- ============================================================
-- Migration 011: medications + medication_reminders + adherence_days
-- Project: RespiraCare
-- Date: 2026-08-10
-- adherence_days is a denormalised aggregate populated by a trigger
-- on medication_reminders. The trigger handles INSERT, all status
-- transitions, and DELETE, using UPSERT pattern for race safety.
-- (Open decision #5 — accepted with caution. Trigger transitions
-- documented in Section 4.7 of the Step 2 v2.1 schema.)
-- ============================================================

-- ---------- medications ----------
create table if not exists public.medications (
    id                          uuid primary key default gen_random_uuid(),
    patient_profile_id          uuid not null,
    label                       text not null,
    prescribed_frequency        text not null,
    device_type                 text not null default 'pressurized_inhaler'
                                check (device_type in
                                       ('pressurized_inhaler','dry_powder_inhaler','nebulizer','oral','other')),
    is_active                   boolean not null default true,
    created_at                  timestamptz not null default now(),
    updated_at                  timestamptz not null default now()
);

alter table public.medications
    drop constraint if exists medications_patient_profile_id_fkey;
alter table public.medications
    add constraint medications_patient_profile_id_fkey
    foreign key (patient_profile_id) references public.patient_profiles(id)
    on delete restrict;

-- ---------- medication_reminders ----------
create table if not exists public.medication_reminders (
    id                          uuid primary key default gen_random_uuid(),
    medication_id               uuid not null,
    patient_profile_id          uuid not null,             -- denormalised for RLS
    medication_label            text not null,             -- denormalised for rendering
    scheduled_at                timestamptz not null,
    status                      text not null default 'pending'
                                check (status in ('upcoming','pending','confirmed','not_confirmed')),
    frequency                   text not null default 'Selon prescription',
    confirmed_at                timestamptz,
    created_at                  timestamptz not null default now(),
    updated_at                  timestamptz not null default now(),
    constraint reminders_confirmed_has_at
        check (status <> 'confirmed' or confirmed_at is not null)
);

alter table public.medication_reminders
    drop constraint if exists medication_reminders_medication_id_fkey;
alter table public.medication_reminders
    add constraint medication_reminders_medication_id_fkey
    foreign key (medication_id) references public.medications(id)
    on delete restrict;

alter table public.medication_reminders
    drop constraint if exists medication_reminders_patient_profile_id_fkey;
alter table public.medication_reminders
    add constraint medication_reminders_patient_profile_id_fkey
    foreign key (patient_profile_id) references public.patient_profiles(id)
    on delete restrict;

-- ---------- adherence_days (denormalised aggregate) ----------
create table if not exists public.adherence_days (
    id                          uuid primary key default gen_random_uuid(),
    patient_profile_id          uuid not null,
    date                        date not null,
    scheduled_count             integer not null default 0
                                check (scheduled_count >= 0),
    confirmed_count             integer not null default 0
                                check (confirmed_count >= 0),
    created_at                  timestamptz not null default now(),
    updated_at                  timestamptz not null default now(),
    constraint adherence_confirmed_le_scheduled
        check (confirmed_count <= scheduled_count)
);

alter table public.adherence_days
    drop constraint if exists adherence_days_patient_profile_id_fkey;
alter table public.adherence_days
    add constraint adherence_days_patient_profile_id_fkey
    foreign key (patient_profile_id) references public.patient_profiles(id)
    on delete restrict;

drop index if exists public.idx_adherence_days_patient_date_unique;
create unique index idx_adherence_days_patient_date_unique
    on public.adherence_days (patient_profile_id, date);

-- ============================================================
-- Trigger: sync_adherence_days
-- Maintains adherence_days from medication_reminders events.
-- Handles INSERT, UPDATE (status transitions), and DELETE.
-- ============================================================
create or replace function public.sync_adherence_days()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_patient uuid;
    v_date date;
    v_was_confirmed boolean;
    v_is_confirmed boolean;
begin
    if (tg_op = 'INSERT') then
        v_patient := new.patient_profile_id;
        v_date := (new.scheduled_at at time zone 'UTC')::date;
        insert into public.adherence_days (patient_profile_id, date, scheduled_count)
        values (v_patient, v_date, 1)
        on conflict (patient_profile_id, date)
        do update set scheduled_count = adherence_days.scheduled_count + 1,
                       updated_at = now();
        if new.status = 'confirmed' then
            update public.adherence_days
            set confirmed_count = confirmed_count + 1, updated_at = now()
            where patient_profile_id = v_patient and date = v_date;
        end if;
        return new;

    elsif (tg_op = 'UPDATE') then
        v_patient := new.patient_profile_id;
        v_date := (new.scheduled_at at time zone 'UTC')::date;
        v_was_confirmed := (old.status = 'confirmed');
        v_is_confirmed := (new.status = 'confirmed');
        if v_was_confirmed and not v_is_confirmed then
            update public.adherence_days
            set confirmed_count = greatest(confirmed_count - 1, 0), updated_at = now()
            where patient_profile_id = v_patient and date = v_date;
        elsif (not v_was_confirmed) and v_is_confirmed then
            update public.adherence_days
            set confirmed_count = confirmed_count + 1, updated_at = now()
            where patient_profile_id = v_patient and date = v_date;
        end if;
        return new;

    elsif (tg_op = 'DELETE') then
        v_patient := old.patient_profile_id;
        v_date := (old.scheduled_at at time zone 'UTC')::date;
        if old.status = 'confirmed' then
            update public.adherence_days
            set confirmed_count = greatest(confirmed_count - 1, 0),
                scheduled_count = greatest(scheduled_count - 1, 0),
                updated_at = now()
            where patient_profile_id = v_patient and date = v_date;
        else
            update public.adherence_days
            set scheduled_count = greatest(scheduled_count - 1, 0), updated_at = now()
            where patient_profile_id = v_patient and date = v_date;
        end if;
        return old;
    end if;
    return null;
end;
$$;

drop trigger if exists trg_adherence_ins on public.medication_reminders;
create trigger trg_adherence_ins
    after insert on public.medication_reminders
    for each row execute procedure public.sync_adherence_days();

drop trigger if exists trg_adherence_upd on public.medication_reminders;
create trigger trg_adherence_upd
    after update of status, patient_profile_id, scheduled_at
    on public.medication_reminders
    for each row execute procedure public.sync_adherence_days();

drop trigger if exists trg_adherence_del on public.medication_reminders;
create trigger trg_adherence_del
    after delete on public.medication_reminders
    for each row execute procedure public.sync_adherence_days();

-- Done.
