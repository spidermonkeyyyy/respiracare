-- ============================================================
-- Migration 010: tasks + care_requests
-- Project: RespiraCare
-- Date: 2026-08-10
-- Also adds forward-reference FKs from messages (Migration 009) to
-- care_requests and tasks.
-- ============================================================

-- ---------- tasks ----------
create table if not exists public.tasks (
    id                          uuid primary key default gen_random_uuid(),
    patient_profile_id          uuid not null,
    conversation_id             uuid,                       -- nullable in Dart
    task_type                   text not null
                                check (task_type in ('monitoring','inhaler_video','follow_up','custom')),
    title                       text not null,
    description                 text not null default '',
    action_route                 text not null,             -- REQUIRED (Dart CommunicationTask.actionRoute)
    status                      text not null default 'open'
                                check (status in ('open','done')),
    due_date                    timestamptz,
    linked_care_request_id      uuid,
    created_at                  timestamptz not null default now(),
    updated_at                  timestamptz not null default now(),
    completed_at                timestamptz,
    constraint tasks_done_has_completed_at
        check (status <> 'done' or completed_at is not null)
);

alter table public.tasks
    drop constraint if exists tasks_patient_profile_id_fkey;
alter table public.tasks
    add constraint tasks_patient_profile_id_fkey
    foreign key (patient_profile_id) references public.patient_profiles(id)
    on delete restrict;

alter table public.tasks
    drop constraint if exists tasks_conversation_id_fkey;
alter table public.tasks
    add constraint tasks_conversation_id_fkey
    foreign key (conversation_id) references public.conversations(id)
    on delete set null;

-- ---------- care_requests ----------
create table if not exists public.care_requests (
    id                          uuid primary key default gen_random_uuid(),
    conversation_id             uuid not null,              -- REQUIRED per Dart CareRequest
    patient_profile_id          uuid not null,
    request_type                text not null
                                check (request_type in ('new_monitoring','inhaler_video','other')),
    reason                      text not null,              -- nurse's verbatim wording
    requested_data              jsonb not null default '[]'::jsonb,
    status                      text not null default 'pending'
                                check (status in ('pending','completed')),
    due_date                    timestamptz,
    created_by_nurse_id         uuid not null,
    created_at                  timestamptz not null default now(),
    completed_at                timestamptz
);

alter table public.care_requests
    drop constraint if exists care_requests_conversation_id_fkey;
alter table public.care_requests
    add constraint care_requests_conversation_id_fkey
    foreign key (conversation_id) references public.conversations(id)
    on delete restrict;

alter table public.care_requests
    drop constraint if exists care_requests_patient_profile_id_fkey;
alter table public.care_requests
    add constraint care_requests_patient_profile_id_fkey
    foreign key (patient_profile_id) references public.patient_profiles(id)
    on delete restrict;

alter table public.care_requests
    drop constraint if exists care_requests_created_by_nurse_id_fkey;
alter table public.care_requests
    add constraint care_requests_created_by_nurse_id_fkey
    foreign key (created_by_nurse_id) references public.nurse_profiles(id)
    on delete restrict;

-- ---------- forward-reference FKs from messages ----------
alter table public.messages
    drop constraint if exists messages_linked_care_request_id_fkey;
alter table public.messages
    add constraint messages_linked_care_request_id_fkey
    foreign key (linked_care_request_id) references public.care_requests(id)
    on delete set null;

alter table public.tasks
    drop constraint if exists tasks_linked_care_request_id_fkey;
alter table public.tasks
    add constraint tasks_linked_care_request_id_fkey
    foreign key (linked_care_request_id) references public.care_requests(id)
    on delete set null;

alter table public.messages
    drop constraint if exists messages_linked_task_id_fkey;
alter table public.messages
    add constraint messages_linked_task_id_fkey
    foreign key (linked_task_id) references public.tasks(id)
    on delete set null;

-- Done.
