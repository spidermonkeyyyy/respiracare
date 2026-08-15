-- ============================================================
-- Migration 012: education_modules
-- Project: RespiraCare
-- Date: 2026-08-10
-- Two distinct gate columns:
--   - is_placeholder  = clinical validation gate
--     (production RLS denies patient SELECT where is_placeholder = true)
--   - is_active       = editorial deactivation gate
--     (a clinically-validated module can still be deprecated)
-- ============================================================

create table if not exists public.education_modules (
    id              uuid primary key default gen_random_uuid(),
    title           text not null,
    summary         text not null,
    content         text not null,
    category        text not null
                    check (category in ('sevrage','rehabilitation','inhalation','general')),
    image_url       text,                         -- Storage path
    is_placeholder  boolean not null default true, -- clinical validation gate
    is_active       boolean not null default true, -- editorial gate
    created_at      timestamptz not null default now(),
    updated_at      timestamptz not null default now()
);

-- Done. No FKs; no seed data — clinical content will be authored later.
