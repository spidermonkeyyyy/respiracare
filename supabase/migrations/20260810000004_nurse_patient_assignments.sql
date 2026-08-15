-- ============================================================
-- Migration 004: nurse_patient_assignments + current_nurse_id sync
-- Project: RespiraCare
-- Date: 2026-08-10
-- Historically preserves all assignments. Current assignment is the
-- row with unassigned_at IS NULL per patient (partial UNIQUE).
-- current_nurse_id on patient_profiles is denormalised and kept in
-- sync by the trigger defined below.
-- ------------------------------------------------------------
-- Decision 2 (Step 2 v2.1 approval): assigned_by is NOT NULL, but
-- the role-authorization invariant is enforced by RLS only — no
-- CHECK trigger at the data layer. RLS on INSERT requires
-- assigned_by = auth.uid() AND current_user_role() in
-- (admin, nurse, pneumologist). (RLS policies are defined in
-- Migration 999 / Step 15.)
-- ============================================================

-- ---------- table ----------
create table if not exists public.nurse_patient_assignments (
    id                  uuid primary key default gen_random_uuid(),
    nurse_profile_id    uuid not null,
    patient_profile_id  uuid not null,
    assigned_at         timestamptz not null default now(),
    assigned_by         uuid not null,           -- profiles.id of the assigning user
    unassigned_at       timestamptz,             -- NULL = active
    unassigned_reason   text,
    created_at          timestamptz not null default now()
);

alter table public.nurse_patient_assignments
    drop constraint if exists npa_nurse_profile_id_fkey;
alter table public.nurse_patient_assignments
    add constraint npa_nurse_profile_id_fkey
    foreign key (nurse_profile_id) references public.nurse_profiles(id)
    on delete restrict;

alter table public.nurse_patient_assignments
    drop constraint if exists npa_patient_profile_id_fkey;
alter table public.nurse_patient_assignments
    add constraint npa_patient_profile_id_fkey
    foreign key (patient_profile_id) references public.patient_profiles(id)
    on delete restrict;

alter table public.nurse_patient_assignments
    drop constraint if exists npa_assigned_by_fkey;
alter table public.nurse_patient_assignments
    add constraint npa_assigned_by_fkey
    foreign key (assigned_by) references public.profiles(id)
    on delete restrict;

-- ---------- partial unique: one active assignment per patient ----------
-- Drop-if-exists + recreate to keep idempotent.
drop index if exists public.idx_npa_patient_active_unique;
create unique index idx_npa_patient_active_unique
    on public.nurse_patient_assignments (patient_profile_id)
    where unassigned_at is null;

-- ============================================================
-- Trigger: sync_current_nurse_id
-- Maintains patient_profiles.current_nurse_id in sync with the
-- current active assignment. Fires on INSERT, UPDATE (of
-- unassigned_at or nurse_profile_id), and DELETE.
-- ============================================================
create or replace function public.sync_current_nurse_id()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_patient uuid;
    v_new_nurse uuid;
begin
    if (tg_op = 'INSERT') then
        if new.unassigned_at is null then
            update public.patient_profiles
            set current_nurse_id = new.nurse_profile_id
            where id = new.patient_profile_id
              and current_nurse_id is null;
            -- If current_nurse_id was already set, leave it; the partial
            -- unique guarantees there is exactly one active assignment,
            -- so the INSERT can only be the active one when current is NULL.
        end if;
        return new;
    elsif (tg_op = 'UPDATE') then
        v_patient := coalesce(new.patient_profile_id, old.patient_profile_id);
        -- Recompute current_nurse_id from the active assignment row.
        select nurse_profile_id into v_new_nurse
        from public.nurse_patient_assignments
        where patient_profile_id = v_patient
          and unassigned_at is null
        order by assigned_at desc
        limit 1;
        update public.patient_profiles
        set current_nurse_id = v_new_nurse
        where id = v_patient;
        return new;
    elsif (tg_op = 'DELETE') then
        v_patient := old.patient_profile_id;
        select nurse_profile_id into v_new_nurse
        from public.nurse_patient_assignments
        where patient_profile_id = v_patient
          and unassigned_at is null
        order by assigned_at desc
        limit 1;
        update public.patient_profiles
        set current_nurse_id = v_new_nurse
        where id = v_patient;
        return old;
    end if;
    return null;
end;
$$;

-- Statement-level triggers to avoid per-row complexity on bulk updates.
drop trigger if exists trg_sync_current_nurse_ins on public.nurse_patient_assignments;
create trigger trg_sync_current_nurse_ins
    after insert on public.nurse_patient_assignments
    for each row execute procedure public.sync_current_nurse_id();

drop trigger if exists trg_sync_current_nurse_upd on public.nurse_patient_assignments;
create trigger trg_sync_current_nurse_upd
    after update of nurse_profile_id, patient_profile_id, unassigned_at
    on public.nurse_patient_assignments
    for each row execute procedure public.sync_current_nurse_id();

drop trigger if exists trg_sync_current_nurse_del on public.nurse_patient_assignments;
create trigger trg_sync_current_nurse_del
    after delete on public.nurse_patient_assignments
    for each row execute procedure public.sync_current_nurse_id();

-- Done.
