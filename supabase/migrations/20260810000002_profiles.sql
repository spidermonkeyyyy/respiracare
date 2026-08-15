-- ============================================================
-- Migration 002: profiles — auth bridge
-- Project: RespiraCare
-- Date: 2026-08-10
-- Principle: profiles.id = auth.users.id (1:1), populated by a trigger
-- using NEW.id (NOT auth.uid()) so the trigger runs under the Auth
-- insert context regardless of who triggers the auth row creation.
-- ------------------------------------------------------------
-- Decision 1 (Step 2 v2.1 approval): profiles.email is a read-through
-- CACHE, synchronized from auth.users on both INSERT and UPDATE OF email.
-- auth.users remains the authoritative identity source.
-- ============================================================

-- ---------- table ----------
create table if not exists public.profiles (
    id              uuid primary key,
    role            text not null
                    check (role in ('patient','nurse','pneumologist','admin')),
    name            text not null,
    email           text not null,             -- cached from auth.users.email
    phone           text,
    date_of_birth   date,
    is_active       boolean not null default true,
    created_at      timestamptz not null default now(),
    updated_at      timestamptz not null default now()
);

-- ---------- foreign key to auth.users (managed identity) ----------
-- ON DELETE CASCADE so deleting an auth user removes their profile.
-- (Note: Supabase Auth users are deleted via Supabase dashboard or the
-- auth.admin.delete_user RPC, not via direct DELETE on auth.users.)
alter table public.profiles
    drop constraint if exists profiles_id_fkey;
alter table public.profiles
    add constraint profiles_id_fkey
    foreign key (id) references auth.users(id) on delete cascade;

-- ---------- indexes ----------
-- Note: most indexes are created in Migration 016 to keep Schema
-- creation cheap and indexes concurrent-friendly. A small set of
-- immediately needed ones is created here.
create index if not exists idx_profiles_role
    on public.profiles (role);
create index if not exists idx_profiles_is_active
    on public.profiles (is_active);

-- ---------- unique email ----------
-- auth.users.email is unique in Supabase Auth. The cached copy in
-- profiles should also be unique to keep fast lookups consistent.
alter table public.profiles
    drop constraint if exists profiles_email_unique;
alter table public.profiles
    add constraint profiles_email_unique unique (email);

-- ============================================================
-- TRIGGER: handle_new_user
-- Fires: AFTER INSERT on auth.users
-- Purpose: insert a matching public.profiles row, using NEW.id (NOT
-- auth.uid()). Default role is 'patient' unless auth.users.raw_user_meta_data
-- contains an explicit role; admin signup flows can override later.
-- ============================================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_role text;
    v_name text;
begin
    -- Resolve role from Auth metadata, default to 'patient'.
    v_role := coalesce(
        nullif(current_setting('request.jwt.claim.role', true), ''),
        nullif(new.raw_user_meta_data->>'role', ''),
        nullif(new.raw_app_meta_data->>'role', ''),
        'patient'
    );
    if v_role not in ('patient','nurse','pneumologist','admin') then
        v_role := 'patient';
    end if;

    -- Resolve a display name from metadata, default to the local-part of email.
    v_name := coalesce(
        nullif(new.raw_user_meta_data->>'full_name', ''),
        nullif(new.raw_user_meta_data->>'name', ''),
        split_part(new.email, '@', 1)
    );

    insert into public.profiles (id, role, name, email, phone, date_of_birth)
    values (
        new.id,
        v_role,
        v_name,
        coalesce(new.email, ''),
        new.raw_user_meta_data->>'phone',
        null
    )
    on conflict (id) do nothing;

    return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
    after insert on auth.users
    for each row execute procedure public.handle_new_user();

-- ============================================================
-- TRIGGER: sync_profile_email
-- Fires: AFTER UPDATE OF email on auth.users
-- Purpose: keep profiles.email in sync when auth.users.email changes
-- (e.g. user changes email from Supabase dashboard). Non-authoritative
-- cache, but never stale.
-- ============================================================
create or replace function public.sync_profile_email()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    if new.email is distinct from old.email then
        update public.profiles
        set email = new.email
        where id = new.id;
    end if;
    return new;
end;
$$;

drop trigger if exists on_auth_user_email_updated on auth.users;
create trigger on_auth_user_email_updated
    after update of email on auth.users
    for each row execute procedure public.sync_profile_email();

-- Done.
